
library(GDELTtools)
library(dplyr) 
library(ggplot2) 
library(leaflet) 
library(rvest)
library(stringr)
library(tidyr)
library(DT)
library(shinydashboard)

# Fetch GDELT data for specified dates
GdeltDF <- GetGDELT("2024-04-24", "2024-04-30")

# Save the data frame to a CSV file
write.csv(GdeltDF, "GdeltData.csv", row.names = FALSE)

GdeltDF1 <- read.csv('GdeltData.csv')
View(GdeltDF1)
# Group data based on specified columns and calculate sum of NumMentions, NumSources, and NumArticles
aggregated_data <- GdeltDF1 %>%
  group_by(Actor1Geo_Lat, Actor1Geo_Long, Actor2Geo_Lat, Actor2Geo_Long, EventRootCode, SOURCEURL) %>%
  filter(!is.na(Actor2Geo_Lat),!is.na(Actor2Geo_Long))%>%
  summarise(TotalMentions = sum(NumMentions),
            TotalSources = sum(NumSources),
            TotalArticles = sum(NumArticles))

# Calculate a score for each event based on the sum of NumMentions, NumSources, and NumArticles
aggregated_data$Score <- aggregated_data$TotalMentions + aggregated_data$TotalSources + aggregated_data$TotalArticles

# Sort events based on the score in descending order
sorted_data <- aggregated_data %>% arrange(desc(Score))

# Display top ten trending events
top_10_trending <- head(sorted_data, 10)
print(top_10_trending)

# Creating a Leaflet map center around the world
world_map <- leaflet() %>%
  addTiles() %>%
  setView(lng = 0, lat = 30, zoom = 2)  # Adjust the center and zoom level as needed

# Add circle markers for each point
for (i in 1:nrow(top_10_trending)) {
  world_map <- addCircleMarkers(world_map,
                                lng = top_10_trending$Actor2Geo_Long[i],
                                lat = top_10_trending$Actor2Geo_Lat[i],
                                color = "red",
                                radius = 5,
                                popup = top_10_trending$SOURCEURL[i])
}

# Display the map
world_map





