library(maps)
library(dplyr) 
library(plotly)
library(leaflet) 
library(htmlwidgets)

# Function to precompute and save data
precompute_data <- function(output_file) {
  # Getting base world map data
  world_map <- map_data("world")
  # Merging base map data with gdelt data
  tone_map <- merge(world_map, wavgtone, by.x = "region", by.y = "COUNTRY_MATCH")
  # grouping the map data
  tone_map <- arrange(tone_map, group, order)
  # Save sorted data to file
  saveRDS(tone_map, file = output_file)
  # Return top ten trending events
  return(tone_map)
}

precompute_data('tone_map.rds')
