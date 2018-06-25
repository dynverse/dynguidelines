collapsePanel <- function(..., title = "", show_on_start = FALSE, id = "") {
  collapse_id <- paste0("collapse", sample(1:100000000, 1))
  div(
    class = "panel panel-default",
    div(
      class = "panel-heading",
      `data-target` = paste0("#", collapse_id),
      `data-toggle` = "collapse",
      span(icon("caret-down"), title)
    ),
    div(
      id = collapse_id,
      class = paste0("panel-collapse collapse", ifelse(show_on_start, " in", "")),
      div(
        ...
      )
    ),
    id = id
  )
}