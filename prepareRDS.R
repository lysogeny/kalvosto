# Convert h5ad to rds

# I need a hdf5 library
library("rhdf5")

# If you run this script alone for debug or something
if (!exists("file_h5ad")) {
  file_h5ad <- "data/data.h5ad"
}

h5 <- h5dump(file_h5ad)

out <- list()

# Mat
out$mat <- t(h5$X)
rownames(out$mat) <- h5$obs$`_index`
colnames(out$mat) <- h5$var$`_index`

# Row annotations
out$rows <- h5$obs[Filter(function(n) substr(n, 1, 1) != "_", names(h5$obs))]
for (name in names(h5$obs$`__categories`)) {
  out$rows[[name]] = h5$obs$`__categories`[[name]][out$rows[[name]]+1]
}
out$rows <- as.data.frame(out$rows)
if ("obsm" %in% names(h5)) {
  out$rows <- cbind(
    out$rows, 
    do.call(
      cbind,
      unname(
        mapply(function(d, n) setNames(data.frame(t(d)), paste0(n, 1:nrow(d))),
               h5$obsm, names(h5$obsm), SIMPLIFY=F)
      )
    )
  )
}
if (prod(dim(out$rows)) > 0) {
  rownames(out$rows) <- h5$obs$`_index`
}

# Column annotations
out$cols <- h5$var[Filter(function(n) substr(n, 1, 1) != "_", names(h5$var))]
for (name in names(h5$var$`__categories`)) {
  out$cols[[name]] = h5$var$`__categories`[[name]][out$cols[[name]]+1]
}
out$cols <- as.data.frame(out$cols)
if ("varm" %in% names(h5)) {
  out$cols <- cbind(
    out$cols,
    do.call(
      cbind,
      unname(
        mapply(function(d, n) setNames(data.frame(t(d)), paste0(n, 1:nrow(d))),
               h5$varm, names(h5$varm), SIMPLIFY=F)
      )
    )
  )
}
if (prod(dim(out$cols)) > 0) {
  rownames(out$cols) <- h5$var$`_index`
}



# Then I save the output
saveRDS(out, "data/data.rds")


####

