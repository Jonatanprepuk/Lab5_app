library(shiny)
library(leaflet)
library(bslib)

page_sidebar(
  title = "Earthquake Map",
  sidebar = sidebar(
    sliderInput(
      inputId = "magnitude_slider",
      label = "Magnitude Range",
      min = 1,
      max = 10,
      step = 0.1,
      value = c(5, 7)
    ),
    dateRangeInput(
      start = "2026-01-01",
      end = "2026-10-05",
      inputId = "date_range",
      label = "Date Range"
    ),
    hr(),
    width = 300
  ),
  card(
    leafletOutput("map")
  )
)
