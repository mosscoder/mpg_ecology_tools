tdir <- 'www'

dir.create(tdir)

files <- c(
  'cluster_priorities.csv',
 # 'cluster_profiles.pdf',
  'color_palette.csv',
  'cover_values.pdf',
  'diversity_values.pdf',
  'umap_cluster.tif',
  'grid_with_additions_and_envdat.csv',
  'guidance_2021_2041.csv',
  'cluster_polys.zip'
)

gcloud_bucket <- 'https://storage.googleapis.com/mpgranch_data'

links <- file.path(gcloud_bucket, files)

for(i in seq_along(files)){
  download.file(links[i], destfile = file.path(tdir, files[i]))
}

unzip('www/cluster_polys.zip', exdir = 'www')
cluster_shap <- shapefile('www/cluster_polys.shp')
dim_red_stack <- stack(file.path(tdir,'umap_cluster.tif'))

source_pal <- read.csv(file.path(tdir, 'color_palette.csv')) %>% mutate(cluster = id) %>% select(-id)

umap_wm <- projectRasterForLeaflet(dim_red_stack[[1:2]], method = 'bilinear')
umap_pts <- rasterToPoints(umap_wm)
umap_cells <- cellFromXY(umap_wm, umap_pts[,1:2])

clust_wm <- template <- projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb')

pal <- colorNumeric(source_pal$pal, values(clust_wm), na.color = "transparent")

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
gp_full_ll@data$long <- gp_full_ll@coords[, 1]
gp_full_ll@data$lat <- gp_full_ll@coords[, 2]
gp_full_ll@data <- gp_full_ll@data %>%
  mutate(easting = gp_full@coords[, 1],
         northing = gp_full@coords[, 2]) %>%
  left_join(source_pal) %>%
  left_join(guidance) %>%
  select(id, cluster, point_age,# sample_year, 
         long, lat, easting, northing,
         everything())

point_pal <- colorFactor(source_pal, gp_full_ll$cluster, na.color = "transparent")

point_choices <- c(0, 2021:2041)
names(point_choices) <- c('All grid points',
                          paste(2021:2041, 'targets'))


