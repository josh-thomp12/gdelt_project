library(GDELTtools)
library(dplyr)
library(urltools)
library(readxl)

# Gather all mentions of an event.
apr7 <- GetGDELT("2024-04-07")
countryDomains <- read_excel("countryDomains.xlsx")

apr7 %>% group_by(SOURCEURL, ActionGeo_Lat, ActionGeo_Long, EventRootCode) %>%
  summarise(n(),mean(AvgTone)) %>%
  mutate(domain = (domain(SOURCEURL))) -> df1

df1 %>% ungroup() %>% select(`n()`, domain, `mean(AvgTone)`) %>% 
  mutate(suffix = sub(".+\\.", ".", domain)) %>%
  left_join(countryDomains, by = c("suffix"="domain")) %>%
  na.omit() -> df2

# Josh's work with MentionSourceName (or however he is getting the URL)
# will allow us to sort these mentions by their country of origin.
df2 %>% group_by(country) %>% summarise(mean(`mean(AvgTone)`))


# For each country, we can average the values of MentionDocTone
# for every mention originating in that country.
# We thereby get some measure of how that entire country responded
# to the event on average.



# This average can be converted to a color and each country
# colored according to its overall tone on that event.