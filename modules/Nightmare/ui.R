sidebarLayout(
  sidebarPanel(
    div(
      id="sidebarfixed",
      h3("Left Panel"),
      # Control plot1
      selectInput("nightmare_x_src", label="X Axis", choices=c("gene", names(annotations)), selected=nightmare_default_x),
      selectizeInput("nightmare_x_gene", label="Gene Symbol", choices=NULL, multiple=F, selected=nightmare_default_gene, options=list(closeAfterSelect=T)),
      selectInput("nightmare_y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=nightmare_default_y),
      selectizeInput("nightmare_y_gene", label="Y Gene", choices=NULL, multiple=F, selected=nightmare_default_gene, options=list(closeAfterSelect=T)),
      selectInput("nightmare_z_src", label="Z Axis (Colour)", choices=c("gene", names(annotations)), selected=nightmare_default_z),
      selectizeInput("nightmare_z_gene", label="Z Gene", choices=NULL, multiple=F, selected=nightmare_default_gene, options=list(closeAfterSelect=T)),
      # Control plot2
      h3("Right Panel"),
      selectInput("nightmare_u_src", label="X Axis", choices=c("gene", names(annotations)), selected=nightmare_default_x),
      selectizeInput("nightmare_u_gene", label="X Gene", choices=NULL, multiple=F, selected=nightmare_default_gene, options=list(closeAfterSelect=T)),
      selectInput("nightmare_v_src", label="Y Axis", choices=c("gene", names(annotations)), selected=nightmare_default_y),
      selectizeInput("nightmare_v_gene", label="Y Gene", choices=NULL, multiple=F, selected=nightmare_default_gene, options=list(closeAfterSelect=T)),
      sliderInput("nightmare_range", label="Distance Clip", min=0, max=1000, step=10, value=100),
      actionButton("nightmare_clear", label="Reset")
    )
  ),
  mainPanel(
    splitLayout(
      plotlyOutput(outputId="nightmare_plot1"),
      plotlyOutput(outputId="nightmare_plot2")
    )
  ),
)
