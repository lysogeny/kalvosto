# About

A shiny app that offers generic exploration of single-cell datasets.
Examples will be available soon.

# Installation

## Dependencies

Make sure that the following R packages are available for your shiny server's shiny user:

- `shiny`
- `ggplot2`
- `yaml`
- `plotly`
- `viridis`
- `Matrix`
- `rhdf5` (from Bioconductor)

## Data Input

This app takes `h5ad` data as inputs. The `h5ad` format is a dialect of `hdf5`
created by [AnnData](https://github.com/theislab/anndata) (part of
[scanpy](https://scanpy.readthedocs.io/en/stable/)). The easiest way to get
`h5ad` files is by using the `anndata.write` method with `h5ad` file endings.

As `h5ad` is just a dialect of `hdf5`, it is generally possible to also create
`h5ad` files in other languages. Refer to the documentation of `AnnData` if you
wish to do that. Alternatively you can look at `generateRDS.R` in this
repository to see what you need.

## The app

Clone this app into your shiny server directory as `[name]`, i.e.:

    git clone https://github.com/lysogeny/kalvosto [name]

Then place a dataset (`data.h5ad`) in the `data` directory.
Optionally modify the `data/meta.yaml` to define some defaults (see `meta.yaml`
for details).

    $ tree data
    data
    ├── data.h5ad
    └── meta.yaml

Finally, make sure that permissions are set in such a way that your shiny user
(or group) has at least:

- `meta.yaml`: `r` (reading)

- `data/`: `rwx` (read, write, execute). Writing is necessary to create intermediate RDS files.

- `data/data.h5ad`: `rw` (read, write). Writing is necessary for the package `rhdf5` to work properly.

## Running

When you run the app for the first time or you have updated `data/data.h5ad`,
the app will create a `data/data.rds`.
This reads much faster than the hdf5. After the first run, the app should start
faster.
If you encounter strange errors related to reading or writing, check that your
permissions in the `data` directory are set properly (see above).

# Modules

This app is composed of modules. Modules are displayed as tabs in the UI.
You can modify the active modules and their order by changing `modules_enabled`
in `meta.yaml`.
You can find the modules in the `modules` directory of this repository.
Currently the following are available:

- Basic Plot: A simple plotting panel that allows for most typical plots
- Simple Plot: A simpler plotting panel
- Twin View: A panel with two plots. The right pane uses the selection as colour.
- Selection Table: A Table of selected objects
- Selection Differences: Experimental computation of fold-changes between selected and unselected groups.

## Extending

It is possible to create extra modules. Each module needs a separate
`global.R`, `server.R` and `ui.R`. For examples on this, see the existing
modules.
To avoid namespace collisions, it is strongly suggested to create a prefix for
all variables and UI elements (i.e. `basic_` or similar)

# Troubleshooting

Check the shiny server's logs for errors. A couple of common ones are:

- Something about reading or writing: Permissions in the `data` directory are probably wrong
- Something about missing packages: One of the dependencies is probably missing

If you encounter other errors, please tell me.


