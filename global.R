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

sim_pal <- read.csv('www/sim_pal.csv')

umap_pts<- umap_pts %>%
  as.data.frame() %>%
  mutate(cluster = values(clust_wm)[umap_cells]) %>%
  left_join(sim_pal)

cluster_shap <- st_read('www/cluster_polys.shp') 

gp_full <-
  read.csv(file.path(tdir, 'grid_with_additions_and_envdat.csv')) %>%
  rename(point_age = new) %>%
  left_join(sim_pal, by = 'cluster') %>%
  mutate(id = str_pad(id, width = 3, pad = '0'))

guidance <-
  read.csv(file.path(tdir, 'guidance_2021_2041.csv')) %>% 
  mutate(id = str_pad(id, width = 3, pad = '0')) %>%
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
gp_full_ll <- gp_full %>% st_as_sf() %>% st_transform(4326)
gp_full_wm <- gp_full %>% st_as_sf() %>% st_transform(3857)
gp_full_utm <- gp_full %>% st_as_sf() %>% st_transform(26911)
gp_full_ll$long <- (gp_full_ll %>% st_coordinates())[,1]
gp_full_ll$lat <- (gp_full_ll %>% st_coordinates())[,2]
gp_full_ll <- gp_full_ll %>%
  mutate(easting = (gp_full_utm %>% st_coordinates())[,1],
         northing = (gp_full_utm %>% st_coordinates())[,2],
         wm_x = (gp_full_wm %>% st_coordinates())[,1],
         wm_y = (gp_full_wm %>% st_coordinates())[,2]) %>%
  left_join(guidance) %>%
  select(id, cluster, point_age, 
         long, lat, easting, northing,
         everything())

point_choices <- c(0, 2021:2041)
names(point_choices) <- c('All grid points',
                          paste(2021:2041, 'targets'))


