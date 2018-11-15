scale_01 <- function(y, lower = min(y, na.rm = TRUE), upper = max(y, na.rm = TRUE)) {

  if (lower == upper) {
    lower <- upper - 0.1
  }

  (y - lower) / (upper - lower)
}


palettes <- tribble(
  ~palette,        ~colours,
  # blues palette
  "overall", grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(9, "Greys")[-1]))(101),
  "accuracy", grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(9, "Blues") %>% c("#011636")))(101),
  "scalability", grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(9, "Reds")[-8:-9]))(101),
  "stability", grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(9, "YlOrBr")[-7:-9]))(101),
  "usability", grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(9, "Greens")[-1] %>% c("#00250f")))(101),
  "column_annotation", c(method = "#555555", overall = "#555555", accuracy = "#4292c6", scalability = "#f6483a", stability = "#fe9929", usability = "#41ab5d")
) %>% deframe()

scaled_color <- function(x, palette) {
  palette[ceiling(x * (length(palette)-1)) + 1]
}

color_based_on_background <- function(background) {
  map_chr(background, function(background) {
    ifelse(
      mean(colorspace::hex2RGB(background)@coords) > 0.6,
      "black",
      "white"
    )
  })
}


get_score_renderer <- function(palette = palettes$accuracy) {
  function(x, options) {
    if (any(is.na(x))) {
      # warning("Some NA values in score renderer! ", x)
    }

    style <- ifelse(is.null(options$score_visualisation), "bar", options$score_visualisation)
    if (style == "bar") {
      y <- tibble(
        x = x,
        normalised = ifelse(is.na(x), 0, scale_01(x, lower = 0)),
        rounded = format_100(normalised),
        formatted = ifelse(is.na(x), "NA", rounded),
        width = paste0(rounded, "px"),
        `background-color` = ifelse(is.na(x), "none", html_color(scaled_color(normalised, palette))),
        color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "black", is.na(x) ~ "grey", TRUE ~ "white"),
        `text-shadow` = case_when(color == "white" ~ "-1px 0 #000000AA, 0 1px #000000AA, 1px 0 #000000AA, 0 -1px #000000AA", TRUE ~ "none"),
        style = pmap(lst(`background-color`, color, width, `text-shadow`), htmltools::css),
        class = "score bar"
      )
    } else if (style == "circle") {
      y <- tibble(
        x = x,
        normalised = ifelse(is.na(x), 0, scale_01(x, lower = 0)),
        rounded = format_100(normalised),
        formatted = ifelse(is.na(x), "NA", rounded),
        width = paste0(rounded/3, "px"),
        `line-height` = paste0(rounded/3, "px"),
        `background-color` = ifelse(is.na(x), "none", html_color(scaled_color(normalised, palette))),
        color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "black", is.na(x) ~ "grey", TRUE ~ "white"),
        `text-shadow` = case_when(color == "white" ~ "-1px 0 #000000AA, 0 1px #000000AA, 1px 0 #000000AA, 0 -1px #000000AA", TRUE ~ "none"),
        style = pmap(lst(`background-color`, color, display = "block", width, `text-shadow`, `line-height`, `text-align` = "center"), htmltools::css),
        class = "score circle"
      )
    }

    pmap(list(y$formatted, style = y$style, class = y$class), span)
  }
}

render_detects_trajectory_type <- function(x) {
  map(
    x,
    function(trajectory_type) {
      if (is.na(trajectory_type)) {
        NA
      } else {
        img(src = str_glue("img/trajectory_types/{trajectory_type}.png"), class = "trajectory_type")
      }
    }
  )
}

get_trajectory_type_renderer <- function(trajectory_type) {
  if (is.na(trajectory_type)) {
    function(x) {NA}
  } else {
    function(x) {
      map(
        x,
        function(x) {
          if(is.na(x)) {
            "NA"
          } else {
            if (isTRUE(x)) {
              class <- "trajectory_type"
            } else {
              class <- "trajectory_type inactive"
            }
            img(src = str_glue("img/trajectory_types/{gsub('method_detects_', '', trajectory_type)}.png"), class = class)
          }
        }
      )
    }
  }
}

