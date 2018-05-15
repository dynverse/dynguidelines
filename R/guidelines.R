# answers using a task
answers_task <- function(task=NULL, answers=list()) {
  if(!dynwrap::is_wrapper_with_expression(task)) {
    stop("Task does not contain expression")
  }

  new_answers <- list()

  # dataset size
  n_cells <- nrow(task$expression)
  n_genes <- nrow(task$expression)

  new_answers$n_cells <- case_when(
    n_cells < 100 ~"< 100",
    n_cells < 1000 ~ "< 1000",
    n_cells < 10000 ~ "< 10000",
    TRUE ~ "10000+"
  )
  attr(new_answers$n_cells, "computed") <- TRUE
  new_answers$n_genes <- case_when(
    n_genes < 100 ~"< 100",
    n_genes < 1000 ~ "< 1000",
    n_genes < 10000 ~ "< 10000",
    TRUE ~ "10000+"
  )
  attr(new_answers$n_genes, "computed") <- TRUE

  # topology
  if(dynwrap::is_wrapper_with_trajectory(task)) {
    classification <- dynwrap::classify_milestone_network(task$milestone_network)

    warning("Known milestone network not used, should do this in the future!")
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

#' @rdname guidelines_shiny
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
  method_columns <- tribble(
    ~column_id, ~filter, ~order,
    "selected", FALSE, FALSE,
    "method_name", FALSE, FALSE,
    # "topology_inference_type", FALSE , FALSE,
    # "maximal_trajectory_type", FALSE, FALSE,
    "overall_benchmark", FALSE, TRUE
  )

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

  data
}