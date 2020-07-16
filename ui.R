ui_tabs <- Map(function(x) tabPanel(x, source(paste0(module_base_dir, '/', x, "/ui.R"))$value), module_names)


ui <- fluidPage(
  theme="theme.css",
  shinyjs::useShinyjs(),
  titlePanel(meta$title),
  actionButton("option_show", "Show plot options"),
  do.call(tabsetPanel, unname(ui_tabs))
)
ui