render_selected <- function(x) {
  map(x, ~if(.) {icon("check")})
}

render_identity <- function(x) {x}

render_article <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = paste0("https://doi.org/", .), icon("paper-plane"), target = "blank")} else {""})
}

render_code <- function(x) {
  map(x, ~if(!is.na(.)) {tags$a(href = ., icon("code"), target = "blank")} else {""})
}

hard_prior_ids <- dynwrap::priors %>% filter(type == "hard") %>% pull(prior_id) # prepopulate
prior_id_to_label <- dynwrap::priors %>% select(prior_id, name) %>% deframe() # prepopulate

render_required_priors <- function(x) {
  map(x, function(prior_ids) {
    if (length(prior_ids)) {
      symbol <- ifelse(any(prior_ids %in% hard_prior_ids), "\U2716", "\U2715")
      tags$span(
        symbol,
        title = paste(prior_id_to_label[prior_ids], collapse = ", "),
        class = "tooltippable"
      )
    } else {
      ""
    }
  })
}

wrapper_type_id_to_label <- dynwrap::wrapper_types %>% select(id, short_name) %>% deframe()
render_wrapper_type <- function(x) {
  wrapper_type_id_to_label[x]
}



get_scaling_renderer <- function(formatter, palette = palettes$scalability, min, max, log = FALSE) {
  function(x) {
    if (log) {
      x <- exp(x)
    }

    x[x < min] <- min
    x[x > max] <- max

    y <- tibble(
      x = x,
      formatted = formatter(x),
      normalised = ifelse(is.na(x), 0, scale_01(log(x))),
      rounded = format_100(normalised),
      width = paste0(rounded, "px"),
      background = ifelse(is.na(x), "none", html_color(scaled_color(1-normalised, palette))),
      color = case_when(scale_01(normalised, lower = 0) > 0.5 ~ "white", is.na(x) ~ "grey", TRUE ~ "black"),
      style = pmap(list(`background-color` = background, color = color, display = "block", width = width), htmltools::css),
      class = "score bar"
    )

    pmap(list(y$formatted, style = y$style, class = y$class), span)
  }
}

time_renderer <- get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7, log = FALSE)
memory_renderer <- get_scaling_renderer(format_memory, min = 1, max = 10^12, log = FALSE)
time_renderer_log <- get_scaling_renderer(format_time, min = 0.1, max = 60*60*24*7, log = TRUE)
memory_renderer_log <- get_scaling_renderer(format_memory, min = 1, max = 10^12, log = TRUE)


get_warning_renderer <- function(
  label,
  title,
  palette
) {
  function(x) {
    map(x, function(x) {
      if (x > 0) {
        background <- scaled_color(1-x, palette)
        color <- color_based_on_background(background)

        tags$span(
          icon("warning"),
          label,
          class = "score box",
          style = paste(
            paste0("background-color:", background),
            paste0("color: ", color),
            "white-space: nowrap",
            sep = ";"
          ),
          `data-toggle` = "tooltip",
          `data-placement` = "top",
          title = title
        )
      } else {
        NULL
      }
    })
  }
}

stability_warning_renderer <- get_warning_renderer(
  "Unstable",
  title = "This method can generate unstable results. We advise you to rerun it multiple times on a dataset.",
  palette = palettes$stability
)

error_warning_renderer <- get_warning_renderer(
  "Errors",
  title = "This method errors often. It may not work on your dataset.",
  palette = palettes$overall
)

