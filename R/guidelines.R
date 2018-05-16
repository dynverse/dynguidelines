#' @rdname guidelines
answers_task <- function(task=NULL, answers=list()) {
  new_answers <- list()

  # dataset size
  if(dynwrap::is_wrapper_with_expression(task)) {
    n_cells <- nrow(task$expression)
    n_features <- nrow(task$expression)

    new_answers$n_cells <- case_when(
      n_cells < 100 ~"< 100",
      n_cells < 1000 ~ "< 1000",
      n_cells < 10000 ~ "< 10000",
      TRUE ~ "10000+"
    )
    attr(new_answers$n_cells, "computed") <- TRUE
    new_answers$n_features <- case_when(
      n_features < 100 ~"< 100",
      n_features < 1000 ~ "< 1000",
      n_features < 10000 ~ "< 10000",
      TRUE ~ "10000+"
    )
    attr(new_answers$n_features, "computed") <- TRUE
  }

  # topology
  if(dynwrap::is_wrapper_with_expression(task)) {
    classification <- dynwrap::classify_milestone_network(task$milestone_network)

    message("Using the known topology is not yet implemented!")
  }

  # prior information
  if("prior_information" %in% names(task) || dynwrap::is_wrapper_with_prior_information(task)) {
    data(priors, envir = environment())

    answers$prior_information <- priors %>% filter(prior_task_id %in% names(task$prior_information)) %>% pull(prior_id)
    attr(answers$prior_information, "computed") <- TRUE
  }

  # update with old answers, overwriting the new ones
  purrr::list_modify(new_answers, !!!answers)
}

#' Select the top methods, optionally based on a given task
#' @param task The task, optional
#' @param answers Optional, pre-provided answers to the different questions
#' @param method_columns The columns to return
#'
#' @export
guidelines <- function(
  task = NULL,
  answers = list()
) {
  if (!is.null(task)) {
    answers <- answers_task(task, answers)
  }

  data(methods, questions, envir = environment())

  # build data with default order and columns
  data("renderers")
  method_columns <- renderers %>%
    filter(!is.na(default)) %>%
    select(column_id) %>%
    mutate(filter=FALSE, order = ifelse(column_id == "overall_benchmark", TRUE, FALSE))

  data <- lst(methods, method_columns)
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

  data$answers <- answers

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