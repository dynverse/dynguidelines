scale_01 <- function(x, lower = min(x), upper = max(x)) {
  (x - lower) / (upper - lower)
}

format_100 <- function(x) {
  round(x * 100)
}

get_score_renderer <- function(palette = viridis::magma) {
  function(x) {
    if (any(is.na(x))) {
      warning("Some NA values in score renderer! ", x)
      x[is.na(x)] <- 0.00000000000001
      # browser()
    }

    y <- tibble(
      x = x,
      normalised = scale_01(x, lower = 0),
      rounded = format_100(x),
      formatted = rounded,
      width = paste0(rounded, "px"),
      background = palette(255)[ceiling(normalised*255)] %>% html_color(),
      color = ifelse(scale_01(normalised, lower = 0) > 0.5, "black", "white"),
      style = pmap(list(`background-color` = background, color = color, display = "block", width = width), htmltools::css)
    )

    pmap(list(y$formatted, style = y$style, class = "score"), span)
  }
}

render_maximal_trajectory_type <- function(x) {
  map(
    x,
    ~img(src = str_glue("img/trajectory_types/{.}.svg"), class = "trajectory_type")
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
        img(src = str_glue("img/trajectory_types/{trajectory_type}.svg"), class = class)
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
  "selected", render_selected, icon("check-circle"), "Selected methods for TI", NA, -100,
  "method_name", render_identity, "Method", "Name of the method", "max-width:99%", -99,
  "maximal_trajectory_type", render_maximal_trajectory_type, "Topology", "The most complex topology this method can predict", NA, NA,
  "overall_benchmark", get_score_renderer(), "Overall score", "Overall score in the benchmark", "width:130px;", 98,
  "user_friendly", get_score_renderer(viridis::viridis), "User friendliness", "User friendliness score", "width:130px;", NA,
  "DOI", render_article, icon("paper-plane"), "Paper/study describing the method", NA, 99,
  "code_location", render_code, icon("code"), "Code of method", NA, 100,
  "platforms", render_identity, "Languages", "Languages", NA, NA,
  "time_method", render_time, icon("time", lib = "glyphicon"), "Estimated running time", NA, NA
) %>% bind_rows(
  tibble(
    column_id = trajectory_types$id,
    undirected = !trajectory_types$directed,
    simplified = trajectory_types$simplified,
    renderer = map(column_id, get_trajectory_type_renderer),
    label = map(column_id, ~""),
    title = as.character(str_glue("Whether this method can predict a {label_split(simplified)} topology")),
    style = NA
  ) %>%
    mutate(default = ifelse(undirected, row_number() - 60, NA))
) %>% bind_rows(
  tibble(
    trajtype = trajectory_types$id,
    simplified = trajectory_types$simplified,
    column_id = paste0("trajtype_", trajtype),
    renderer = map(column_id, ~get_score_renderer()),
    label = as.list(str_glue("{label_capitalise(trajtype)} score")),
    title = as.character(str_glue("Score on datasets containing a {label_split(simplified)} topology")),
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