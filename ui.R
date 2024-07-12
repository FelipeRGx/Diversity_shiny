library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(leaflet)
library(highcharter)

default_species <- "Great Tit"

ui <- dashboardPage(
  dashboardHeader(title = "Biodiversity Dashboard"),
  dashboardSidebar(
    width = 350,  # Ancho del sidebar ajustado
    selectInput("country", "Select Country", choices = NULL, multiple = FALSE, selected = "Poland"),
    selectInput("vernacular_name", "Select by Vernacular Name", choices = NULL, multiple = TRUE, selected = default_species),
    selectInput("scientific_name", "Select by Scientific Name", choices = NULL, multiple = TRUE),
    checkboxInput("select_all", "Select All Species", FALSE),
    uiOutput("species_list"),
    actionButton("clear_selection", "Clear Selection"),
    sliderInput("time_range", "Select Time Range:", 
                min = as.Date("1970-01-01"), 
                max = Sys.Date(), 
                value = c(as.Date("1970-01-01"), Sys.Date())),
    div(style = "text-align: center; margin-top: 20px;", h3("Species Information")),
    div(style = "text-align: center;", uiOutput("species_image")),
    verbatimTextOutput("")
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .info-box {
          min-height: 60px;  /* Ajusta esta altura según sea necesario */
        }
        .info-box-icon {
          height: 60px;  /* Asegura que el icono se ajuste a la nueva altura */
          line-height: 60px;  /* Centra el icono verticalmente */
        }
        .info-box-content {
          padding-top: 0;
          padding-bottom: 0;
        }
        .info-box-number {
          font-size: 18px;  /* Ajusta el tamaño del texto según sea necesario */
        }
      "))
    ),
    fluidRow(
      column(width = 3, infoBoxOutput("total_observations", width = 12)),
      column(width = 3, infoBoxOutput("species_count", width = 12)),
      column(width = 3, infoBoxOutput("start_date", width = 12)),
      column(width = 3, infoBoxOutput("end_date", width = 12))
    ),
    fluidRow(
      column(
        width = 12,
        leafletOutput("species_map", height = "500px", width = "100%") %>% withSpinner()  # Ajustamos la altura del mapa
      )
    ),
    fluidRow(
      column(6, box(title = "Species Timeline", highchartOutput("species_timeline", height = "230px") %>% withSpinner(), width = NULL)),
      column(6, box(title = "Species Growth Over Time", highchartOutput("species_growth", height = "230px") %>% withSpinner(), width = NULL))
    )
  )
)
