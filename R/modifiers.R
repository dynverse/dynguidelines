default_modifier <- function(data, answers) {
  data$methods_aggr <- data$methods_aggr %>% arrange(-benchmark_overall)

  benchmark_overall <- methods_aggr %>%
    select(method_id, benchmark) %>%
    filter(!map_lgl(benchmark, is.null)) %>%
    tidyr::unnest(benchmark) %>%
    calculate_benchmark_score(answers = answers)
  data$methods_aggr$benchmark_overall <- benchmark_overall[data$methods_aggr$method_id]

  data$methods_aggr <- data$methods_aggr %>% arrange(-benchmark_overall)

  data
}


multiple_disconnected_modifier <- function(data, answers) {
  if(isTRUE(answers$multiple_disconnected)) {
    data$methods_aggr <- data$methods_aggr %>% filter(detects_disconnected_graph)
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "detects_disconnected_graph", filter = TRUE, order = FALSE)
  }
  data
}


expect_topology_modifier <- function(data, answers) {
  if (!isTRUE(answers$expect_topology)) {
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


expected_topology_modifier <- function(data, answers) {
  trajectory_type_column <- paste0("detects_", answers$expected_topology)
  score_column <- paste0("benchmark_", answers$expected_topology)

  trajectory_type_score <- methods_aggr %>%
    select(method_id, benchmark) %>%
    filter(!map_lgl(benchmark, is.null)) %>%
    tidyr::unnest(benchmark) %>%
    filter(dataset_trajectory_type == answers$expected_topology) %>%
    calculate_benchmark_score(answers = answers)
  data$methods_aggr[score_column] <- trajectory_type_score[data$methods_aggr$method_id]

  data$methods_aggr <- data$methods_aggr[data$methods_aggr[[trajectory_type_column]], ] %>% arrange(-.[[score_column]])
  data$method_columns <- data$method_columns %>%
    mutate(order = FALSE) %>%
    add_row(column_id = score_column, order = TRUE, filter = FALSE) %>%
    add_row(column_id = trajectory_type_column, filter = TRUE, order = FALSE)

  data
}


expect_cycles_modifier <- function(data, answers) {
  if(isTRUE(answers$expect_cycles)) {
    data$methods_aggr <- data$methods_aggr %>% filter(detects_graph & detects_cycle)
    data$method_columns <- data$method_columns %>%
      bind_rows(
        tibble(
          column_id = c("detects_graph", "detects_cycle"),
          filter = TRUE,
          order = FALSE
        )

      )
  }
  data
}


expect_complex_tree_modifier <- function(data, answers) {
  if(isTRUE(answers$expect_complex_tree)) {
    data$methods_aggr <- data$methods_aggr %>% arrange(-benchmark_tree)
    data$method_columns <- data$method_columns %>%
      mutate(order = FALSE) %>%
      add_row(column_id = "benchmark_tree", filter = FALSE, order = TRUE)
  }
  data
}



dynmethods_modifier <- function(data, answers) {
  if (!isTRUE(answers$dynmethods)) {
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "qc_user_friendly", filter = TRUE, order = FALSE)
  }

  data
}


programming_interface_modifier <- function(data, answers) {
  if (!isTRUE(answers$programming_interface)) {
    data$methods_aggr <- data$methods_aggr %>% filter(gui > 0)
  }

  data
}


languages_modifier <- function(data, answers) {
  data$methods_aggr <- data$methods_aggr %>% filter(platform %in% answers$languages)
  data$method_columns <- data$method_columns %>%
    add_row(column_id = "platform", filter = TRUE, order = FALSE)

  data
}


user_friendliness_modifier <- function(data, answers) {
  data$methods_aggr <- data$methods_aggr %>% filter(qc_user_friendly >= as.numeric(answers$user_friendliness)/100)

  data
}

time_modifier <- function(data, answers) {
  time_cutoff <- process_time(answers$time)
  if (!is.na(time_cutoff)) {
    # calculate the time
    data$methods_aggr <- data$methods_aggr %>%
      mutate(
        time_prediction = map(
          scaling_model_time,
          function(scaling_model_time) {
            if(is.null(scaling_model_time)) {
              list(mean = NA, sd = NA)
            } else {
              scaling_model_time(n_cells = answers$n_cells, n_features = answers$n_features)
            }
          }
        ),
        time_prediction_mean = map_dbl(time_prediction, "mean"),
        time_prediction_sd = map_dbl(time_prediction, "sd")
      )

    # filter on time
    data$methods_aggr <- data$methods_aggr %>%
      filter(is.na(time_prediction_mean) | time_prediction_mean <= time_cutoff)

    # add to method columns
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "time_prediction_mean", filter = TRUE, order = FALSE)
  }
  data
}

