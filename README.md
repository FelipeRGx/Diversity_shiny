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
9. [Server Deployment](#Server-Deployment)
10. [Flow Explanation](#flow-explanation)

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


## Dependencies

The following R packages are required for this project:

- `shiny`
- `shinydashboard`
- `shinycssloaders`
- `leaflet`
- `dplyr`
- `data.table`
- `httr`
- `rvest`
- `highcharter`
- `RColorBrewer`
- `reticulate`

# Installation

To install the required R packages, run the following commands in your R console:

```r
install.packages(c("shiny", "shinydashboard", "shinycssloaders", "leaflet", "dplyr", "data.table", "httr", "rvest", "highcharter", "RColorBrewer", "reticulate"))```
```
Additionally, install any required Python packages using reticulate and ensure the virtual environment is properly set up:

```r
use_virtualenv("~/.virtualenvs/r-reticulate", required = TRUE)
```

## Data Loading
The data_loader.R module is responsible for loading and filtering the biodiversity data from a CSV file. The module contains functions to read the data, filter it by country, and manage the reactive data table combined_data.

### Functions
- load_data_by_country(country): Loads data filtered by the specified country using ripgrep.
- countries: List of countries loaded from a text file.

## Image Processing
The image_processing.R module handles the retrieval and processing of species images. This includes functions to download images from Wikipedia and remove image backgrounds using OpenCV.

### Functions
- remove_background(input_path, output_path): Removes the background from an image using a circular or oval mask.
- get_wikipedia_image(query): Retrieves the URL of an image from Wikipedia based on the species name.

## UI Components
The ui.R file defines the user interface of the dashboard using the shinydashboard package. The UI includes selectors for country and species, a date range slider, and various output elements such as maps, charts, and info boxes.

### Main Components
- dashboardHeader(): Defines the header of the dashboard.
- dashboardSidebar(): Contains selectors for country, species names, and a date range slider.
- dashboardBody(): Includes the main content area with maps, charts, and info boxes.

## Server Logic
The server.R file contains the server-side logic of the Shiny application. It includes reactive expressions and observers to handle data updates, generate plots, and update the UI components based on user input.

#Main Logic
- Observers to update species selectors and clear selections.
- Reactive expressions to filter and process the selected data.
- Rendering functions for maps (leaflet), timelines, and growth charts (highcharter).
- Info boxes to display summary statistics.

## Server Deployment 
To deploy the application using Shiny Server, ensure the shiny-server.conf file is properly configured:

```r
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

```

Place the project directory (biodiversity_dashboard/) under /srv/shiny-server/ and ensure the Shiny Server is running.

# Flow Explanation

The flow of the Biodiversity Dashboard is as follows:

- **Data Merge**: Initially, the multimedia and occurrence datasets were merged into a single dataset. This process involved combining both datasets and removing many unnecessary columns, which significantly reduced the total data size from 21 GB to just 4 GB.

- **High-Performance Filtering**: A high-performance solution was developed and integrated for filtering data by country. This solution uses ripgrep, a tool that allows for highly efficient searches. Thanks to this, users can quickly and optimally select almost any country.

- **Species Image Retrieval**: Once a country is selected through the interface, the system searches for images of observations in that country. If no image is available for a specific observation, a web scraping operation is performed on Wikipedia, using a common URL pattern combined with the species name. This method allows access to both information and images of the species.

- **Image Processing**: The retrieved images are processed using a Python wrapper that crops them into circular icons. This processing step ensures that the images are uniformly styled, creating circular icons that are visually consistent.

- **Visualization**: The processed images are then displayed on a map using the Mapbox API. The visualization includes clustering to optimize the display of multiple observations, enhancing the user's ability to analyze and interpret the data.

### Complementary Explanation

First, a merge between the multimedia and occurrence datasets was performed, combining both into a single dataset. During this process, many columns deemed unnecessary were deleted, reducing the data size from 21 GB to just 4 GB. Following this, a high-performance solution was developed and integrated for filtering the country field. This field uses ripgrep, enabling highly efficient searches. Consequently, users can quickly and optimally select almost any country.

Additionally, once the selected country is obtained from the interface, the system searches for an image of the observation. If there is no image available for the observation, web scraping is performed on the Wikipedia portal using a common URL combined with the species name. This approach provides access to species information and images. These images are then processed by a Python wrapper, which crops them into circular icons. Following this, the processed images are graphically represented using the Mapbox API, with clustering enabled for optimized visualization of multiple observations.

