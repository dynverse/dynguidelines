multiple_disconnected_modifier <- function(data, answer=NULL) {
  data$methods <- data$methods %>% arrange(-overall_benchmark)
  if(answer == "Yes") {
    data$methods <- data$methods %>% filter(disconnected_undirected_graph)
  }
  data
}


expect_topology_modifier <- function(data, answer=NULL) {data}


expected_topology_modifier <- function(data, answer=NULL) {
  if(answer == "Linear") {
    trajectory_type_column <- "undirected_linear"
    score_column <- "trajtype_directed_linear"
  } else if (answer == "Cyclic") {
    trajectory_type_column <- "undirected_cycle"
    score_column <- "trajtype_directed_cycle"
  } else if (answer == "Bifurcating") {
    trajectory_type_column <- "simple_fork"
    score_column <- "trajtype_bifurcation"
  }

  data$methods <- data$methods[data$methods[[trajectory_type_column]], ] %>% arrange(-.[[score_column]])
  data$method_columns <- data$method_columns %>%
    add_row(column_id = score_column) %>%
    add_row(column_id = trajectory_type_column)

  data
}


expect_cycles_modifier <- function(data, answer=NULL) {
  if(answer == "It's possible") {
    data$methods <- data$methods %>% filter(undirected_graph)
  }
  data
}


expect_complex_tree_modifier <- function(data, answer=NULL) {
  if(answer == "Yes") {
    data$methods <- data$methods %>% filter(unrooted_tree) %>% arrange(-trajtype_rooted_tree)
    data$method_columns <- data$method_columns %>% add_row(column_id = "trajtype_rooted_tree")
  }
  data
}



programming_interface_modifier <- function(data, answer = NULL) {
  if (answer == "No") {
    data$methods <- data$methods %>% filter(gui > 0)
  } else if (answer == "Yes") {
    data$method_columns <- data$method_columns %>% add_row(column_id = "platforms")
  }

  data
}


languages_modifier <- function(data, answer=NULL) {
  data$methods <- data$methods %>% filter(map_lgl(platforms_split, ~length(intersect(answer, .)) > 0))

  data
}


user_friendliness_modifier <- function(data, answer=NULL) {
  data$methods <- data$methods %>% filter(user_friendly >= as.numeric(answer)/100)

  data
}


prior_information_modifier <- function(data, answer=NULL) {
  unavailable_priors <- priors %>% filter(!prior_name %in% answer) %>% pull(prior_id)
  data$methods <- data$methods[data$methods[, unavailable_priors] %>% apply(1, function(x) all(x != "required", na.rm=T)), ]

  data
}


n_methods_modifier <- function(data, answer=NULL) {
  data$methods <- data$methods %>%
    mutate(selected = row_number() < answer+1)
  data
}




n_cells_modifier <- function(data, answer) {
  data
}


n_genes_modifier <- function(data, answer) {
  data
}