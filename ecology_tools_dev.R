library(leafem)
library(leaflet)
library(leaflet.opacity)
library(pdftools)
library(RANN)
library(raster)
library(rgdal)
library(scales)
library(shiny)
library(shinyWidgets)
library(sf)
library(tidyverse)

select <- dplyr::select

source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/global.R') #remote global
source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/ui.R') #remote ui
source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/server.R') #remote server

shinyApp(ui = ui, server = server)