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

source_app <- function(local = FALSE, dev = FALSE) {
  if(isTRUE(local)){
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/global.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/ui.R')
  source('/Users/kyledoherty/mpgPostdoc/projects/ecology_tools/app/server.R')
    }
  if(isFALSE(local) & isFALSE(dev)){
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/global.R') #remote global
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/ui.R') #remote ui
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/server.R') #remote server
  }
  
  if(isFALSE(local) & isTRUE(dev)){
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/global.R') #remote global
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/ui.R') #remote ui
    source('https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/dev/server.R') #remote server
  }
}

source_app(local = FALSE, dev = FALSE)
shinyApp(ui = ui, 
         server = server)