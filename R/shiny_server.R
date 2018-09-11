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

      question$answer <- reactive(parse_answers(input[[question$question_id]]))

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

    ## create answer reactivity
    reactive_answers <- reactive({
      answers$answer <- map(answers$question_id, function(question_id) {parse_answers(input[[question_id]])})
      answers$source <- map_chr(questions[answers$question_id], function(question) question$source())
      answers
    })
    current_guidelines <- reactive(guidelines(dataset = NULL, answers = reactive_answers()))

    ## create show/hide columns reactivity
    renderers <- get_renderers()

    # individual inputs
    show_column_ids <- paste0("column_", get_renderers()$column_id)
    show_columns <- reactive(map(show_column_ids, ~input[[.]]) %>% set_names(show_column_ids) %>% unlist())

    output$column_show_hide <- renderUI(
      tags$ul(
        class = "list-group",
        style = "position:static;",
        tidyr::nest(renderers, -category, .key = "renderers") %>%
          pmap(function(category, renderers) {
            tags$li(
              class = "list-group-item",
              tags$em(label_capitalise(category)),
              map2(renderers$column_id, renderers$label, function(column_id, label) {
                indeterminateCheckbox(
                  paste0("column_", column_id),
                  label,
                  "indeterminate"
                )
              }) %>% tags$div()
            )
          })
      )
    )

    # presets
    column_presets <- get_column_presets()
    output$column_presets <- renderUI(
      map(column_presets, function(column_preset) {
        # observe button event, and change the show columns accordingly
        button_id <- paste0("column_preset_", column_preset$id)
        observeEvent(input[[button_id]], {
          # change the columns checkboxes
          new_show_columns <- column_preset$activate(show_columns())
          changed_show_columns <- new_show_columns[new_show_columns != show_columns()]

          walk2(names(changed_show_columns), changed_show_columns, function(column_id, value) {
            updateIndeterminateCheckboxInput(session, column_id, value)
          })
        })

        actionButton(
          button_id,
          label = column_preset$label
        )
      }) %>% tags$div()
    )

    ## create the UI
    # questions
    output$questions_panel <- renderUI(get_questions_ui(question_categories, reactive_answers()))

    # methods table
    output$methods_table <- renderUI(get_guidelines_methods_table(current_guidelines(), show_columns()))

    # code
    output$code <- renderText(get_answers_code(answers = reactive_answers()))

    # toggleClass(id = NULL, class = NULL, condition = NULL, selector = NULL)

    ## on exit, return guidelines
    if (interactive()) {
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
  }

  # set default answers argument to given answers
  formals(server)$answers <- answers

  server
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