MPG Ranch Ecology Tools
================

## Introduction

Welcome to the [Ecology Tools app](mpgranch.shinyapps.io/ecology_tools),
a resource developed to support research and management at MPG Ranch.
One critical objective in ecology is understanding how biological
patterns correlate with environmental conditions, such as aspects of
terrain (abiotic), vegetation structure (biotic), and land-use history
(anthropogenic). Ecology Tools visualizes environmental variability and
facilitate its study across the property. Some use cases for the app
include selection of survey sites, identifying areas environmentally
similar to a point of interest, guiding native seed collection, and
identifying homogeneous units for targeted restoration seeding.

## Background

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/overview.png?raw=true" height="300px" style="float:right; padding:10px" />
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

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/transparency.png?raw=true" height="400px" />

Once the app is loaded you will see an interactive map. By default the
grid point network and environmental clusters are displayed.
Transparency of the cluster overlay may be adjusted with the
transparency slider in the upper right and both points and overlay may
be toggled on and off in the layers controls, also found in the upper
right.

## Visualize cluster extent

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/highlights.png?raw=true" height="400px" />

To visualize the spatial extent of a cluster you may hover over a region
of the map with your cursor and the underlying cluster will be
highlighted in red. Note that clusters and points are colored such that
similar colors correspond to similar environmental conditions.

## Inspect cluster conditions

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/clust_report.png?raw=true" height="400px" />

To inspect the conditions within a cluster you may click on it. This
produces a report with a static map of the cluster extent and violin
plots that show the range and probability density of the seven
environmental properties upon which the cluster analysis was based. Also
included in this report are suggested native forb seed mixes for average
and drought years depending on whether the objective is to enhance cover
or diversity (under development).

## Filter points by sampling year

<img src="https://github.com/mosscoder/mpg_ecology_tools/blob/dev/images/survey_years.png?raw=true" height="400px" />

By default all grid points are shown, but points may be filtered by
suggested annual sampling locations using the drop down menu in the
upper left corner. In this strategy a single point is observed from each
of the 63 environmental clusters each year. This strategy was developed
for the vegetation survey, but may be applied to any monitoring effort.
To download a spreadsheet and Google Earth layer, click the download
button to the right of the point selection drop down menu.