memory_modifier <- function(data, answers) {
  memory_cutoff <- process_memory(answers$memory)
  if (!is.na(memory_cutoff)) {
    # calculate the memory
    data$methods_aggr <- data$methods_aggr %>%
      mutate(
        memory_prediction = map(
          scaling_model_mem,
          function(scaling_model_mem) {
            if(is.null(scaling_model_mem)) {
              list(mean = NA, sd = NA)
            } else {
              scaling_model_mem(n_cells = answers$n_cells, n_features = answers$n_features)
            }
          }
        ),
        memory_prediction_mean = map_dbl(memory_prediction, "mean"),
        memory_prediction_sd = map_dbl(memory_prediction, "sd")
      )

    # filter on memory
    data$methods_aggr <- data$methods_aggr %>%
      filter(is.na(memory_prediction_mean) | memory_prediction_mean <= memory_cutoff)

    # add to method columns
    data$method_columns <- data$method_columns %>%
      add_row(column_id = "memory_prediction_mean", filter = TRUE, order = FALSE)
  }

  data
}


prior_information_modifier <- function(data, answers) {
  unavailable_priors <- dynwrap::priors %>% filter(!prior_id %in% answers$prior_information) %>% pull(prior_id)
  data$methods_aggr <- data$methods_aggr %>%
    filter(
      input %>% map("required") %>% map_lgl(~!any(. %in% unavailable_priors))
    )

  data
}


method_selection_modifier <- function(data, answers) {
  data
}


dynamic_n_methods_modifier <- function(data, answers) {
  data$methods_aggr <- data$methods_aggr %>%
    mutate(selected = row_number() < 5)
  data$method_columns <- data$method_columns %>%
    add_row(column_id = "selected", filter = FALSE, order = FALSE)
  data$methods_selected <- data$methods_aggr %>% filter(selected) %>% pull(method_id)

  data
}


fixed_n_methods_modifier <- function(data, answers) {
  data$methods_aggr <- data$methods_aggr %>%
    mutate(selected = row_number() < answers$fixed_n_methods+1)
  data$method_columns <- data$method_columns %>%
    add_row(column_id = "selected", filter = FALSE, order = FALSE)
  data$methods_selected <- data$methods_aggr %>% filter(selected) %>% pull(method_id)

  data
}


n_cells_modifier <- function(data, answers) {
  data
}


n_features_modifier <- function(data, answers) {
  data
}


docker_modifier <- function(data, answers) {
  data
}


metric_importance_modifier <- function(data, answers) {
  data
}





calculate_benchmark_score <- function(benchmark, answers) {
  benchmark %>%
    group_by(method_id, dataset_trajectory_type) %>%
    summarise_if(is.numeric, mean) %>%
    summarise_if(is.numeric, mean) %>%
    mutate(score = dyneval::calculate_geometric_mean(.[, benchmark_metrics$metric_id], weights = unlist(answers$metric_importance[benchmark_metrics$metric_id]))) %>%
    select(method_id, score) %>%
    deframe()
}