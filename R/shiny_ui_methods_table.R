add_icons <- function(label, conditions, icons) {
  pmap(c(list(label = label), conditions), function(label, ...) {
    icons <- list(...) %>%
      keep(~!is.na(.) && .) %>%
      names() %>%
      {icons[.]}

    span(c(list(label), icons))
  })
}

get_guidelines_methods_table <- function(guidelines, show_columns = character(), options = list()) {
  testthat::expect_true(length(names(show_columns)) == length(show_columns))

  if(nrow(guidelines$methods_aggr) == 0) {
    span(class = "text-danger", "No methods fullfilling selection")
  } else {
    # remove duplicate columns
    method_columns <- guidelines$method_columns %>%
      group_by(column_id) %>%
      slice(n()) %>%
      ungroup()

    # add or remove columns based on `show_columns`
    if (is.null(show_columns)) {show_columns <- character()}
    names(show_columns) <- gsub("^column_(.*)", "\\1", names(show_columns))
    method_columns <- method_columns %>%
      filter(
        isTRUE(show_columns[method_columns$column_id]) |
          show_columns[method_columns$column_id] %in% c("true", "indeterminate") |
          is.na(show_columns[method_columns$column_id])
      ) %>%
      bind_rows(
        tibble(
          column_id = names(show_columns[show_columns == "true" | isTRUE(show_columns)]) %>% as.character() %>% setdiff(method_columns$column_id)
        )
      )

    # add renderers
    method_columns <- method_columns %>%
      left_join(get_renderers(), c("column_id" = "column_id")) %>%
      mutate(renderer = map(renderer, ~ifelse(is.null(.), function(x) {x}, .)))

    # add labels
    method_columns <- method_columns %>%
      mutate(
        label = add_icons(label, lst(filter, order), list(filter = icon("filter"), order = icon("sort-amount-asc")))
      )

    # order columns
    method_columns <- method_columns %>%
      mutate(order = case_when(!is.na(default)~default, filter~1, order~2, TRUE~3)) %>%
      left_join(get_column_categories(), "category") %>%
      arrange(category_order, order)

    # extract correct columns from guidelines
    methods <- guidelines$methods_aggr %>% select(!!method_columns$column_id)

    if (ncol(methods) == 0) {
      span(class = "text-danger", "No columns selected")
    } else {
      # render individual columns
      methods_rendered <- methods %>%
        map2(method_columns$renderer, function(col, renderer) {
          if ("options" %in% names(formals(renderer))) {
            renderer(col, options)
          } else {
            renderer(col)
          }
        }) %>%
        as_tibble()

      # get information on categories
      rle_group <- function(x) {
        rle <- rle(x)
        unlist(map2(seq_along(rle$length), rle$length, rep))
      }

      method_column_categories <- method_columns %>%
        mutate(run = rle_group(category)) %>%
        group_by(run, category) %>%
        summarise(colspan = n(), color = first(color))

      # construct html of table
      methods_table <- tags$table(
        class = "table table-responsive",
        tags$tr(
          pmap(method_column_categories, function(category, colspan, color, ...) {
            tags$th(
              label_capitalise(category),
              style = paste0("background-color:", color),
              class = "method-column-header method-column-header-category",
              colspan = colspan
            )
          })
        ),
        tags$tr(
          pmap(method_columns, function(label, title, style, ...) {
            tags$th(
              label,
              `data-toggle` = "tooltip",
              `data-placement` = "top",
              title = title,
              style = ifelse(is.na(style), "", style),
              class = "method-column-header tooltippable"
            )
          })
        ),
        map(
          seq_len(nrow(methods)),
          function(row_i) {
            row_rendered <- extract_row_to_list(methods_rendered, row_i)
            row <- extract_row_to_list(methods, row_i)
            if ("selected" %in% names(row) && row$selected) {
              class <- "selected"
            } else {
              class <- ""
            }

            tags$tr(
              class = class,
              map(row_rendered, .f = tags$td)
            )
          }
        ),
        tags$script('activeTooltips()')
      )

      methods_table
    }
  }
}