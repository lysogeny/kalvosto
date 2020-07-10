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
    dims <- c("x", "y", "z")
    srcs <- src()
    genes <- gene()
    gene_truthiness <- sapply(genes, isTruthy)
    genes <- ifelse(gene_truthiness, genes, default_gene)
    features <- mapply(function(src, gene) {
      if (src == 'gene' & isTruthy(gene))
        return(mat[,gene])
      else if (src == 'gene' & !isTruthy(gene))
        return(rep(0, dim(mat))[1])
      else
        return(annotations[[src]])
    }, srcs, genes, SIMPLIFY=F) 
    features <- as.data.frame(features)
    names(features) <- dims
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
    if (is.numeric(z_feature())) {
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
    if (input$group != "None") {
      facet_wrap(~facet, scales=ifelse(input$axis_lock, "fixed", "free"))
    } else {
      facet_null()
    }
  })

  output$plot <- renderPlotly({
    d <- feature()
    d$facet = facet_feature()
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

  output$embedding1 <- renderPlot({
    em <- embeddings[[input$embedding1]]
    d <- data.frame(
      x=annotations[[em[1]]],
      y=annotations[[em[2]]],
      z=z_feature(),
      facet=facet_feature()
    )
    d$facet = facet_feature()
    g <- ggplot(d, aes(x, y, col=z)) + 
      geom_point() + 
      z_colour_scale() +
      labs(col=z_feature_name(), x=em[1], y=em[2]) +
      faceting()
    g
  }, res=110)

  output$embedding2 <- renderPlot({
    em <- embeddings[[input$embedding2]]
    d <- data.frame(
      x=annotations[[em[1]]],
      y=annotations[[em[2]]],
      z=z_feature(),
      facet=facet_feature()
    )
    g <- ggplot(d, aes(x, y, col=z)) + 
      geom_point() +
      z_colour_scale() +
      labs(col=z_feature_name(), x=em[1], y=em[2]) +
      faceting()
    g
  }, res=110)


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
