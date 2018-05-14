# go from javascript conditions to R conditions
javascript_to_r_condition <- function(x) {
  if(x == "true") {
    "TRUE"
  } else {
    gsub("\\.", "$", x)
  }
}

# check whether a question is active
check_active <- function(question, input) {
  active <- eval(parse(text=javascript_to_r_condition(question$activeIf)))

  length(active) && !is.na(active) && active
}

#' @rdname guidelines_shiny
#' @export
guidelines <- function(
  task = NULL,
  answers = list(programming_interface = "Yes", prior_information=c("Start cell"), n_methods = 4),
  method_columns = tibble(column_id = c("selected", "method_name", "topology_inference_type", "maximal_trajectory_type", "overall_benchmark")
)
) {
  data(methods, questions, envir = environment())

  # build data with default order
  data <- lst(methods, method_columns)
  data$methods <- data$methods %>% arrange(-overall_benchmark)
  data$methods$selected <- FALSE

  for (question in questions) {
    # only modify if question is checkbox (and can therefore be NULL) or if answers is not NULL
    if(question$type == "checkbox" || !is.null(answers[[question$question_id]])) {
      # only modify if question is active
      if(check_active(question, answers)) {
        data <- question$modifier(data, answers[[question$question_id]])
      }
    }
  }
  data
}