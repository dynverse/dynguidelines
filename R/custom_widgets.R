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



balancingSliders <- function(
  inputId,
  label,
  labels,
  inputIds,
  mins,
  maxs,
  sum,
  values,
  steps,
  tooltips = TRUE,
  ticks = FALSE
) {
  tags$div(
    class = "form-group shiny-input-container balancing-sliders",
    id = inputId,
    # singleton(tags$head(includeScript(system.file("js/balancing-sliders.js", package = "dynguidelines")))),
    tags$label(
      class = "control-label",
      `for` = inputId,
      label
    ),
    pmap(
      lst(
        label = labels,
        inputId = inputIds,
        min = mins,
        max = maxs,
        value = values,
        step = steps,
        ticks = ticks
      ),
      shiny::sliderInput
    )
  )
}