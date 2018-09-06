scale_01 <- function(x, lower = min(x, na.rm = TRUE), upper = max(x, na.rm = TRUE)) {
  (x - lower) / (upper - lower)
}

format_100 <- function(x) {
  round(x * 100)
}

get_score_renderer <- function(palette = viridis::magma) {
  function(x) {
    if (any(is.na(x))) {
      warning("Some NA values in score renderer! ", x)
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
        img(src = str_glue("img/trajectory_types/{trajectory_type}.png"), class = class)
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

render_time <- function(x) {
  map_chr(x, function(x) {
    if(x < 60) {
      paste0(round(x), "s")
    } else if (x < (60*60)) {
      paste0(round(x/60), "m")
    } else {
      paste0(round(x/60/60), "h")
    }
  })
}

data(trajectory_types, package = "dynwrap", envir = environment())

renderers <- tribble(
  ~column_id, ~renderer, ~label, ~title, ~style, ~default,
  "selected", render_selected, icon("check-circle"), "Selected methods for TI", NA, NA,
  "name", render_identity, "Method", "Name of the method", "max-width:99%", -99,
  "maximal_trajectory_type", render_detects_trajectory_type, "Topology", "The most complex topology this method can predict", NA, NA,
  "benchmark_overall", get_score_renderer(), "Benchmark score", "Overall score in the benchmark", "width:130px;", 98,
  "qc_user_friendly", get_score_renderer(viridis::viridis), "User friendliness", "User friendliness score", "width:130px;", NA,
  "doi", render_article, icon("paper-plane"), "Paper/study describing the method", NA, 99,
  "code_url", render_code, icon("code"), "Code of method", NA, 100,
  "platforms", render_identity, "Languages", "Languages", NA, NA,
  "time_method", render_time, icon("time", lib = "glyphicon"), "Estimated running time", NA, NA
) %>% bind_rows(
  tibble(
    trajectory_type = trajectory_types$id,
    column_id = paste0("detects_", trajectory_type),
    renderer = map(column_id, get_trajectory_type_renderer),
    label = map(column_id, ~""),
    title = as.character(str_glue("Whether this method can predict a {trajectory_type} topology")),
    style = NA
  ) %>%
    mutate(default = row_number() - 60)
) %>% bind_rows(
  tibble(
    trajectory_type = trajectory_types$id,
    column_id = paste0("benchmark_", trajectory_type),
    renderer = map(column_id, ~get_score_renderer()),
    label = as.list(str_glue("{label_capitalise(trajectory_type)} score")),
    title = as.character(str_glue("Score on datasets containing a {trajectory_type} topology")),
    style = "width:130px;",
    default = NA
  )
)

#' Get all renderers
#'
#' @export
get_renderers <- function() {
  renderers
}