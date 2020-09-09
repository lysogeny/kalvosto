servers <- Map(function(x) source(paste0(module_base_dir, '/', x, "/server.R")), module_names)
server <- function(input, output, session) {
  # Reactive values for plotting options
  plotopt <- reactiveValues(
    size=1.0,
    alpha=1.0,
    scale_cont_name="ViridisC",
    scale_disc_name="Rainbow",
    scale_cont=scales_cont[["ViridisC"]],
    scale_disc=scales_disc[["Rainbow"]]
  )

  # Handle option modal
  optionmodal <- function(failed=F) {
    modalDialog(
      title="Plot options", 
      numericInput("opt_size", label="Point size", value=plotopt$size, min=0, step=0.1),
      numericInput("opt_alpha", label="Point alpha", value=plotopt$alpha, max=1.0, min=0.0, step=0.1),
      selectInput("opt_scale_cont", label="Continuous colour scale", choices=names(scales_cont), selected=plotopt$scale_cont_name),
      selectInput("opt_scale_disc", label="Discrete colour scale", choices=names(scales_disc), selected=plotopt$scale_disc_name),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("opt_ok", "OK")
      )
    )
  }

  observeEvent(input$option_show, {
    showModal(optionmodal())
  })


  observeEvent(input$opt_ok, {
    # For some reason the input will be null, even if a value was set by the
    # server. Because of this, we need this weird function
    f <- function(x, y) if (is.null(x)) y else x
    plotopt$size <- f(input$opt_size, plotopt$size)
    plotopt$alpha <- f(input$opt_alpha, plotopt$alpha)
    plotopt$scale_cont_name <- f(input$opt_scale_cont, plotopt$scale_cont_name)
    plotopt$scale_disc_name <- f(input$opt_scale_disc, plotopt$scale_disc_name)
    plotopt$scale_cont <- f(scales_cont[[input$opt_scale_cont]], plotopt$scale_cont)
    plotopt$scale_disc <- f(scales_disc[[input$opt_scale_disc]], plotopt$scale_disc)
    removeModal()
  })

  # Handle other modules
  Map(function(x) x$value(input, output, session, plotopt), servers)
}
server
