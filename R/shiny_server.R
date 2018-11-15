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

    # make sure questions and answers match
    testthat::expect_setequal(names(questions), answers$question_id)

    # update question defaults based on given (default) answers
    # add question answer and source reactive inputs
    questions <- map(questions, function(question) {
      question_answer <- answers %>% extract_row_to_list(which(question_id == question$question_id))

      question[["default"]] <- question_answer$answer
      question$source_default <- question_answer$source

      question$answer <- reactive(get_answer(question, input))

      question$source <- reactive({
        if (isTRUE(all.equal(question$answer(), question[["default"]]))) {
          question$source_default
        } else {
          "adapted"
        }
      })

      question$active <- reactive(question$active_if(input))

      question
    })

    # nest questions based on category
    question_categories <- split(questions, factor(map_chr(questions, "category"), unique(map_chr(questions, "category"))))

    ## create show/hide columns reactivity
    show_column_ids <- paste0("column_", get_renderers()$column_id)
    show_columns <- reactive(map(show_column_ids, ~input[[.]]) %>% set_names(show_column_ids) %>% unlist())

    output$column_presets <- renderUI(get_columns_presets_ui(column_presets = get_column_presets(), session = session, show_columns = show_columns))
    output$column_show_hide <- renderUI(get_columns_show_hide_ui(renderers = get_renderers()))
    outputOptions(output, "column_show_hide", suspendWhenHidden = FALSE)

    ## create answer reactivity
    reactive_answers <- reactive({
      answers$answer <- map(questions[answers$question_id], get_answer, input = input)

      answers$source <- map_chr(questions[answers$question_id], function(question) question$source())
      answers
    })
    current_guidelines <- reactive({
      # wait with calculating the guidelines until the answers have all been initialized, using the hidden input "questions_loaded"
      if (!is.null(input$questions_loaded)) {
        guidelines(dataset = NULL, answers = reactive_answers())
      } else {
        NULL
      }
    })

    ## create the UI
    # questions
    output$questions_panel <- renderUI(get_questions_ui(question_categories, reactive_answers()))

    # methods table
    output$methods_table <- renderUI(
      if(!is.null(current_guidelines())) {
        get_guidelines_methods_table(current_guidelines(), show_columns(), options = options())
      } else {
        icon("spinner", class = "fa-pulse fa-3x fa-fw")
      }
    )

    # code
    output$code <- renderText(get_answers_code(answers = reactive_answers()))

    # citations
    observe({
      if (input$show_citation) {
        get_citations_modal()
      }
    })

    # options
    output$options <- renderUI(get_options_ui())
    options <- reactive({
      lst(
        score_visualisation = input$score_visualisation
      )
    })

    ## on exit, return guidelines
    if (interactive() || Sys.getenv("CI") == "true") {
      return_guidelines <- function() {
        isolate({
          if (isRunning()) {
            cat(
              c(
                "Code to reproduce the guidelines, copy it over to your script!",
                "",
                crayon::bold(get_answers_code(reactive_answers()))
              ) %>% glue::glue_collapse("\n"),
              "\n"
            )

            return_value <- guidelines(dataset = NULL, answers = reactive_answers())

            stopApp(return_value)
          }
        })
      }

      # activate this function when pressing the submit button
      observe({
        if(!is.null(input$submit) && input$submit > 0) {
          return_guidelines()
        }
      })

      # or when exiting through rstudio exit button
      session$onSessionEnded(return_guidelines)
    }
  }

  # set default answers argument to given answers
  formals(server)$answers <- answers

  server
}

# Get the answer either directly from the input or from the module
get_answer <- function(question, input) {
  if (question$type == "module") {
    parse_answers(callModule(question$module_server, question$question_id)())
  } else {
    parse_answers(input[[question$question_id]])
  }
}


# Function which converts "TRUE" -> TRUE and "FALSE" -> FALSE because shiny cannot handle such values
# It also converts singleton characters to numbers if possible
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