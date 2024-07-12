library(testthat)
library(your_project)

source("../modules/initial_setup.R")


test_that("initialize_data initializes correctly", {
  data_setup <- initialize_data()
  expect_true("country_cache" %in% names(data_setup))
  expect_true("countries" %in% names(data_setup))
  expect_true("column_names" %in% names(data_setup))
  expect_true("combined_data" %in% names(data_setup))
  expect_true("image_cache" %in% names(data_setup))
})