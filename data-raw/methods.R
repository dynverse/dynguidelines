library(tidyverse)
devtools::load_all()

methods_aggr <- read_rds("~/methods_aggr.rds") %>% select(-benchmark, -parameters, -authors, -qc_category_scores)

usethis::use_data(methods_aggr, overwrite = TRUE, internal = TRUE, compress = "xz")
