#' @rdname guidelines
#' @export
guidelines_prompt <- function(task = NULL, answers = list()) {
  string_is_integer <- function(x) {
    stringr::str_detect(x, "^[0-9]*$")
  }

  # process questions to R
  data(questions, envir = environment(), package = "dynguidelines")

  questions <- questions %>% map(
    function(q) {
      if(q$activeIf == "true") {
        q$active_if <- function(answers) TRUE
      } else {
        parsed <- parse(
          text =
            q$activeIf %>%
            gsub("\\[", "[[", .) %>%
            gsub("\\]", "]]", .)
        )
        q$active_if <- function(answers) {
          eval(parsed)
        }
      }
      q
    }
  )

  answers <- list()
  question_i <- 0
  while(question_i != -1) {
    question_i <- question_i + 1
    question <- questions[[question_i]]

    while(!question$active_if(answers)) {
      question_i <- question_i + 1
      question <- questions[[question_i]]
    }

    ## Ask question
    prompt <- stringr::str_glue("{crayon::italic(question$title)}")

    # default value
    if(!is.null(question$default) & length(question$default)) {
      default <- question$default
    } else if (question$type %in% c("radio", "textslider")) {
      default <- question$choices[[1]]
    } else {
      default <- NULL
    }

    if (!is.null(default)) {
      prompt <- stringr::str_glue("{prompt} [default: {crayon::bold(default)}]:")
    }

    print(prompt)

    # print choices
    if (question$type %in% c("radio", "textslider")) {
      print(stringr::str_glue("{seq_along(question$choices)}: {crayon::bold(question$choices)}\n"))
    } else if (question$type %in% c("checkbox")) {
      print(glue::collapse(question$choices, ", "))
    }

    ## Process answer
    answer <- readline("Answer: ")

    if(answer == "") {
      answer <- default
    } else if (string_is_integer(answer) && !answer %in% question$choices) {
      answer <- as.integer(answer)

      if (answer > length(question$choices)) {
        stop("Answer too large")
      } else {
        answer <- question$choices[[as.integer(answer)]]
      }
    }
    answers[[question$question_id]] <- answer

    if(question_i >= length(questions)) {
      question_i <- -1
    }
  }

  guidelines(answers)$methods
}
