#' Select the top methods, optionally based on a given dataset
#' @param dataset The dataset, optional
#' @param answers Optional, pre-provided answers to the different questions. See [answer_questions()]
#'
#' @return Returns a dynguidelines::guidelines object, containing
#'   - `methods`: Ordered tibble containing information about the selected methods
#'   - `method_columns`: Information about what columns in methods are given and whether the were used for filtering or ordering
#'   - `answers`: An answers object, can be further modified.
#'   - `methods_selected`: Identifiers for all selected methods
#'
#' @export
guidelines <- function(
  dataset = NULL,
  answers = answer_questions(dataset = dataset)
) {
  # build data with default order and columns
  method_columns <- renderers %>%
    filter(!is.na(default)) %>%
    select(column_id) %>%
    mutate(filter = FALSE, order = ifelse(column_id == "overall_benchmark", TRUE, FALSE))

  # default ordering
  data <- lst(methods, method_columns, answers)
  data$methods <- data$methods %>% arrange(-overall_benchmark)
  data$methods$selected <- FALSE

  # get the answers in a list
  question_answers <- answers %>% select(question_id, answer) %>% deframe()

  # call the modifiers if the question is active
  for (question in questions) {
    # only modify if question is checkbox/picker (and therefore NULL can be a valid answer) or if answers is not NULL
    if(question$type %in% c("checkbox", "picker") || !is.null(question_answers[[question$question_id]])) {
      # only modify if question is active
      if(question$active_if(question_answers)) {
        data <- question$modifier(data, question_answers[[question$question_id]])
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