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
    } else if (x < (60*60*24)) {
      paste0(round(x/60/60), "h")
    } else {
      paste0(round(x/60/60/24), "d")
    }
  })
}
process_time <- function(x) {
  map_dbl(x, function(x) {
    if (is.na(x)) {
      NA
    } else if (x == "\U221E") {
      Inf
    } else {
      number <- as.numeric(gsub("([0-9]*)[smhd]", "\\1", x))
      if (endsWith(x, "s")) {
        number
      } else if (endsWith(x, "m")) {
        number * 60
      } else if (endsWith(x, "h")) {
        number * 60 * 60
      } else if (endsWith(x, "d")) {
        number * 60 * 60 * 24
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
      paste0(round(x), "B")
    } else if (x < 10^6) {
      paste0(round(x/10^3), "kB")
    } else if (x < 10^9) {
      paste0(round(x/10^6), "MB")
    } else if (x < 10^12) {
      paste0(round(x/10^9), "GB")
    } else {
      paste0(round(x/10^12), "TB")
    }
  })
}
process_memory <- function(x) {
  map_dbl(x, function(x) {
    if (is.na(x)) {
      NA
    } else if (x == "\U221E") {
      Inf
    } else {
      number <- as.numeric(gsub("([0-9]*)[kMGT]?B", "\\1", x))
      unit <- gsub("[0-9]*([kMGT]?B)", "\\1", x)
      if (unit == "B") {
        number
      } else if (unit == "kB") {
        number * 10^3
      } else if (unit == "MB") {
        number * 10^6
      } else if (unit == "GB") {
        number * 10^9
      } else if (unit == "TB") {
        number * 10^12
      } else {
        stop("Invalid memory: ", x)
      }
    }
  })
}