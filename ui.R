ui <- fluidPage(
  theme="theme.css",
  shinyjs::useShinyjs(),
  titlePanel(meta$title),
  sidebarLayout(
    sidebarPanel(
      div(
        id="sidebarfixed",
        selectInput("group", label="Grouping", choices=c("None", grouping_vars)),
        hr(),
        selectInput("x_src", label="X Axis", choices=c("gene", names(annotations)), selected=default_x),
        conditionalPanel(condition="input.x_src == 'gene'",
          selectizeInput("x_gene", label="Gene Symbol", choices=NULL, multiple=F, selected=default_gene, options=list(closeAfterSelect=T))
        ),
        selectInput("y_src", label="Y Axis", choices=c("gene", names(annotations)), selected=default_y),
        conditionalPanel(condition="input.y_src == 'gene'",
          selectizeInput("y_gene", label="Gene Symbol", choices=NULL, multiple=F, selected=default_gene, options=list(closeAfterSelect=T))
        ),
        selectInput("z_src", label="Colour", choices=c("gene", names(annotations)), selected=default_z),
        conditionalPanel(condition="input.z_src == 'gene'",
          selectizeInput("z_gene", label="Gene Symbol", choices=NULL, multiple=T, selected=default_gene, options=list(closeAfterSelect=T))
        ),
        conditionalPanel(condition="input.group != 'None'",
          checkboxInput("axis_lock", "Lock axes", value=F),
        ),
        actionButton("clear", label="Reset"),
      ),
      plotOutput("sideplot")
    ),
    mainPanel(
      tabsetPanel(
        type='tabs',
        tabPanel("Plot", plotlyOutput(outputId="plot")),
        tabPanel("Selected", tableOutput("table"))
      ),
    ),
  ),
)
ui
