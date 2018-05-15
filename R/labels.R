#' @importFrom Hmisc capitalize
label_capitalise <- function(x) {
  x %>% str_replace_all("_", " ") %>% Hmisc::capitalize()
}