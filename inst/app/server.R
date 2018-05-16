server <- function(input, output, session) {
  # add path of images
  addResourcePath("img", system.file("img/", package="dynguidelines"))

  # add methods table
  output$methods_table <- renderUI(get_guidelines_methods_table(NULL,input))

  # on exit, return the methods and answers
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