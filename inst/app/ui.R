ui <- function() {
  ## build the page ----------------------------
  fluidPage(
    shinyjs::useShinyjs(),
    tags$head(includeScript("https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/google-analytics.js", package = "dynguidelines"))),
    tags$head(includeScript(system.file("js/tooltips.js", package = "dynguidelines"))),

    tags$head(includeScript("https://cdn.jsdelivr.net/npm/lodash@4.17.10/lodash.min.js")),

    tags$head(includeCSS(system.file("css/style.css", package = "dynguidelines"))),

    titlePanel("Selecting the most optimal TI methods"),

    sidebarLayout(
      column(
        4,
        uiOutput("questions_panel"),
        style = "overflow-y:scroll; max-height:100vh;"
      ),
      column(
        8,
        actionButton(
          "submit",
          span(icon("chevron-circle-right"), " Use methods ",  icon("chevron-circle-right")),
          width = "100%",
          class = "btn-primary"
        ),
        div(
          uiOutput("methods_table")
        )
      )
    )


  )
}