#' Select the top methods, optionally based on a given task
#' @param task The task, optional
#' @param answers Optional, pre-provided answers to the different questions
#'
#' @export
guidelines <- function(
  task = NULL,
  answers = list()
) {
  # get answers from task
  if (!is.null(task)) {
    answers <- get_defaults_task(task, answers)
  }

  # build data with default order and columns
  method_columns <- renderers %>%
    filter(!is.na(default)) %>%
    select(column_id) %>%
    mutate(filter = FALSE, order = ifelse(column_id == "overall_benchmark", TRUE, FALSE))

  # now modify the methods based on the answers
  data <- lst(methods, method_columns, answers)
  data$methods <- data$methods %>% arrange(-overall_benchmark)
  data$methods$selected <- FALSE

  for (question in questions) {
    # only modify if question is checkbox (and can therefore be NULL) or if answers is not NULL
    if(question$type == "checkbox" || !is.null(answers[[question$question_id]])) {
      # only modify if question is active
      if(question$active_if(answers)) {
        data <- question$modifier(data, answers[[question$question_id]])
      }
    }
  }

  # select methods
  data$methods_selected <- data$methods %>% filter(selected) %>% pull(method_id)

  data <- add_class(data, "dynguidelines::guidelines")
  data
}

#' Check whether object is guidelines
#'
#' @param guidelines The object to check
#' @export
is_guidelines <- function(guidelines) {
  if("dynguidelines::guidelines" %in% class(x)) {
    TRUE
  } else if (all(c("methods", "answers") %in% names(x))) {
    TRUE
  } else {
    FALSE
  }
}