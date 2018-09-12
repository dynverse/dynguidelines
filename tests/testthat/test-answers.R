context("Testing answers")


test_that("answer_questions", {
  answers <- answer_questions()
  testthat::expect_true(all(answers$source == "default"))

  answers <- answer_questions(multiple_disconnected = TRUE)
  testthat::expect_false(all(answers$source == "default"))
  testthat::expect_true(answers$source[answers$question_id == "multiple_disconnected"] == "adapted")
})

test_that("answer_questions_docs", {
  answers_questions_docs <- dynguidelines:::answer_questions_docs()
  testthat::expect_is(answers_questions_docs, "character")
})

test_that("get_answers_code", {
  answers <- answer_questions()
  testthat::expect_true(startsWith(get_answers_code(answers), "# Reproduces the guidelines as created in the shiny app\nanswers <- dynguidelines::answer_questions()"))

  answers <- answer_questions(multiple_disconnected = TRUE)
  testthat::expect_false(get_answers_code(answers) == "# Reproduces the guidelines as created in the shiny app\nanswers <- dynguidelines::answer_questions()")
})