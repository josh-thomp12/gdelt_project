library(maps)
library(dplyr)
world_map <- map_data("world")

tone_map <- merge(world_map, test2, by.x = "region", by.y = "COUNTRY_MATCH")

tone_map

tone_map <- arrange(tone_map, group, order)
tone_map

ggplot(tone_map, aes(x = long, y = lat, group = group, fill = weighted_avg_tone)) +
  geom_polygon(colour = "black") +
  scale_fill_viridis_c() +
  borders("world", colour = "black")

