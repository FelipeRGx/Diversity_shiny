library(highcharter)
library(RColorBrewer)

render_species_timeline_chart <- function(selected_species_data) {
  renderHighchart({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      return(NULL)
    }
    species <- species %>% group_by(eventDate, vernacularName) %>% summarise(count = n(), .groups = 'drop')
    
    unique_species <- unique(species$vernacularName)
    color_palette <- colorRampPalette(RColorBrewer::brewer.pal(8, "Set1"))(length(unique_species))
    names(color_palette) <- unique_species
    
    hchart(species, "column", hcaes(x = eventDate, y = count, group = vernacularName)) %>%
      hc_title(text = "Species Timeline") %>%
      hc_xAxis(title = list(text = "Event Date")) %>%
      hc_yAxis(title = list(text = "Count")) %>%
      hc_plotOptions(column = list(
        dataLabels = list(enabled = TRUE),
        enableMouseTracking = TRUE,
        animation = list(duration = 2000)
      )) %>%
      hc_colors(color_palette[species$vernacularName]) %>%
      hc_add_theme(hc_theme_google())
  })
}

render_species_growth_chart <- function(selected_species_data) {
  renderHighchart({
    req(selected_species_data())
    species <- selected_species_data()
    if (is.null(species) || nrow(species) == 0) {
      return(NULL)
    }
    
    # Convertir eventDate a formato Date
    species$eventDate <- as.Date(species$eventDate)
    
    # Asegurarse de que individualCount sea numérico
    species$individualCount <- as.numeric(species$individualCount)
    
    # Eliminar filas donde individualCount es NA o cero
    species <- species %>% 
      filter(!is.na(individualCount) & individualCount > 0)
    
    # Agrupar por fecha y nombre vernáculo, sumando el conteo individual
    species <- species %>% 
      group_by(eventDate, vernacularName) %>% 
      summarise(total_individuals = sum(individualCount, na.rm = TRUE), .groups = 'drop')
    
    # Crear una columna acumulativa para cada especie
    species <- species %>% 
      arrange(eventDate) %>% 
      group_by(vernacularName) %>% 
      mutate(cumulative_count = cumsum(total_individuals))
    
    unique_species <- unique(species$vernacularName)
    color_palette <- colorRampPalette(RColorBrewer::brewer.pal(8, "Set1"))(length(unique_species))
    names(color_palette) <- unique_species
    
    hchart(species, "spline", hcaes(x = eventDate, y = cumulative_count, group = vernacularName)) %>%
      hc_title(text = "Species Growth Over Time") %>%
      hc_xAxis(
        title = list(text = "Date"),
        type = "datetime",
        dateTimeLabelFormats = list(
          day = '%Y-%m-%d',
          week = '%Y-%m-%d',
          month = '%Y-%m',
          year = '%Y'
        ),
        labels = list(format = '{value:%Y}')
      ) %>%
      hc_yAxis(title = list(text = "Cumulative Count")) %>%
      hc_plotOptions(spline = list(
        dataLabels = list(enabled = FALSE),
        enableMouseTracking = TRUE,
        animation = list(duration = 2000)
      )) %>%
      hc_colors(color_palette[species$vernacularName]) %>%
      hc_add_theme(hc_theme_google())
  })
}