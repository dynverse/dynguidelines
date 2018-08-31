library(dyntoy)
library(dynplot)
library(tidyverse)


## disconnected example
dataset <- dyntoy::generate_dataset(model = "disconnected", num_cells = 1000)
plot <- plot_dimred(dataset)
ggsave("inst/img/disconnected_example.png", plot = plot, width = 3, height = 3)



## cyclic example
dataset <- dyntoy::generate_dataset(model = tibble(from = c("A", "A", "B", "C"), to = c("D", "B", "C", "A")), num_cells = 1000)
plot <- plot_dimred(dataset)
ggsave("inst/img/cyclic_example.png", plot = plot, width = 3, height = 3)




## complex tree example
dataset <- dyntoy::generate_dataset(model = tibble(from = c("A", "B", "B", "C", "C"), to = c("B", "C", "D", "E", "F")), num_cells = 1000)
plot <- plot_dimred(dataset, dimred = dyndimred::dimred_landmark_mds)
ggsave("inst/img/complex_tree_example.png", plot = plot, width = 3, height = 3)
