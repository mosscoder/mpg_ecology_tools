library(leafem)
library(leaflet)
library(leaflet.opacity)
library(shiny)
library(shinyWidgets)
library(raster)
library(rgdal)
library(pdftools)
library(scales)

source_app <- function(local = FALSE) {
  if(isTRUE(local)){
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/ui.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/server.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/global.R')
  } else{
    source('https://github.com/mosscoder/mpg_ecology_tools/blob/main/ui') #remote ui
    source('https://github.com/mosscoder/mpg_ecology_tools/blob/main/server.R') #remote server
    source('https://github.com/mosscoder/mpg_ecology_tools/blob/main/global.R') #remote global
  }
}

source_app()
shinyApp(ui = ui, 
         server = server)