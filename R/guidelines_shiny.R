#' @rdname guidelines
#' @export
guidelines_shiny <- function(task = NULL, answers = list()) {
  # get defaults from the task
  if (!is.null(task)) {
    answers <- get_defaults_task(task, answers)
  }

  # load in the ui and the server
  file_path <- system.file("app/ui.R", package = "dynguidelines")
  source(file_path, local = TRUE)
  file_path <- system.file("app/server.R", package = "dynguidelines")
  source(file_path, local = TRUE)

  # create a server environment, in which we will put certain variables such as the previous answers
  # trick from https://stackoverflow.com/questions/44999615/passing-parameters-into-shiny-server
  # this looks ugly though, but seems to me the most acceptable way to get variables into the shiny server
  server_env <- environment(server)

  # update defaults based on previous answers
  questions <- map(questions, function(question) {
    question$computed <- FALSE

    if (is.function(question$default)) {
      question$default <- question$default()
    }

    if(!is.null(question$default) && length(question$default)) {
      question$source <- "default"
    }

    if (!is.null(answers[[question$question_id]])) {
      question$default <- answers[[question$question_id]]
      if (!is.null(attr(question$default, "computed")) && attr(question$default, "computed")) {
        question$source <- "computed"
      }
    }
    question
  })

  # nest questions based on category
  question_categories <- split(questions, factor(map_chr(questions, "category"), unique(map_chr(questions, "category"))))

  server_env$answer_names <- names(questions)
  server_env$question_categories <- question_categories
  server_env$previous_answers <- answers

  app <- shiny::shinyApp(
    ui(),
    server
  )
  shiny::runApp(app)
}


add_icons <- function(label, conditions, icons) {
  pmap(c(list(label = label), conditions), function(label, ...) {
    icons <- list(...) %>%
      keep(~!is.na(.) && .) %>%
      names() %>%
      {icons[.]}

    span(c(list(label), icons))
  })
}

get_guidelines_methods_table <- function(guidelines) {
  if(nrow(guidelines$methods) == 0) {
    span(class = "text-danger", "No methods fullfilling selection")
  } else {
    # remove duplicate columns
    method_columns <- guidelines$method_columns %>%
      group_by(column_id) %>%
      slice(n()) %>%
      ungroup()

    # add renderers
    method_columns <- method_columns %>%
      left_join(renderers, c("column_id" = "column_id")) %>%
      mutate(renderer = map(renderer, ~ifelse(is.null(.), function(x) {x}, .)))

    # add labels
    method_columns <- method_columns %>%
      mutate(
        label = add_icons(label, lst(filter, order), list(filter = icon("filter"), order = icon("sort-amount-asc")))
      )

    # order columns
    method_columns <- method_columns %>%
      mutate(order = case_when(!is.na(default)~default, filter~1, order~2, TRUE~3)) %>%
      arrange(order)

    # extract correct columns from guidelines
    methods <- guidelines$methods %>% select(!!method_columns$column_id)

    # render columns
    methods_rendered <- methods %>%
      map2(method_columns$renderer, function(col, renderer) renderer(col)) %>%
      as_tibble()

    # construct html of table
    methods_table <- tags$table(
        class = "table table-striped table-responsive",
        tags$tr(
          pmap(method_columns, function(label, title, style, ...) {
            tags$th(
              label,
              `data-toggle` = "tooltip",
              `data-placement` = "top",
              title = title,
              style = paste0("vertical-align:bottom;", ifelse(is.na(style), "width:20px;", style)),
              class = "tooltippable"
            )
          })
        ),
        map(
          seq_len(nrow(methods)),
          function(row_i) {
            row_rendered <- extract_row_to_list(methods_rendered, row_i)
            row <- extract_row_to_list(methods, row_i)
            if (row$selected) {
              class <- "selected"
            } else {
              class <- ""
            }

            tags$tr(
              class = class,
              map(row_rendered, .f = tags$td)
            )
          }
        ),
        tags$script('activeTooltips()')
      )

    # methods_table <- methods %>%
    #   map2(method_columns$renderer, function(col, renderer) renderer(col)) %>%
    #   set_names(method_columns$label) %>%
    #   as_tibble() %>%
    #   knitr::kable("html", escape = FALSE) %>%
    #   kableExtra::kable_styling("striped", full_width = TRUE) %>%
    #   kableExtra::row_spec(which(methods$selected), background = "#E1EEEE") %>%
    #   kableExtra::row_spec(0, extra_css = "font-size:0.7em")

    methods_table
  }
}



