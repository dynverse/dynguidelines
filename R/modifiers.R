multiple_disconnected_modifier <- function(data, answer = NULL) {
  data$methods <- data$methods %>% arrange(-overall_benchmark)
  if(answer == "Yes") {
    data$methods <- data$methods %>% filter(disconnected_undirected_graph)
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "disconnected_undirected_graph", filter = TRUE, order = FALSE)
  }
  data
}


expect_topology_modifier <- function(data, answer = NULL) {
  if (answer == "No") {
    data$methods <- data$methods %>% filter(undirected_linear & simple_fork & unrooted_tree)
    data$method_columns <- data$method_columns %>%
      bind_rows(
        tibble(
          column_id = c("undirected_linear", "simple_fork", "complex_fork", "unrooted_binary_tree", "unrooted_tree"),
          filter = TRUE,
          order = FALSE
        )
      )
  }
  data
}


expected_topology_modifier <- function(data, answer = NULL) {
  data(trajectory_types, package = "dynwrap", envir = environment())

  trajectory_type_directed <- trajectory_types %>% filter(directed) %>% slice(match(answer, simplified)) %>% pull(id) %>% first()
  trajectory_type_undirected <- trajectory_types %>% filter(!directed) %>% slice(match(answer, simplified)) %>% pull(id) %>% first()

  trajectory_type_column <- trajectory_type_undirected
  score_column <- paste0("trajtype_", trajectory_type_directed)

  data$methods <- data$methods[data$methods[[trajectory_type_column]], ] %>% arrange(-.[[score_column]])
  data$method_columns <- data$method_columns %>%
    mutate(order = FALSE) %>%
    add_row(column_id = score_column, order = TRUE, filter = FALSE) %>%
    add_row(column_id = trajectory_type_column, filter = TRUE, order = FALSE)

  data
}


expect_cycles_modifier <- function(data, answer = NULL) {
  if(answer == "It's possible") {
    data$methods <- data$methods %>% filter(undirected_graph & undirected_cycle)
    data$method_columns <- data$method_columns %>%
      bind_rows(
        tibble(
          column_id = c("undirected_graph", "undirected_cycle"),
          filter = TRUE,
          order = FALSE
        )

      )
  }
  data
}


expect_complex_tree_modifier <- function(data, answer = NULL) {
  if(answer == "Yes") {
    data$methods <- data$methods %>% arrange(-trajtype_rooted_tree)
    data$method_columns <- data$method_columns %>%
      mutate(order = FALSE) %>%
      add_row(column_id = "trajtype_rooted_tree", filter = FALSE, order = TRUE)
  }
  data
}



dynmethods_modifier <- function(data, answer = NULL) {
  if (answer == "No") {
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "user_friendly", filter = TRUE, order = FALSE)
  }

  data
}


programming_interface_modifier <- function(data, answer = NULL) {
  if (answer == "No") {
    data$methods <- data$methods %>% filter(gui > 0)
  } else if (answer == "Yes") {
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "platforms", filter = TRUE, order = FALSE)
  }

  data
}


languages_modifier <- function(data, answer = NULL) {
  data$methods <- data$methods %>% filter(map_lgl(platforms_split, ~length(intersect(answer, .)) > 0))

  data
}


user_friendliness_modifier <- function(data, answer = NULL) {
  data$methods <- data$methods %>% filter(user_friendly >= as.numeric(answer)/100)

  data
}

running_time_modifier <- function(data, answer = NULL) {
  answer <- as.numeric(answer)
  if (!is.na(answer)) {
    data$methods <- data$methods %>%
      filter((time_method/60) <= answer)
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "time_method", filter = TRUE, order = FALSE)
  }

  data
}


prior_information_modifier <- function(data, answer = NULL) {
  data(priors, envir = environment(), package = "dynguidelines")
  unavailable_priors <- priors %>% filter(!prior_id %in% answer) %>% pull(prior_id)
  data$methods <- data$methods[data$methods[, unavailable_priors] %>% apply(1, function(x) all(x != "required", na.rm = T)), ]

  data
}


n_methods_modifier <- function(data, answer = NULL) {
  data$methods <- data$methods %>%
    mutate(selected = row_number() < answer+1)
  data
}


n_cells_modifier <- function(data, answer) {
  data
}


n_features_modifier <- function(data, answer) {
  data
}


docker_modifier <- function(data, answer) {
  data
}


metric_importance_modifier <- function(data, answer) {
  # cat(glue::collapse(answer, ", "))
  data
}