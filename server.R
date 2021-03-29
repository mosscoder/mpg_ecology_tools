server <- function(input, output,session) {
  
  showModal(modalDialog(includeMarkdown("www/readme.md"),
                        size = 'l', easyClose = T, footer = NULL))
  
  
  output$myMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(attributionControl=FALSE,
                               zoomControl = FALSE)) %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addLayersControl(overlayGroups = c('Environmental clusters', 'Grid points')) %>%
      addMapPane("polys", zIndex = 410) %>%
      addMapPane("markers", zIndex = 420) %>%
      addRasterImage(projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb'),
                     colors = colorNumeric(domain =sim_pal$cluster, sim_pal$sim_hex,
                                           na.color = "transparent"),
                     opacity = 0.7,
                     group = 'Environmental clusters',
                     project = FALSE,
                     layerId = 'simras') %>%
      addOpacitySlider(layerId = 'simras')
    
  })
  
  observe({
    leafletProxy("myMap") %>%
      addPolygons(data = cluster_shap,
                  color = "black",
                  weight = 0.2, 
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
    out <- gp_full_ll %>%
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
    focal_year_shp <- gp_full_ll %>% mutate(Name = id)
    select_val <- input$pt_select 
    
    if(select_val != 0){
      yr_colname <- paste('samp', select_val, sep='_')
      focal_year_shp <- focal_year_shp %>% filter(!!rlang::sym(yr_colname) == 1)
    }
    
    kml_name <- file.path('www',
                          ifelse(select_val == 0, 'all_grid_points.kml', paste0(select_val, '_gp_targets.kml'))
    )
    csv_name <- file.path('www',
                          ifelse(select_val == 0, 'all_grid_points.csv', paste0(select_val, '_gp_targets.csv'))
    )
    zip_name <- file.path('www',
                          ifelse(select_val == 0, 'all_grid_points.zip', paste0(select_val, '_gp_targets.zip'))
    )
    
    st_write(focal_year_shp, kml_name, driver = 'kml', delete_dsn = TRUE)
    write.csv(focal_year_shp %>% 
                as.data.frame(), csv_name, row.names = FALSE)
    
    zip(zipfile = zip_name, files = c(kml_name, csv_name), zip = 'zip', flags = '-j')
    
    output$points_kml <- downloadHandler(
      filename = function() {
        basename(zip_name)
      },
      content = function(file) {
        file.copy(zip_name, file)
      },
      contentType = 'application/zip'
      
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
  
  observeEvent(input$zoom_id,{
    format_id <- input$zoom_id %>% str_pad(width = 3, pad = '0')
    
    if(format_id %in% gp_full_ll$id){
      zoom_coords <- gp_full_ll %>% 
        filter(id == format_id) %>%
        select(long, lat)
      leafletProxy("myMap") %>%
        setView(lng = zoom_coords$long, lat = zoom_coords$lat, zoom = 18)
    }
  })
  
  observeEvent(input$myMap_click, {
    click <- input$myMap_click
    if(is.null(click))
      return()
    
    clust_id <- NA
    umap_dat <- NA
    
    click_xy <- SpatialPoints(coords = data.frame(click$lng, click$lat),
                              proj4string=CRS('+init=epsg:4326'))
    click_trans <- spTransform(click_xy, '+init=epsg:26911') 
    clust_id <- raster::extract(dim_red_stack[[3]], click_trans)
    umap_dat <- raster::extract(dim_red_stack[[1:2]], click_trans)
    
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
        showModal(modalDialog(tags$iframe(style="height:75vh; width:100%", src='joined.pdf'), size = 'l', easyClose = T, footer = NULL))
        
      })
    }
    
    
    if(!is.na(umap_dat) & isTRUE(input$sim_mode)){
      
      dists <- RANN::nn2(data = umap_dat,
                         query = umap_pts[,3:4])$nn.dists %>% unlist()
      
      template <- dim_red_stack[[1]]
      values(template)[umap_cells] <- 1-rescale(dists)
      
      point_sim <- raster::extract(template, gp_full_ll %>% 
                                     as.data.frame() %>% 
                                     select(easting, northing))
      point_dat <- data.frame(id = gp_full_ll$id,
                              cluster = gp_full_ll$cluster,
                              long = gp_full_ll$long,
                              lat = gp_full_ll$lat, 
                              similarity = point_sim %>% round(., 4),
                              gp_full_ll %>%
                                as.data.frame() %>%
                                select(Elevation:Canopy_cover) %>% round(.,2)) %>%
        arrange(-similarity)
      
      cols <- rev(RColorBrewer::brewer.pal(11, 'Spectral'))
      
      heat_ras_pal <- colorNumeric(
        palette = cols,
        domain = values(template),
        na.color = 'transparent'
      )
      
      heat_pt_pal <- colorNumeric(
        palette = cols,
        domain = point_dat$similarity,
        na.color = 'transparent'
      )
      
      heatmap <- leaflet(options = leafletOptions(attributionControl = FALSE,
                                                  zooomControl = FALSE)) %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addRasterImage(template,
                       project = TRUE,
                       opacity = 0.5,
                       colors = heat_ras_pal,
                       layerId = 'heat',
                       group = 'Heatmap') %>%
        addCircleMarkers(data = point_dat,
                         lng = ~long, lat = ~lat,
                         color = 'black',
                         radius = 4,
                         group = 'Grid points'
        ) %>%
        addCircleMarkers(data = point_dat, 
                         lng = ~long, lat = ~lat,
                         color = ~heat_pt_pal(similarity),
                         opacity = 1,
                         radius = 3,
                         label = ~id,
                         group = 'Grid points'
        ) %>%
        addMarkers(data = data.frame(x = click$lng, y = click$lat), 
                   lng = ~x, lat = ~y, label = 'Clicked point') %>%
        addLegend("bottomright", 
                  colors = rev(cols),
                  values = seq(0,1, length.out = 11),
                  labFormat = c('High', rep('',9), 'Low'),
                  labels = c('High', rep('',9), 'Low'),
                  title = "Similarity",
                  opacity = 1
        ) %>%
        addLayersControl(overlayGroups = c('Heatmap', 'Grid points')) 
      
      heat_name <- 'www/similarity_heatmap.kmz'
      table_name <- 'www/similar_points.csv'
      points_name <- 'www/similar_points.kml'
      zip_name <- 'www/similarity_files.zip'
      
      output$heat_kmz <- downloadHandler(
        filename = function() {
          basename(zip_name)
        },
        content = function(file) {
          out_heat <- projectRaster(template, crs = CRS("+proj=longlat +datum=WGS84"))
          names(out_heat) <- 'environmental_similarity'
          KML(out_heat, heat_name, col = cols, overwrite = TRUE)
          write.csv(point_dat, table_name, row.names = FALSE)
          st_write(
            st_as_sf(point_dat, coords = c('long', 'lat')) %>%
              mutate(Name = paste0('Sim-', round(similarity, 3))),
            points_name,
            driver = 'kml',
            delete_dsn = TRUE
          )
          
          zip(zipfile = zip_name, files = c(heat_name, 
                                            table_name,
                                            points_name), 
              zip = 'zip',
              flags = '-j')
          
          file.copy(zip_name, file)
          
        }
        
      )
      
      output$modal_2 <- renderUI({
        showModal(modalDialog(inputId = 'heatmap', 
                              renderLeaflet(heatmap),
                              br(),
                              renderDataTable(point_dat, #%>% select(-long,-lat),
                                              options = list(pageLength = 10, scrollX = T)),
                              footer = downloadButton(outputId = 'heat_kmz', label = 'Offline data'),
                              size = 'l', 
                              easyClose = T))
        
      })
      
    }
  })
  
  session$onSessionEnded(function() {
    # trash <- setdiff(list.files('www', full.names = TRUE), list.dirs('www', recursive = FALSE, full.names = TRUE))
    # trash <- trash[which(!trash %in% 'www/ecology_tools_dat.zip')]
    # file.remove(trash)
  })
  
  
}