library(leafem)
library(leaflet)
library(leaflet.opacity)
library(shiny)
library(shinyWidgets)
library(raster)
library(rgdal)
library(pdftools)
library(scales)

source_app <- function(local = TRUE) {
  if(isTRUE(local)){
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/ui.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/server.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/global.R')
  } else{
    source('') #remote ui
    source('') #remote server
    source('') #remote global
  }
}

source_app()
shinyApp(ui = ui, 
         server = server)