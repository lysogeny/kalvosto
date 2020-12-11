server <- function(input, output, session, opt) {
  dims <- c("x", "y", "z")

  # To not kill common browsers by having a drop-down menu with 50000 options,
  # the server=T argument has to be set. Unfortunately, this is not present in
  # the selectizeInput constructor, so we need an update call at the start of
  # this function.
  Map(function(x) updateSelectizeInput(session, paste0('basic_', x, '_gene'), server=T, choices=colnames(mat), selected=basic_default_gene), dims)

  src <- reactive({
    sapply(paste0('basic_', dims, '_src'), function(x) input[[x]])
  })

  gene <- reactive({
    sapply(paste0('basic_', dims, '_gene'), function(x) input[[x]])
  })

  feature_names <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, basic_default_gene)
    name <- ifelse(srcs == 'gene', genes, srcs)
    names(name) <- dims
    if (input$basic_log_z) {
      name['z'] <- paste0('log1p(', name['z'], ')')
    }
    name
  })

  # This represents the data that will be plotted.
  feature <- reactive({
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, basic_default_gene)
    features <- mapply(function(src, gene) {
      if (src == 'gene' & isTruthy(gene) & length(gene) == 1)
        return(mat[,gene])
      else if (src == 'gene' & isTruthy(gene) & length(gene > 1))
        return(as.matrix(mat[,gene]))
      else if (src == 'gene' & !isTruthy(gene))
        return(rep(0, dim(mat))[1])
      else
        return(annotations[[src]])
    }, srcs, genes, SIMPLIFY=F) 
    features <- as.data.frame(features) # as.matrix will densify
    names(features) <- gsub("basic_(.*)_src", "\\1", names(features))
    # Handle z axis transformations
    if (class(features$z) %in% c("factor", "character")) {
      updateCheckboxInput(session, "basic_log_z", value=F)
      shinyjs::disable("basic_log_z")
    } else {
      shinyjs::enable("basic_log_z")
      if (input$basic_log_z) {
        features[names(features)[-(1:2)]] <- lapply(names(features)[-(1:2)], function(x) log1p(features[[x]]))
      }
    }
    # This checks if we are faceting by gene
    faceted_vars <- grep("\\..+", colnames(features))
    if (length(faceted_vars) > 0) {
      # Stacks the data frame if we are faceting by genes
      stacked <- stack(features, faceted_vars)
      colnames(stacked) <- c("z", "facet")
      stacked$facet <- gsub("z\\.", "", stacked$facet)
      features <- cbind(features[-faceted_vars], stacked)
      # User has selected many many genes
    } else {
      features$facet <- facet_feature()
    }
    features
  })

  z_colour_scale <- reactive({
    if (src()['basic_z_src'] == "gene") {
      s <- opt$scale_cont
    } else if (is.numeric(feature()[['z']])) {
      s <- opt$scale_cont
    } else {
      s <- opt$scale_disc
    }
    s
  })

  facet_feature <- reactive({
    if (input$basic_group != "None") {
      annotations[[input$basic_group]]
    } else {
      rep(0, dim(annotations)[1])
    }
  })

  faceting <- reactive({
    if (input$basic_group != "None" | (length(input$basic_z_gene) > 1)) {
      facet_wrap(~facet, scales=ifelse(input$basic_axis_lock, "fixed", "free"))
    } else {
      facet_null()
    }
  })

  output$basic_plot <- renderPlotly({
    d <- feature()
    name <- feature_names()
    d$row <- 1:dim(d)[1]
    g <- ggplot(d, aes(x, y, col=z, key=row)) +
      geom_jitter(width=ifelse(is.numeric(d$x), 0, 0.4),
                  height=ifelse(is.numeric(d$y), 0, 0.4),
                  size=opt$size, alpha=opt$alpha) +
      labs(col=name[['z']], x=name[['x']], y=name[['y']]) +
      z_colour_scale() + 
      faceting()
    if (input$basic_asp_lock) {
      g <- g + coord_fixed()
    }
    return(layout(ggplotly(g, key=d$row), dragmode="lasso"))
  })#, res=150)

  values <- reactive({
    d <- event_data('plotly_selected')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  observeEvent(input$basic_z_gene, {
    if ((length(input$basic_z_gene) > 1) & (input$basic_z_src == "gene")) {
      shinyjs::disable("group")
    } else {
      shinyjs::enable("group")
    }
  })
  observeEvent(input$basic_z_src, {
    if ((length(input$basic_z_gene) > 1) & (input$basic_z_src == "gene")) {
      shinyjs::disable("group")
    } else {
      shinyjs::enable("group")
    }
  })

  dims <- c("x", "y", "z")
  Map(function(x, y) {
    observeEvent(input[[x]], {
      ifelse(input[[x]] == 'gene', shinyjs::enable, shinyjs::disable)(y)
    })
  }, paste0('basic_', dims, '_src'), paste0('basic_', dims, '_gene')
  )


  observeEvent(input$basic_clear, {
    updateSelectInput(session, 'basic_group', selected="None")
    updateSelectInput(session, 'basic_x_src', selected=basic_default_x)
    updateSelectInput(session, 'basic_y_src', selected=basic_default_y)
    updateSelectInput(session, 'basic_z_src', selected=basic_default_z)
    updateSelectizeInput(session, 'basic_x_gene', server=T, 
                         choices=colnames(mat), 
                         selected=basic_default_gene)
    updateSelectizeInput(session, 'basic_y_gene', server=T, 
                         choices=colnames(mat), 
                         selected=basic_default_gene)
    updateSelectizeInput(session, 'basic_z_gene', server=T, 
                         choices=colnames(mat), 
                         selected=basic_default_gene)
  })
}
server
