MPG Ranch Ecology Tools
================

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/overview.png?raw=true" width="100%" />

## Introduction

Welcome to the
<a href="https://mpgranch.shinyapps.io/ecology_tools/">Ecology Tools
app</a>\*, a resource developed to support research and management at
MPG Ranch. One critical objective in ecology is understanding how
biological patterns correlate with environmental conditions, such as
aspects of terrain (abiotic), vegetation structure (biotic), and
land-use history (anthropogenic). Ecology Tools visualizes environmental
variability and facilitates its study across the property. Some use
cases for the app include selection of survey sites, identifying areas
environmentally similar to a point of interest, guiding native seed
collection, and identifying homogeneous units for targeted restoration
seeding.

\*<i>Please note that this tool is not yet optimized for smart phone or
tablet devices.</i>

## Background

At the heart of the app is a product that depicts environmental
sub-divisions, or clusters, across MPG Ranch. Within each cluster you
will find conditions are homogeneous in terms of elevation, slope, solar
inputs, drainage, plant canopy cover, plant canopy height, and
probability of past agricultural activity. These clusters do not
represent an attempt to classify the study region into discrete habitat
types, though there may be some correspondence. The clusters are best
thought of as a device to evenly sample the range of environmental
conditions present on the property. Observing the full range of
conditions is critical to training contemporary models that learn by
example. For further information on the methods for developing the
clusters please refer to
<a href="https://docs.google.com/document/d/e/2PACX-1vTcnPVBAkI0Pbwa0gc0LmNPKL_91BtwnLOWDMSwurHrc_D9l45IKcbwOtw3Uhu_iA4zTXU6F5Xs1Zph/pub">this
document</a>.

## Basics

### Toggle overlays on/off

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/transparency.png?raw=true" width="100%" />

Once the app is loaded you will see an interactive map. By default the
grid point network and environmental clusters are displayed.
Transparency of the cluster overlay may be adjusted with the
transparency slider in the upper right and both points and overlay may
be toggled on and off in the layers controls, also found in the upper
right.

### Visualize cluster extent

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/highlights.png?raw=true" width="100%" />

To visualize the spatial extent of a cluster you may hover over a region
of the map with your cursor and the underlying cluster will be
highlighted in red. Note that clusters and points are colored such that
similar colors correspond to similar environmental conditions. Also note
that you can reveal the ID of any grid point by hovering your cursor
over it.

### Inspect cluster conditions

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/clust_report.png?raw=true" width="100%" />

To inspect the conditions within a cluster you may click on it. This
produces a report with a static map of the cluster extent and violin
plots that show the range and probability density of the seven
environmental properties upon which the cluster analysis was based. Also
included in this report are suggested native forb seed mixes for average
and drought years depending on whether the objective is to enhance cover
or diversity (under development).

### Filter points by sampling year

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/survey_years.png?raw=true" width="50%" />

By default all grid points are shown, but points may be filtered by
suggested annual sampling locations using the drop down menu in the
upper left corner. In this strategy a single point is observed from each
of the 63 environmental clusters each year. This strategy was developed
for the vegetation survey, but may be applied to any monitoring effort.
To download a spreadsheet and Google Earth layer containing the metadata
of the selected points, click the download button to the right of the
point selection drop down menu.

### Zoom to grid point

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/zoomto.png?raw=true" width="50%" />

To focus the map on a grid point of interest, type the ID number into
the “Zoom to point…” text box in the upper left.

## Advanced features

### Similarity mode

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/sim_mode.png?raw=true" width="50%" />

By toggling similarity mode on (switch in upper left) you can identify
sites and grid points that are environmentally similar to a point of
interest. Simply click on the map when similarity mode is active.

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/sim_output.png?raw=true" width="100%" />

After clicking a point of interest a popup will appear containing
another interactive map and table.

### Similarity map

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/sim_map.png?raw=true" width="100%" />

Within the map you will find grid points colored by their similarity to
the clicked point (blue pin) of interest as well as a heatmap, also
colored by similarity. Dark red values indicate high environmental
similarity and dark blue values indicate low similarity. Both layers may
be toggled off with the controls in the upper right

### Similarity table

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/sim_table.png?raw=true" width="100%" />

Within the popup you will also find a table that provides a ranked list
of grid points sorted by environmental similarity to the clicked point.
The environmental cluster of the grid point, its coordinates, and
environmental properties are presented in the table.

### Download data

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/sim_download.png?raw=true" width="15%" />

The products of the similarity analyses: heatmap, grid points, and table
may be downloaded for offline inspection by clicking the button at the
bottom of the popup. The grid points (.kml) will be labeled by their
similarity within Google Earth.
