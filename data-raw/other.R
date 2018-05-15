priors <- tribble(
  ~prior_id, ~prior_name, ~prior_task_id,
  "start_id", "Start cell","start_cells",
  "end_id", "End cell(s)","end_cells",
  "end_n", "# end states","n_end_states",
  "states_id", "Cell clustering","grouping_assignment",
  "states_n", "# states","n_branches",
  "states_network", "State network","grouping_network",
  "time_id", "Time course","time",
  "genes_id", "Marker genes","marker_feature_ids"
)

usethis::use_data(priors, overwrite = TRUE)