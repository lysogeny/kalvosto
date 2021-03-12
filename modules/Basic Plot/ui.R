sidebarLayout(
  sidebarPanel(
    div(
      id="sidebarfixed",
      selectInput("basic_group", label="Grouping", choices=c("None", basic_grouping_vars)),
      hr(),
      selectInput("basic_x_src", label="X Axis", choices=c("gene", names(annotations)), selected=basic_default_x),
      selectizeInput("basic_x_gene", label="X Gene", choices=NULL, multiple=F, selected=basic_default_gene, options=list(closeAfterSelect=T)),
      selectInput("basic_y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=basic_default_y),
      selectizeInput("basic_y_gene", label="Y Gene", choices=NULL, multiple=F, selected=basic_default_gene, options=list(closeAfterSelect=T)),
      selectInput("basic_z_src", label="Z Axis (Colour)", choices=c("gene", names(annotations)), selected=basic_default_z),
      selectizeInput("basic_z_gene", label="Z Gene", choices=NULL, multiple=T, selected=basic_default_gene, options=list(closeAfterSelect=T)),
      div(checkboxInput("basic_log_z", "Log1p-transform Z axis", value=F), 
          class="sideways"),
      div(checkboxInput("basic_axis_lock", "Lock axes", value=F),
          checkboxInput("basic_asp_lock", "Lock aspect", value=F),
          class="sideways"),
      actionButton("basic_clear", label="Reset"),
    )
  ),
  mainPanel(
    girafeOutput(outputId="basic_plot")
  ),
)
