get_columns_presets_ui <- function(column_presets, session, show_columns) {
  tags$div(
    class = "btn-group",
    tags$label("Lenses ", style = "float:left;line-height: 38px;font-size: 14px;margin-right: 5px;"),
    map(column_presets, function(column_preset) {
      # observe button event, and change the show columns accordingly
      button_id <- paste0("column_preset_", column_preset$id)
      observeEvent(session$input[[button_id]], {
        # change the columns checkboxes
        new_show_columns <- column_preset$activate(show_columns())
        changed_show_columns <- new_show_columns[new_show_columns != show_columns()[names(new_show_columns)]]

        walk2(names(changed_show_columns), changed_show_columns, function(column_id, value) {
          updateIndeterminateCheckboxInput(session, column_id, value)
        })
      })

      actionButton(
        button_id,
        label = column_preset$label
      )
    })
  )
}


get_columns_show_hide_ui <- function(renderers) {
  tags$ul(
    class = "list-group",
    style = "position:static;",
    tidyr::nest(renderers, -category, .key = "renderers") %>%
      pmap(function(category, renderers) {
        tags$li(
          class = "list-group-item",
          tags$em(label_capitalise(category)),
          pmap(renderers, function(column_id, label, name, ...) {
            # use label by default, unless name is not na
            if (!is.na(name)) {
              label <- name
            }
            indeterminateCheckbox(
              paste0("column_", column_id),
              label,
              "indeterminate"
            )
          }) %>% tags$div()
        )
      })
  )
}





get_options_ui <- function() {
  tagList(
    shinyWidgets::radioGroupButtons(
      "score_visualisation",
      "How to show the scores",
      choices = c(Circles = "circle", Bars = "bar"),
      selected = "bar"
    ),
    shinyWidgets::radioGroupButtons(
      "advanced_mode",
      "Show advanced questions",
      choiceNames = c("Yes", "No"),
      choiceValues = c(TRUE, FALSE),
      selected = FALSE
    )
  )
}