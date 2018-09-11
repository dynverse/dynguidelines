library(shinytest)
library(testthat)

context("Test Shiny app")

# open Shiny app and PhantomJS
app <- ShinyDriver$new(system.file("deploy", package = "dynguidelines"))
Sys.sleep(5)

test_that("A methods table is returned", {
  app$setInputs(multiple_disconnected = "TRUE")
  app$setInputs(multiple_disconnected = "FALSE")
  app$setInputs(expect_topology = "TRUE")
  app$setInputs(expected_topology = "linear")
  app$setInputs(expect_topology = "FALSE")
  app$setInputs(expect_cycles = "TRUE")
  app$setInputs(expect_cycles = "FALSE")
  app$setInputs(expect_complex_tree = "FALSE")
  app$setInputs(expect_complex_tree = "TRUE")

  app$setInputs(time = "\U221E")
  app$setInputs(memory = "\U221E")
  app$setInputs(n_cells = "1")
  app$setInputs(n_features = "1")
  app$setInputs(n_cells = "10000000")
  app$setInputs(n_features = "10000000")

  app$setInputs(dynmethods = "TRUE")
  app$setInputs(dynmethods = "FALSE")
  app$setInputs(programming_interface = "TRUE")
  app$setInputs(languages = c("python", "R"))
  app$setInputs(languages = c())
  app$setInputs(programming_interface = "FALSE")

  # get text_out
  output <- app$getValue(name = "methods_table")
  # test
  expect_is(output, "character")
})

# stop the Shiny app
app$stop()
