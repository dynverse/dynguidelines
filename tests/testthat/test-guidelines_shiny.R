library(shinytest)
library(testthat)

context("Test Shiny app")

# open Shiny app and PhantomJS
app <- ShinyDriver$new(system.file("deploy", package = "dynguidelines"))

test_that("A methods table is returned", {
  app$setInputs(multiple_disconnected = "TRUE")
  # get text_out
  output <- app$getValue(name = "methods_table")
  # test
  expect_is(output, "character")
})

# stop the Shiny app
app$stop()
