library(GDELTtools)
library(dplyr) 
library(leaflet) 

# Function to precompute and save data
precompute_data <- function(start_date, end_date, output_file) {
  # Aggregate data by SOURCEURL and calculate sum of NumMentions, NumSources, and NumArticles
  GdeltDF <- GetGDELT(start_date, end_date)
  
  # Group data based on specified columns and calculate sum of NumMentions, NumSources, and NumArticles
  aggregated_data <- GdeltDF %>%
    group_by(Actor1Geo_Lat, Actor1Geo_Long, Actor2Geo_Lat, Actor2Geo_Long, EventRootCode, SOURCEURL) %>%
    filter(!is.na(Actor2Geo_Lat), !is.na(Actor2Geo_Long)) %>%
    summarise(TotalMentions = sum(NumMentions),
              TotalSources = sum(NumSources),
              TotalArticles = sum(NumArticles))
  
  # Calculate a score for each event based on the sum of NumMentions, NumSources, and NumArticles
  aggregated_data$Score <- aggregated_data$TotalMentions + aggregated_data$TotalSources + aggregated_data$TotalArticles
  
  # Sort events based on the score in descending order
  sorted_data <- aggregated_data %>% arrange(desc(Score))
  
  # Save sorted data to file
  saveRDS(sorted_data, file = output_file)
  
  # Return top ten trending events
  return(head(sorted_data, 10))
}

# Define date range
start_date <- "2024-02-23"
end_date <- "2024-02-24"

# Precompute data and save to file
precomputed_data <- precompute_data(start_date, end_date, "precomputed_data.rds")

# Creating a Leaflet map center around the world
world_map <- leaflet() %>%
  addTiles() %>%
  setView(lng = 0, lat = 30, zoom = 2)  # Adjust the center and zoom level as needed

# Add circle markers for each point
for (i in 1:nrow(precomputed_data)) {
  world_map <- addCircleMarkers(world_map,
                                lng = precomputed_data$Actor2Geo_Long[i],
                                lat = precomputed_data$Actor2Geo_Lat[i],
                                color = "red",
                                radius = 5,
                                popup = precomputed_data$SOURCEURL[i])
}

# Save the map to an HTML file
saveWidget(world_map, file = "world_map.html")

