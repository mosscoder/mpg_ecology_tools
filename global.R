tdir <- 'www'

dir.create(tdir)

files <- c(
  'ecology_tools_dat.zip'
)

gcloud_bucket <- 'https://storage.googleapis.com/mpgranch_data'

links <- file.path(gcloud_bucket, files)

for(i in seq_along(files)){
  download.file(links[i], destfile = file.path(tdir, files[i]))
}

unzip('www/ecology_tools_dat.zip', exdir = 'www')
dim_red_stack <- stack(file.path(tdir,'umap_cluster.tif'))

umap_wm <- template <-projectRasterForLeaflet(dim_red_stack[[1:2]], method = 'bilinear')
clust_wm <-projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb')
template <- template[[1]]
umap_pts <- rasterToPoints(umap_wm)
umap_cells <- cellFromXY(umap_wm, umap_pts[,1:2])

umap_pts <- umap_pts %>%
  as.data.frame() %>%
  mutate(sim_hex = hsv(h = rescale(umap_cluster.1 ), s = rescale(umap_cluster.2), v = 1), 
         cell = umap_cells) 

sim_rgb <- col2rgb(umap_pts$sim_hex) %>% t() %>% as.data.frame()

umap_sim_rgb <- stack(replicate(template, n = 3))
for(i in 1:3){
  values(umap_sim_rgb[[i]])[umap_cells] <- sim_rgb[,i]
}

umap_sim_ll <- projectRaster(umap_sim_rgb, crs = crs('+init=epsg:4326'))

cluster_shap <- shapefile('www/cluster_polys.shp') 

gp_full <-
  read.csv(file.path(tdir, 'grid_with_additions_and_envdat.csv')) %>%
  rename(point_age = new)

guidance <-
  read.csv(file.path(tdir, 'guidance_2021_2041.csv')) %>% 
  rename(sample_year = year) %>%
  select(id, sample_year) %>% 
  mutate(value = 1) %>%
  pivot_wider(id_cols = 'id',
              names_from = 'sample_year',
              values_from = 'value', 
              names_prefix = 'samp_') %>%
  select('id', paste('samp',2021:2041, sep = '_'))

guidance[,-1] <- ifelse(is.na(guidance[,-1]) ,0, 1)

coordinates(gp_full) <- c('x', 'y')
crs(gp_full) <- crs('+init=epsg:26911')
gp_full_ll <- spTransform(gp_full, CRSobj = crs('+init=epsg:4326'))
gp_full_wm <- spTransform(gp_full, CRSobj = crs(template))
gp_full_ll@data$long <- gp_full_ll@coords[, 1]
gp_full_ll@data$lat <- gp_full_ll@coords[, 2]
gp_full_ll@data <- gp_full_ll@data %>%
  mutate(easting = gp_full@coords[, 1],
         northing = gp_full@coords[, 2]) %>%
  mutate(pal = rgb(raster::extract(umap_sim_ll, gp_full_ll@coords), maxColorValue = 255))%>%
  left_join(guidance) %>%
  select(id, cluster, point_age, 
         long, lat, easting, northing,
         everything())

point_choices <- c(0, 2021:2041)
names(point_choices) <- c('All grid points',
                          paste(2021:2041, 'targets'))


