#' @rdname guidelines
#' @export
guidelines_shiny <- function(dataset = NULL, answers = answer_questions(dataset = dataset)) {
  app <- shiny::shinyApp(
    shiny_ui(),
    shiny_server
  )
  shiny::runApp(app)
}