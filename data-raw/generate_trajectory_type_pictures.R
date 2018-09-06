library(dynbenchmark)
library(dynwrap)
library(tidyverse)

trajectory_types$id %>% map(function(trajectory_type) {
  plot <- dynbenchmark::plot_trajectory_types(trajectory_type = trajectory_type, size = 5) + scale_x_continuous(expand = c(0.1, 0)) + scale_y_continuous(expand = c(0.3, 0))

  ggsave(glue::glue("inst/img/trajectory_types/{trajectory_type}.png"), width = 2, height = 1.2, bg = "transparent")

})
