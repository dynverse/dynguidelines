#' Shiny user interface
#'
#' @export
shiny_ui <- function() {
  ## build the page ----------------------------
  fluidPage(
    shinyjs::useShinyjs(),
    tags$head(includeScript("https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/google-analytics.js", package = "dynguidelines"))),
    tags$head(includeScript(system.file("js/tooltips.js", package = "dynguidelines"))),

    tags$head(includeScript("https://cdn.jsdelivr.net/npm/lodash@4.17.10/lodash.min.js")),

    tags$head(includeCSS(system.file("css/style.css", package = "dynguidelines"))),

    title = "Selecting the most optimal TI methods - dynguidelines",

    # navbar
    tags$nav(
      class = "navbar navbar-default",
      div(
        class = "container-fluid",
        div(
          class = "navbar-header",
          tags$a(
            class = "",
            href = "#",
            img(src = "man_img/logo_horizontal.png")
          )
        ),
        div(
          class = "navbar-collapse collapse",
          tags$ul(
            class = "nav navbar-nav",
            tags$li(
              class = "active",
              tags$a(
                `data-toggle` = "tab",
                href = "#tab-methods",
                "Select the optimal methods"
              )
            ),
            tags$li(
              tags$a(
                `data-toggle` = "tab",
                href = "#tab-info",
                "Information"
                )
              )
          ),
          tags$ul(
            class = "nav navbar-nav navbar-right",
            tags$li(
              "Part of",
              a(
                style = "display: inline;",
                href = "https://github.com/dynverse/dynverse",
                img(
                  src = "img/logo_dynverse.png"
                )
              )
            )
          )
        )
      )
    ),


    div(
      class = "tab-content",
      div(
        id = "tab-methods",
        class = "tab-pane active",
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
              span(icon("chevron-circle-right"), " Ready ",  icon("chevron-circle-right")),
              class = "btn-primary",
              width = "100%"
            ),
            div(
              uiOutput("methods_table")
            )
          )
        )
      ),


      div(
        id = "tab-info",
        class = "tab-pane",
        "Dynguidelines allows you to select the most optimal trajectory inference (TI) methods given a particular dataset and user provided information."
      )
    )
  )
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

    methods_table
  }
}


# Functions to create each type of input
input_functions <- list(
  radiobuttons = function(q) {
    if (is.null(q$default)) q$default <- character()

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
      selected = as.character(q$default),
      choiceNames = choiceNames,
      choiceValues = choiceValues,
      status = "default"
    )
  },
  radio = function(q) {
    if (is.null(q$default)) q$default <- character()

    radioButtons(
      q$question_id,
      q$label,
      q$choices,
      q$default
    )
  },
  checkbox = function(q) {
    checkboxGroupInput(
      q$question_id,
      q$label,
      q$choices,
      q$default
    )
  },
  picker = function(q) {
    shinyWidgets::pickerInput(
      inputId = q$question_id,
      label = q$label,
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
      label = q$label,
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
      q$label,
      q$choices,
      q$default
    )
  },
  balancing_sliders = function(q) {
    balancingSliders(
      inputId = q$question_id,
      label = q$label,
      labels = q$labels,
      ids = q$ids,
      values = q$default,
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
      value = q$default,
      min = 0
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
    show_on_start <- question_category %>%
      map_chr("default_source") %>%
      {!all(. %in% c("computed"))}

    # create the panel of the category
    category_panel <- collapsePanel(
      id = category_id,
      header = category_header,
      show_on_start = show_on_start,
      map(question_category, function(question) {
        if(!question$type %in% names(input_functions)) {stop("Invalid question type")}

        # if this question has a label and title, add the collapsible help information
        if (!is.null(question$label) && !is.null(question$title)) {
          question$label <-
            tags$span(
              class = "tooltippable",
              title = question$title,
              question$label,
              `data-toggle` = "tooltip",
              `data-placement` = "right"
            )
        }

        question_panel <- div(
          conditionalPanel(
            question$activeIf,
            input_functions[[question$type]](question)
          ),
          class = ifelse(question$computed, "computed", "")
        )

        question_panel
      })
    )
#
#     # observe changes in completion
    observe({
      category_sources <- question_category %>% keep(~.$active()) %>% map_chr(~.$source())

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
          any(category_sources == "adapted")
        )
      }
    })

    category_panel
  })
}