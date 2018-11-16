# Functions to create each type of input
input_functions <- list(
  radiobuttons = function(q) {
    if (is.null(q[["default"]])) q[["default"]] <- character()

    # if choices not defined, use choiceNames and choiceValues
    if (is.null(q$choices)) {
      choiceNames <- q$choiceNames
      choiceValues <- q$choiceValues
    } else {
      # default choiceNames is simply the choices
      if (is.null(names(q$choices))) {
        choiceNames <- q$choices
      } else {
        choiceNames <- names(q$choices)
      }
      choiceValues <- unname(q$choices)
    }

    shinyWidgets::radioGroupButtons(
      inputId = q$question_id,
      label = q$label,
      selected = as.character(q[["default"]]),
      choiceNames = choiceNames,
      choiceValues = choiceValues,
      status = "default"
    )
  },
  radio = function(q) {
    if (is.null(q[["default"]])) q[["default"]] <- character()

    radioButtons(
      q$question_id,
      q$label,
      q$choices,
      q[["default"]]
    )
  },
  checkbox = function(q) {
    checkboxGroupInput(
      q$question_id,
      q$label,
      q$choices,
      q[["default"]]
    )
  },
  picker = function(q) {
    shinyWidgets::pickerInput(
      inputId = q$question_id,
      label = q$label,
      choices = q$choices,
      selected = q[["default"]],
      multiple = q$multiple %||% TRUE,
      options = list(
        `actions-box` = TRUE,
        `deselect-all-text` = "None",
        `select-all-text` = "All",
        `none-selected-text` = "None"
      )
    )
  },
  slider = function(q) {
    sliderInput(
      inputId = q$question_id,
      label = q$label,
      min = q$min,
      max = q$max,
      value = q[["default"]],
      step = q$step,
      ticks = FALSE
    )
  },
  textslider = function(q) {
    testthat::expect_true(q$default %in% q$choices)
    shinyWidgets::sliderTextInput(
      inputId = q$question_id,
      label = q$label,
      choices = q$choices,
      selected = q[["default"]],
      grid = TRUE
    )
  },
  balancing_sliders = function(q) {
    balancingSliders(
      inputId = q$question_id,
      label = q$label,
      labels = q$labels,
      ids = q$ids,
      values = q[["default"]],
      min = q$min,
      max = q$max,
      sum = q$sum,
      step = q$step,
      ticks = q$ticks
    )
  },
  numeric = function(q) {
    numericInput(
      inputId = q$question_id,
      label = q$label,
      value = q[["default"]],
      min = 0
    )
  },
  module = function(q) {
    q$module_input(
      id = q$question_id,
      data = q$data
    )
  }
)


get_questions_ui <- function(question_categories, answers) {
  # build the questions ui

  # create every category
  questions_ui <- map(question_categories, function(question_category) {
    # get the header of the panel
    category_id <- question_category[[1]]$category
    category_header <- category_id %>% label_capitalise

    # check if the panel has to be opened from the start
    show_on_start <- map_lgl(question_category, ~ifelse(is.null(.$show_on_start), FALSE, .$show_on_start)) %>% any()

    # create the panel of the category
    category_panel <- collapsePanel(
      id = category_id,
      header = category_header,
      show_on_start = show_on_start,
      map(question_category, function(question) {
        if(!question$type %in% names(input_functions)) {stop("Invalid question type")}

        # if this question has a label and title, add the tooltip help information
        if (!is.null(question$label) && !is.null(question$title)) {
          question$label <-
            tags$span(
              class = "tooltippable",
              title = question$title,
              question$label,
              `data-toggle` = "tooltip",
              `data-trigger` = "hover click",
              `data-placement` = "right"
            )
        }

        question_panel <- div(
          conditionalPanel(
            question$activeIf,
            input_functions[[question$type]](question)
          )
        )

        question_panel
      })
    )

    # observe changes in completion
    observe({
      category_sources <- question_category %>% keep(~.$active()) %>% map_chr(~.$source())

      if (all(category_sources != "none")) {
        shinyjs::toggleClass(
          category_panel$attr$id,
          "completed-category",
          any(category_sources == "adapted")
        )

        shinyjs::toggleClass(
          category_panel$attr$id,
          "computed-category",
          any(category_sources == "computed") && all(category_sources %in% c("computed", "default"))
        )

        shinyjs::toggleClass(
          category_panel$attr$id,
          "default-category",
          all(category_sources == "default")
        )
      }
    })

    category_panel
  }) %>% add_loaded_proxy()
}




# adds a proxy input, which can tell others that these inputs have been loaded and that their inputs are "correct"
add_loaded_proxy <- function(inputs, id) {
  c(
    inputs,
    list(
      tags$div(
        style = "display:none;",
        shiny::radioButtons(
          "questions_loaded",
          "whatevs",
          "loaded",
          "loaded",
          width = "0%"
        )
      )
    )
  )
}