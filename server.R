library(leaflet)
library(Lab5)

function(input, output) {
  data <- reactive({
    earthquake_API(
      starttime = input$date_range[1],
      endtime = input$date_range[2],
      min_magnitude = input$magnitude_slider[1],
      max_magnitude = input$magnitude_slider[2],
    )
  })

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

    mag_pal <- colorBin(
      palette = richter_colors,
      domain = df$mag,
      bins = c(0, 1, 2, 3, 4, 5, 6, 7, 8, Inf),
      na.color = "#808080"
    )

    map <- leaflet(data = df) |>
      setView(lat = 0, lng = 0, zoom = 1) |>
      leaflet::addProviderTiles("Stadia.AlidadeSmoothDark") |>
      leaflet::addLegend(
        "bottomright",
        pal = mag_pal,
        values = ~mag,
        title = "Magnitude",
        opacity = 0.8
      )

    if (nrow(df) != 0) {
      leaflet::addCircleMarkers(map,
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
      )
    } else {
      map
    }
  })
}
