## Answer questions
# get default answers based on questions
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
answer_questions_docs <- function() {
  parameters <- paste0(
    "@param ",
    names(questions),
    " ",
    map_chr(questions, "label"),
    " Defaults to ",
    get_defaults(names(questions)) %>% as.character()
  )
}

#' Provide answers to various questions
#'
#' @include questions.R
#' @param dataset The dataset from which the answers will be computed
#' @eval answer_questions_docs()
#'
#' @export
answer_questions <- function(dataset = NULL, ...) {
  # get either the defaults or the arguments given by the user
  answers <- as.list(environment())
  answers <- answers[names(answers) != "dataset"]

  # get the question ids that were given by the user
  given_question_ids <- names(match.call())

  # get computed answers from dataset
  computed_question_ids <- character()
  if (!is.null(dataset)) {
    for (question_id in setdiff(names(questions), given_question_ids)) {
      if (is.function(questions[[question_id]]$default_dataset)) {
        answers[[question_id]] <- questions[[question_id]]$default_dataset(dataset, answers[[question_id]])
        computed_question_ids <- c(computed_question_ids, question_id)
      }
    }
  }

  tibble(
    question_id = names(answers),
    answer = answers,
    source = case_when(
      question_id %in% given_question_ids ~ "given",
      question_id %in% computed_question_ids ~ "computed",
      TRUE ~ "default"
    )
  )
}
formals(answer_questions) <- c(list(dataset = NULL), get_defaults(names(questions)))