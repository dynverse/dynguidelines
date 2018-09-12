#' Shiny user interface
#'
#' @export
shiny_ui <- function() {
  # add path of images
  addResourcePath("img", system.file("img/", package = "dynguidelines"))

  ## build the page ----------------------------
  fluidPage(
    title = "Selecting the most optimal TI method - dynguidelines",
    shinyjs::useShinyjs(),
    tags$head(tags$script(src = "https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/tooltips.js", package = "dynguidelines"))),
    tags$head(includeScript(system.file("js/google-analytics.js", package = "dynguidelines"))),

    tags$head(tags$script(src = "https://cdn.jsdelivr.net/combine/npm/lodash@4.17.10,npm/intro.js@2.9.3")),

    tags$head(tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/intro.js@2.9.3/introjs.min.css")),

    tags$head(includeCSS(system.file("css/style.css", package = "dynguidelines"))),

    tags$head(tags$link(rel = "icon", type = "image/png", href = "img/favicon_16.png")),

    # navbar
    tags$nav(
      class = "navbar navbar-default navbar-fixed-top",
      div(
        class = "container-fluid",
        div(
          class = "navbar-header",
          tags$a(
            class = "",
            href = "#",
            img(src = "img/logo_horizontal.png")
          )
        ),

        div(
          class = "navbar-collapse collapse",
          tags$ul(
            class = "nav navbar-nav navbar-left",
            # tutorial
            tags$li(
              class = "nav-highlight",
              tags$a(
                "Tutorial",
                icon("question-circle"),
                href = "#intro",
                onclick="javascript:introJs().setOption('showBullets', false).setOption('scrollToElement', false).start();"
              )
            ),

            # citation
            tags$li(
              class = "nav-highlight",
              actionLink(
                "show_citation",
                tagList("Citation ", icon("quote-right"))
              )
            )
          ),
          tags$ul(
            class = "nav navbar-nav navbar-right",

            # benchmarking study
            tags$li(
              tags$a(
                "Benchmark study ",
                icon("paper-plane"),
                href = "https://doi.org/10.1101/276907",
                target = "blank"
              )
            ),

            # benchmarking repo
            tags$li(
              tags$a(
                HTML("<em>dyn</em>benchmark "),
                icon("github"),
                href = "https://github.com/dynverse/dynbenchmark",
                target = "blank"
              )
            ),

            # dyno repo
            tags$li(
              tags$a(
                HTML("<em>dyn</em>o "),
                icon("github"),
                href = "https://github.com/dynverse/dyno",
                target = "blank"
              )
            ),

            tags$li(
              a(
                style = "display: inline;",
                href = "https://github.com/dynverse/dynverse",
                target = "blank",
                "Part of",
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
      style = "position:relative; width:100%; top:80px;",
      div(
        div(
          style = "width:30%",
          div(
            style = "overflow-y:scroll; position:fixed; bottom:0px; top:80px; width:inherit; padding-right: 10px;background-color:white;z-index:1;",
            uiOutput("questions_panel"),
            `data-intro` = "The choice of methods is different for every analysis. These questions guide you through method selection by polling the prior information on the trajectory, the size of the data and the work environment.",
            `data-step` = 1
          )
        ),
        div(
          style = "width:70%;float:right;padding-left:20px;",

          # top buttons
          div(
            class = "btn-group btn-group-justified",
            # code toggle
            tags$a(
              class = "btn btn-default",
              style = "",
              "Show code ",
              icon("code"),
              href = "#toggle-code",
              `data-target` = "#code",
              `data-toggle` = "collapse",
              `data-intro` = "You can get the code necessary to reproduce the guidelines here. Copy it over to your script!",
              `data-step` = 3
            ),

            # columns toggle
            tags$a(
              class = "btn btn-default",
              style = "",
              "Show/hide columns ",
              icon("columns"),
              href = "#toggle-columns",
              `data-target` = "#columns",
              `data-toggle` = "collapse",
              `data-intro` = "Here, you can change the columns displayed in the main table. It allows you to focus on particular aspects of the benchmarking, such as scalability, benchmarking metrics, and quality control.",
              `data-step` = 4
            ),

            # columns toggle
            tags$a(
              class = "btn btn-default",
              style = "",
              "Options ",
              icon("gear"),
              href = "#toggle-options",
              `data-target` = "#options",
              `data-toggle` = "collapse"
            ),

            if (interactive()) {
              # submit button
              actionLink(
                class = "btn",
                "submit",
                label = span(
                  icon("chevron-circle-right", class = "arrow4"),
                  " Close & use ",
                  icon("chevron-circle-right", class = "arrow4")
                ),
                style = "color: white;font-weight: bold; background-color:#9362e0",
                `data-step` = 5,
                `data-intro` = "When ready, click this button to return the selected set of methods in R.",
                onclick = "window.close();"
              )
            } else {
              ""
            }
          ),



          # columns collapsible
          tags$div(
            class = "panel-collapse collapse",
            id = "columns",

            tags$div(
              # presets buttons
              tags$div(
                uiOutput("column_presets")
              ),

              # individual checkboxes
              tags$div(
                class = "indeterminate-checkbox-group",
                uiOutput("column_show_hide")
              )
            )
          ),

          # code collapible
          tags$div(
            class = "panel-collapse collapse",
            id = "code",

            # copy button
            singleton(tags$head(tags$script(src = "https://cdn.jsdelivr.net/npm/clipboard@2/dist/clipboard.min.js"))),
            tags$button(
              class = "btn btn-default btn-s btn-copy",
              style = "float:left",
              icon("copy"),
              `data-clipboard-target`="#code"
            ),
            tags$script("$(document).ready(function() {new ClipboardJS('.btn-copy')});"),

            # actual code
            textOutput("code", container = tags$pre)
          ),

          # options
          tags$div(
            class = "panel-collapse collapse",
            id = "options",

            # actual code
            uiOutput("options")
          ),

          # method table
          div(
            `data-intro` = "The relevant methods are displayed here, along with information on how they were ordered and selected.",
            uiOutput("methods_table")
          )
        )
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

get_guidelines_methods_table <- function(guidelines, show_columns = character(), options = list()) {
  testthat::expect_true(length(names(show_columns)) == length(show_columns))

  if(nrow(guidelines$methods_aggr) == 0) {
    span(class = "text-danger", "No methods fullfilling selection")
  } else {
    # remove duplicate columns
    method_columns <- guidelines$method_columns %>%
      group_by(column_id) %>%
      slice(n()) %>%
      ungroup()

    # add or remove columns based on `show_columns`
    if (is.null(show_columns)) {show_columns <- character()}
    names(show_columns) <- gsub("^column_(.*)", "\\1", names(show_columns))
    method_columns <- method_columns %>%
      filter(
        isTRUE(show_columns[method_columns$column_id]) |
        show_columns[method_columns$column_id] %in% c("true", "indeterminate") |
        is.na(show_columns[method_columns$column_id])
      ) %>%
      bind_rows(
        tibble(
          column_id = names(show_columns[show_columns == "true" | isTRUE(show_columns)]) %>% as.character() %>% setdiff(method_columns$column_id)
        )
      )

    # add renderers
    method_columns <- method_columns %>%
      left_join(get_renderers(), c("column_id" = "column_id")) %>%
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
    methods <- guidelines$methods_aggr %>% select(!!method_columns$column_id)

    if (ncol(methods) == 0) {
      span(class = "text-danger", "No columns selected")
    } else {
      # render columns
      methods_rendered <- methods %>%
        map2(method_columns$renderer, function(col, renderer) {
          if ("options" %in% names(formals(renderer))) {
            renderer(col, options)
          } else {
            renderer(col)
          }
        }) %>%
        as_tibble()

      # construct html of table
      methods_table <- tags$table(
        class = "table table-responsive",
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
            if ("selected" %in% names(row) && row$selected) {
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
}


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




get_columns_presets_ui <- function(column_presets, session, show_columns) {
  tags$div(
    class = "btn-group",
    tags$label("Presets: ", style = "float:left;"),
    map(column_presets, function(column_preset) {
      # observe button event, and change the show columns accordingly
      button_id <- paste0("column_preset_", column_preset$id)
      observeEvent(session$input[[button_id]], {
        # change the columns checkboxes
        new_show_columns <- column_preset$activate(show_columns())
        changed_show_columns <- new_show_columns[new_show_columns != show_columns()]

        walk2(names(changed_show_columns), changed_show_columns, function(column_id, value) {
          updateIndeterminateCheckboxInput(session, column_id, value)
        })
      })

      actionButton(
        button_id,
        label = column_preset$label
      )
    })
  )
}


get_columns_show_hide_ui <- function(renderers) {
  tags$ul(
    class = "list-group",
    style = "position:static;",
    tidyr::nest(renderers, -category, .key = "renderers") %>%
      pmap(function(category, renderers) {
        tags$li(
          class = "list-group-item",
          tags$em(label_capitalise(category)),
          pmap(renderers, function(column_id, label, name, ...) {
            # use label by default, unless name is not na
            if (!is.na(name)) {
              label <- name
            }
            indeterminateCheckbox(
              paste0("column_", column_id),
              label,
              "indeterminate"
            )
          }) %>% tags$div()
        )
      })
  )
}




# get the modal to display the citations
get_citations_modal <- function() {
  showModal(modalDialog(
    title = tagList("If ", HTML("<em>dyn</em>guidelines was helpful to you, please cite: ")),

    tags$div(
      style = "float:right;",

      singleton(tags$head(tags$script(type = "text/javascript", src = "https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"))),
      tags$div(
        class = "altmetric-embed",
        `data-badge-type` = "medium-donut",
        `data-doi` = "10.1101/276907"
      ),
      tags$script("if (typeof _altmetric_embed_init !== 'undefined') {_altmetric_embed_init()};"),

      singleton(tags$head(tags$script(type = "text/javascript",src = "https://badge.dimensions.ai/badge.js"))),
      tags$div(
        class = "__dimensions_badge_embed__",
        `data-doi` = "10.1101/276907"
      ),
      tags$script("if (typeof __dimensions_embed !== 'undefined') {__dimensions_embed.addBadges()};")
    ),



    tags$a(
      href = "http://dx.doi.org/10.1101/276907",
      tags$blockquote(HTML(paste0("<p>", glue::glue_collapse(sample(c("Wouter Saelens*", "Robrecht Cannoodt*")), ", "), ", Helena Todorov, and Yvan Saeys. </p><p> \U201C A Comparison of Single-Cell Trajectory Inference Methods: Towards More Accurate and Robust Tools.\U201D </p><p> BioRxiv, March 5, 2018, 276907. </p> <p> https://doi.org/10.1101/276907 </p>"))),
      target = "blank"
    ),

    tags$div(
      style = "font-size: 17.5px;",
      "... or give us a shout-out on twitter (", tags$a(href = "https://twitter.com/saeyslab", "@saeyslab", target = "blank"), "). We'd love to hear your feedback!"
    ),

    style = "overflow:visible;",

    easyClose = TRUE,
    size = "l",
    footer = NULL
  ))
}





get_options_ui <- function() {
  tagList(
     shinyWidgets::radioGroupButtons(
       "score_visualisation",
       "How to show the scores",
       choices = c(Circles = "circle", Bars = "bar"),
       selected = "bar"
     )
  )
}