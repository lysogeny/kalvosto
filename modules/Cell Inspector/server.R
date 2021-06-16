function(input, output, session, opt) {
  # This is the rows that we must show the user
  dims <- c("x", "y", "z")
  Map(function(x) updateSelectizeInput(session, paste0('inspector_', x, '_gene'), server=T, choices=colnames(mat), selected=inspector_default_gene), dims)

  # Returns a state-vector for the src selectboxes
  src <- reactive({
    sapply(paste0('inspector_', dims, '_src'), function(x) input[[x]])
  })

  # Returns a state-vector for the gene selectboxes
  gene <- reactive({
    sapply(paste0('inspector_', dims, '_gene'), function(x) input[[x]])
  })

  rows <- reactive({
    d <- event_data('plotly_click')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  feature_names <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, inspector_default_gene)
    name <- ifelse(srcs == 'gene', genes, srcs)
    names(name) <- dims
    name
  })

  # Returns a data frame of features for the above variables
  feature <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, inspector_default_gene)
    features <- mapply(function(src, gene) {
      if (src == 'gene' & isTruthy(gene))
        return(mat[,gene])
      else if (src == 'gene' & !isTruthy(gene))
        return(rep(0, dim(mat))[1])
      else
        return(annotations[[src]])
    }, srcs, genes, SIMPLIFY=F) 
    features <- as.data.frame(features)
    names(features) <- gsub("inspector_(.*)_src", "\\1", names(features))
    features
  })

  output$inspector_plot <- renderPlotly({
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

  Map(function(x, y) {
    observeEvent(input[[x]], {
      ifelse(input[[x]] == 'gene', shinyjs::enable, shinyjs::disable)(y)
    })
  }, paste0('inspector_', dims, '_src'), paste0('inspector_', dims, '_gene')
  )



  z_colour_scale <- reactive({
    if (src()['inspector_z_src'] == "gene")
      opt$scale_cont
    else if (is.numeric(feature()[['z']]))
      opt$scale_cont
    else
      opt$scale_disc
  })

  dataframe1 <- reactive({
    if (isTruthy(rows())) {
      dd <- data.frame(
       # name=colnames(mat),
        value=mat[rows(),] 
      )
      rownames(dd) <- colnames(mat)
      dd[order(dd$value, decreasing=T),, drop=F]
    } else {
      data.frame()
    }
  })

  dataframe2 <- reactive({
    if (isTruthy(rows())) {
      dd <- as.data.frame(t(annotations[rows(),]))
      colnames(dd) <- "value"
      dd[order(dd$value, decreasing=T),, drop=F]
    } else {
      data.frame()
    }
  })

  output$inspector_table1 <- DT::renderDataTable({
    dataframe1()
  }, filter="none", selection="none")

  output$inspector_table2 <- DT::renderDataTable({
    dataframe2()
  }, filter="none", selection="none")


  observeEvent(input$inspector_clear, {
    updateSelectInput(session, 'inspector_x_src', selected=inspector_default_x)
    updateSelectInput(session, 'inspector_y_src', selected=inspector_default_y)
    updateSelectInput(session, 'inspector_z_src', selected=inspector_default_z)
    updateSelectInput(session, 'inspector_u_src', selected=inspector_default_x)
    updateSelectInput(session, 'inspector_v_src', selected=inspector_default_y)
    updateSelectizeInput(session, 'inspector_x_gene', server=T, 
                         choices=colnames(mat), 
                         selected=inspector_default_gene)
    updateSelectizeInput(session, 'inspector_y_gene', server=T, 
                         choices=colnames(mat), 
                         selected=inspector_default_gene)
    updateSelectizeInput(session, 'inspector_z_gene', server=T, 
                         choices=colnames(mat), 
                         selected=inspector_default_gene)
    updateSelectizeInput(session, 'inspector_u_gene', server=T, 
                         choices=colnames(mat), 
                         selected=inspector_default_gene)
    updateSelectizeInput(session, 'inspector_v_gene', server=T, 
                         choices=colnames(mat), 
                         selected=inspector_default_gene)
  })
}
