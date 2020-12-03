if (exists("rawmat")){
  ui.this <- sidebarLayout(
    sidebarPanel(
      #selectizeInput("diff_vars", "Annotation Columns",
      #               colnames(annotations), diff_default_anns,
      #               multiple=T),
      checkboxInput("diff_mean", "Compute mean", value=F),
      checkboxInput("diff_exclude", "Keep only finite foldchange", value=T),
      checkboxInput("diff_log", "Log2 fold changes", value=T),
      downloadButton("diff_dl", "Download CSV"),
      hr(),
      helpText("Pseudocounts means adding a one to all counts.", "Computing the mean will compute the mean.", "Log2 fold changes will log-transform fold changes."),
      hr(),
      plotOutput("diff_ma")
    ),
    mainPanel(
      dataTableOutput("diff_table"),
      dataTableOutput("diff_go"),
    )
  )
} else {
  ui.this <- strong("No raw counts provided. Please contact whover deployed this app.")
}
ui.this
