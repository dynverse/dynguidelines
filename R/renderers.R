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
      `background-color` = ifelse(is.na(x), "none", palette(255)[ceiling(normalised*254)+1] %>% html_color()),
      color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "black", is.na(x) ~ "grey", TRUE ~ "white"),
      `text-shadow` = case_when(color == "white" ~ "-1px 0 black, 0 1px black, 1px 0 black, 0 -1px black", TRUE ~ "none"),
      style = pmap(lst(`background-color`, color, display = "block", width, `text-shadow`), htmltools::css)
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
    ~column_id, ~category, ~renderer, ~label, ~title, ~style, ~default, ~name,
    "selected", "basic", render_selected, icon("check-circle"), "Selected methods for TI", NA, -100, NA,
    "name", "basic", render_identity, "Method", "Name of the method", "max-width:99%", -99, NA,
    "most_complex_trajectory_type", "method", render_detects_trajectory_type, "Topology", "The most complex topology this method can predict", NA, -98, NA,
    "benchmark_overall", "benchmark", get_score_renderer(), "Benchmark score", "Overall score in the benchmark", "width:130px;", 98, NA,
    "doi", "method", render_article, icon("paper-plane"), "Paper/study describing the method", NA, 99, "paper",
    "code_url", "method", render_code, icon("code"), "Code of method", NA, 100, "code",
    "platform", "method", render_identity, "Language", "Language", NA, NA, NA,
    "time_prediction_mean", "scaling", get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7), "Time", "Estimated running time", NA, NA, NA,
    "memory_prediction_mean", "scaling", get_scaling_renderer(format_memory, min = 1, max = 10^12), "Memory", "Estimated maximal memory usage", NA, NA, NA
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("detects_", trajectory_type),
      category = "method",
      renderer = map(column_id, get_trajectory_type_renderer),
      label = map(column_id, ~""),
      name = paste0("Detects ", trajectory_type),
      title = as.character(str_glue("Whether this method can predict a {label_split(trajectory_type)} topology")),
      style = NA,
      default = NA
    )
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("benchmark_", trajectory_type),
      category = "benchmark",
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(str_glue("{label_capitalise(trajectory_type)} score")),
      name = NA,
      title = as.character(str_glue("Score on datasets containing a {label_split(trajectory_type)} topology")),
      style = "width:130px;",
      default = NA
    )
  ) %>% bind_rows(
    tibble(
      column_id = methods_aggr %>% select(starts_with("qc_")) %>% select_if(is.numeric) %>% colnames(),
      category = "qc",
      renderer = map(column_id, ~get_score_renderer(viridis::viridis)),
      label = as.list(label_capitalise(column_id)),
      name = NA,
      title = as.character(label),
      style = "width:130px;",
      default = NA
    )
  )

  renderers
}




#' Get column presets
#'
#' @export
get_column_presets <- function() {
  list(
    list(
      id = "intelligent",
      label = "Intelligent",
      activate = function(show_columns) {
        show_columns[names(show_columns)] <- "indeterminate"
        show_columns
      }
    ),
    list(
      id = "method",
      label = "Method characteristics",
      activate = activate_column_preset_category("method")
    ),
    list(
      id = "benchmark",
      label = "Benchmark",
      activate = activate_column_preset_category("benchmark")
    ),
    list(
      id = "scaling",
      label = "Scaling",
      activate = activate_column_preset_category("scaling")
    ),
    list(
      id = "qc",
      label = "Quality control",
      activate = activate_column_preset_category("qc")
    ),
    list(
      id = "everything",
      label = "Everything",
      activate = function(show_columns) {
        show_columns[names(show_columns)] <- "true"
        show_columns
      }
    )
  )
}



activate_column_preset_category <- function(category) {
  function(show_columns) {
    show_columns[names(show_columns)] <- "false"
    columns_oi <- get_renderers() %>% filter(category == !!category) %>% pull(column_id) %>% paste0("column_", .)
    columns_oi <- c("column_name", columns_oi)
    show_columns[columns_oi] <- "true"
    show_columns
  }
}