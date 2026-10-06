library(leaflet)
library(Lab5)
library(shiny)
library(sf)

function(input, output) {
  data <- reactive({
    earthquake_API(
      starttime = input$date_range[1],
      endtime = input$date_range[2],
      min_magnitude = input$magnitude_slider[1],
      max_magnitude = input$magnitude_slider[2]
    )
  })

  plates <- st_read(
    "https://raw.githubusercontent.com/fraxen/tectonicplates/master/GeoJSON/PB2002_boundaries.json",
    quiet = TRUE
  )

  output$map <- renderLeaflet({
    df <- tryCatch(
      data(),
      error = function(e) {
        data.frame(
          time = character(),
          latitude = numeric(),
          longitude = numeric(),
          mag = numeric(),
          place = character()
        )
      }
    )

    map <- leaflet(data = df) |>
      setView(lat = 0, lng = 0, zoom = 1.5) |>
      addProviderTiles("Stadia.AlidadeSmoothDark") |>
      addPolylines(
        data = plates,
        color = "#E67E22",
        weight = 2,
        opacity = 0.5,
        dashArray = "5, 5"
      )

    if (nrow(df) != 0) {
      mag_pal <- colorBin(
        palette = richter_colors,
        domain = df$mag,
        bins = c(0, 1, 2, 3, 4, 5, 6, 7, 8, Inf),
        na.color = "#808080"
      )

      map |>
        addCircleMarkers(
          lng = ~longitude,
          lat = ~latitude,
          radius = ~mag,
          fillColor = ~ mag_pal(mag),
          color = ~ mag_pal(mag),
          fillOpacity = 0.8,
          weight = 1,
          popup = ~ paste0(
            "<b>", place, "</b><br>",
            "<b>Time:</b> ", as.character(time), "<br>",
            "<b>Magnitude:</b> ", mag
          )
        ) |>
        addLegend(
          "bottomright",
          pal = mag_pal,
          values = ~mag,
          title = "Magnitude",
          opacity = 0.8
        )
    } else {
      map
    }
  })
}
