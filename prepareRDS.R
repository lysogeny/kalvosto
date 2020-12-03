# Convert h5ad to rds

# I need a hdf5 library
library("Matrix")
library("rhdf5")

# If you run this script alone for debug or something
if (!exists("file_h5ad")) {
  file_h5ad <- "data/data.h5ad"
}

h5 <- h5dump(file_h5ad)

out <- list()

# Mat
if (typeof(h5$X) == "list") {
  xattr <- h5readAttributes("data/data.h5ad", "X")
  X_indptr <- as.matrix(h5$X$indptr)[,1]
  X_indices <- as.matrix(h5$X$indices)[,1]
  X_data <- as.matrix(h5$X$data)[,1]
  if (xattr$`encoding-type` == "csr_matrix") {
    out$mat <- sparseMatrix(p=X_indptr,
                            x=X_data,
                            j=X_indices,
                            dims=xattr$shape,
                            index1=F)
  } else if (xattr$`encoding-type` == "csc_matrix") {
    out$mat <- sparseMatrix(p=X_indptr,
                            x=X_data,
                            i=X_indices,
                            dims=xattr$shape,
                            index1=F)
  } else {
    message("Unknown sparse matrix format, exiting")
    q(status=1, save="no")
  }
} else {
  out$mat <- t(h5$X)
}

obsindex <- h5readAttributes(file_h5ad, "obs")[["_index"]]
varindex <- h5readAttributes(file_h5ad, "var")[["_index"]]

rownames(out$mat) <- h5$obs[[obsindex]]
colnames(out$mat) <- h5$var[[varindex]]


# There is a raw count matrix.
if ("raw_counts" %in% names(h5$layers)) {
  if (typeof(h5$layers$raw_counts) == "list") {
    rattr <- h5readAttributes("data/data.h5ad", "/layers/raw_counts")
    raw_indptr <- as.matrix(h5$layers$raw_counts$indptr)[,1]
    raw_indices <- as.matrix(h5$layers$raw_counts$indices)[,1]
    raw_data <- as.matrix(h5$layers$raw_counts$data)[,1]
    if (rattr$`encoding-type` == "csr_matrix") {
      out$raw <- sparseMatrix(p=raw_indptr,
                              x=raw_data,
                              j=raw_indices,
                              dims=rattr$shape,
                              index1=F)
    } else if (rattr$`encoding-type` == "csc_matrix") {
      out$raw <- sparseMatrix(p=raw_indptr,
                              x=raw_data,
                              i=raw_indices,
                              dims=rattr$shape,
                              index1=F)
    } else {
      message("Unknown sparse matrix format, ignoring")
    }
  } else {
    out$raw <- t(h5$layers$raw_counts)
  }
  rownames(out$raw) <- h5$obs[[obsindex]]
  colnames(out$raw) <- h5$var[[varindex]]
}



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
# We don't want the index to be visible to the user. Likely they will just
# crash the server if they try to plot it.
out$rows <- out$rows[colnames(out$rows) != obsindex]
# Getting the indices
if (prod(dim(out$rows)) > 0) {
  rownames(out$rows) <- h5$obs[[varindex]]
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
  rownames(out$cols) <- h5$var[[varindex]]
}



# Then I save the output
saveRDS(out, file_rds)
####
