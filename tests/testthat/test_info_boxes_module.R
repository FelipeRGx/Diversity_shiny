library(testthat)
library(shiny)
source("../modules/info_boxes_module.R")

test_that("render_total_observations_box returns a valid InfoBox", {
  selected_species_data <- reactive({
    data.frame(individualCount = c(10, 20, 30))
  })
  info_box <- render_total_observations_box(selected_species_data)
  expect_true("shiny.render.function" %in% class(info_box))
})

test_that("render_start_date_box returns a valid InfoBox", {
  selected_species_data <- reactive({
    data.frame(eventDate = as.Date(c("2022-01-01", "2022-02-01", "2022-03-01")))
  })
  info_box <- render_start_date_box(selected_species_data)
  expect_true("shiny.render.function" %in% class(info_box))
})

test_that("render_end_date_box returns a valid InfoBox", {
  selected_species_data <- reactive({
    data.frame(eventDate = as.Date(c("2022-01-01", "2022-02-01", "2022-03-01")))
  })
  info_box <- render_end_date_box(selected_species_data)
  expect_true("shiny.render.function" %in% class(info_box))
})

test_that("render_species_count_box returns a valid InfoBox", {
  species_data <- reactive({
    data.frame(vernacularName = c("Great Tit", "Blue Tit", "Great Tit"))
  })
  info_box <- render_species_count_box(species_data)
  expect_true("shiny.render.function" %in% class(info_box))
})