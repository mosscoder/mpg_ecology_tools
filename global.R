library(raster)
library(leaflet)

dim_red_stack <- stack('www/umap_cluster.tif')
pal <- read.csv('www/color_palette.csv')$pal

umap_wm <- projectRasterForLeaflet(dim_red_stack[[1:2]], method = 'bilinear')
umap_pts <- rasterToPoints(umap_wm)
umap_cells <- cellFromXY(umap_wm, umap_pts[,1:2])

clust_wm <- template <- projectRasterForLeaflet(dim_red_stack[[3]], method = 'ngb')

pal <- colorNumeric(pal, values(clust_wm), na.color = "transparent")
