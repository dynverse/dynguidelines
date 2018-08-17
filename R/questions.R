# all priors
priors <- tribble(
  ~prior_id, ~prior_name, ~prior_dataset_id,
  "start_id", "Start cell","start_cells",
  "end_id", "End cell(s)","end_cells",
  "end_n", "# end states","n_end_states",
  "states_id", "Cell clustering","grouping_assignment",
  "states_n", "# states","n_branches",
  "states_network", "State network","grouping_network",
  "time_id", "Time course","time",
  "genes_id", "Marker genes","marker_feature_ids"
)

# possible programming languages
all_programming_languages <-c("python", "Matlab", "C++", "R")
all_free_programming_languages <- intersect(all_programming_languages, c("python", "R", "C++"))

# possible trajectory types
data(trajectory_types, package = "dynwrap", envir = environment())
all_simplified_trajectory_types <- trajectory_types %>% filter(!directed) %>% pull(simplified) %>% unique() %>% keep(~!. == "binary_tree")

# metrics, TODO: import from dyneval
metrics <- tibble(
  id = c("correlation", "edge_flip", "featureimp_cor", "F1_branches"),
  name = c("Ordering", "Topology", "Important features/genes", "Clustering quality")
)

#' @include modifiers.R
#' @include labels.R
questions <- list(
  list(
    question_id = "multiple_disconnected",
    modifier = multiple_disconnected_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    modifier = function(data, answer = NULL) {},
    activeIf = "true",
    title = "Do you expect multiple disconnected trajectories in the data?",
    help = "Disconnected trajectories are trajectories which are not connected, eg: <img src='img/disconnected.png'>",
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        "No"
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
    title = "Do you expect a particular topology in the data?",
    help = "Select 'Yes' if you already know the expected topology in the data.",
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        "No"
      } else {
        default
      }
    }
  ),
  list(
    question_id = "expected_topology",
    modifier = expected_topology_modifier,
    type = "radiobuttons",
    choiceValues = all_simplified_trajectory_types,
    choiceNames = map(all_simplified_trajectory_types, function(trajectory_type) {
      directed_trajectory_type <- trajectory_types %>% filter(simplified == trajectory_type, directed == TRUE) %>% pull(id) %>% first()
      span(
        img(src = str_glue("img/trajectory_types/{directed_trajectory_type}.svg"), class = "trajectory_type"),
        label_capitalise(trajectory_type)
      )
    }),
    activeIf = "
    input.multiple_disconnected == 'FALSE' &&
    input.expect_topology == 'TRUE'
    ",
    title = "What is the expected topology",
    help = "Select the expected topology <img src='img/topologies.png'>",
    category = "topology",
    default = NULL,
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_trajectory(dataset)) {
        trajectory_type <- dynwrap::classify_milestone_network(dataset$milestone_network)$network_type
        data(trajectory_types, package = "dynwrap", envir = environment())
        trajectory_type_simplified <- trajectory_types$simplified[first(match(trajectory_type, trajectory_types$id))]
        trajectory_type_simplified
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
    title = "Do you expect cycles in the data?",
    help = "Cells within a cyclic topology can go back to their original state. Apart from the cell cycle, such trajectories can also include sucessive stages of activation and a return to steady state.",
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
    title = "Do you expect a complex tree in the data?",
    help = "A complex tree can include two or more bifurcations.",
    category = "topology",
    default = NULL
  ),
  list(
    question_id = "prior_information",
    modifier = prior_information_modifier,
    type = "picker",
    choices = set_names(priors$prior_id, priors$prior_name),
    multiple = TRUE,
    title = "Are you willing to provide the following prior information?",
    help = "Some methods require some prior information, such as the start cells, to help with the construction of the trajectory. Although this can help the method with finding the right trajectory, prior information can also bias the trajectory towards what is already known. Prior information should therefore be given with great care.",
    activeIf = "true",
    category = "prior_information",
    default = c(),
    default_dataset = function(dataset, default) {
      if("prior_information" %in% names(dataset) || dynwrap::is_wrapper_with_prior_information(dataset)) {
        data(priors, envir = environment(), package = "dynguidelines")
        priors %>% filter(prior_dataset_id %in% names(dataset$prior_information)) %>% pull(prior_id)
      } else {
        default
      }
    }
  ),
  list(
    question_id = "n_cells",
    modifier = n_cells_modifier,
    type = "textslider",
    choices = c("< 100", "< 1000", "< 10000", "10000+"),
    title = "Number of cells",
    activeIf = "true",
    category = "dataset",
    default = "< 10000",
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
    type = "textslider",
    choices = c("< 100", "< 1000", "< 10000", "10000+"),
    title = "Number of features (genes)",
    activeIf = "true",
    category = "dataset",
    default = "< 1000",
    default_dataset = function(dataset, default) {
      if(dynwrap::is_wrapper_with_expression(dataset)) {
        ncol(dataset$expression)
      } else {
        default
      }
    }
  ),
  # list(
  #   question_id = "metric_importance",
  #   modifier = metric_importance_modifier,
  #   type = "balancing_sliders",
  #   title = "How important are the following aspects of the trajectory?",
  #   help = "We assessed ...........",
  #   activeIf = "true",
  #   category = "metric_importance",
  #   labels = metrics$name %>% set_names(metrics$id),
  #   slider_ids = metrics$id %>% set_names(metrics$id),
  #   default = rep(1/nrow(metrics), nrow(metrics)) %>% set_names(metrics$id),
  #   mins = rep(0, nrow(metrics)) %>% set_names(metrics$id),
  #   maxs = rep(1, nrow(metrics)) %>% set_names(metrics$id),
  #   steps = rep(0.01, nrow(metrics)) %>% set_names(metrics$id)
  # ),
  list(
    question_id = "dynmethods",
    modifier = dynmethods_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    title = "Do you use dynmethods to run the methods?",
    help = "Dynmethods is an R package which contains wraps TI methods into a common interface. While we highly recommend the use of this package, as it eases interpretation, some users may prefer to work in other programming languages.",
    activeIf = "true",
    category = "availability",
    default = TRUE
  ),
  list(
    question_id = "docker",
    modifier = docker_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    title = "Is docker installed?",
    help = "Docker makes it easy to run each TI method without dependency issues, apart from the installation of docker itself.",
    activeIf = "input.dynmethods == 'TRUE'",
    category = "availability",
    default = function() {dynwrap::test_docker_installation()}
  ),
  list(
    question_id = "programming_interface",
    modifier = programming_interface_modifier,
    type = "radiobuttons",
    choices = c("Yes" = TRUE, "No" = FALSE),
    title = "Can you work in a programming interface?",
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
    title = "Which languages can you work with?",
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
    label = "
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
    title = "Minimal user friendliness score",
    activeIf = "input.dynmethods == 'FALSE'",
    category = "availability"
  ),
  list(
    question_id = "running_time",
    modifier = running_time_modifier,
    type = "slider",
    min = 1,
    max = 240,
    default = 5,
    activeIf = "input.dynmethods == 'TRUE'",
    category = "availability",
    title = "Maximal estimated running time (minutes)"
  ),
  list(
    question_id = "n_methods",
    modifier = n_methods_modifier,
    type = "slider",
    min = 1,
    max = 10,
    default = 4,
    title = "Number of methods",
    activeIf = "true",
    category = "methods"
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