# Generic data exploration single-cell shiny app

A shiny app that offers exploration of single-cell datasets while trying to be
as generic as possible.

## Installation

### Dependencies

Make sure that the following R packages are available on your shiny server:

- `shiny`
- `ggplot2`
- `yaml`
- `plotly`
- `viridis`
- `Matrix`
- `rhdf5` (from Bioconductor)

### The app

Clone this app into your shiny server directory i.e.:

    git clone [appurl] [name]

Then place a dataset (`data.h5ad`) in the `data` directory.
Optionally modify the `data/meta.yaml` to define some defaults (see `meta.yaml`
for details).

    $ tree data
    data
    ├── data.h5ad
    └── meta.yaml

Finally, make sure that permissions are set in such a way that your shiny user
(or group) has at least:

`meta.yaml`
:   r (reading)

`data/`
:   rwx (read, write, execute). Writing is necessary to create intermediate RDS files.

`data/data.h5ad`
:   rw (read, write). Writing is necessary for the package `rhdf5` to work properly.

### Running

When you run the app for the first time or you have updated `data/data.h5ad`,
the app will create a `data/data.rds`.
This reads much faster than the hdf5. After the first run, the app should start
faster.
If you encounter strange errors related to reading or writing, check that your
permissions in the `data` directory are set properly (see above).

## Troubleshooting

Check the shiny server's logs for errors. A couple of common ones are:

Something about reading or writing
:   Permissions in the `data` directory are probably wrong

Something about missing packages
:   One of the dependencies is probably missing

If you encounter other errors, please tell me.

