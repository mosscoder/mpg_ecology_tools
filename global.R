tdir <- 'www'

dir.create(tdir)

files <- c(
  'cluster_priorities.csv',
  'cluster_profiles.pdf',
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

source_pal <- read.csv(file.path(tdir, 'color_palette.csv'))$pal

umap_wm <- projectRasterForLeaflet(dim_red_stack[[1:2]], method = 'bilinear')
umap_pts <- rasterToPoints(umap_wm)
umap_cells <- cellFromXY(umap_wm, umap_pts[,1:2])

clust_wm <- template <- projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb')

pal <- colorNumeric(source_pal, values(clust_wm), na.color = "transparent")
