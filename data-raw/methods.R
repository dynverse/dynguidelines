library(tidyverse)
devtools::load_all()

methods_aggr <- read_rds("~/methods_aggr.rds")

usethis::use_data(methods_aggr, overwrite = TRUE, compress = "xz")
