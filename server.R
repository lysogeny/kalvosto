server <- function(input, output, session) {
  # To not kill common browsers by having a drop-down menu with 50000 options,
  # the server=T argument has to be set. Unfortunately, this is not present in
  # the selectizeInput constructor, so we need an update call at the start of
  # this function.
  updateSelectizeInput(session, 'x_gene', server=T,
                       choices=colnames(mat), 
                       selected=default_gene)
  updateSelectizeInput(session, 'y_gene', server=T,
                       choices=colnames(mat), 
                       selected=default_gene)
  updateSelectizeInput(session, 'z_gene', server=T,
                       choices=colnames(mat), 
                       selected=default_gene)

  src <- reactive({
    dims <- c("x", "y", "z")
    sapply(paste0(dims, '_src'), function(x) input[[x]])
  })

  gene <- reactive({
    dims <- c("x", "y", "z")
    sapply(paste0(dims, '_gene'), function(x) input[[x]])
  })

  feature_names <- reactive({
    dims <- c("x", "y", "z")
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, default_gene)
    name <- ifelse(srcs == 'gene', genes, srcs)
    names(name) <- dims
    name
  })

  feature <- reactive({
    # TODO: This should also return the variable "facet" if `facet != 'None'`
    # Basically this should return a plot-ready dataframe
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, default_gene)
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
    names(features) <- gsub("_src", "", names(features))
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

  x_feature <- reactive({
    feature()[['x']]
  })
  x_feature_name <- reactive({
    feature_names()[['x']]
  })

  y_feature <- reactive({
    feature()[['y']]
  })
  y_feature_name <- reactive({
    feature_names()[['y']]
  })

  z_feature <- reactive({
    feature()[['z']]
  })
  z_feature_name <- reactive({
    feature_names()[['z']]
  })

  z_colour_scale <- reactive({
    if (src()['z_src'] == "gene") {
      s <- scale_colour_viridis()
    } else if (is.numeric(z_feature())) {
      s <- scale_colour_viridis()
    } else {
      s <- scale_colour_discrete()
    }
    s
  })

  facet_feature <- reactive({
    if (input$group != "None") {
      annotations[[input$group]]
    } else {
      rep(0, dim(annotations)[1])
    }
  })

  faceting <- reactive({
    if (input$group != "None" | (length(input$z_gene) > 1)) {
      facet_wrap(~facet, scales=ifelse(input$axis_lock, "fixed", "free"))
    } else {
      facet_null()
    }
  })

  output$plot <- renderPlotly({
    d <- feature()
    d$row <- 1:dim(d)[1]
    g <- ggplot(d, aes(x, y, col=z, key=row)) +
      geom_jitter(width=ifelse(is.numeric(d$x), 0, 0.4),
                  height=ifelse(is.numeric(d$y), 0, 0.4)) +
      labs(col=z_feature_name(), x=x_feature_name(), y=y_feature_name()) +
      z_colour_scale() + 
      faceting()
    return(layout(ggplotly(g, key=d$row), dragmode="lasso"))
  })#, res=150)

  values <- reactive({
    d <- event_data('plotly_selected')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  output$table <- renderTable({
    if (isTruthy(values())) {
      d <- annotations[values(),]
      d <- cbind(data.frame(cell=rownames(d)), d)
      feat <- feature()[values(),]
      names(feat) <- feature_names()
      cbind(d, feat)
    }
  })

  output$sideplot <- renderPlot({
    rows <- 1:dim(annotations)[1]
    index_this <- values()
    index_other <- setdiff(rows, index_this)
    d_this <- data.frame(
      value=z_feature()[index_this],
      group=rep_len(paste0('true\n', ' (n=', length(index_this), ')'), length(index_this))
    )
    d_other <- data.frame(
      value=z_feature()[index_other], 
      group=rep_len(paste0('false\n', '(n=', length(index_other), ')'), length(index_other))
    )
    d <- rbind(d_this, d_other)
    ggplot(d, aes(group, value)) +
      geom_jitter(alpha=0.5, width=0.4, 
                  height=ifelse(is.numeric(d$value), 0, 0.4)) +
      theme(panel.background=element_rect(fill='white'),
            plot.background=element_rect(fill='transparent', colour='transparent')) +
      labs(x="Selected", y=z_feature_name())
  }, res=110, bg='transparent')

  observeEvent(input$z_gene, {
    if ((length(input$z_gene) > 1) & (input$z_src == "gene")) {
      shinyjs::disable("group")
    } else {
      shinyjs::enable("group")
    }
  })
  observeEvent(input$z_src, {
    if ((length(input$z_gene) > 1) & (input$z_src == "gene")) {
      shinyjs::disable("group")
    } else {
      shinyjs::enable("group")
    }
  })

  observeEvent(input$clear, {
    updateSelectInput(session, 'x_src', selected=default_x)
    updateSelectInput(session, 'y_src', selected=default_y)
    updateSelectInput(session, 'z_src', selected=default_z)
    updateSelectizeInput(session, 'x_gene', server=T, 
                         choices=colnames(mat), 
                         selected=default_gene)
    updateSelectizeInput(session, 'y_gene', server=T, 
                         choices=colnames(mat), 
                         selected=default_gene)
    updateSelectizeInput(session, 'z_gene', server=T, 
                         choices=colnames(mat), 
                         selected=default_gene)
  })
}
server
