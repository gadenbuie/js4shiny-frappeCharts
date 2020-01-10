library(shiny)

ui <- fluidPage(
  # Application title
  titlePanel("htlmwidgets rock"),
  sidebarLayout(
    sidebarPanel(
      # Sidebar with a button to create new data
      sliderInput("n_bars", "Number of bars", 1, 26, 10),
      actionButton("new_data", "New Data")
    ),
    # Show a plot of the generated distribution
    mainPanel(
      frappeCharts::frappeChartOutput("chart")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  initial_data <- data.frame(
    x = LETTERS[seq_len(10)],
    Frequency = rep(0.5, 10)
  )

  data <- reactive({
    input$new_data

    data.frame(x = LETTERS[seq_len(input$n_bars)], Frequency = runif(input$n_bars))
  })

  output$chart <- frappeCharts::renderFrappeChart({
    frappeCharts::frappeChart(
      initial_data,
      type = "bar",
      tooltipOptions = list(
        formatTooltipY = htmlwidgets::JS("d => Math.round(d * 100) + '%'")
      )
    )
  })

  observe({
    updateFrappeChart("chart", data())
  })
}

# Run the application
shinyApp(ui = ui, server = server)
