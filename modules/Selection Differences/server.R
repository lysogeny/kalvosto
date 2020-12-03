function(input, output, session, opt) {
  # This is the rows that we must show the user
  # Selected genes
  # Will be used for pseudobulk
  rows <- reactive({
    d <- event_data('plotly_selected')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  dataframe <- reactive({
    if (isTruthy(rows())) {
      # We have a selection
      indices <- 1:nrow(rawmat)
      m <- rawmat[,colSums(rawmat) > 20]
      select_bool <- indices %in% rows()
      selected <- colSums(m[select_bool,])
      background <- colSums(m[!select_bool,])
      p.value <- apply(m, 2, function(r) wilcox.test(r[select_bool], r[!select_bool])$p.value)
      total <- background+selected
      if (input$diff_mean) {
        selected <- selected / sum(select_bool)
        background <- background / sum(!select_bool)
      } 
      change <- selected / background
      d <- data.frame(
        gene_symbol=colnames(rawmat),
        foldchange=change,
        selected=selected,
        rest=background,
        p.value=p.value,
        total=total
      )
      if (exists("cols"))
        d$id <- cols
      if (input$diff_log)
        d$foldchange <- log2(d$foldchange)
      if (input$diff_exclude)
        d <- d[is.finite(d$foldchange),]
      d[order(d$foldchange, decreasing=T),]
    } else {
      # No selection
      data.frame()
    }
  })

  goterms <- reactive({
    d <- dataframe()
    v <- d$foldchange
    names(v) <- d$gene_symbol
  })

  output$diff_go <- renderDataTable({
    goterms()
  })

  output$diff_table <- renderDataTable({
    dataframe()
  }, list(scrollX=T))

  output$diff_ma <- renderPlot({
    ggplot(dataframe()) +
      geom_point(aes(total, foldchange), alpha=0.2) +
      scale_x_log10()
  })

  output$diff_dl <- downloadHandler(
    filename = function() {
      paste0("data.csv")
    },
    content = function(filename) {
      write.csv(dataframe(), filename, row.names=F)
    }
  )
}
