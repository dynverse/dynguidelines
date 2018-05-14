ui <- function(previous_answers=list()) {
  ## make the sidebar questions -------------------------
  # different functions depending on the type of questions
  make_ui <- list(
    radio = function(q) {
      radioButtons(
        q$question_id,
        q$title,
        q$choices,
        q$default
      )
    },
    checkbox = function(q) {
      checkboxGroupInput(
        q$question_id,
        q$title,
        q$choices,
        q$default
      )
    },
    slider = function(q) {
      sliderInput(
        q$question_id,
        q$title,
        q$min,
        q$max,
        q$default,
        q$step
      )
    },
    textslider = function(q) {
      shinyWidgets::sliderTextInput(
        q$question_id,
        q$title,
        q$choices,
        q$default
      )
    }
  )

  # update defaults based on previous answers
  questions <- map(questions, function(question) {
    if (!is.null(previous_answers[[question$question_id]])) {
      question$default <- previous_answers[[question$question_id]]
    }
    question
  })

  # build the questions ui
  questions_ui <- map(questions, function(question) {
    if(!question$type %in% names(make_ui)) {stop("Invalid question type")}

    conditionalPanel(
      question$activeIf,
      make_ui[[question$type]](question)
    )
  })

  ## build the sidebar ----------------------------

  fluidPage(
    tags$head(includeScript("https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/google-analytics.js", package="dynguidelines"))),

    titlePanel("Selecting the most optimal methods"),

    sidebarLayout(
      sidebarPanel(
        questions_ui
      ),
      mainPanel(
        actionButton("submit", "Use methods", icon("chevron-circle-right"), width="100%", class="btn-primary"),
        htmlOutput("methods_table")
      )
    )
  )
}