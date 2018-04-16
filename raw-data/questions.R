library(tidyverse)
library(dynguidelines)
data(methods)

process_prior_information <- function(data, answer=NULL) {
  unavailable_priors <- priors %>% filter(!prior_name %in% answer) %>% pull(prior_id)
  data$methods <- data$methods[data$methods[, unavailable_priors] %>% apply(1, function(x) all(x != "required", na.rm=T)), ]

  data
}

javascript_array <- function(x) {paste0("['", glue::collapse(x, "','"), "']")}

all_programming_languages <- unlist(methods$platforms_split) %>% unique()
all_free_programming_languages <- intersect(all_programming_languages, c("python", "R", "C++"))

questions <- list(
  list(
    question_id = "programming_interface",
    modifier = function(data, answer = NULL) {
      if (answer == "No") {
        data$methods <- data$methods %>% filter(gui > 0)
      }

      data
    },
    type = "radio",
    choices = c("Yes", "No"),
    title = "Can you work in a programming interface?",
    activeIf = "true",
    category = "programming"
  ),
  list(
    question_id = "languages",
    modifier = function(data, answer=NULL) {
      data$methods <- data$methods %>% filter(map_lgl(platforms_split, ~length(intersect(answer, .)) > 0))
      data
    },
    type = "checkbox",
    choices = all_programming_languages,
    special_choices = list(c("All", javascript_array(all_programming_languages)), c("Any free",  javascript_array(all_free_programming_languages))),
    default = all_free_programming_languages,
    title = "Which languages can you work with?",
    activeIf = "survey_results['programming_interface'] == 'Yes'",
    category = "programming"
  ),
  list(
    question_id = "prior_information",
    modifier = process_prior_information,
    type = "checkbox",
    choices = priors$prior_name,
    special_choices = list(c("All", javascript_array(priors$prior_name)), c("None", "[]")),
    title = "Are you willing to provide the following prior information?",
    activeIf = "true",
    category = "prior_information"
  ),
  list(
    question_id = "multiple_disconnected",
    modifier = function(data, answer=NULL) {
      data$methods <- data$methods %>% arrange(-overall_benchmark)
      if(answer == "Yes") {
        data$methods <- data$methods %>% filter(disconnected_undirected_graph)
      }
      data
    },
    type = "radio",
    choices = c("Yes", "No"),
    modifier = function(data, answer=NULL) {},
    title = "Do you expect multiple disconnected trajectories in the data?",
    activeIf = "true",
    category = "topology"
  ),
  list(
    question_id = "expect_topology",
    modifier = function(data, answer=NULL) {data},
    type = "radio",
    choices = c("Yes", "No"),
    activeIf = "survey_results['multiple_disconnected'] == 'No'",
    title = "Do you expect a particular topology in the data?",
    activeIf = "true",
    category = "topology"
  ),
  list(
    question_id = "expected_topology",
    modifier = function(data, answer=NULL) {
      if(answer == "Linear") {
        trajectory_type_column <- "undirected_linear"
        score_column <- "trajtype_directed_linear"
      } else if (answer == "Cyclic") {
        trajectory_type_column <- "undirected_cycle"
        score_column <- "trajtype_directed_cycle"
      } else if (answer == "Bifurcating") {
        trajectory_type_column <- "simple_fork"
        score_column <- "trajtype_bifurcation"
      }

      data$methods <- data$methods[data$methods[[trajectory_type_column]], ] %>% arrange(-.[[score_column]])
      data$method_columns <- data$method_columns %>%
        add_row(column_id = score_column, renderer = "benchmark_score") %>%
        add_row(column_id = trajectory_type_column, renderer = "bool")

      data
    },
    type = "radio",
    choices = c("Linear", "Cyclic", "Bifurcating"),
    activeIf = "survey_results['expect_topology'] == 'Yes'",
    title = "What is the expected topology",
    category = "topology"
  ),
  list(
    question_id = "expect_cycles",
    modifier = function(data, answer=NULL) {
      if(answer == "It's possible") {
        data$methods <- data$methods %>% filter(undirected_graph)
      }
      data
    },
    type = "radio",
    choices = c("It's possible", "No"),
    activeIf = "survey_results['expect_topology'] == 'No'",
    title = "Do you expect cycles in the data?",
    category = "topology"
  ),
  list(
    question_id = "expect_complex_tree",
    modifier = function(data, answer=NULL) {
      if(answer == "Yes") {
        data$methods <- data$methods %>% filter(unrooted_tree) %>% arrange(-trajtype_rooted_tree)
        data$method_columns <- data$method_columns %>% add_row(column_id = "trajtype_rooted_tree", renderer = "benchmark_score")
      }
      data
    },
    type = "radio",
    choices = c("Yes", "Not necessarily"),
    activeIf = "survey_results['expect_cycles'] == 'No'",
    title = "Do you expect a complex tree in the data?",
    category = "topology"
  )
) %>% {set_names(., map(., "question_id"))}

question_map <- setNames(seq_along(questions)-1, map(questions, "question_id"))

questions <- lst(
  questions = unname(questions),
  questionMap = question_map
)

usethis::use_data(questions, overwrite = TRUE)
