library(dplyr)
library(data.table)
library(reticulate)

load_data_by_country <- function(country, column_names) {
  rg_cmd <- sprintf("rg ',%s,' data/combined_data.csv", country)
  message(sprintf("Executing command: %s", rg_cmd))
  
  tryCatch({
    country_data <- fread(cmd = rg_cmd, col.names = column_names)
    
    # Convertir todas las columnas a caracteres primero
    country_data[] <- lapply(country_data, as.character)
    
    # Convertir columnas a los tipos adecuados y manejar valores vacíos
    country_data <- country_data %>%
      mutate(across(everything(), ~ na_if(., ""))) %>%
      mutate(
        longitudeDecimal = as.numeric(longitudeDecimal),
        latitudeDecimal = as.numeric(latitudeDecimal)
      )
    
    return(country_data)
  }, error = function(e) {
    message(sprintf("Error loading data for country: %s", country))
    message(e)
    return(data.table())
  })
}

remove_background <- function(input_path, output_path) {
  py_run_string("
import cv2
import numpy as np

def remove_background_with_silhouette(input_path, output_path):
    # Leer la imagen de entrada
    image = cv2.imread(input_path, cv2.IMREAD_UNCHANGED)
    
    if image is None:
        raise ValueError('Invalid image.')
    
    # Crear una máscara de forma circular u ovalada
    height, width = image.shape[:2]
    mask = np.zeros((height, width), dtype=np.uint8)
    
    if height == width:
        # Crear una máscara circular
        center = (width // 2, height // 2)
        radius = min(center[0], center[1], width - center[0], height - center[1])
        mask = cv2.circle(mask, center, radius, 255, -1)
    else:
        # Crear una máscara ovalada
        axes = (width // 2, height // 2)
        center = (width // 2, height // 2)
        mask = cv2.ellipse(mask, center, axes, 0, 0, 360, 255, -1)
    
    # Aplicar la máscara a la imagen
    result_image = cv2.bitwise_and(image, image, mask=mask)
    
    # Añadir un canal alfa a la imagen si no tiene uno
    if result_image.shape[2] == 3:
        result_image = cv2.cvtColor(result_image, cv2.COLOR_BGR2BGRA)
    
    # Establecer el fondo como transparente
    result_image[:, :, 3] = mask
    
    # Guardar la imagen recortada
    cv2.imwrite(output_path, result_image)
  ")
  py$remove_background_with_silhouette(input_path, output_path)
}

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
