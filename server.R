library(shiny)
library(leaflet)
library(dplyr)
library(data.table)
library(httr)
library(rvest)
library(highcharter)
library(shinydashboard)
library(RColorBrewer)
library(reticulate)
library(leaflet.extras)

use_virtualenv("~/.virtualenvs/r-reticulate", required = TRUE)

# Cargar los módulos
source("modules/helpers.R")
source("modules/initial_setup.R")
source("modules/map_module.R")
source("modules/info_boxes_module.R")
source("modules/charts_module.R")

# Inicializar datos y cachés
data_setup <- initialize_data()
country_cache <- data_setup$country_cache
countries <- data_setup$countries
column_names <- data_setup$column_names
combined_data <- data_setup$combined_data
image_cache <- data_setup$image_cache

server <- function(input, output, session) {
  # Cargar países en el selectInput
  observe({
    updateSelectInput(session, "country", choices = countries, selected = "Poland")
  })
  
  # Manejar la selección de países
  observeEvent(input$country, {
    country <- input$country
    if (!is.null(country) && country != "") {
      new_country_data <- load_data_by_country(country, column_names)
      
      if (nrow(new_country_data) > 0) {
        combined_data(new_country_data)
        country_cache$data[[country]] <- new_country_data
        vernacular_names <- unique(new_country_data$vernacularName)
        if (default_species %in% vernacular_names) {
          selected_species <- default_species
        } else {
          selected_species <- vernacular_names[1]
        }
        updateSelectInput(session, "vernacular_name", choices = vernacular_names, selected = selected_species)
        updateSelectInput(session, "scientific_name", choices = unique(new_country_data$scientificName))
      }
    }
  })
  
  # Especie por defecto
  default_species <- "Great Tit"
  generic_icon_url <- "www/generic_icon.png"  # Reemplazar con la URL de un ícono genérico
  
  species_data <- reactive({
    req(input$country)  # Asegurarse de que se seleccione al menos un país
    current_data <- combined_data()
    if (input$select_all) {
      selected_data <- current_data
    } else {
      selected_data <- current_data %>% 
        filter(vernacularName %in% input$vernacular_name | scientificName %in% input$scientific_name)
    }
    return(selected_data)
  })
  
  observe({
    data <- combined_data()
    if (nrow(data) > 0) {
      vernacular_names <- unique(data$vernacularName)
      if (default_species %in% vernacular_names) {
        selected_species <- default_species
      } else {
        selected_species <- vernacular_names[1]
      }
      updateSelectInput(session, "vernacular_name", choices = vernacular_names, selected = selected_species)
      updateSelectInput(session, "scientific_name", choices = unique(data$scientificName))
    }
  })
  
  observeEvent(input$scientific_name, {
    data <- combined_data()
    selected_scientific <- input$scientific_name
    corresponding_vernacular <- data$vernacularName[data$scientificName %in% selected_scientific]
    updateSelectInput(session, "vernacular_name", selected = unique(c(input$vernacular_name, corresponding_vernacular)))
  })
  
  observeEvent(input$clear_selection, {
    updateSelectInput(session, "country", selected = "Poland")
    updateSelectInput(session, "vernacular_name", selected = default_species)
    updateSelectInput(session, "scientific_name", selected = character(0))
    updateCheckboxInput(session, "select_all", value = FALSE)
    combined_data(data.table(matrix(ncol = length(column_names), nrow = 0, dimnames = list(NULL, column_names))))
    country_cache$data <- list()
    new_country_data <- load_data_by_country("Poland")
    combined_data(new_country_data)
  })
  
  selected_species_data <- reactive({
    req(species_data())
    species_data <- species_data()
    if (nrow(species_data) == 0) {
      return(NULL)
    } else {
      species_data <- species_data %>%
        filter(eventDate >= input$time_range[1] & eventDate <= input$time_range[2]) %>%
        mutate(
          longitudeDecimal = as.numeric(longitudeDecimal),
          latitudeDecimal = as.numeric(latitudeDecimal)
        )
      if (nrow(species_data) == 0) {
        species_data <- combined_data() %>% filter(vernacularName == default_species)
      }
      return(species_data)
    }
  })
  
  observeEvent(input$vernacular_name, {
    if (length(input$vernacular_name) > 8) {
      showModal(modalDialog(
        title = "Warning",
        "You can select a maximum of 8 species at a time.",
        easyClose = TRUE,
        footer = NULL
      ))
      updateSelectInput(session, "vernacular_name", selected = input$vernacular_name[1:8])
    }
  })
  
  observe({
    if (length(input$vernacular_name) == 0) {
      data <- combined_data()
      if (nrow(data) > 0) {
        vernacular_names <- unique(data$vernacularName)
        if (default_species %in% vernacular_names) {
          selected_species <- default_species
        } else {
          selected_species <- vernacular_names[1]
        }
        updateSelectInput(session, "vernacular_name", selected = selected_species)
      }
    }
  })
  
  selected_species_multimedia <- reactive({
    req(species_data())
    multimedia <- combined_data() %>% filter(vernacularName %in% input$vernacular_name & !is.na(accessURI))
    if (nrow(multimedia) > 0) {
      return(multimedia$accessURI)
    } else {
      return(NULL)
    }
  })
  
  # Utilizar el módulo del mapa
  output$species_map <- renderLeaflet({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      return(NULL)
    }
    create_species_map(species, combined_data, image_cache, remove_background, generic_icon_url)
  })
  
  # Utilizar el módulo de info boxes
  output$total_observations <- render_total_observations_box(selected_species_data)
  output$start_date <- render_start_date_box(selected_species_data)
  output$end_date <- render_end_date_box(selected_species_data)
  output$species_count <- render_species_count_box(species_data)
  
  # Utilizar el módulo de gráficos
  output$species_timeline <- render_species_timeline_chart(selected_species_data)
  output$species_growth <- render_species_growth_chart(selected_species_data)
}