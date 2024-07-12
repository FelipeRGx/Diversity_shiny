# Biodiversity Dashboard Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Dependencies](#dependencies)
4. [Installation](#installation)
5. [Data Loading](#data-loading)
6. [Image Processing](#image-processing)
7. [UI Components](#ui-components)
8. [Server Logic](#server-logic)
9. [Deployment](#deployment)
10. [Flow Explanation](#flow-explanation)
11. [Conclusion](#conclusion)

## Introduction
The **Biodiversity Dashboard** is an interactive Shiny application designed to visualize biodiversity data. The dashboard allows users to select countries, species (by vernacular and scientific names), and view various statistics and visualizations related to biodiversity observations.

You can access the live application [here](https://f631-35-184-27-9.ngrok-free.app/).

## Project Structure
The project is organized into the following directories and files:
```plaintext
your_project/
├── data/
│   └── combined_data.csv
├── www/
│   └── countries.txt
│   └── generic_icon.png
├── modules/
│   ├── helpers.R
│   ├── initial_setup.R
│   ├── map_module.R
│   ├── info_boxes_module.R
│   └── charts_module.R
├── server.R
└── ui.R
```


##Dependencies
The following R packages are required for this project:

shiny
shinydashboard
shinycssloaders
leaflet
dplyr
data.table
httr
rvest
highcharter
RColorBrewer
reticulate
Installation
To install the required R packages, run the following commands in your R console:

r
Copiar código
install.packages(c("shiny", "shinydashboard", "shinycssloaders", "leaflet", "dplyr", "data.table", "httr", "rvest", "highcharter", "RColorBrewer", "reticulate"))
Additionally, install any required Python packages using reticulate and ensure the virtual environment is properly set up:

r
Copiar código
use_virtualenv("~/.virtualenvs/r-reticulate", required = TRUE)
Data Loading
The data_loader.R module is responsible for loading and filtering the biodiversity data from a CSV file. The module contains functions to read the data, filter it by country, and manage the reactive data table combined_data.

Functions
load_data_by_country(country): Loads data filtered by the specified country using ripgrep.
countries: List of countries loaded from a text file.
Image Processing
The image_processing.R module handles the retrieval and processing of species images. This includes functions to download images from Wikipedia and remove image backgrounds using OpenCV.

Functions
remove_background(input_path, output_path): Removes the background from an image using a circular or oval mask.
get_wikipedia_image(query): Retrieves the URL of an image from Wikipedia based on the species name.
UI Components
The ui.R file defines the user interface of the dashboard using the shinydashboard package. The UI includes selectors for country and species, date range slider, and various output elements such as maps, charts, and info boxes.

Main Components
dashboardHeader(): Defines the header of the dashboard.
dashboardSidebar(): Contains selectors for country, species names, and a date range slider.
dashboardBody(): Includes the main content area with maps, charts, and info boxes.
Server Logic
The server.R file contains the server-side logic of the Shiny application. It includes reactive expressions and observers to handle data updates, generate plots, and update the UI components based on user input.

Main Logic
Observers to update species selectors and clear selections.
Reactive expressions to filter and process the selected data.
Rendering functions for maps (leaflet), timelines, and growth charts (highcharter).
Info boxes to display summary statistics.
Deployment
To deploy the application using Shiny Server, ensure the shiny-server.conf file is properly configured:

plaintext
Copiar código
run_as shiny;
preserve_logs true;
http_keepalive_timeout 300;

server {
  listen 80;

  location / {
    app_idle_timeout 1800;
    app_init_timeout 1800;
    site_dir /srv/shiny-server;
    log_dir /var/log/shiny-server;
    directory_index on;
  }
}
Place the project directory (biodiversity_dashboard/) under /srv/shiny-server/ and ensure the Shiny Server is running.

Flow Explanation
The flow of the Biodiversity Dashboard is as follows:

Data Merge: The multimedia and occurrence datasets were merged, reducing data size from 21 GB to 4 GB by removing unnecessary columns.
High-Performance Filtering: Data is filtered by country using ripgrep for efficient searches.
Species Image Retrieval: Searches for images of observations when a country is selected. If no image is available, images are fetched from Wikipedia.
Image Processing: Images are processed using a Python wrapper that crops them into circular icons.
Visualization: Processed images are displayed on a map using Mapbox, with clustering for optimized visualization of multiple observations.
Conclusion
The Biodiversity Dashboard provides an interactive way to explore biodiversity data. The application leverages various R packages and integrates with Python for image processing, offering a comprehensive tool for visualizing and analyzing species observations.

If you encounter any issues or have questions, please feel free to reach out.
