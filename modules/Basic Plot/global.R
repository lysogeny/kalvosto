basic_default_x <- meta$default_x
basic_default_y <- meta$default_y
basic_default_z <- meta$default_z
basic_default_gene <- meta$default_gene
basic_grouping_vars <- sapply(annotations, function(x) is.character(x) | is.factor(x) | is.logical(x))
basic_grouping_vars <- names(basic_grouping_vars)[basic_grouping_vars]
