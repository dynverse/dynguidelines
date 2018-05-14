server <- function(input, output, session) {
  output$methods_table <- reactive(get_guidelines_methods_table(NULL,input))

  # on exit, return the methods and answers
  return_methods <- function() {
    isolate({
      return_value <- list(
        answers = reactiveValuesToList(input)[questions %>% map_chr("question_id")],
        methods = guidelines(NULL, input)$methods
      )
      stopApp(return_value)
    })
  }

  # activate this function when pressing the submit button
  observe({
    if(input$submit > 0) {
      return_methods()
    }
  })

  # or when exiting through rstudio exit buttong
  session$onSessionEnded(return_methods)
}