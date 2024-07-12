library(testthat)
# Asegúrate de que el nombre del paquete sea correcto
source("../modules/helpers.R")


test_that("get_wikipedia_image returns a valid URL", {
  result <- get_wikipedia_image("Great Tit")
  expect_true(grepl("^https://", result))
})

test_that("get_wikipedia_image returns NULL for non-existing species", {
  result <- get_wikipedia_image("NonExistingSpecies")
  expect_null(result)
})