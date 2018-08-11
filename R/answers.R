get_defaults_task <- function(task = NULL, answers = list()) {
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
    new_answers$n_features <- case_when(
      n_features < 100 ~"< 100",
      n_features < 1000 ~ "< 1000",
      n_features < 10000 ~ "< 10000",
      TRUE ~ "10000+"
    )
  }

  # topology
  if(dynwrap::is_wrapper_with_trajectory(task)) {
    trajectory_type <- dynwrap::classify_milestone_network(task$milestone_network)$network_type
    data(trajectory_types, package = "dynwrap", envir = environment())
    trajectory_type_simplified <- trajectory_types$simplified[first(match(trajectory_type, trajectory_types$id))]

    new_answers <- c(new_answers, list(
      multiple_disconnected = "No",
      expect_topology = "Yes",
      expected_topology = trajectory_type_simplified
    ))
  }

  # prior information
  if("prior_information" %in% names(task) || dynwrap::is_wrapper_with_prior_information(task)) {
    data(priors, envir = environment(), package = "dynguidelines")

    new_answers$prior_information <- priors %>% filter(prior_task_id %in% names(task$prior_information)) %>% pull(prior_id)
  }

  # add computed attribute to answers
  new_answers <- map(new_answers, function(.) {attr(., "computed") <- TRUE;.})

  # update with old answers, overwriting the new ones
  purrr::list_modify(new_answers, !!!answers)
}

get_defaults <- function(question_ids = names(get_questions())) {
  map(question_ids, get_default) %>% set_names(question_ids)
}

get_default <- function(question_id) {
  default <- questions[[question_id]]$default

  if (is.function(default)) {
    default <- default()
  }

  default
}





# function which generates the documentation for the answers function based on all the questions
answers_docs <- function() {
  parameters <- paste0(
    "@param ",
    names(questions),
    " ",
    map_chr(questions, "title"),
    " Defaults to ",
    get_defaults(questions$id) %>% as.character()
  )
}

#' Provide answers to various questions
#'
#' @include questions.R
#' @eval answers_docs()
answers <- function() {
  print(match.call())
  tibble(
    answer = as.list(environment())
  )
}
# formals(answers) <- get_defaults(names(questions))
