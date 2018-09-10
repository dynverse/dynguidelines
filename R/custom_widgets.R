collapsePanel <- function(..., header = "", show_on_start = FALSE, id = "") {
  collapse_id <- paste0("collapse", sample(1:100000000, 1))
  div(
    class = "panel panel-default",
    div(
      class = "panel-heading",
      `data-target` = paste0("#", collapse_id),
      `data-toggle` = "collapse",
      span(icon("caret-down"), header)
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
  ids,
  values,
  min = 0,
  max = 1,
  sum = 1,
  step = 0.01,
  tooltips = TRUE,
  ticks = FALSE
) {
  sliderTags <- pmap(lst(label = labels, id = ids, value = values), function(label, id, value) {
    sliderProps <- shiny:::dropNulls(list(
      id = id,
      class = "js-range-slider",
      `data-type` = "single",
      `data-from` = value,
      `data-min` = min,
      `data-max` = max,
      `data-step` = step,
      `data-grid` = ticks
    ))

    sliderTag <- div(
      class = "form-group shiny-input-container",
      style = paste0("width: 100%;"),
      `data-sum` = 1,
      tags$button(id = id, class = "lock btn btn-xs", icon("lock")),
      tags$label(shiny::HTML(label)),
      do.call(tags$input, sliderProps)
    )
  })

  tags$div(
    class = "form-group shiny-input-container balancing-sliders",
    id = inputId,
    singleton(tags$head(includeScript(system.file("js/balancing-sliders.js", package = "dynguidelines")))),
    singleton(tags$head(includeCSS(system.file("css/balancing-sliders.css", package = "dynguidelines")))),
    tags$label(
      class = "control-label",
      `for` = inputId,
      label
    ),
    sliderTags
  )
}