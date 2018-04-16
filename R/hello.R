method_columns <- tribble(
  ~column_id, ~renderer,
  "method_name", "text",
  "topology_inference_type", "topology_inference_type",
  "maximal_trajectory_type", "text",
  "overall_benchmark", "benchmark_score"
)

#' @export
get_results <- function(
  survey_results = list(programming_interface = "Yes", prior_information=c("Start cell")),
  column_ids = c("method_name", "topology_inference_type", "maximal_trajectory_type", "overall_benchmark")
) {
  method_columns <- method_columns %>% slice(match(column_ids, column_id))

  data <- lst(methods, method_columns)

  # default order
  data$methods <- data$methods %>% arrange(-overall_benchmark)

  # modify everything
  for (question in questions$questions) {
    if(!is.null(survey_results[[question$question_id]])) {
      print(question$question_id)
      print(survey_results[[question$question_id]])
      data <- question$modifier(data, survey_results[[question$question_id]])

      print(data$methods %>% nrow)
    }
  }

  data$methods <- data$methods %>% select(!!data$method_columns$column_id)
  data$method_columns <- data$method_columns  %>%
    mutate(label = column_id %>% gsub("_", " ", .) %>% Hmisc::capitalize())

  data
}

#' @export
test_plot <- function() {
  plot(1:10, 1:10)
}

#' @export
priors <- tribble(
  ~prior_id, ~prior_name,
  "start_id", "Start cell",
  "end_id", "End cell(s)",
  "end_n", "# end states",
  "states_id", "Cell clustering",
  "states_n", "# states",
  "states_network", "State network",
  "time_id", "Time course",
  "genes_id", "Marker genes"
)