#' Get all renderers
#'
#' @export
get_renderers <- function() {
  data(trajectory_types, package = "dynwrap", envir = environment())

  renderers <- tribble(
    ~column_id, ~category, ~renderer, ~label, ~title, ~style, ~default, ~name,
    "selected", "method", render_selected, icon("check-circle"), "Selected methods for TI", NA, -100, NA,
    "method_name", "method", render_identity, "Name", "Name of the method", "max-width:99%;width:100%", -98, NA,
    "method_doi", "method", render_article, icon("paper-plane"), "Paper/study describing the method", NA, -99, "paper",
    "method_code_url", "method", render_code, icon("code"), "Code of method", NA, -99, "code",
    "method_required_priors", "method", render_required_priors, "Priors", "Required priors", NA, 1, NA,
    "method_wrapper_type", "method", render_wrapper_type, "Wrapper", "How the method was wrapped using <a href='wrap.dynverse.org'><em>dyn</em>wrap</a>", NA, NA, NA,
    "method_most_complex_trajectory_type", "method", render_detects_trajectory_type, "Topology", "The most complex topology this method can predict", NA, NA, NA,
    "method_platform", "method", render_identity, "Platform", "Platform", NA, NA, NA,
    "scaling_predicted_time", "scalability", time_renderer, "Time", "Estimated running time", NA, 2, NA,
    "scaling_predicted_mem", "scalability", memory_renderer, "Memory", "Estimated maximal memory usage", NA, 2.1, NA,
    "stability_warning", "stability", stability_warning_renderer, "Stability", "Whether the stability is low", NA, 3, NA,
    "error_warning", "method", error_warning_renderer, "Errors", "Whether the method errors often", NA, 99, NA
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("method_detects_", trajectory_type),
      category = "method",
      renderer = map(column_id, get_trajectory_type_renderer),
      label = map(column_id, ~""),
      name = paste0("Detects ", trajectory_type),
      title = as.character(str_glue("Whether this method can predict a {label_split(trajectory_type)} topology")),
      style = NA,
      default = ifelse(trajectory_type %in% c("convergence", "acyclic_graph"), NA, 3 + seq_len(length(trajectory_type))/100)
    )
  ) %>% bind_rows(
    tibble(
      column_id = methods_aggr %>% select(matches("(benchmark|scaling_pred|stability|qc|summary)_overall_overall")) %>% colnames(),
      category_old = gsub("(benchmark|scaling_pred|stability|qc|summary)_overall_overall", "\\1", column_id),
      category = c(benchmark = "accuracy", scaling_pred = "scalability", stability = "stability", qc = "usability", summary = "overall")[category_old],
      renderer = map(palettes[category], get_score_renderer),
      label = list("Overall"),
      name = NA,
      title = "",
      style = "",
      default = NA
    )
  ) %>% bind_rows(
    tibble(
      trajectory_type = trajectory_types$id,
      column_id = paste0("benchmark_tt_", trajectory_type),
      category = "accuracy",
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(str_glue("{label_capitalise(trajectory_type)} score")),
      name = NA,
      title = as.character(str_glue("Score on datasets containing a {label_split(trajectory_type)} topology")),
      style = "",
      default = NA
    ) %>% select(-trajectory_type)
  ) %>% bind_rows(
    tibble(
      metric_id = benchmark_metrics$metric_id,
      column_id = paste0("benchmark_overall_norm_", metric_id),
      category = "accuracy",
      renderer = map(column_id, ~get_score_renderer()),
      label = map(benchmark_metrics$html, HTML),
      name = NA,
      title = benchmark_metrics$html,
      style = "width:11px;",
      default = NA
    ) %>% select(-metric_id)
  ) %>% bind_rows(
    tibble(
      dataset_source = gsub("/", "_", unique(benchmark_datasets_info$source)),
      column_id = paste0("benchmark_source_", dataset_source),
      category = "accuracy",
      renderer = map(column_id, ~get_score_renderer()),
      label = as.list(label_capitalise(dataset_source)),
      name = NA,
      title = dataset_source,
      style = "",
      default = NA
    ) %>% select(-dataset_source)
  ) %>% bind_rows(
    tibble(
      column_id = methods_aggr %>%
        select(starts_with("qc_"), -qc_overall_overall) %>%
        select_if(is.numeric) %>%
        colnames(),
      category = "usability",
      renderer = map(column_id, ~get_score_renderer(palettes$usability)),
      label = str_match(column_id, "qc_(app|cat)_(.*)") %>%
        as.data.frame() %>%
        mutate_all(as.character) %>%
        glue::glue_data("{label_capitalise(.$V3)}") %>%
        as.character() %>%
        as.list(),
      name = NA,
      title = as.character(label),
      style = "",
      default = NA
    ) %>% bind_rows(
      tibble(
        column_id = methods_aggr %>% select(matches("scaling_pred_(time|mem)_")) %>% colnames(),
        scaling_type = gsub("scaling_pred_(time|mem)_.*", "\\1", column_id),
        category = "scalability",
        renderer = list(mem = memory_renderer, time = time_renderer)[scaling_type],
        label = str_match(column_id, "scaling_pred_(time|mem)_cells(.*)_features(.*)") %>%
          as.data.frame() %>%
          mutate_all(as.character) %>%
          glue::glue_data("{.$V2} {.$V3} cells and {.$V4} features") %>%
          as.character() %>%
          as.list(),
        name = NA,
        title = as.character(label),
        style = "",
        default = NA
      )
    ) %>% bind_rows(
      tibble(
        column_id = methods_aggr %>%
          select(starts_with("stability"), -stability_overall_overall) %>%
          select_if(is.numeric) %>%
          colnames(),
        scaling_type = gsub("stability_([^_]*)_.*", "\\1", column_id),
        category = "stability",
        renderer = map(column_id, ~get_score_renderer(palettes$stability)),
        label = as.list(column_id),
        name = NA,
        title = as.character(label),
        style = "",
        default = NA
      )
    )
  )

  renderers
}


