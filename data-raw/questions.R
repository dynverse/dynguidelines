## Generates a list which contains all different questions and their modifiers

library(tidyverse)
devtools::load_all()

# possible programming languages
all_programming_languages <- unlist(methods$platforms_split) %>% unique()
all_free_programming_languages <- intersect(all_programming_languages, c("python", "R", "C++"))

# possible trajectory types
data(trajectory_types, package = "dynwrap", envir = environment())
all_simplified_trajectory_types <- trajectory_types %>% filter(!directed) %>% pull(simplified) %>% unique() %>% keep(~!. == "binary_tree")

# metrics, TODO: import from dyneval
metrics <- tibble(
  id = c("correlation", "edge_flip", "featureimp_cor"),
  name = c("Ordering", "Topology", "Important features/genes")
)


# the questions
questions <- list(
  list(
    question_id = "multiple_disconnected",
    modifier = multiple_disconnected_modifier,
    type = "radio",
    choices = c("Yes", "No"),
    modifier = function(data, answer = NULL) {},
    activeIf = "true",
    title = "Do you expect multiple disconnected trajectories in the data?",
    help = "Disconnected trajectories are trajectories which are not connected, eg: <img src='img/disconnected.png'>",
    category = "topology",
    default = character()
  ),
  list(
    question_id = "expect_topology",
    modifier = expect_topology_modifier,
    type = "radio",
    choices = c("Yes", "No"),
    activeIf = "input.multiple_disconnected == 'No'",
    title = "Do you expect a particular topology in the data?",
    help = "Select 'Yes' if you already know what topology can be expected in the data.",
    category = "topology",
    default = character()
  ),
  list(
    question_id = "expected_topology",
    modifier = expected_topology_modifier,
    type = "radio",
    choices = set_names(all_simplified_trajectory_types, label_capitalise(all_simplified_trajectory_types)),
    activeIf = "
      input.multiple_disconnected == 'No' &&
      input.expect_topology == 'Yes'
    ",
    title = "What is the expected topology",
    help = "Select the expected topology <img src='img/topologies.png'>",
    category = "topology",
    default = character()
  ),
  list(
    question_id = "expect_cycles",
    modifier = expect_cycles_modifier,
    type = "radio",
    choices = c("It's possible", "No"),
    activeIf = "
      input.expect_topology == 'No'
    ",
    title = "Do you expect cycles in the data?",
    help = "Cells within a cyclic topology can go back to their original state. Apart from the cell cycle, such trajectories can also include sucessive stages of activation and a return to steady state.",
    category = "topology",
    default = character()
  ),
  list(
    question_id = "expect_complex_tree",
    modifier = expect_complex_tree_modifier,
    type = "radio",
    choices = c("Yes", "Not necessarily"),
    activeIf = "
      input.expect_cycles == 'No' &&
      input.expect_topology == 'No'
    ",
    title = "Do you expect a complex tree in the data?",
    help = "A complex tree can include two or more bifurcations.",
    category = "topology",
    default = character()
  ),
  list(
    question_id = "prior_information",
    modifier = prior_information_modifier,
    type = "checkbox",
    choices = set_names(priors$prior_id, priors$prior_name),
    special_choices = list(c("All", priors$prior_name), c("None", "[]")),
    title = "Are you willing to provide the following prior information?",
    help = "Some methods require some prior information, such as the start cells, to help with the construction of the trajectory. Although this can help the method with finding the right trajectory, prior information can also bias the trajectory towards what is already known. Prior information should therefore be given with great care.",
    activeIf = "true",
    category = "prior_information",
    default = c()
  ),
  list(
    question_id = "n_cells",
    modifier = n_cells_modifier,
    type = "textslider",
    choices = c("< 100", "< 1000", "< 10000", "10000+"),
    title = "Number of cells",
    activeIf = "true",
    category = "task",
    default = "< 10000"
  ),
  list(
    question_id = "n_features",
    modifier = n_features_modifier,
    type = "textslider",
    choices = c("< 100", "< 1000", "< 10000", "10000+"),
    title = "Number of features (genes)",
    activeIf = "true",
    category = "task",
    default = "< 1000"
  ),
  list(
    question_id = "metric_importance",
    modifier = metric_importance_modifier,
    type = "balancing_sliders",
    title = "How important are the following aspects of the trajectory?",
    help = "We assessed ...........",
    activeIf = "true",
    category = "metric_importance",
    labels = metrics$name %>% set_names(metrics$id),
    slider_ids = metrics$id %>% set_names(metrics$id),
    default = rep(1/nrow(metrics), nrow(metrics)) %>% set_names(metrics$id),
    mins = rep(0, nrow(metrics)) %>% set_names(metrics$id),
    maxs = rep(1, nrow(metrics)) %>% set_names(metrics$id),
    steps = rep(0.1, nrow(metrics)) %>% set_names(metrics$id)
  ),
  list(
    question_id = "dynmethods",
    modifier = dynmethods_modifier,
    type = "radio",
    choices = c("Yes", "No"),
    title = "Do you use dynmethods to run the methods?",
    help = "Dynmethods is an R package which contains wraps TI methods into a common interface. While we highly recommend the use of this package, as it eases interpretation, some users may prefer to work in other programming languages.",
    activeIf = "true",
    category = "availability",
    default = "Yes"
  ),
  list(
    question_id = "docker",
    modifier = docker_modifier,
    type = "radio",
    choices = c("Yes", "No"),
    title = "Is docker installed?",
    help = "Docker makes it easy to run each TI method without dependency issues, apart from the installation of docker itself.",
    activeIf = "input.dynmethods == 'Yes'",
    category = "availability",
    default = function() {ifelse(dynwrap::test_docker_installation(), "Yes", "No")}
  ),
  list(
    question_id = "programming_interface",
    modifier = programming_interface_modifier,
    type = "radio",
    choices = c("Yes", "No"),
    title = "Can you work in a programming interface?",
    activeIf = "input.dynmethods == 'No'",
    category = "availability",
    default = "Yes"
  ),
  list(
    question_id = "languages",
    modifier = languages_modifier,
    type = "checkbox",
    choices = all_programming_languages,
    special_choices = list(c("All", all_programming_languages), c("Any free",  all_free_programming_languages), c("Clear", "[]")),
    default = all_free_programming_languages,
    title = "Which languages can you work with?",
    activeIf = "input.dynmethods == 'No' && input.programming_interface == 'Yes'",
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
    activeIf = "input.dynmethods == 'No'",
    category = "availability"
  ),
  list(
    question_id = "running_time",
    modifier = running_time_modifier,
    type = "slider",
    min = 1,
    max = 240,
    default = 5,
    activeIf = "input.dynmethods == 'Yes'",
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

# make the R active_if function from the javascript activeIf function
questions <- map(questions, function(q) {
  activeIf <- q$activeIf
  if(activeIf == "true") {
    activeIf <- "TRUE"
  } else {
    activeIf <- gsub("\\.", "$", activeIf)
  }
  activeIf <- parse(text = activeIf)
  q$active_if <- function(input) {
    active <- eval(activeIf)
    length(active) && !is.na(active) && active
  }
  q
})


usethis::use_data(questions, overwrite = TRUE)
