load("data/questions.rda")
load("data/renderers.rda")
load("data/priors.rda")
load("data/methods.rda")

usethis::use_data(questions, renderers, priors, methods, overwrite = TRUE, internal = TRUE)