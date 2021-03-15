tdir <- 'www'

dir.create(tdir)

files <- c('cluster_priorities.csv',
           'cluster_profiles.pdf',
           'color_palette.csv',
           'cover_values.pdf',
           'diversity_values.pdf',
           'umap_cluster.tif')

gcloud_bucket <- 'https://storage.googleapis.com/mpgranch_data'

links <- file.path(gcloud_bucket, files)

for(i in seq_along(files)){
  download.file(links[i], destfile = file.path(tdir, files[i]))
}


dim_red_stack <- stack(file.path(tdir,'umap_cluster.tif'))
pal <- read.csv(file.path(tdir, 'color_palette.csv'))$pal

umap_wm <- projectRasterForLeaflet(dim_red_stack[[1:2]], method = 'bilinear')
umap_pts <- rasterToPoints(umap_wm)
umap_cells <- cellFromXY(umap_wm, umap_pts[,1:2])

clust_wm <- template <- projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb')

pal <- colorNumeric(pal, values(clust_wm), na.color = "transparent")
