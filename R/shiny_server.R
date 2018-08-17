#' The shiny server
#'
#' @param answers Previous answers other than default, see the [answer_questions()] function
#'
#' @export
shiny_server <- function(
  answers = answer_questions()
) {
  # create the server function, which will be called by shiny internally
  server <- function(input, output, session, answers = answer_questions()) {
    questions <- get_questions()

    # add path of images
    addResourcePath("img", system.file("img/", package = "dynguidelines"))
    addResourcePath("man_img", system.file("man/img/", package = "dynguidelines"))

    # make sure questions and answers match
    testthat::expect_setequal(names(questions), answers$question_id)

    # update question defaults based on given (default) answers
    # add question answer and source reactive inputs
    questions <- map(questions, function(question) {
      question_answer <- answers %>% extract_row_to_list(which(question_id == question$question_id))

      question$default <- question_answer$answer
      question$default_source <- question_answer$source

      question$answer <- reactive(parse_answers(input[[question$question_id]]))

      question$source <- reactive({
        if (isTRUE(all.equal(question$answer(), question$default))) {
          question$default_source
        } else {
          "adapted"
        }
      })

      question$active <- reactive(question$active_if(input))

      question
    })

    # nest questions based on category
    question_categories <- split(questions, factor(map_chr(questions, "category"), unique(map_chr(questions, "category"))))

    ## create answer reactivity
    reactive_answers <- reactive({
      answers$answer <- map(answers$question_id, function(question_id) {parse_answers(input[[question_id]])})
      answers$source <- map_chr(questions[answers$question_id], function(question) question$source())
      answers
    })
    current_guidelines <- reactive(guidelines(dataset = NULL, answers = reactive_answers()))

    ## create the UI
    # questions
    output$questions_panel <- renderUI(get_questions_ui(question_categories, reactive_answers()))

    # methods table
    output$methods_table <- renderUI(get_guidelines_methods_table(current_guidelines()))

    # toggleClass(id = NULL, class = NULL, condition = NULL, selector = NULL)

    ## on exit, return guidelines
    return_guidelines <- function() {
      isolate({
        return_value <- guidelines(dataset = NULL, answers = reactive_answers())
        stopApp(return_value)
      })
    }

    # activate this function when pressing the submit button
    observe({
      if(input$submit > 0) {
        return_guidelines()
      }
    })

    # or when exiting through rstudio exit buttong
    session$onSessionEnded(return_guidelines)
  }

  formals(server)$answers <- answers

  server
}


# Function which converts "TRUE" -> TRUE and "FALSE" -> FALSE because shiny cannot handle such values
parse_answers <- function(x) {
  if (identical(x, "TRUE")) {
    TRUE
  } else if (identical(x, "FALSE")) {
    FALSE
  } else if (length(x) == 1 && !is.na(suppressWarnings(as.numeric(x)))) {
    as.numeric(x)
  } else {
    x
  }
}