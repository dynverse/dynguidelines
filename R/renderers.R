scale_01 <- function(x, lower=min(x), upper=max(x)) {
  (x - lower) / (upper - lower)
}

format_100 <- function(x) {
  round(x * 100)
}

get_score_renderer <- function(palette = viridis::magma) {
  function(x) {
    y <- tibble(
      x = x,
      normalised = scale_01(x, lower=0),
      rounded = format_100(x),
      formatted = rounded,
      width = paste0(rounded, "px"),
      background = palette(255)[ceiling(normalised*255)] %>% kableExtra:::html_color(),
      color = ifelse(scale_01(normalised, lower=0) > 0.5, "black", "white"),
      style = pmap(list(`background-color`=background, color=color, display="block", width=width), htmltools::css)
    )

    pmap(list(y$formatted, style=y$style, class="score"), span)
  }
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

render_identity <- function(x) {x}

render_article <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href=paste0("https://doi.org/", .), icon("paper-plane"))} else {""})
}

render_code <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href=., icon("code"))} else {""})
}