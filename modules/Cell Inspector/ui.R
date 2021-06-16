sidebarLayout(
  sidebarPanel(
    div(
      id="sidebarfixed",
      selectInput("inspector_x_src", label="X Axis", choices=c("gene", names(annotations)), selected=inspector_default_x),
      selectizeInput("inspector_x_gene", label="Gene Symbol", choices=NULL, multiple=F, selected=inspector_default_gene, options=list(closeAfterSelect=T)),
      selectInput("inspector_y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=inspector_default_y),
      selectizeInput("inspector_y_gene", label="Y Gene", choices=NULL, multiple=F, selected=inspector_default_gene, options=list(closeAfterSelect=T)),
      selectInput("inspector_z_src", label="Z Axis (Colour)", choices=c("gene", names(annotations)), selected=inspector_default_z),
      selectizeInput("inspector_z_gene", label="Z Gene", choices=NULL, multiple=F, selected=inspector_default_gene, options=list(closeAfterSelect=T)),
      # Control plot2
    )
  ),
  mainPanel(
    column(8, plotlyOutput(outputId="inspector_plot")),
    column(4, 
      fluidRow(
        DT::dataTableOutput("inspector_table1")
      ),
      fluidRow(
        DT::dataTableOutput("inspector_table2")
      )
    )
  )
)
