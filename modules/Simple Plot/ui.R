sidebarLayout(
  sidebarPanel(
    div(
      id="sidebarfixed",
      selectInput("simple_x_src", label="X Axis", choices=c("gene", names(annotations)), selected=simple_default_x),
      selectizeInput("simple_x_gene", label="X Gene", choices=NULL, multiple=F, selected=simple_default_gene, options=list(closeAfterSelect=T)),
      selectInput("simple_y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=simple_default_y),
      selectizeInput("simple_y_gene", label="Y Gene", choices=NULL, multiple=F, selected=simple_default_gene, options=list(closeAfterSelect=T)),
      selectInput("simple_z_src", label="Z Axis (Colour)", choices=c("gene", names(annotations)), selected=simple_default_z),
      selectizeInput("simple_z_gene", label="Z Gene", choices=NULL, multiple=F, selected=simple_default_gene, options=list(closeAfterSelect=T)),
      actionButton("simple_clear", label="Reset")
    ),
  ),
  mainPanel(
    plotlyOutput(outputId="simple_plot")
  ),
)
