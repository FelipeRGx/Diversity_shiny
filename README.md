Biodiversity Dashboard Documentation
Table of Contents
Introduction
Project Structure
Dependencies
Installation
Data Loading
Image Processing
UI Components
Server Logic
Deployment
Data Processing Flow
Conclusion
Introduction
The Biodiversity Dashboard is an interactive Shiny application designed to visualize biodiversity data. The dashboard allows users to select countries, species (by vernacular and scientific names), and view various statistics and visualizations related to biodiversity observations.

Project Structure
The project is organized into the following directories and files:

kotlin
Copiar código
biodiversity_dashboard/
├── data/
│   └── combined_data.csv
├── modules/
│   ├── data_loader.R
│   ├── image_processing.R
│   ├── plots.R
│   ├── info_boxes.R
├── www/
│   └── countries.txt
├── styles.css
├── ui.R
├── server.R
└── shiny-server.conf
Dependencies
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

bash
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

Data Processing Flow
The data processing flow involves several steps to ensure efficient data handling and visualization:

Data Merge: Initially, a merge is performed between the multimedia and occurrence datasets. This consolidation helps in unifying the data into a single dataset. During this process, many columns deemed unnecessary were removed, reducing the dataset size from 21 GB to 4 GB.

Country Filtering: A high-performance solution was developed and integrated to filter the data by country. This functionality utilizes ripgrep, enabling highly efficient searches. This allows for rapid and optimized selection of almost any country.

Image Retrieval and Processing:

After a country is selected via the interface, an observation image is searched for. If no image is available, a web scraping process is initiated on Wikipedia using a common URL pattern appended with the species name.
The retrieved images are processed using a Python wrapper that crops the images circularly to create icons.
These images are then graphically represented using the Mapbox API with clustering enabled.
For more details on the application flow, you can visit the following link: Biodiversity Dashboard Flow

Conclusion
The Biodiversity Dashboard provides an interactive way to explore biodiversity data. The application leverages various R packages and integrates with Python for image processing, offering a comprehensive tool for visualizing and analyzing species observations.

If you encounter any issues or have questions, please feel free to reach out.
