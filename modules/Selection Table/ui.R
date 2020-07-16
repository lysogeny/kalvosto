sidebarLayout(
  sidebarPanel(
    selectizeInput("selection_vars", "Annotation Columns",
                   colnames(annotations), selection_default_anns,
                   multiple=T),
    selectizeInput("selection_genes", "Gene Columns", choices=NULL,
                   multiple=T),
    downloadButton("selection_dl", "Download CSV")
  ),
  mainPanel(
    dataTableOutput("selection_table")
  )
)
