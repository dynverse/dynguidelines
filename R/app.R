#' Select the top methods, optionally based on a given task
#' @param task The task, optional
#' @param answers Optional, pre-provided answers to the different questions
#' @param method_columns The columns to return
#'
#' @export
guidelines_shiny <- function(task=NULL, answers=NULL) {
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
  kableExtra::cell_spec(
    format_100(x),
    background=kableExtra::spec_color(scale_01(x, lower=0), scale_from = c(0,1), option="A"),
    color=ifelse(scale_01(x, lower=0) > 0.5, "black", "white"),
    "html",
    escape=F
  )
}

renderers <- tribble(
  ~column_id, ~renderer,
  "selected", function(x) {
    kableExtra::cell_spec(
      ifelse(x, "<input type='checkbox' checked disabled>", "<input type='checkbox' disabled>"), "html", escape=F
    )
  },
  "overall_benchmark", render_score,
  "trajtype_directed_linear", render_score,
  "trajtype_bifurcation", render_score,
  "trajtype_directed_cycle", render_score,
  "trajtype_rooted_tree", render_score
)

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
    method_columns <- method_columns  %>%
      mutate(label = column_id %>% gsub("_", " ", .) %>% Hmisc::capitalize())

    methods_table <- methods %>%
      map2(method_columns$renderer, function(col, renderer) renderer(col)) %>%
      set_names(method_columns$label) %>%
      as_tibble() %>%
      knitr::kable("html", escape=FALSE) %>%
      kableExtra::kable_styling("striped", full_width = TRUE) %>%
      kableExtra::row_spec(which(methods$selected), background = "#DDDDDD") %>%
      kableExtra::row_spec(0, extra_css = "font-size:0.7em")

    methods_table
  }
}