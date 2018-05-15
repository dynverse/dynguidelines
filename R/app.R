#' Select the top methods, optionally based on a given task
#' @param task The task, optional
#' @param answers Optional, pre-provided answers to the different questions
#' @param method_columns The columns to return
#'
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






scale_01 <- function(x, lower=min(x), upper=max(x)) {
  (x - lower) / (upper - lower)
}

format_100 <- function(x) {
  round(x * 100)
}

render_score <- function(x) {
  y <- tibble(
    x = x,
    normalised = scale_01(x, lower=0),
    formatted  = format_100(x),
    background = viridisLite::magma(255)[ceiling(normalised*255)] %>% kableExtra:::html_color(),
    color = ifelse(scale_01(normalised, lower=0) > 0.5, "black", "white"),
    style = pmap(list(`background-color`=background, color=color), htmltools::css)
  )

  pmap(list(y$formatted, style=y$style, class="score"), span)
}

render_maximal_trajectory_type <- function(x) {
  map(
    x,
    ~img(src=str_glue("img/trajectory_types/{.}.svg"), class="trajectory_type")
  )
}

get_trajectory_type_renderer <- function(trajectory_type) {
  function(x) {
    map(
      x,
      function(x) {
        if(x) {
          class <- "trajectory_type"
        } else {
          class <- "trajectory_type inactive"
        }
        img(src=str_glue("img/trajectory_types/{trajectory_type}.svg"), class=class)
      }
    )
  }
}

render_selected <- function(x) {
  map(x, ~if(.) {icon("check")})
}

renderers <- tribble(
  ~column_id, ~renderer, ~label,
  "selected", render_selected, "",
  "overall_benchmark", render_score, NA,
  "maximal_trajectory_type", render_maximal_trajectory_type, "Topology",
  "trajtype_directed_linear", render_score, NA,
  "trajtype_bifurcation", render_score, NA,
  "trajtype_directed_cycle", render_score, NA,
  "trajtype_rooted_tree", render_score, NA,
  "undirected_linear", get_trajectory_type_renderer("undirected_linear"), "",
  "simple_fork", get_trajectory_type_renderer("simple_fork"), "",
  "undirected_cycle", get_trajectory_type_renderer("undirected_cycle"), "",
  "unrooted_tree", get_trajectory_type_renderer("unrooted_tree"), ""
)


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
    "<span class='text-danger'>No methods fullfilling selection</span>"
  } else {
    # render columns
    method_columns <- data$method_columns %>%
      left_join(renderers, "column_id") %>%
      mutate(renderer = map(renderer, ~ifelse(is.null(.), function(x) {x}, .)))

    methods <- data$methods %>% select(!!method_columns$column_id)
    method_columns <- method_columns %>%
      mutate(label = ifelse(is.na(label),label_capitalise(column_id), label)) %>%
      mutate(
        label = add_icons(label, lst(filter, order), list(filter=icon("filter"), order=icon("sort-amount-asc")))
      ) %>%
      arrange(!column_id %in% c("selected", "method_name"), -filter, -order)

    methods_rendered <- methods %>%
      map2(method_columns$renderer, function(col, renderer) renderer(col)) %>%
      as_tibble()

    # construct html of table
    methods_table <- tags$table(
        class = "table table-striped table-responsive",
        tags$tr(
          map(method_columns$label, tags$th)
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
        )
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