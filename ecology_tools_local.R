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

source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/global.R')
source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/ui.R')
source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/server.R')

shinyApp(ui = ui, server = server)