scale_01 <- function(y, lower = min(y, na.rm = TRUE), upper = max(y, na.rm = TRUE)) {

  if (lower == upper) {
    lower <- upper - 0.1
  }

  (y - lower) / (upper - lower)
}

get_score_renderer <- function(palette = viridis::magma) {
  function(x, options) {
    if (any(is.na(x))) {
      # warning("Some NA values in score renderer! ", x)
    }

    style <- ifelse(is.null(options$score_visualisation), "bar", options$score_visualisation)
    if (style == "bar") {
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
    } else if (style == "circle") {
      y <- tibble(
        x = x,
        normalised = ifelse(is.na(x), 0, scale_01(x, lower = 0)),
        rounded = format_100(normalised),
        formatted = ifelse(is.na(x), "NA", rounded),
        width = paste0(rounded/3, "px"),
        `line-height` = paste0(rounded/3, "px"),
        `background-color` = ifelse(is.na(x), "none", palette(255)[ceiling(normalised*254)+1] %>% html_color()),
        color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "black", is.na(x) ~ "grey", TRUE ~ "white"),
        `text-shadow` = case_when(color == "white" ~ "-1px 0 black, 0 1px black, 1px 0 black, 0 -1px black", TRUE ~ "none"),
        style = pmap(lst(`background-color`, color, display = "block", width, `text-shadow`, `line-height`, `border-radius` = "50%", `text-align` = "center"), htmltools::css)
      )
    }

    pmap(list(y$formatted, style = y$style, class = "score"), span)
  }
}

render_detects_trajectory_type <- function(x) {
  map(
    x,
    function(trajectory_type) {
      if (is.na(trajectory_type)) {
        NA
      } else {
        img(src = str_glue("img/trajectory_types/{trajectory_type}.png"), class = "trajectory_type")
      }
    }
  )
}

get_trajectory_type_renderer <- function(trajectory_type) {
  if (is.na(trajectory_type)) {
    function(x) {NA}
  } else {
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
}

render_selected <- function(x) {
  map(x, ~if(.) {icon("check")})
}

render_identity <- function(x) {x}

render_article <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = paste0("https://doi.org/", ., target = "blank"), icon("paper-plane"))} else {""})
}

render_code <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = ., icon("code"))} else {""})
}



get_scaling_renderer <- function(formatter, palette = viridis::cividis, min, max, log = FALSE) {
  function(x) {
    if (log) {
      x <- exp(x)
    }

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

time_renderer <- get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7, log = FALSE)
memory_renderer <- get_scaling_renderer(format_memory, min = 1, max = 10^12, log = FALSE)
time_renderer_log <- get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7, log = TRUE)
memory_renderer_log <- get_scaling_renderer(format_memory, min = 1, max = 10^12, log = TRUE)

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
    "time_prediction_mean", "scaling", time_renderer, "Estimated time", "Estimated running time", NA, NA, NA,
    "memory_prediction_mean", "scaling", memory_renderer, "Estimated memory", "Estimated maximal memory usage", NA, NA, NA
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
      category = "benchmark_trajectory_types",
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(str_glue("{label_capitalise(trajectory_type)} score")),
      name = NA,
      title = as.character(str_glue("Score on datasets containing a {label_split(trajectory_type)} topology")),
      style = "width:130px;",
      default = NA
    ) %>% select(-trajectory_type)
  ) %>% bind_rows(
    tibble(
      metric_id = benchmark_metrics$metric_id,
      column_id = paste0("benchmark_", metric_id),
      category = "benchmark_metrics",
      renderer = map(column_id, ~get_score_renderer()),
      label = map(benchmark_metrics$html, HTML),
      name = NA,
      title = benchmark_metrics$html,
      style = "width:130px;",
      default = NA
    ) %>% select(-metric_id)
  ) %>% bind_rows(
    tibble(
      dataset_source = unique(benchmark_datasets_info$source),
      column_id = paste0("benchmark_", dataset_source),
      category = "benchmark_dataset_sources",
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(dataset_source),
      name = NA,
      title = dataset_source,
      style = "width:130px;",
      default = NA
    ) %>% select(-dataset_source)
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
    ) %>% bind_rows(
      tibble(
        column_id = methods_aggr %>% select(starts_with("scaling")) %>% select_if(is.numeric) %>% colnames(),
        scaling_type = gsub("scaling_([^_]*)_.*", "\\1", column_id),
        category = "scaling",
        renderer = list(mem = memory_renderer_log, time = time_renderer_log)[scaling_type],
        label = as.list(column_id),
        name = NA,
        title = as.character(label),
        style = "width:130px",
        default = NA
      )
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
      id = "everything",
      label = "Everything",
      activate = function(show_columns) {
        show_columns[names(show_columns)] <- "true"
        show_columns
      }
    )
  ) %>%
    c(map(unique(get_renderers()$category), function(category) {
      list(
        id = category,
        label = label_capitalise(category),
        activate = activate_column_preset_category(category)
      )
    })
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