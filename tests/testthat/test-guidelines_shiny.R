library(shinytest)
library(testthat)

context("Test Shiny app")

# open Shiny app and PhantomJS
app <- ShinyDriver$new(system.file("deploy", package = "dynguidelines"))

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

  app$setInputs(dynmethods = "TRUE")
  app$setInputs(dynmethods = "FALSE")
  app$setInputs(programming_interface = "TRUE")
  app$setInputs(languages = c("python", "R"))
  app$setInputs(languages = c())
  app$setInputs(programming_interface = "FALSE")

  app$setInputs(method_selection = "dynamic_n_methods")
  app$setInputs(method_selection = "fixed_n_methods")
  # get text_out
  output <- app$getValue(name = "methods_table")
  # test
  expect_is(output, "character")
})

# stop the Shiny app
app$stop()
