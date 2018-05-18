library(tidyverse)
library(shiny)
devtools::load_all()

data(trajectory_types, package="dynwrap", envir=environment())

renderers <- tribble(
  ~column_id, ~renderer, ~label, ~title, ~style, ~default,
  "selected", render_selected, icon("check-circle"), "Selected methods for TI", NA, -100,
  "method_name", render_identity, "Method", "Name of the method", "max-width:99%", -99,
  "maximal_trajectory_type", render_maximal_trajectory_type, "Topology", "The most complex topology this method can predict", NA, NA,
  "overall_benchmark", get_score_renderer(), "Overall score", "Overall score in the benchmark", "width:130px;", 98,
  "user_friendly", get_score_renderer(viridis::viridis), "User friendliness", "User friendliness score", "width:130px;", NA,
  "DOI", render_article, icon("paper-plane"), "Paper/study describing the method", NA, 99,
  "code_location", render_code, icon("code"), "Code of method", NA, 100,
  "platforms", render_identity, "Languages", "Languages", NA, NA,
  "time_method", render_time, icon("time", lib="glyphicon"), "Estimated running time", NA, NA
) %>% bind_rows(
  tibble(
    column_id = trajectory_types$id,
    undirected = !trajectory_types$directed,
    simplified = trajectory_types$simplified,
    renderer = map(column_id, get_trajectory_type_renderer),
    label = map(column_id, ~""),
    title = str_glue("Whether this method can predict a {label_split(simplified)} topology"),
    style = NA
  ) %>%
    mutate(default = ifelse(undirected, row_number() - 60, NA))
) %>% bind_rows(
  tibble(
    trajtype = trajectory_types$id,
    simplified = trajectory_types$simplified,
    column_id = paste0("trajtype_", trajtype),
    renderer = map(column_id, ~get_score_renderer()),
    label = as.list(str_glue("{label_capitalise(trajtype)} score")),
    title = str_glue("Score on datasets containing a {label_split(simplified)} topology"),
    style = "width:130px;",
    default = NA
  )
)


usethis::use_data(renderers, overwrite=TRUE)
