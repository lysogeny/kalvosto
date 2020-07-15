library("shiny")
#library("shinyjs") # this is not explicitly imported
library("ggplot2")
library("plotly")
library("viridis")
library("Matrix")

# NB: currently there is a problem that all plots get drawn 4 times on initial
# load, and on reset. I have not been able to fix this.
# Unfortunately there doesn't really seem to be a good way of fixing this.
# I can only mitigate this by using debounce and throttle, but that's not
# really a good solution either.

# If you want to modify the theme of the plots, I suggest you do it here. This
# will avoid repetitions.
here_theme <- theme_bw()
theme_set(here_theme)

# These files are created by the 'prepare.R' script. Please refer to that for
# information on how you shoudl shape these
# Meta contains stuff such as the title of the data and whatnot
meta <- readRDS('data/shiny/meta.rds')
annotations <- readRDS('data/shiny/annotations.rds')
mat <- readRDS('data/shiny/mat.rds')

# Pick a default gene to have as the default value for the colour scale.
default_x <- meta$default_x
default_y <- meta$default_y
default_z <- meta$default_z
default_gene <- meta$default_gene

grouping_vars <- sapply(annotations, function(x) is.character(x) | is.factor(x) | is.logical(x))
grouping_vars <- names(grouping_vars)[grouping_vars]
