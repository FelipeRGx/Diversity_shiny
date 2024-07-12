library(testthat)
library(highcharter)

source("../modules/charts_module.R")


test_that("render_species_timeline_chart returns a valid highchart", {
  selected_species_data <- reactive({
    data.frame(
      eventDate = as.Date(c("2022-01-01", "2022-02-01", "2022-03-01")),
      vernacularName = c("Great Tit", "Blue Tit", "Great Tit")
    )
  })
  chart <- render_species_timeline_chart(selected_species_data)
  expect_true("shiny.render.function" %in% class(chart))
})

test_that("render_species_growth_chart returns a valid highchart", {
  selected_species_data <- reactive({
    data.frame(
      eventDate = as.Date(c("2022-01-01", "2022-02-01", "2022-03-01")),
      vernacularName = c("Great Tit", "Blue Tit", "Great Tit"),
      individualCount = c(10, 20, 30)
    )
  })
  chart <- render_species_growth_chart(selected_species_data)
  expect_true("shiny.render.function" %in% class(chart))
})