get_questions <- function(question_categories, answers) {
  ## make the sidebar questions -------------------------
  # different functions depending on the type of questions
  make_ui <- list(
    radiobuttons = function(q) {
      if (is.null(q$default)) q$default <- character()

      # default choiceNames is simply the choices
      if (is.null(names(q$choices))) {
        choiceNames <- q$choices
      } else {
        choiceNames <- names(q$choices)
      }
      choiceValues <- unname(q$choices)

      shinyWidgets::radioGroupButtons(
        inputId = q$question_id,
        label = q$title,
        selected = q$default,
        choiceNames = choiceNames,
        choiceValues = choiceValues,
        status = "default"
      )
    },
    radio = function(q) {
      if (is.null(q$default)) q$default <- character()

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
    picker = function(q) {
      shinyWidgets::pickerInput(
        inputId = q$question_id,
        label = q$title,
        choices = q$choices,
        selected = q$default,
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
        label = q$title,
        min = q$min,
        max = q$max,
        value = q$default,
        step = q$step,
        ticks = FALSE
      )
    },
    textslider = function(q) {
      shinyWidgets::sliderTextInput(
        q$question_id,
        q$title,
        q$choices,
        q$default
      )
    },
    balancing_sliders = function(q) {
      balancingSliders(
        inputId = q$question_id,
        label = q$title,
        labels = q$labels,
        inputIds = q$slider_ids,
        mins = q$mins,
        maxs = q$maxs,
        sum = q$sum,
        values = q$default,
        steps = q$steps,
        ticks = q$ticks %||% FALSE
      )
    }
  )

  # build the questions ui

  # loop over every category
  questions_ui <- map(question_categories, function(question_category) {
    category_id <- question_category[[1]]$category
    category_title <- category_id %>% label_capitalise

    computed <- all(map_lgl(question_category %>% keep(~.$active_if(answers)), "computed"))
    if(computed) {
      title <- span(
        title,
        span(
          "computed",
          class = "computed tooltippable",
          `data-toggle` = "tooltip",
          `data-placement` = "top",
          title = "Answers were computed based on information from the provided dataset"
        )
      )
    }

    category_panel <- collapsePanel(
      id = category_id,
      title = category_title,
      show_on_start = !computed,
      # class = ifelse(!is.null(question_category[[1]]$answer()), "yay", "booo"),

      map(question_category, function(question) {
        if(!question$type %in% names(make_ui)) {stop("Invalid question type")}

        question_panel <- div(
          conditionalPanel(
            question$activeIf,
            make_ui[[question$type]](question)
          ),
          class = ifelse(question$computed, "computed", "")
        )

        question_panel
      })
    )

    # observe changes in completion
    observe({
      category_sources <- question_category %>% keep(~.$active()) %>% map_chr(~.$dynamicsource())

      if (all(category_sources != "none")) {
        shinyjs::toggleClass(
          category_panel$attr$id,
          "default-category",
          all(category_sources == "default")
        )

        shinyjs::toggleClass(
          category_panel$attr$id,
          "computed-category",
          all(category_sources == "computed")
        )

        shinyjs::toggleClass(
          category_panel$attr$id,
          "completed-category",
          any(category_sources == "given")
        )
      }
    })

    category_panel
  })
}