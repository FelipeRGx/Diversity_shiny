library(leaflet)
library(dplyr)
library(data.table)

# Función para obtener la URL de una imagen de Wikipedia
get_wikipedia_image <- function(query) {
  search_url <- paste0("https://en.wikipedia.org/wiki/", URLencode(query, reserved = TRUE))
  message("Searching URL: ", search_url)
  
  page <- tryCatch({
    read_html(search_url)
  }, error = function(e) {
    message("Error fetching URL: ", search_url)
    return(NULL)
  })
  
  if (is.null(page)) {
    return(NULL)
  }
  
  img_node <- page %>%
    html_node(".mw-file-element")
  
  if (!is.null(img_node)) {
    img_url <- img_node %>%
      html_attr("src")
    
    if (!is.null(img_url) && !is.na(img_url)) {
      message("Found image URL: ", img_url)
      
      if (!startsWith(img_url, "http")) {
        img_url <- paste0("https:", img_url)
      }
      return(img_url)
    }
  }
  
  message("No image URL found.")
  return(NULL)
}

# Función para obtener la URL de la imagen
get_image_url <- function(name, combined_data, image_cache, generic_icon_url) {
  if (name %in% names(image_cache$urls)) {
    return(image_cache$urls[[name]])
  }
  
  img_url_dataset <- combined_data() %>%
    filter(vernacularName == name & !is.na(accessURI)) %>%
    select(accessURI) %>%
    .[["accessURI"]] %>%
    first()
  
  if (!is.null(img_url_dataset) && !is.na(img_url_dataset) && length(img_url_dataset) > 0) {
    image_cache$urls[[name]] <- img_url_dataset
    return(img_url_dataset)
  } else {
    wiki_img_url <- get_wikipedia_image(name)
    if (!is.null(wiki_img_url)) {
      image_cache$urls[[name]] <- wiki_img_url
      return(wiki_img_url)
    } else {
      return(generic_icon_url)
    }
  }
}

# Función para procesar las imágenes
process_images <- function(images, remove_background, image_cache, generic_icon_url) {
  sapply(images, function(img_url) {
    if (img_url != generic_icon_url) {
      if (img_url %in% names(image_cache$files)) {
        return(image_cache$files[[img_url]])
      }
      
      input_path <- tempfile(fileext = ".jpg")
      output_path <- tempfile(fileext = ".png")
      
      download.file(img_url, input_path, mode = "wb")
      remove_background(input_path, output_path)
      
      image_cache$files[[img_url]] <- output_path
      return(output_path)
    } else {
      return(img_url)
    }
  }, USE.NAMES = TRUE)
}

# Función para crear el mapa de especies
create_species_map <- function(species, combined_data, image_cache, remove_background, generic_icon_url) {
  images <- sapply(unique(species$vernacularName), get_image_url, combined_data, image_cache, generic_icon_url, USE.NAMES = TRUE)
  
  images_processed <- process_images(images, remove_background, image_cache, generic_icon_url)
  
  heatmap_data <- species %>%
    group_by(latitudeDecimal, longitudeDecimal) %>%
    summarise(frequency = sum(as.numeric(individualCount), na.rm = TRUE))
  
  pal <- colorNumeric(palette = "viridis", domain = heatmap_data$frequency)
  
  leaflet(species) %>%
    addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZmVsaXBlcm9kcmlndWV6IiwiYSI6ImNsZHh6dWloZTA3Nnczd211ZWRoanN6bmsifQ.pOwKS4z_peodWIbOR861Nw",
             attribution = 'Map data © <a href="https://www.mapbox.com/">Mapbox</a>') %>%
    addMarkers(
      lng = ~longitudeDecimal,
      lat = ~latitudeDecimal,
      icon = ~icons(
        iconUrl = images_processed[species$vernacularName],
        iconWidth = 55, iconHeight = 70
      ),
      popup = ~paste0("<b>", vernacularName, "</b><br>", scientificName),
      clusterOptions = markerClusterOptions(disableClusteringAtZoom = 11)
    ) %>%
    addHeatmap(
      lng = heatmap_data$longitudeDecimal,
      lat = heatmap_data$latitudeDecimal,
      intensity = heatmap_data$frequency * 10,
      blur = 30,
      max = 2,
      radius = 45,
      gradient = "plasma"
    )
}