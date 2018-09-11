dataset_chooser_input <- function(id, data) {
  # create namespace of shiny modules
  ns <- NS(id)

  # get information on datasets
  benchmark_datasets_info <- data$benchmark_datasets_info

  # filter datasets on source
  all_sources <- unique(benchmark_datasets_info$source)
  source_buttons <- shinyWidgets::checkboxGroupButtons(
    inputId = ns("sources"),
    label = "Dataset sources",
    selected = all_sources,
    choices = all_sources,
    status = "default"
  )

  # filter datasets on trajectory type
  all_trajectory_types <- unique(benchmark_datasets_info$trajectory_type)
  choices <- map(all_trajectory_types, function(trajectory_type) {
    span(
      img(src = str_glue("img/trajectory_types/{trajectory_type}.png"), class = "trajectory_type"),
      label_capitalise(trajectory_type)
    )
  }) %>% set_names(all_trajectory_types)

  trajectory_type_buttons <- shinyWidgets::checkboxGroupButtons(
    inputId = ns("trajectory_types"),
    label = "Trajectory types",
    selected = all_trajectory_types,
    choiceNames = unname(choices),
    choiceValues = names(choices),
    status = "default"
  )

  # filter dataset individually
  dataset_picker <- shinyWidgets::pickerInput(
    inputId = ns("ids"),
    label = "Select individual datasets",
    choices = benchmark_datasets_info,
    selected = benchmark_datasets_info$id,
    multiple = TRUE,
    options = list(
      `actions-box` = TRUE,
      `deselect-all-text` = "None",
      `select-all-text` = "All",
      `none-selected-text` = "None"
    )
  )

  tagList(
    tags$p("Number of datasets: ", textOutput(ns("n_datasets"), container = tags$em), "/", nrow(data$benchmark_datasets)),

    source_buttons,

    trajectory_type_buttons,

    tags$style("
      .dropdown-menu.inner {
        max-height: 200px!important;
      }
    "),
    dataset_picker
  )
}


dataset_chooser <- function(input, output, session) {
  # filter datasets on every aspect
  excluded_dataset_ids <- reactive({
    included <- benchmark_datasets_info %>%
      filter(
        source %in% input$sources,
        trajectory_type %in% input$trajectory_types,
        id %in% input$ids
      ) %>%
      pull(id)

    setdiff(benchmark_datasets_info$id, included)
  })

  # change the number of datasets in the ui
  output$n_datasets <- renderText(nrow(benchmark_datasets_info) - length(excluded_dataset_ids()))

  # output the excluded dataset ids
  excluded_dataset_ids
}