server <- function(input, output,session) {
  
  output$myMap <- renderLeaflet({
    leaflet(
            options = leafletOptions(attributionControl=FALSE,
                                     zoomControl = FALSE)) %>%
      setView(lng = -114.0045, lat = 46.69875, zoom = 14) %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addLayersControl(overlayGroups = c('Environmental clusters', 'Grid points')) %>%
      addMapPane("polys", zIndex = 410) %>%
      addMapPane("markers", zIndex = 420)  %>%
      addOpacitySlider(layerId = 'simras')
    
  })
  
  observe({
    leafletProxy("myMap") %>%
      addRasterImage(clust_wm,
                     colors = colorNumeric(domain =sim_pal$cluster, sim_pal$sim_hex,
                                           na.color = "transparent"),
                     opacity = 0.7,
                     group = 'Environmental clusters',
                     project = FALSE,
                     layerId = 'simras') %>%
    addPolygons(data = cluster_shap,
                color = "transparent",
                weight = 0.25, 
                smoothFactor = 1.25,
                fillOpacity = 0,
                fillColor = 'transparent',
                group = 'Environmental clusters',
                options = pathOptions(pane = "polys"),
                highlightOptions = highlightOptions(
                  color = "black",
                  fillColor = 'red',
                  fillOpacity = 1,
                  weight = 1,
                  bringToFront = FALSE
                )
              ) 
  })
  
  focal_dat <- reactive({
    
    sel <- input$pt_select
    out <- gp_full_ll@data %>%
      pivot_longer(cols = samp_2021:samp_2041,
                   names_to = 'sample_year') %>%
      filter(value == 1) %>%
      mutate(sample_year = as.integer(str_remove(sample_year, 'samp_'))) %>%
      select(-value)
    
    if(sel > 0){
      out <- out %>% filter(sample_year == sel)
    }
    
    out
    
  })
  
  observe({
    focal_year_shp <- gp_full_ll

    if(input$pt_select != 0){
      yr_colname <- paste('samp', input$pt_select, sep='_')

      focal_year_shp <- focal_year_shp[which(focal_year_shp@data[,yr_colname] == 1),]
    }
    focal_name <- file.path('www',
                           ifelse(input$pt_select == 0, 'all_grid_points.kmz', paste(input$pt_select, '_gp_targets.kml'))
                           )


    KML(focal_year_shp, focal_name, overwrite = TRUE)

    output$points_kml <- downloadHandler(
      filename = function() {
        basename(focal_name)
      },
      content = function(file) {
        file.copy(focal_name, file)
      }

    )
  })

  
  observe({
    d <- focal_dat()
  
    leafletProxy("myMap", data = d)  %>%
      clearMarkers() %>%
      addCircleMarkers( lng= ~long, lat =~lat, 
                       radius=5.5, color='black',fillOpacity = 1, stroke = F,
                       group='Grid points', label=~id,
                       options = pathOptions(pane = "markers")) %>%
      addCircleMarkers(lng= ~long, lat =~lat,
                     radius=4, 
                     color= d$sim_hex, 
                     fillOpacity = 1, stroke = F,
                     group='Grid points', label=~id,
                     options = pathOptions(pane = "markers"))
  })
  
  observeEvent(input$myMap_click, {
    click <- input$myMap_click
    if(is.null(click))
      return()
    
    clust_id <- NA
    umap_dat <- NA
    
    click_xy <- SpatialPoints(coords = data.frame(click$lng, click$lat),
                              proj4string=CRS('+init=epsg:4326'))
    click_trans <- spTransform(click_xy, '+init=epsg:3857') 
    clust_id <- raster::extract(clust_wm, click_trans)
    umap_dat <- raster::extract(umap_wm, click_trans)
    
    if(!is.na(clust_id)  & isFALSE(input$sim_mode)){
      
      pdf_subset(file.path(tdir,'cluster_profiles.pdf'), pages = clust_id, output = file.path(tdir, 'map.pdf'))
      pdf_subset(file.path(tdir,'cover_values.pdf'), pages = clust_id, output = file.path(tdir, 'cover.pdf'))
      pdf_subset(file.path(tdir,'diversity_values.pdf'), pages = clust_id, output = file.path(tdir, 'div.pdf'))
      
      to_comb <- c(file.path(tdir, 'map.pdf'),
                   file.path(tdir, 'cover.pdf'),
                   file.path(tdir, 'div.pdf'))
      
      pdf_combine(to_comb,
                  output = file.path(tdir, 'joined.pdf'))
      
      file.remove(to_comb)
      
      output$modal_1 <- renderUI({
        showModal(modalDialog(tags$iframe(style="height:85vh; width:100%", src='joined.pdf'), size = 'l', easyClose = T, footer = NULL))
        
      })
    }
    
    
    if(!is.na(umap_dat) & isTRUE(input$sim_mode)){
      
      dists <- RANN::nn2(data = umap_dat,
                query = umap_pts[,3:4])$nn.dists %>% unlist()
      
      values(template)[umap_cells] <- 1-rescale(dists)
      
      cols <- viridis::inferno(100)
      pal <- colorNumeric(
        palette = cols,
        domain = values(template),
        na.color = 'transparent'
      )
      
      heatmap <- leaflet(options = leafletOptions(attributionControl = FALSE,
                                                  zooomControl = FALSE)) %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addRasterImage(template,
                       project = FALSE,
                       opacity = 0.5,
                       colors = pal,
                       layerId = 'heat',
                       group = 'Heatmap') %>%
        addMarkers(data = data.frame(x = click$lng, y = click$lat), lng = ~x, lat = ~y) %>%
        addLegend("bottomright", pal = pal,
                  values = values(template),
                  title = "Similarity",
                  
                  opacity = 1
        ) %>%
        addLayersControl(overlayGroups = c('Heatmap')) 
      
      heat_name <- 'www/env_sim'
      
      output$heat_kmz <- downloadHandler(
        filename = function() {
          paste(heat_name, ".kmz", sep="")
        },
        content = function(file) {
          out_heat <- projectRaster(template, crs = CRS("+proj=longlat +datum=WGS84"))
          names(out_heat) <- 'environmental_similarity'
          KML(out_heat, heat_name, col = cols, overwrite = TRUE)
          file.copy('www/env_sim.kmz', file)
        }
        
      )
      
      output$modal_2 <- renderUI(expr = {
        showModal(modalDialog(renderLeaflet({heatmap}), 
                              footer = downloadButton(outputId = 'heat_kmz', label = 'Google Earth layer'),
                              size = 'l', 
                              easyClose = T))
        
      })
      
    }
  })
  
  session$onSessionEnded(function() {
    trash <- setdiff(list.files('www', full.names = TRUE), list.dirs('www', recursive = FALSE, full.names = TRUE))
    trash <- trash[which(!trash %in% 'www/ecology_tools_dat.zip')]
    file.remove(trash)
  })
  
  
}