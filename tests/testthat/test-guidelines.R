context("Testing")

test_that("guidelines", {
  guidelines <- guidelines(answers = answer_questions())

  expect_true("dynguidelines::guidelines" %in% attr(guidelines, "class"))
  expect_true(is_guidelines(guidelines))
  expect_is(guidelines$methods_selected, "character")
  expect_is(guidelines$methods, "tbl")
  expect_is(guidelines$answers, "tbl")
  expect_is(guidelines$method_columns, "tbl")
})