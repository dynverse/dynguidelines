context("Testing")

test_that("guidelines", {
  guidelines <- guidelines(answers = answer_questions())

  expect_true(is(guidelines, "dynguidelines::guidelines"))
  expect_is(guidelines$methods_selected, "character")
  expect_is(guidelines$methods_aggr, "tbl")
  expect_is(guidelines$methods, "tbl")
  expect_is(guidelines$answers, "tbl")
  expect_is(guidelines$method_columns, "tbl")
})