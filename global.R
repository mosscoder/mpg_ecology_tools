tdir <- 'www'

dir.create(tdir)

base_file <- 'ecology_tools_dat.zip'

gcloud_bucket <- 'https://storage.googleapis.com/mpgranch_data'
base_url <- file.path(gcloud_bucket, base_file)
md_url <- 'https://raw.githubusercontent.com/mosscoder/mpg_ecology_tools/main/README.md'
standing_pt_url <- 
  'https://docs.google.com/spreadsheets/d/e/2PACX-1vQ_fKMa804Ibq9hlpnAmtgCePybZard2-j-8wnlHMcGKbknJ7q0jzhOQ6tz33p8lOvcYgu5eE1mpIns/pub?gid=0&single=true&output=csv'

download.file(base_url, destfile = file.path(tdir, base_file))
download.file(md_url, destfile = file.path(tdir, 'readme.md'))
download.file(standing_pt_url, destfile = file.path(tdir, 'standing_pts.csv'))

unzip('www/ecology_tools_dat.zip', exdir = 'www')
dim_red_stack <- raster::stack(file.path(tdir,'umap_cluster.tif'))

umap_pts <- rasterToPoints(dim_red_stack)
umap_cells <- cellFromXY(dim_red_stack, umap_pts[,1:2])

sim_pal <- read.csv('www/sim_pal.csv')

umap_pts <- umap_pts %>%
  as.data.frame() %>%
  rename(axis_1 = umap_cluster.1,
         axis_2 = umap_cluster.2,
         cluster = umap_cluster.3
         ) %>%
  left_join(sim_pal)

cluster_shap <- st_read('www/cluster_polys.shp') 

standing_pts <- read.csv(file.path(tdir, 'standing_pts.csv')) %>% 
  mutate(id = str_pad(id, width = 3, pad = '0')) %>%
  rename(sp = priority)
  
base_low_priorities <- read.csv('./www/low_priority_list.csv') %>% 
  mutate(bp = 'lower') %>%
  mutate(id = str_pad(id, width = 3, pad = '0'))

gp_full <-
  read.csv(file.path(tdir, 'grid_with_additions_and_envdat.csv')) %>%
  rename(point_age = new) %>%
  left_join(sim_pal, by = 'cluster') %>%
  mutate(id = str_pad(id, width = 3, pad = '0'),
         priority = 'higher') %>% 
  left_join(base_low_priorities) %>%
  mutate(priority = ifelse(bp != priority & !is.na(bp), bp, priority)) %>%
  left_join(standing_pts) %>%
  mutate(priority = ifelse(sp != priority & !is.na(sp), sp, priority)) %>%
  select(-bp, -sp)

standing_inds <- which(gp_full$id %in% standing_pts$id)
gp_full$standing <- 0
gp_full$standing[standing_inds] <- 1

guidance <-
  read.csv(file.path(tdir, 'guidance_2021_2041_safe_points.csv')) %>% 
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
gp_full_utm <- gp_full %>% st_as_sf() %>% st_transform(26911)
gp_full_ll$long <- (gp_full_ll %>% st_coordinates())[,1]
gp_full_ll$lat <- (gp_full_ll %>% st_coordinates())[,2]
gp_full_ll <- gp_full_ll %>%
  mutate(easting = (gp_full_utm %>% st_coordinates())[,1],
         northing = (gp_full_utm %>% st_coordinates())[,2]) %>%
  left_join(guidance) %>%
  select(id, cluster, point_age, standing, priority,
         long, lat,
         easting, northing,
         everything()) %>%
  arrange(id) 

point_choices <- c(0, 2021:2041)
names(point_choices) <- c('All grid points',
                          paste(2021:2041, 'targets'))




flag_url <- 'https://upload.wikimedia.org/wikipedia/commons/c/ce/Farm-Fresh_flag_orange.png'
flag_icon <- makeIcon(
  iconUrl = flag_url,
  iconWidth = 20, iconHeight = 20,
  iconAnchorX = -3, iconAnchorY = 22,

)



