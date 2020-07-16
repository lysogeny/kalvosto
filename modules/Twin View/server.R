function(input, output, session, opt) {
  # To not kill common browsers by having a drop-down menu with 50000 options,
  # the server=T argument has to be set. Unfortunately, this is not present in
  # the selectizeInput constructor, so we need an update call at the start of
  # this function.
  dims <- c("x", "y", "z", "u", "v")
  Map(function(x) updateSelectizeInput(session, paste0('twin_', x, '_gene'), server=T, choices=colnames(mat), selected=twin_default_gene), dims)

  # Returns a state-vector for the src selectboxes
  src <- reactive({
    sapply(paste0('twin_', dims, '_src'), function(x) input[[x]])
  })

  # Returns a state-vector for the gene selectboxes
  gene <- reactive({
    sapply(paste0('twin_', dims, '_gene'), function(x) input[[x]])
  })

  # Returns a state-vector for the composite result of the above boxes, i.e.
  # the pretty variable name
  feature_names <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, twin_default_gene)
    name <- ifelse(srcs == 'gene', genes, srcs)
    names(name) <- dims
    name
  })

  # Returns a data frame of features for the above variables
  feature <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, twin_default_gene)
    features <- mapply(function(src, gene) {
      if (src == 'gene' & isTruthy(gene))
        return(mat[,gene])
      else if (src == 'gene' & !isTruthy(gene))
        return(rep(0, dim(mat))[1])
      else
        return(annotations[[src]])
    }, srcs, genes, SIMPLIFY=F) 
    features <- as.data.frame(features)
    names(features) <- gsub("twin_(.*)_src", "\\1", names(features))
    features
  })

  z_colour_scale <- reactive({
    if (src()['twin_z_src'] == "gene")
      opt$scale_cont
    else if (is.numeric(feature()[['z']]))
      opt$scale_cont
    else
      opt$scale_disc
  })

  values <- reactive({
    d <- event_data('plotly_selected')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  output$twin_plot1 <- renderPlotly({
    d <- feature()
    d$row <- 1:dim(d)[1]
    name <- feature_names()
    g <- ggplot(d, aes(x, y, col=z, key=row)) +
      geom_jitter(width=ifelse(is.numeric(d$x), 0, 0.4),
                  height=ifelse(is.numeric(d$y), 0, 0.4),
                  size=opt$size, alpha=opt$alpha) +
      labs(col=name[['z']], x=name[['x']], y=name[['y']]) +
      z_colour_scale()
    return(layout(ggplotly(g, key=d$row), dragmode="lasso"))
  })#, res=150)

  output$twin_plot2 <- renderPlotly({
    d <- feature()
    d$row <- 1:dim(d)[1]
    d$w <- d$row %in% values()
    name <- feature_names()
    g <- ggplot(d, aes(u, v, col=w, key=row)) +
      geom_jitter(width=ifelse(is.numeric(d$u), 0, 0.4),
                  height=ifelse(is.numeric(d$v), 0, 0.4),
                  size=opt$size, alpha=opt$alpha) +
      labs(col='selected', x=name[['u']], y=name[['v']]) +
      scale_colour_manual(values=c('black', 'red'))
    return(layout(ggplotly(g, key=d$row)))
  })#, res=150)

  Map(function(x, y) {
    observeEvent(input[[x]], {
      ifelse(input[[x]] == 'gene', shinyjs::enable, shinyjs::disable)(y)
    })
  }, paste0('twin_', dims, '_src'), paste0('twin_', dims, '_gene')
  )


  observeEvent(input$twin_clear, {
    updateSelectInput(session, 'twin_x_src', selected=twin_default_x)
    updateSelectInput(session, 'twin_y_src', selected=twin_default_y)
    updateSelectInput(session, 'twin_z_src', selected=twin_default_z)
    updateSelectInput(session, 'twin_u_src', selected=twin_default_x)
    updateSelectInput(session, 'twin_v_src', selected=twin_default_y)
    updateSelectizeInput(session, 'twin_x_gene', server=T, 
                         choices=colnames(mat), 
                         selected=twin_default_gene)
    updateSelectizeInput(session, 'twin_y_gene', server=T, 
                         choices=colnames(mat), 
                         selected=twin_default_gene)
    updateSelectizeInput(session, 'twin_z_gene', server=T, 
                         choices=colnames(mat), 
                         selected=twin_default_gene)
    updateSelectizeInput(session, 'twin_u_gene', server=T, 
                         choices=colnames(mat), 
                         selected=twin_default_gene)
    updateSelectizeInput(session, 'twin_v_gene', server=T, 
                         choices=colnames(mat), 
                         selected=twin_default_gene)
  })
}
