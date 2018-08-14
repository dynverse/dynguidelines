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
  sliders,
  tooltips = TRUE,
  ticks = FALSE
) {


  sliderTags <- lmap(sliders, function(slider) {
    sliderProprs <- shiny:::dropNulls(list(
      class = "js-range-slider",
      id = slider$inputId,
      `data-type` = "double",
      `data-min` = slider$min,
      `data-max` = slider$max,
      `data-from` = slider$value,
      `data-step` = slider$step,
      `data-grid` = slider$ticks
    ))

    sliderTag <- div(
      class = "form-group shiny-input-container",
      style = paste0("width: 100%;"),
      if (!is.null(label)) controlLabel(inputId, label),
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
      function(label, inputId, min, max, value, step, ticks) {
        sliderTag <- div(
          class = "form-group shiny-input-container",
          style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
          if (!is.null(label)) controlLabel(inputId, label),
          do.call(tags$input, sliderProps)
        )


        list(shiny::sliderInput(...))

      }
    )
  )
}