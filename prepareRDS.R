# Convert h5ad to rds

library("rhdf5")

# I need a hdf5 library

h5 <- h5dump("data/data.h5ad")

out <- list()

# Mat

out$mat <- t(h5$X)
rownames(out$mat) <- h5$obs$`_index`
colnames(out$mat) <- h5$var$`_index`

out$rows <- cbind(
  as.data.frame(h5$obs[Filter(function(n) substr(n, 1, 1) != "_", names(h5$obs))]),
  do.call(
    cbind,
    unname(
      mapply(function(d, n) setNames(data.frame(t(d)), paste0(n, 1:nrow(d))),
             h5$obsm, names(h5$obsm), SIMPLIFY=F)
    )
  )
)
rownames(out$rows) <- h5$obs$`_index`


out$cols <- cbind(
  as.data.frame(h5$var[Filter(function(n) substr(n, 1, 1) != "_", names(h5$var))]),
  do.call(
    cbind,
    unname(
      mapply(function(d, n) setNames(data.frame(t(d)), paste0(n, 1:nrow(d))),
             h5$varm, names(h5$varm), SIMPLIFY=F)
    )
  )
)
rownames(out$cols) <- h5$var$`_index`

# Then I save the output
saveRDS(out, "data/data.rds")
