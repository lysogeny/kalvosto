sidebarLayout(
  sidebarPanel(
    #selectizeInput("diff_vars", "Annotation Columns",
    #               colnames(annotations), diff_default_anns,
    #               multiple=T),
    checkboxInput("diff_pseudo", "Pseudocounts", value=F),
    checkboxInput("diff_mean", "Compute mean", value=F),
    checkboxInput("diff_exclude", "Keep only finite foldchange", value=T),
    checkboxInput("diff_log", "Log2 fold changes", value=T),
    downloadButton("diff_dl", "Download CSV"),
    hr(),
    plotOutput("diff_ma")
  ),
  mainPanel(
    dataTableOutput("diff_table"),
    dataTableOutput("diff_go"),
  )
)
