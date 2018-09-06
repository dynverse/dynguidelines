priors <- dynwrap::priors

# possible programming languages
all_programming_languages <- c("python", "R", "C++")
all_free_programming_languages <- intersect(all_programming_languages, c("python", "R", "C++"))

# possible trajectory types
data(trajectory_types, package = "dynwrap", envir = environment())
all_trajectory_types <- trajectory_types$id

# metrics, TODO: import from dyneval
metrics <- tibble(
  id = c("correlation", "edge_flip", "featureimp_cor", "F1_branches"),
  name = c("Ordering", "Topology", "Important features/genes", "Clustering quality"),
  description = c("How well the cells were ordered", "How well the overall topology of the trajectory is recovered", "Whether the correct genes/features are retrieved from the trajectory", "Whether the cells are correctly clustered in branches and milestones")
)

#' @include modifiers.R
#' @include labels.R
questions <- list(
  list(
    question_id = "multiple_disconnected",
    modifier = multiple_disconnected_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "It's possible" = TRUE, "No" = FALSE),
    modifier = function(data, answer = NULL) {},
    activeIf = "true",
    label = "Do you expect multiple disconnected trajectories in the data?",
    title = tags$p("Disconnected trajectories are trajectories which are not connected", tags$im(src='img/disconnected_example.png')),
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        FALSE
      } else {
        default
      }
    }
  ),
  list(
    question_id = "expect_topology",
    modifier = expect_topology_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    activeIf = "input.multiple_disconnected == 'FALSE'",
    label = "Do you expect a particular topology in the data?",
    title = "Select 'Yes' if you already know the expected topology in the data.",
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        FALSE
      } else {
        default
      }
    }
  ),
  list(
    question_id = "expected_topology",
    modifier = expected_topology_modifier,
    type = "radiobuttons",
    choiceValues = all_trajectory_types,
    choiceNames = map(all_trajectory_types, function(trajectory_type) {
      span(
        img(src = str_glue("img/trajectory_types/{trajectory_type}.png"), class = "trajectory_type"),
        label_capitalise(trajectory_type)
      )
    }),
    activeIf = "
    input.multiple_disconnected == 'FALSE' &&
    input.expect_topology == 'TRUE'
    ",
    label = "What is the expected topology",
    title = "Select the expected topology <img src='img/topologies.png'>",
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        dynwrap::classify_milestone_network(dataset$milestone_network)$network_type
      } else {
        default
      }
    }
  ),
  list(
    question_id = "expect_cycles",
    modifier = expect_cycles_modifier,
    type = "radiobuttons",
    choices = c("It's possible" = TRUE, "No" = FALSE),
    activeIf = "
    input.multiple_disconnected == 'FALSE' &&
    input.expect_topology == 'FALSE'
    ",
    label = "Do you expect cycles in the data?",
    title = p(
      "Select 'Yes' or 'It's possible' if cyclic could be present in the trajectory.",
      tags$br(),
      "Cells within a cyclic topology can go back to their original state. A cycle can be part of a larger trajectory topology, for example:",
      tags$img(src = "img/cyclic_example.png"),
      "Examples of cyclic trajectories can be: cell cycle or cell activation and deactivation"
    ),
    category = "topology",
    default = NULL
  ),
  list(
    question_id = "expect_complex_tree",
    modifier = expect_complex_tree_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "Not necessarily" = FALSE),
    activeIf = "
    input.multiple_disconnected == 'FALSE' &&
    input.expect_cycles == 'FALSE' &&
    input.expect_topology == 'FALSE'
    ",
    label = "Do you expect a complex tree in the data?",
    title = tags$p(
      "A complex tree can include two or more bifurcations.",
      tags$img(src = "img/complex_tree_example.png")
    ),
    category = "topology",
    default = NULL
  ),
  list(
    question_id = "prior_information",
    modifier = prior_information_modifier,
    type = "picker",
    choices = set_names(priors$prior_id, priors$name),
    multiple = TRUE,
    label = "Are you able to provide the following prior information?",
    title = "Some methods require some prior information, such as the start cells, to help with the construction of the trajectory. Although this can help the method with finding the right trajectory, prior information can also bias the trajectory towards what is already known. <br> Prior information should therefore be given with great care.",
    activeIf = "true",
    category = "prior_information",
    default = c(),
    default_dataset = function(dataset, default) {
      if("prior_information" %in% names(dataset) || dynwrap::is_wrapper_with_prior_information(dataset)) {
        priors %>% filter(prior_id %in% names(dataset$prior_information)) %>% pull(prior_id)
      } else {
        default
      }
    }
  ),
  list(
    question_id = "n_cells",
    modifier = n_cells_modifier,
    type = "numeric",
    label = "Number of cells",
    title = "Number of cells in the dataset. Will be estimated if a dataset is given.",
    activeIf = "true",
    category = "dataset",
    default = 1000,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_expression(dataset)) {
        nrow(dataset$expression)
      } else {
        default
      }
    }
  ),
  list(
    question_id = "n_features",
    modifier = n_features_modifier,
    type = "numeric",
    label = "Number of features (genes)",
    title = "Number of features in the dataset. Will be estimated if a dataset is given.",
    activeIf = "true",
    category = "dataset",
    default = 1000,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_expression(dataset)) {
        ncol(dataset$expression)
      } else {
        default
      }
    }
  ),
  list(
    question_id = "running_time",
    modifier = running_time_modifier,
    type = "slider",
    min = 1,
    max = 240,
    default = 5,
    category = "scalability",
    activeIf = "true",
    label = "Maximal estimated running time (minutes)",
    title = "All methods with a higher estimated running time will be filtered."
  ),
  list(
    question_id = "memory",
    modifier = memory_modifier,
    type = "slider",
    min = 1,
    max = 128,
    default = 4,
    category = "scalability",
    activeIf = "true",
    label = "Maximal estimated memory usage (GB)"
  ),
  list(
    question_id = "method_selection",
    modifier = method_selection_modifier,
    type = "radiobuttons",
    choices = c("Dynmaic" = "dynamic_n_methods", "Fixed" = "fixed_n_methods"),
    label = "How to select the number of methods",
    default = "dynamic_n_methods",
    activeIf = "true",
    category = "method_selection"
  ),
  list(
    question_id = "dynamic_n_methods",
    modifier = dynamic_n_methods_modifier,
    type = "slider",
    min = 1,
    max = 100,
    default = 80,
    label = "Minimal probability of selecting the top model for the task",
    activeIf = "input.method_selection  == 'dynamic_n_methods'",
    category = "method_selection"
  ),
  list(
    question_id = "fixed_n_methods",
    modifier = fixed_n_methods_modifier,
    type = "slider",
    min = 1,
    max = 10,
    default = 4,
    label = "Number of methods",
    activeIf = "input.method_selection  == 'fixed_n_methods'",
    category = "method_selection"
  ),
  list(
    question_id = "metric_importance",
    modifier = metric_importance_modifier,
    type = "balancing_sliders",
    label = "How important are the following aspects of the trajectory?",
    title = tags$p(
      tags$em("This question is currently not yet implemented"),
      tags$br(),
      "Within dynbenchmark, we assessed the performance of a TI method by comparing the similarity of its model to a given gold standard. There are several metrics to quantify this similarity, and this question allows to give certain metrics more weights than others: ",
      tags$ul(
        style = "text-align:left;",
        map2(metrics$name, metrics$description, function(name, description) {tags$li(tags$strong(name), ": ", description)})
      )
    ),
    activeIf = "true",
    category = "metric_importance",
    labels = metrics$name,
    ids = metrics$id,
    default = rep(1/nrow(metrics), nrow(metrics)),
    min = 0,
    max = 1,
    step = 0.01,
    sum = 1
  ),
  list(
    question_id = "dynmethods",
    modifier = dynmethods_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    label = "Do you use dynmethods to run the methods?",
    title = "Dynmethods is an R package which contains wrappers TI methods into a common interface. While we highly recommend the use of this package, as it eases interpretation, some users may prefer to work in other programming languages.",
    activeIf = "true",
    category = "availability",
    default = TRUE
  ),
  list(
    question_id = "docker",
    modifier = docker_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    label = "Is docker installed?",
    title = "Docker makes it easy to run each TI method without dependency issues, apart from the installation of docker itself.",
    activeIf = "input.dynmethods == 'TRUE'",
    category = "availability",
    default =  quote(dynwrap::test_docker_installation())
  ),
  list(
    question_id = "programming_interface",
    modifier = programming_interface_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    label = "Can you work in a programming interface?",
    activeIf = "input.dynmethods == 'FALSE'",
    category = "availability",
    default = TRUE
  ),
  list(
    question_id = "languages",
    modifier = languages_modifier,
    type = "picker",
    choices = all_programming_languages,
    special_choices = list(c("All", all_programming_languages), c("Any free",  all_free_programming_languages), c("Clear", "[]")),
    default = all_free_programming_languages,
    label = "Which languages can you work with?",
    activeIf = "input.dynmethods == 'FALSE' && input.programming_interface == 'TRUE'",
    category = "availability",
    default = all_free_programming_languages
  ),
  list(
    question_id = "user_friendliness",
    modifier = user_friendliness_modifier,
    type = "slider",
    min = 0,
    max = 100,
    step = 10,
    default = 60,
    slider_label = "
    function(x) {
    if(x < 50) {
    return 'Poor'
    } else if (x < 70) {
    return 'Fair'
    } else if (x < 90) {
    return 'Decent'
    } else {
    return 'Excellent'
    }
    }
    ",
    label = "Minimal user friendliness score",
    activeIf = "input.dynmethods == 'FALSE'",
    category = "availability"
  )
) %>% {set_names(., map(., "question_id"))}

# convert javascript active if question
generate_r_active_if <- function(question) {
  activeIf <- question$activeIf
  if(activeIf == "true") {
    activeIf <- "TRUE"
  } else {
    activeIf <- gsub("\\.", "$", activeIf)
  }
  activeIf <- parse(text = activeIf)
  active_if <- function(input) {
    active <- eval(activeIf)
    length(active) && !is.na(active) && active
  }
}

questions <- map(questions, function(question) {
  question$active_if <- generate_r_active_if(question)
  question
})

#' Load in the questions
#' @export
get_questions <- function() {
  questions
}

#' @rdname get_questions
#' @param question_id The id of the questions
get_question <- function(question_id) {
  questions[[question_id]]
}