get_column_categories <- function() {
  palettes$column_annotation %>%
    enframe("category", "color") %>%
    mutate(category_order = row_number())
}




#' Get column presets
#'
#' @export
get_column_presets <- function() {
  list(
    list(
      id = "intelligent",
      label = "Intelligent",
      activate = function(show_columns) {
        show_columns[names(show_columns)] <- "indeterminate"
        show_columns
      }
    ),
    list(
      id = "everything",
      label = "Everything",
      activate = function(show_columns) {
        show_columns[names(show_columns)] <- "true"
        show_columns
      }
    ),
    list(
      id = "fig2",
      label = "Summary Figure 2",
      activate = function(show_columns) {
        show_columns[] <- "false"

        columns_oi <- c(
          "column_selected",
          "column_method_name",
          "column_method_required_priors",
          "column_method_wrapper_type",
          "column_method_platform",
          names(show_columns)[str_detect(names(show_columns), "^column_method_detects")] %>% discard(str_detect, "(convergence|acyclic_graph)"),
          "column_summary_overall_overall",
          "column_benchmark_overall_overall",
          "column_qc_overall_overall",
          "column_stability_overall_overall",
          "column_scaling_pred_overall_overall"
        )
        show_columns[columns_oi] <- "true"

        show_columns
      }
    )
  ) %>%
    c(map(unique(get_renderers()$category), function(category) {
      list(
        id = category,
        label = label_capitalise(category),
        activate = activate_column_preset_category(category)
      )
    })
    )
}



activate_column_preset_category <- function(category) {
  function(show_columns) {
    show_columns[names(show_columns)] <- "false"
    columns_oi <- get_renderers() %>% filter((category %in% !!category) | (column_id %in% c("selected", "method_name" ))) %>% pull(column_id) %>% paste0("column_", .)
    columns_oi <- c("column_name", columns_oi)
    show_columns[columns_oi] <- "true"
    show_columns
  }
}