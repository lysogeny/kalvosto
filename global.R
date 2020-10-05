library("shiny")
library("yaml")
#library("shinyjs") # this is not explicitly imported
library("ggplot2")
library("plotly")
library("viridis")
library("Matrix")
#library("clusterProfiler")

# NB: currently there is a problem that all plots get drawn 4 times on initial
# load, and on reset. I have not been able to fix this.
# Unfortunately there doesn't really seem to be a good way of fixing this.
# I can only mitigate this by using debounce and throttle, but that's not
# really a good solution either.

# If you want to modify the theme of the plots, I suggest you do it here. This
# will avoid repetitions.
here_theme <- theme_bw()
theme_set(here_theme)

## Data Handling 
# Data is as follows:
# - App accepts an h5ad file (for example produced by python anndata)
#   Basically just hdf5 with specific attribute names
# - This app converts the h5ad to an intermediate format for faster reading.
# - a meta.yaml Describes the data about the app (default columns, title)

# TODO: Consider adding a module for changing preferences in meta.yaml

file_h5ad <- "data/data.h5ad"
file_rds <- "data/data.rds"
file_meta <- "data/meta.yaml"

# Check RDS are up to date and present
if ((!file.exists(file_rds)) | (file.info(file_h5ad)$mtime > file.info(file_rds)$mtime)) {
  # build RDS if they are out of date or missing
  message("Rebuilding RDS cache")
  source("prepareRDS.R")
}

######### Read RDS
rdsdat <- readRDS(file_rds)
mat <- rdsdat$mat
annotations <- rdsdat$rows
cols <- rdsdat$cols
rm(rdsdat)

if (file.exists(file_meta)) {
  meta <- read_yaml(file_meta)
} else {
  meta <- list(
    title="Assign a name to this by creating 'data/meta.yaml'",
    default_x=colnames(cols)[1],
    default_y=colnames(cols)[2],
    default_z=colnames(cols)[3],
    default_gene=colnames(mat)[1]
  )
}

######### discrete colour

## Create viridis colour scales
scales_disc <- list(
  Viridis=scale_colour_viridis(discrete=T),
  Rainbow=discrete_scale("colour", "rainbow", palette=rainbow),
  Topographical=discrete_scale("colour", "topo", palette=topo.colors),
  Heatmap=discrete_scale("colour", "heat", palette=heat.colors),
  CyanMagenta=discrete_scale("colour", "cm", palette=cm.colors)
)
## Create brewer colour scales
# Discrete colour scales
brewer_palettes <- list(
  seq = c("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd"),
  div = c("BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral"),
  qual = c("Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3")
)
brewer_palettes <- stack(brewer_palettes)
names(brewer_palettes) <- c("type", "pal")
scales_brew <- Map(function(x, y) scale_colour_brewer(type=x, palette=y),
                   as.character(brewer_palettes$pal), as.character(brewer_palettes$type))
names(scales_brew) <- paste("Brewer", brewer_palettes$pal, brewer_palettes$type)
scales_dist <- Map(function(x, y) scale_colour_distiller(type=x, palette=y), 
                   as.character(brewer_palettes$pal), as.character(brewer_palettes$type))
names(scales_dist) <- paste("Distiller", brewer_palettes$pal, brewer_palettes$type)

more_scales <- lapply(hcl.pals(), function(name) discrete_scale("colour", name, function(n) hcl.colors(n, palette=name)))
names(more_scales) <- hcl.pals()
scales_disc <- c(scales_disc, more_scales, scales_brew)

########### continuous colour

scales_cont <- list(ViridisC=scale_colour_viridis())
scales_cont_gen <- lapply(hcl.pals(), function(x) scale_colour_gradientn(colors=hcl.colors(16, x)))
names(scales_cont_gen) <- hcl.pals()
scales_cont <- c(scales_cont, scales_cont_gen, scales_dist)

message(paste("I have", length(scales_cont), "continuous and", length(scales_disc), "discrete colour scales"))

################ MODULES

module_base_dir <- "modules"
# Either disable modules
#modules_disable <- c("Simple Plot")
#module_names <- dir(module_base_dir, full.names=F)
#module_names <- setdiff(module_names, modules_disable)

# Or explicitly enable them. This way you can order the tab panes
module_names <- c("Basic Plot", "Twin View", "Selection Table", "Selection Differences")


# Handle module globals
Map(function(x) source(paste0(module_base_dir, '/', x, '/global.R')), module_names)
