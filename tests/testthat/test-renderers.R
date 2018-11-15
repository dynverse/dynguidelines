context("Test renderers")

renderers <- get_renderers()

expect_false(any(duplicated(get_renderers()$column_id)))