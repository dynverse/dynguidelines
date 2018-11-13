get_available_memory <- function(
  choices = memory_choices
) {
  available_memory <- if(Sys.info()["sysname"] == "Linux") {
    system("cat /proc/meminfo | grep MemTotal", intern = TRUE) %>%
      gsub("MemTotal:[ ]*([0-9]*) (kB)", "\\1\\2", .) %>%
      process_memory()
  } else {
    process_memory("4GB")
  }

  available_memory <- available_memory - process_memory("2GB")

  choices[first(which.min(abs(available_memory - choices)))] %>% format_memory()
}
