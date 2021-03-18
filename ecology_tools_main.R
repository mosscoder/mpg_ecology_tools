library(leafem)
library(leaflet)
library(leaflet.opacity)
library(shiny)
library(shinyWidgets)
library(raster)
library(rgdal)
library(pdftools)
library(scales)
library(tidyverse)

source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/global.R') #remote global
source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/ui.R') #remote ui
source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/server.R') #remote server

shinyApp(ui = ui, server = server)