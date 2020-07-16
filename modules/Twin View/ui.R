sidebarLayout(
  sidebarPanel(
    div(
      id="sidebarfixed",
      h3("Left Panel"),
      # Control plot1
      selectInput("twin_x_src", label="X Axis", choices=c("gene", names(annotations)), selected=twin_default_x),
      selectizeInput("twin_x_gene", label="Gene Symbol", choices=NULL, multiple=F, selected=twin_default_gene, options=list(closeAfterSelect=T)),
      selectInput("twin_y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=twin_default_y),
      selectizeInput("twin_y_gene", label="Y Gene", choices=NULL, multiple=F, selected=twin_default_gene, options=list(closeAfterSelect=T)),
      selectInput("twin_z_src", label="Z Axis (Colour)", choices=c("gene", names(annotations)), selected=twin_default_z),
      selectizeInput("twin_z_gene", label="Z Gene", choices=NULL, multiple=F, selected=twin_default_gene, options=list(closeAfterSelect=T)),
      # Control plot2
      h3("Right Panel"),
      selectInput("twin_u_src", label="X Axis", choices=c("gene", names(annotations)), selected=twin_default_x),
      selectizeInput("twin_u_gene", label="X Gene", choices=NULL, multiple=F, selected=twin_default_gene, options=list(closeAfterSelect=T)),
      selectInput("twin_v_src", label="Y Axis", choices=c("gene", names(annotations)), selected=twin_default_y),
      selectizeInput("twin_v_gene", label="Y Gene", choices=NULL, multiple=F, selected=twin_default_gene, options=list(closeAfterSelect=T)),
      actionButton("twin_clear", label="Reset")
    )
  ),
  mainPanel(
    splitLayout(
      plotlyOutput(outputId="twin_plot1"),
      plotlyOutput(outputId="twin_plot2")
    )
  ),
)
