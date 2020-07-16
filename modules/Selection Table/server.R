function(input, output, session, opt) {
  # This is the rows that we must show the user
  updateSelectizeInput(session, 'selection_genes', server=T, choices=colnames(mat), selected=selection_default_gene)

  rows <- reactive({
    d <- event_data('plotly_selected')
    # This key existing depends on me creating and adding it to the ggplot
    as.numeric(d$key)
  })

  columns <- reactive({
    input$selection_vars
  })

  genes <- reactive({
    input$selection_genes
  })

  dataframe <- reactive({
    if (isTruthy(rows())) {
      # Annotations
      ann <- annotations[rows(),][columns()]
      ann <- cbind(data.frame(cell=rownames(ann)), ann)
      # Mat
      tam <- as.data.frame(as.matrix(mat[rows(),genes()]))
      colnames(tam) <- genes()
      cbind(ann, tam)
    } else {
      data.frame()
    }
  })

  output$selection_table <- renderDataTable({
    dataframe()
  }, list(scrollX=T))

  output$selection_dl <- downloadHandler(
    filename = function() {
      paste0("data_", 
             do.call(function(...) paste(..., sep='-'), as.list(columns())), 
             '_',
             do.call(function(...) paste(..., sep='-'), as.list(genes())), 
             ".csv")
    },
    content = function(filename) {
      write.csv(dataframe(), filename, row.names=F)
    }
  )
}
