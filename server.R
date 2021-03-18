server <- function(input, output,session) {
  
  output$myMap <- renderLeaflet({
    
    leaflet(cluster_shap,
            options = leafletOptions(attributionControl=FALSE,
                                     zoomControl = FALSE)) %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addPolygons(
        color = "black",
        weight = 0.1, 
        smoothFactor = 1.25,
        fillOpacity = 0.35,
        fillColor = ~colorFactor(palette = source_pal$pal, domain = ump_cls)(ump_cls),
        group = 'Environmental clusters',
        highlightOptions = highlightOptions(
          color = "transparent",
          fillColor = 'red',
          fillOpacity = 0.75,
          weight = 1,
          bringToFront = FALSE
        )
      ) %>%
      addLayersControl( overlayGroups = c('Environmental clusters', 'Grid points'))
    
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
    
    leafletProxy("myMap", data = focal_dat())  %>%
      clearMarkers() %>%
      addCircleMarkers( lng= ~long, lat =~lat, 
                       radius=5, color='white',fillOpacity = 1, stroke = F,
                       group='Grid points', label=~id) %>%
      addCircleMarkers(lng= ~long, lat =~lat,
                     radius=4, color= ~pal, fillOpacity = 1, stroke = F,
                     group='Grid points', label=~id)
  })
  
  observe({
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
      
      dists <- unlist(lapply(FUN = function(x) {unlist(dist(rbind(umap_dat, umap_pts[x,3:4])))}, X = seq_along(umap_pts[,1])))
      
      values(template)[umap_cells] <- 1-rescale(dists)
      
      cols <- viridis::inferno(100)
      pal <- colorNumeric(
        palette = cols,
        domain = values(template),
        na.color = 'transparent'
      )
      
      heatmap <- leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addRasterImage(template,
                       project = FALSE,
                       opacity = 0.8,
                       colors = pal,
                       layerId = 'heat') %>%
        addLegend("bottomright", pal = pal,
                  values = values(template),
                  title = "Similarity",
                  
                  opacity = 1
        ) %>%
        addOpacitySlider(layerId = 'heat') 
      
      out_heat <- projectRaster(template, crs = CRS("+proj=longlat +datum=WGS84"))
      names(out_heat) <- 'environmental_similarity'
      heat_name <- 'www/env_sim'
      KML(out_heat, heat_name, col = cols, overwrite = TRUE)
      
      output$heat_kmz <- downloadHandler(
        filename = function() {
          paste(heat_name, ".kmz", sep="")
        },
        content = function(file) {
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
    trash <- c('www/joined.pdf',
               'www/env_sim.kmz')
    for(i in trash){
    file.remove(i)
    }
  })
  
  
}