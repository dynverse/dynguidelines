#' @rdname guidelines
#' @inheritParams shiny::runApp
#' @param ... Other parameters given to [shiny::runApp()]
#' @export
guidelines_shiny <- function(
  dataset = NULL,
  answers = answer_questions(dataset = dataset),
  port = NULL,
  launch.browser = TRUE,
  host = NULL,
  ...
  ) {

  app <- shiny::shinyApp(
    shiny_ui(),
    shiny_server(answers = answers)
  )

  shiny::runApp(
    app,
    port = port,
    launch.browser = launch.browser,
    host = host,
    ...
  )
}