library(leafem)
library(leaflet)
library(leaflet.opacity)
library(shiny)
library(shinyWidgets)
library(raster)
library(rgdal)
library(pdftools)
library(scales)

source_app <- function(local = FALSE, dev = FALSE) {
  if(isTRUE(local)){
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/ui.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/server.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/global.R')
  } else{
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/ui.R') #remote ui
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/server.R') #remote server
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/global.R') #remote global
  }
}

source_app(local = FALSE, dev = TRUE)
shinyApp(ui = ui, 
         server = server)