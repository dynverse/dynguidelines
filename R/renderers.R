scale_01 <- function(y, lower = min(y, na.rm = TRUE), upper = max(y, na.rm = TRUE)) {

  if (lower == upper) {
    lower <- upper - 0.1
  }

  (y - lower) / (upper - lower)
}

get_score_renderer <- function(palette = viridis::magma) {
  function(x) {
    if (any(is.na(x))) {
      # warning("Some NA values in score renderer! ", x)
    }

    y <- tibble(
      x = x,
      normalised = ifelse(is.na(x), 0, scale_01(x, lower = 0)),
      rounded = format_100(normalised),
      formatted = ifelse(is.na(x), "NA", rounded),
      width = paste0(rounded, "px"),
      background = ifelse(is.na(x), "none", palette(255)[ceiling(normalised*254)+1] %>% html_color()),
      color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "black", is.na(x) ~ "grey", TRUE ~ "white"),
      style = pmap(list(`background-color` = background, color = color, display = "block", width = width), htmltools::css)
    )

    pmap(list(y$formatted, style = y$style, class = "score"), span)
  }
}

render_detects_trajectory_type <- function(x) {
  map(
    x,
    ~img(src = str_glue("img/trajectory_types/{.}.png"), class = "trajectory_type")
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
        img(src = str_glue("img/trajectory_types/{gsub('detects_', '', trajectory_type)}.png"), class = class)
      }
    )
  }
}

render_selected <- function(x) {
  map(x, ~if(.) {icon("check")})
}

render_identity <- function(x) {x}

render_article <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = paste0("https://doi.org/", .), icon("paper-plane"))} else {""})
}

render_code <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = ., icon("code"))} else {""})
}



get_scaling_renderer <- function(formatter, palette = viridis::cividis, min, max) {
  function(x) {
    x[x < min] <- min
    x[x > max] <- max

    y <- tibble(
      x = x,
      formatted = formatter(x),
      normalised = ifelse(is.na(x), 0, scale_01(log(x))),
      rounded = format_100(normalised),
      width = paste0(rounded, "px"),
      background = ifelse(is.na(x), "none", palette(255, direction = -1)[ceiling(normalised*254)+1] %>% html_color()),
      color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "white", is.na(x) ~ "grey", TRUE ~ "black"),
      style = pmap(list(`background-color` = background, color = color, display = "block", width = width), htmltools::css)
    )

    pmap(list(y$formatted, style = y$style, class = "score"), span)
  }
}

#' Get all renderers
#'
#' @export
get_renderers <- function() {
  data(trajectory_types, package = "dynwrap", envir = environment())

  renderers <- tribble(
    ~column_id, ~renderer, ~label, ~title, ~style, ~default,
    "selected", render_selected, icon("check-circle"), "Selected methods for TI", NA, -100,
    "name", render_identity, "Method", "Name of the method", "max-width:99%", -99,
    "maximal_trajectory_type", render_detects_trajectory_type, "Topology", "The most complex topology this method can predict", NA, NA,
    "benchmark_overall", get_score_renderer(), "Benchmark score", "Overall score in the benchmark", "width:130px;", 98,
    "qc_user_friendly", get_score_renderer(viridis::viridis), "User friendliness", "User friendliness score", "width:130px;", NA,
    "doi", render_article, icon("paper-plane"), "Paper/study describing the method", NA, 99,
    "code_url", render_code, icon("code"), "Code of method", NA, 100,
    "platforms", render_identity, "Languages", "Languages", NA, NA,
    "time_prediction_mean", get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7), "Time", "Estimated running time", NA, NA,
    "memory_prediction_mean", get_scaling_renderer(format_memory, min = 1, max = 10^12), "Memory", "Estimated maximal memory usage", NA, NA
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("detects_", trajectory_type),
      renderer = map(column_id, get_trajectory_type_renderer),
      label = map(column_id, ~""),
      title = as.character(str_glue("Whether this method can predict a {label_split(trajectory_type)} topology")),
      style = NA
    ) %>%
      mutate(default = row_number() - 60)
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("benchmark_", trajectory_type),
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(str_glue("{label_capitalise(trajectory_type)} score")),
      title = as.character(str_glue("Score on datasets containing a {label_split(trajectory_type)} topology")),
      style = "width:130px;",
      default = NA
    )
  )

  renderers
}