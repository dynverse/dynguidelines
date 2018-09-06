format_100 <- function(y) {
  round(y * 100)
}


format_time <- function(x) {
  map_chr(x, function(x) {
    if (is.na(x)) {
      NA
    } else if(x < 60) {
      paste0(round(x), "s")
    } else if (x < (60*60)) {
      paste0(round(x/60), "m")
    } else {
      paste0(round(x/60/60), "h")
    }
  })
}
process_time <- function(x) {
  map_dbl(x, function(x) {
    if (is.na(x)) {
      NA
    } else if (x == "∞") {
      Inf
    } else {
      number <- as.numeric(gsub("([0-9]*)[a-z]", "\\1", x))
      if (endsWith(x, "s")) {
        number
      } else if (endsWith(x, "m")) {
        number * 60
      } else if (endsWith(x, "h")) {
        number * 60 * 60
      } else {
        stop("Invalid time: ", x)
      }
    }
  })
}

format_memory <- function(x) {
  map_chr(x, function(x) {
    if (is.na(x)) {
      NA
    } else if (x < 10^3) {
      paste0(round(x), "kB")
    } else if (x < 10^6) {
      paste0(round(x/10^3), "MB")
    } else if (x < 10^9) {
      paste0(round(x/10^6), "GB")
    } else {
      warning("More than a terrabyte of memory seems a bit overkill...")
      paste0(round(x/10^9), "TB")
    }
  })
}
process_memory <- function(x) {
  map_dbl(x, function(x) {
    if (is.na(x)) {
      NA
    } else if (x == "∞") {
      Inf
    } else {
      number <- as.numeric(gsub("([0-9]*)[kMGT]B", "\\1", x))
      if (endsWith(x, "kB")) {
        number
      } else if (endsWith(x, "MB")) {
        number * 10^3
      } else if (endsWith(x, "GB")) {
        number * 10^6
      } else if (endsWith(x, "TB")) {
        number * 10^9
      } else {
        stop("Invalid memory: ", x)
      }
    }
  })
}