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

      if (!is.null(attr(question$default, "computed")) && attr(question$default, "computed")) {
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

  ## build the page ----------------------------
  fluidPage(
    tags$head(includeScript("https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/google-analytics.js", package="dynguidelines"))),
    tags$head(includeScript(system.file("js/tooltips.js", package="dynguidelines"))),

    tags$head(includeCSS(system.file("css/style.css", package="dynguidelines"))),

    titlePanel("Selecting the most optimal TI methods"),


    column(4,
      questions_ui,
      `data-intro` = "First answer a set of questions depending on prior knowledge of the topology present within the data, the dataset size and own preferences"
    ),
    column(8,
      actionButton(
        "submit",
        span(icon("chevron-circle-right"), " Use methods ",  icon("chevron-circle-right")),
        width="100%",
        class="btn-primary",
        `data-intro` = "Click this button when ready to continue"
      ),
      div(
        uiOutput("methods_table"),
        `data-intro` = "Based on these answers, a top set of methods will be selected."
      )
    )
  )
}