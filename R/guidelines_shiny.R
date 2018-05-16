#' @rdname guidelines
#' @export
guidelines_shiny <- function(task=NULL, answers=list()) {
  if (!is.null(task)) {
    answers <- answers_task(task, answers)
  }

  # trick from https://stackoverflow.com/questions/44999615/passing-parameters-into-shiny-server
  # this looks ugly though, but seems to me the most acceptable way to get variables into the shiny server
  file_path <- system.file("app/ui.R", package = "dynguidelines")
  source(file_path, local = TRUE)
  file_path <- system.file("app/server.R", package = "dynguidelines")
  source(file_path, local = TRUE)
  server_env <- environment(server)

  server_env$task <- task

  app <- shiny::shinyApp(
    ui(answers),
    server
  )
  shiny::runApp(app)
}


add_icons <- function(label, conditions, icons) {
  pmap(c(list(label=label), conditions), function(label, ...) {
    icons <- list(...) %>%
      keep(~!is.na(.) && .) %>%
      names() %>%
      {icons[.]}

    span(c(list(label), icons))
  })
}

get_guidelines_methods_table <- function(task = NULL, answers = list()) {
  data <- guidelines(task, answers)

  if(nrow(data$methods) == 0) {
    span(class="text-danger", "No methods fullfilling selection")
  } else {
    # remove duplicate columns
    method_columns <- data$method_columns %>%
      group_by(column_id) %>%
      filter(row_number() == n()) %>%
      ungroup()

    # add renderers
    data("renderers", envir=environment())
    method_columns <- method_columns %>%
      left_join(renderers, "column_id") %>%
      mutate(renderer = map(renderer, ~ifelse(is.null(.), function(x) {x}, .)))

    # add labels
    method_columns <- method_columns %>%
      mutate(
        label = add_icons(label, lst(filter, order), list(filter=icon("filter"), order=icon("sort-amount-asc")))
      )

    # order columns
    method_columns <- method_columns %>%
      mutate(order = case_when(!is.na(default)~default, filter~1, order~2, TRUE~3)) %>%
      arrange(order)

    # extract correct columns from data
    methods <- data$methods %>% select(!!method_columns$column_id)

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
              `data-toggle`="tooltip",
              `data-placement`="top",
              title=title,
              style=paste0("vertical-align:bottom;", ifelse(is.na(style), "width:20px;", style))
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
              map(row_rendered, .f=tags$td)
            )
          }
        ),
        tags$script('activeTooltips()')
      )

    # methods_table <- methods %>%
    #   map2(method_columns$renderer, function(col, renderer) renderer(col)) %>%
    #   set_names(method_columns$label) %>%
    #   as_tibble() %>%
    #   knitr::kable("html", escape=FALSE) %>%
    #   kableExtra::kable_styling("striped", full_width = TRUE) %>%
    #   kableExtra::row_spec(which(methods$selected), background = "#E1EEEE") %>%
    #   kableExtra::row_spec(0, extra_css = "font-size:0.7em")

    methods_table
  }
}