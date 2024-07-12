library(testthat)

source("../modules/map_module.R")
source("../modules/helpers.R")  # Asegúr

test_that("create_species_map generates a leaflet map", {
  species <- data.frame(
    vernacularName = c("Great Tit", "Blue Tit"),
    longitudeDecimal = c(1.5, 2.5),
    latitudeDecimal = c(50.5, 51.5),
    individualCount = c(10, 20)
  )
  combined_data <- function() species
  image_cache <- list(urls = list(), files = list())
  remove_background <- function(input_path, output_path) NULL
  generic_icon_url <- "www/generic_icon.png"
  
  map <- create_species_map(species, combined_data, image_cache, remove_background, generic_icon_url)
  expect_true("leaflet" %in% class(map))
})