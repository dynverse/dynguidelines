# metrics from dyneval
benchmark_metrics <- dyneval::metrics %>%
  filter(metric_id %in% c("correlation", "him", "F1_branches", "featureimp_wcor"))
benchmark_metrics$description <- "todo"

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

#' Get the the questions, their modifiers and properties
#'
#' @include modifiers.R
#' @include labels.R
#' @include formatters.R
#' @export
get_questions <- function() {
  priors <- dynwrap::priors %>%
    filter(prior_id != "dataset")

  # possible programming languages
  all_programming_languages <- c("python", "R", "C++", "Matlab")
  all_free_programming_languages <- intersect(all_programming_languages, c("python", "R", "C++"))

  # possible trajectory types
  trajectory_types <- dynwrap::trajectory_types
  all_trajectory_types <- trajectory_types$id

  # benchmark metrics
  questions <- list(
    list(
      question_id = "multiple_disconnected",
      modifier = multiple_disconnected_modifier,
      type = "radiobuttons",
      choices = c("Yes" = TRUE, "I don't know" = TRUE, "No" = FALSE),
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
      },
      show_on_start = TRUE
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
      choices = c("Yes" = TRUE, "I don't know" = TRUE, "No" = FALSE),
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
      choices = c("Yes" = TRUE, "I don't know" = FALSE, "No" = FALSE),
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
      question_id = "n_cells",
      modifier = n_cells_modifier,
      type = "numeric",
      label = "Number of cells",
      title = "Number of cells in the dataset. Will be extracted from the dataset if provided.",
      activeIf = "true",
      category = "scalability",
      default = 1000,
      default_dataset = function(dataset, default) {
        if(dynwrap::is_wrapper_with_expression(dataset)) {
          nrow(dataset$expression)
        } else {
          default
        }
      },
      show_on_start = TRUE
    ),
    list(
      question_id = "n_features",
      modifier = n_features_modifier,
      type = "numeric",
      label = "Number of features (genes)",
      title = "Number of features in the dataset. Will be extracted from the dataset if provided.",
      activeIf = "true",
      category = "scalability",
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
      question_id = "time",
      modifier = time_modifier,
      type = "textslider",
      choices = c(format_time(c(seq(10, 60, 5), seq(5, 60, 5)*60, seq(4, 24, 4) * 60 * 60, seq(2, 4) * 60 * 60 * 24)), "\U221E"),
      default = "1h",
      category = "scalability",
      activeIf = "true",
      label = "Time limit",
      title = span("Limits the maximal time a method is allowed to run. The running times is estimated based on dataset size and the ", tags$a("scalability assessment of dynbenchmark", href = "https://github.com/dynverse/dynbenchmark_results/tree/master/05-scaling"), ".")
    ),
    list(
      question_id = "memory",
      modifier = memory_modifier,
      type = "textslider",
      choices = c(format_memory(c(seq(10^8, 10^9, 10^8), seq(10^9, 10^10, 10^9), seq(10^10, 10^11, 10^10))), "\U221E"),
      default = "2GB",
      category = "scalability",
      category = "scalability",
      activeIf = "true",
      label = "Memory limit",
      title = span("Limits the maximal memory a method is allowed to use. The memory usage is estimated based on dataset size and the ", tags$a("scalability assessment of dynbenchmark", href = "https://github.com/dynverse/dynbenchmark_results/tree/master/05-scaling"), ".")
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
      default = dynwrap::priors %>% filter(type == "soft") %>% pull(prior_id),
      default_dataset = function(dataset, default) {
        if("prior_information" %in% names(dataset) || dynwrap::is_wrapper_with_prior_information(dataset)) {
          priors %>% filter(prior_id %in% names(dataset$prior_information)) %>% pull(prior_id)
        } else {
          default
        }
      },
      show_on_start = TRUE
    ),
    list(
      question_id = "method_selection",
      modifier = method_selection_modifier,
      type = "radiobuttons",
      choices = c("Dynamic" = "dynamic_n_methods", "Fixed" = "fixed_n_methods"),
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
          map2(benchmark_metrics$category, benchmark_metrics$description, function(name, description) {tags$li(tags$strong(name), ": ", description)})
        )
      ),
      activeIf = "true",
      category = "benchmarking_metrics",
      labels = glue::glue("{label_split(benchmark_metrics$category)}: {benchmark_metrics$html}"),
      ids = benchmark_metrics$metric_id,
      default = rep(1/nrow(benchmark_metrics), nrow(benchmark_metrics)) %>% set_names(benchmark_metrics$metric_id) %>% as.list(),
      min = 0,
      max = 1,
      step = 0.01,
      sum = 1
    ),

    # list(
    #   activeIf = "true",
    #   category = "benchmarking_datasets",
    #   labels =
    # ),

    list(
      question_id = "user",
      modifier = function(data, answers) {data},
      type = "radiobuttons",
      choices = c("User" = "user", "Developer" = "developer"),
      label = "Are you an end-user or a method developer?",
      activeIf = "true",
      category = "availability",
      default = "user"
    ),
    list(
      question_id = "dynmethods",
      modifier = dynmethods_modifier,
      type = "radiobuttons",
      choices = c("Yes" = TRUE, "No" = FALSE),
      label = "Do you use dynmethods to run the methods?",
      title = "Dynmethods is an R package which contains wrappers TI methods into a common interface. While we highly recommend the use of this package, as it eases interpretation, some users may prefer to work in other programming languages.",
      activeIf = "input.user == 'user'",
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
      activeIf = "input.user == 'user' && input.dynmethods == 'TRUE'",
      category = "availability",
      default =  function() if(interactive()) {dynwrap::test_docker_installation()} else {TRUE}
    ),
    list(
      question_id = "programming_interface",
      modifier = programming_interface_modifier,
      type = "radiobuttons",
      choices = c("Yes" = TRUE, "No" = FALSE),
      label = "Can you work in a programming interface?",
      activeIf = "input.user == 'user' && input.dynmethods == 'FALSE'",
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
      activeIf = "input.user == 'user' && input.dynmethods == 'FALSE' && input.programming_interface == 'TRUE'",
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
      label = "Minimal user friendliness score",
      activeIf = "input.user == 'user' && input.dynmethods == 'FALSE'",
      category = "availability"
    )
    ,
    list(
      question_id = "developer_friendliness",
      modifier = developer_friendliness_modifier,
      type = "slider",
      min = 0,
      max = 100,
      step = 10,
      default = 60,
      label = "Minimal developer friendliness score",
      activeIf = "input.user == 'developer'",
      category = "availability"
    ),
    list(
      question_id = "exclude_datasets",
      modifier = function(data, answers) {data},
      type = "module",
      module_input = dataset_chooser_input,
      module_server = dataset_chooser,
      data = lst(benchmark_datasets_info),
      default = character(),
      label = "Which datasets should be excluded",
      activeIf = "true",
      category = "benchmarking_datasets"
    )
  ) %>% {set_names(., map(., "question_id"))}

  # generate R active_if from javascript activeIf
  questions <- map(questions, function(question) {
    question$active_if <- generate_r_active_if(question)
    question
  })

  questions
}