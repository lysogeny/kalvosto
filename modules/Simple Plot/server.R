function(input, output, session, opt) {
  dims <- c("x", "y", "z")
  Map(function(x) updateSelectizeInput(session, paste0('simple_', x, '_gene'), server=T, choices=colnames(mat), selected=simple_default_gene), dims)

  src <- reactive({
    sapply(paste0('simple_', dims, '_src'), function(x) input[[x]])
  })

  # Returns a state-vector for the gene selectboxes
  gene <- reactive({
    sapply(paste0('simple_', dims, '_gene'), function(x) input[[x]])
  })

  # Returns a state-vector for the composite result of the above boxes, i.e.
  # the pretty variable name
  feature_names <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, simple_default_gene)
    name <- ifelse(srcs == 'gene', genes, srcs)
    names(name) <- dims
    name
  })

  # Returns a data frame of features for the above variables
  feature <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, simple_default_gene)
    features <- mapply(function(src, gene) {
      if (src == 'gene' & isTruthy(gene))
        return(mat[,gene])
      else if (src == 'gene' & !isTruthy(gene))
        return(rep(0, dim(mat))[1])
      else
        return(annotations[[src]])
    }, srcs, genes, SIMPLIFY=F) 
    features <- as.data.frame(features)
    names(features) <- gsub("simple_(.*)_src", "\\1", names(features))
    features
  })

  z_colour_scale <- reactive({
    if (src()['simple_z_src'] == "gene")
      opt$scale_cont
    else if (is.numeric(feature()[['z']]))
      opt$scale_cont
    else
      opt$scale_disc
  })

  output$simple_plot <- renderPlotly({
    d <- feature()
    d$row <- 1:dim(d)[1]
    name <- feature_names()
    g <- ggplot(d, aes(x, y, col=z, key=row)) +
      geom_jitter(width=ifelse(is.numeric(d$x), 0, 0.4),
                  height=ifelse(is.numeric(d$y), 0, 0.4)) +
      labs(col=name[['z']], x=name[['x']], y=name[['y']]) +
      z_colour_scale()
    return(layout(ggplotly(g, key=d$row), dragmode="lasso"))
  })#, res=150)

  ############ Observations

  dims <- c("x", "y", "z")
  Map(function(x, y) {
    observeEvent(input[[x]], {
      ifelse(input[[x]] == 'gene', shinyjs::enable, shinyjs::disable)(y)
    })
  }, paste0('simple_', dims, '_src'), paste0('simple_', dims, '_gene')
  )

  observeEvent(input$simple_clear, {
    updateSelectInput(session, 'simple_x_src', selected=simple_default_x)
    updateSelectInput(session, 'simple_y_src', selected=simple_default_y)
    updateSelectInput(session, 'simple_z_src', selected=simple_default_z)
    updateSelectizeInput(session, 'simple_x_gene', server=T, 
                         choices=colnames(mat), 
                         selected=simple_default_gene)
    updateSelectizeInput(session, 'simple_y_gene', server=T, 
                         choices=colnames(mat), 
                         selected=simple_default_gene)
    updateSelectizeInput(session, 'simple_z_gene', server=T, 
                         choices=colnames(mat), 
                         selected=simple_default_gene)
  })
}
