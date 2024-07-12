library(shinydashboard)

render_total_observations_box <- function(selected_species_data) {
  renderInfoBox({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      total_observations <- 0
    } else {
      species$individualCount <- as.numeric(species$individualCount)
      total_observations <- sum(species$individualCount, na.rm = TRUE)
    }
    infoBox("Total Observations", total_observations, icon = icon("binoculars"), color = "aqua", width = 10)
  })
}

render_start_date_box <- function(selected_species_data) {
  renderInfoBox({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      start_date <- NA
    } else {
      start_date <- min(species$eventDate, na.rm = TRUE)
    }
    infoBox("Start Date", as.character(start_date), icon = icon("calendar"), color = "green", width = 10)
  })
}

render_end_date_box <- function(selected_species_data) {
  renderInfoBox({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      end_date <- NA
    } else {
      end_date <- max(species$eventDate, na.rm = TRUE)
    }
    infoBox("End Date", as.character(end_date), icon = icon("calendar"), color = "red", width = 10)
  })
}

render_species_count_box <- function(species_data) {
  renderInfoBox({
    req(species_data())
    species <- species_data()
    if (is.null(species) || nrow(species) == 0) {
      species_count <- 0
    } else {
      species_count <- length(unique(species$vernacularName))
    }
    infoBox("Species Count", species_count, icon = icon("leaf"), color = "purple", width = 10)
  })
}