library(tidyverse)
library(dynbenchmark)

## TODO: THIS HAS TO BE SYNCHRONISED WITH THE NEW DYNBENCHMARK ##

experiment("7-user_guidelines")

read_rds(derived_file("evaluation_algorithm.rds", "5-optimise_parameters/10-aggregations")) %>% list2env(.GlobalEnv)

implementation_qc <- read_rds(dynalysis::derived_file("implementation_qc.rds", "4-method_characterisation"))

methods <-
  left_join(
    methods,
    read_rds(dynalysis::derived_file("implementation_qc_application_scores.rds", "4-method_characterisation")) %>%
      spread("application", "score"),
    "implementation_id"
  ) %>%
  left_join(
    implementation_qc %>% select(implementation_id, item_id, answer) %>% spread(item_id, answer),
    "implementation_id"
  )

methods <- methods %>%
  left_join(
    overall_scores[c(colnames(overall_scores)[!colnames(overall_scores) %in% colnames(methods)], "method_short_name")],
    "method_short_name"
  ) %>%
  filter(type %in% c("algorithm", "control"))

usethis::use_data(methods, overwrite = TRUE)
