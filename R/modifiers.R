multiple_disconnected_modifier <- function(data, multiple_disconnected = NULL) {
  data$methods_aggr <- data$methods_aggr %>% arrange(-benchmark_overall)
  if(isTRUE(multiple_disconnected)) {
    data$methods_aggr <- data$methods_aggr %>% filter(detects_disconnected_graph)
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "detects_disconnected_graph", filter = TRUE, order = FALSE)
  }
  data
}


expect_topology_modifier <- function(data, expect_topology = NULL) {
  if (!isTRUE(expect_topology)) {
    data$methods_aggr <- data$methods_aggr %>% filter(detects_linear & detects_bifurcation & detects_tree)
    data$method_columns <- data$method_columns %>%
      bind_rows(
        tibble(
          column_id = c("detects_linear", "detects_bifurcation", "detects_tree"),
          filter = TRUE,
          order = FALSE
        )
      )
  }
  data
}


expected_topology_modifier <- function(data, expected_topology = NULL) {
  trajectory_type_column <- paste0("detects_", expected_topology)
  score_column <- paste0("benchmark_", expected_topology)

  data$methods_aggr <- data$methods_aggr[data$methods_aggr[[trajectory_type_column]], ] %>% arrange(-.[[score_column]])
  data$method_columns <- data$method_columns %>%
    mutate(order = FALSE) %>%
    add_row(column_id = score_column, order = TRUE, filter = FALSE) %>%
    add_row(column_id = trajectory_type_column, filter = TRUE, order = FALSE)

  data
}


expect_cycles_modifier <- function(data, expect_cycles = NULL) {
  if(isTRUE(expect_cycles)) {
    data$methods_aggr <- data$methods_aggr %>% filter(graph & cycle)
    data$method_columns <- data$method_columns %>%
      bind_rows(
        tibble(
          column_id = c("graph", "cycle"),
          filter = TRUE,
          order = FALSE
        )

      )
  }
  data
}


expect_complex_tree_modifier <- function(data, expect_complex_tree = NULL) {
  if(isTRUE(expect_complex_tree)) {
    data$methods_aggr <- data$methods_aggr %>% arrange(-benchmark_tree)
    data$method_columns <- data$method_columns %>%
      mutate(order = FALSE) %>%
      add_row(column_id = "benchmark_tree", filter = FALSE, order = TRUE)
  }
  data
}



dynmethods_modifier <- function(data, dynmethods = NULL) {
  if (!isTRUE(dynmethods)) {
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "qc_user_friendly", filter = TRUE, order = FALSE)
  }

  data
}


programming_interface_modifier <- function(data, programming_interface = NULL) {
  if (!isTRUE(programming_interface)) {
    data$methods_aggr <- data$methods_aggr %>% filter(gui > 0)
  }

  data
}


languages_modifier <- function(data, languages = NULL) {
  data$methods_aggr <- data$methods_aggr %>% filter(platform %in% languages)
  data$method_columns <- data$method_columns %>%
    add_row(column_id = "platform", filter = TRUE, order = FALSE)

  data
}


user_friendliness_modifier <- function(data, user_friendliness = NULL) {
  data$methods_aggr <- data$methods_aggr %>% filter(qc_user_friendly >= as.numeric(user_friendliness)/100)

  data
}

running_time_modifier <- function(data, running_time = NULL, n_cells = NULL, n_features = NULL) {
  running_time <- suppressWarnings(as.numeric(running_time))
  if (!is.na(running_time)) {
    # calculate the time

    # filter the time cutoff
    data$methods_aggr <- data$methods_aggr %>%
      filter((time_method/60) <= running_time)
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "time_method", filter = TRUE, order = FALSE)
  }

  data
}

memory_modifier <- function(data, memory = NULL, n_cells = NULL, n_genes = NULL) {
  data
}


prior_information_modifier <- function(data, prior_information = NULL) {
  unavailable_priors <- dynwrap::priors %>% filter(!prior_id %in% prior_information) %>% pull(prior_id)
  data$methods_aggr <- data$methods_aggr %>%
    filter(
      input %>% map("required") %>% map_lgl(~!any(. %in% unavailable_priors))
    )

  data
}


method_selection_modifier <- function(data, method_selection = NULL) {
  data
}


dynamic_n_methods_modifier <- function(data, dynamic_n_methods = NULL) {
  data$methods_aggr <- data$methods_aggr %>%
    mutate(selected = row_number() < 5)
  data
}


fixed_n_methods_modifier <- function(data, fixed_n_methods = NULL) {
  data$methods_aggr <- data$methods_aggr %>%
    mutate(selected = row_number() < fixed_n_methods+1)
  data
}


n_cells_modifier <- function(data, n_cells) {
  data
}


n_features_modifier <- function(data, n_features) {
  data
}


docker_modifier <- function(data, docker) {
  data
}


metric_importance_modifier <- function(data, metric_importance) {
  # cat(glue::glue_collapse(answer, ", "))
  data
}