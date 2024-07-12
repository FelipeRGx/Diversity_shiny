library(dplyr)
library(data.table)

initialize_data <- function() {
  # Inicializar caché para países ya cargados
  country_cache <- reactiveValues(data = list())
  
  # Cargar países desde el archivo TXT
  countries <- readLines("www/countries.txt")
  countries <- gsub("'", "", countries)  # Eliminar comillas simples
  
  # Leer los nombres de las columnas del archivo completo
  column_names <- names(fread("data/combined_data.csv", nrows = 1))
  
  # Inicializar combined_data vacío
  combined_data <- reactiveVal(data.table(matrix(ncol = length(column_names), nrow = 0, dimnames = list(NULL, column_names))))
  
  list(
    country_cache = country_cache,
    countries = countries,
    column_names = column_names,
    combined_data = combined_data
  )
}
