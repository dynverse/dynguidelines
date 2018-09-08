port <- Sys.getenv('PORT')

dynguidelines::guidelines_shiny(
  port = as.numeric(port),
  launch.browser = FALSE,
  host = '0.0.0.0'
)