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
    question$computed <- FALSE
    if (!is.null(previous_answers[[question$question_id]])) {
      question$default <- previous_answers[[question$question_id]]

      if (attr(question$default, "computed")) {
        question$computed <- TRUE
      }
    }
    question
  })

  # nest questions based on category
  questions <- split(questions, forcats::fct_inorder(map_chr(questions, "category")))

  # build the questions ui
  questions_ui <- map(questions, function(questions_category) {
    computed <- all(map_lgl(questions_category, "computed"))

    title <- questions_category[[1]]$category %>% label_capitalise
    if(computed) {
      title <- span(title, span("computed", class="computed"))
    }

    collapsePanel(
      title = title,
      show_on_start = !computed,

      map(questions_category, function(question) {
        if(!question$type %in% names(make_ui)) {stop("Invalid question type")}

        div(
          conditionalPanel(
            question$activeIf,
            make_ui[[question$type]](question)
          ),
          class=ifelse(question$computed, "computed", "")
        )
      })
    )
  })

  ## build the sidebar ----------------------------
  fluidPage(
    tags$head(includeScript("https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/google-analytics.js", package="dynguidelines"))),

    # tags$head(includeScript("https://code.jquery.com/jquery-3.3.1.slim.min.js")),

    tags$head(includeCSS(system.file("css/style.css", package="dynguidelines"))),

    titlePanel("Selecting the most optimal methods"),

    fluidPage(
      column(4,
        questions_ui
      ),
      column(8,
        actionButton("submit", "Use methods", icon("chevron-circle-right"), width="100%", class="btn-primary"),
        uiOutput("methods_table")
      )
    )
  )
}