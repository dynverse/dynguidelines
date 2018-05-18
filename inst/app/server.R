server <- function(input, output, session) {
  # add path of images
  addResourcePath("img", system.file("img/", package="dynguidelines"))

  # load question + update questions after a user answers it
  question_categories <- map(question_categories, function(question_category) {
    map(question_category, function(question) {
      question$answer <- reactive(input[[question$question_id]])
      question$dynamicsource <- reactive({
        if (!is.null(question$answer())) {
          if(is.null(question$default) || length(question$default) == 0) {
            "given"
          } else if (all.equal(question$default, question$answer(), check.attributes=FALSE) == TRUE) {
            question$source
          } else {
            "given"
          }
        } else {
          "none"
        }
      })
      question$active <- reactive(question$active_if(input))
      question
    })
  })

  # add questions
  # questions and previous_answers were provided by guidelines_shiny into the environment
  output$questions_panel <- renderUI(get_questions(question_categories, previous_answers))

  answers <- reactive(map(answer_names, ~input[[.]]) %>% set_names(answer_names))
  current_guidelines <- reactive(guidelines(task=NULL, answers=answers()))

  # add methods table
  output$methods_table <- renderUI(get_guidelines_methods_table(current_guidelines()))

  # toggleClass(id = NULL, class = NULL, condition = NULL, selector = NULL)

  ## on exit, return guidelines
  return_guidelines <- function() {
    isolate({
      answers <- reactiveValuesToList(input)[questions %>% map_chr("question_id")] %>% {.[!is.na(names(.))]}
      return_value <- guidelines(task=NULL, answers=answers)
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