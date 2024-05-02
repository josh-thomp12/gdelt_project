# gdelt_project
This project is for the data capstone Spring 2024 class. Our goal is to create an interactive dashboard using data collected from the gdelt website, https://www.gdeltproject.org/. The Gdelt Project collects news articles from around the globe daily. By itself, the data is extremely messy and hard to understand, so we decided to try to give the data some applicable meaning through the use of tables and graphics.

The 'url_suffix_V3.R' file takes a single date as input and uses the suffixes of the URLs to determine where the article originated from. In this file, the weighted average tone over all events for that day is found per country.

The 'webscraping_v4.R' file finds the top-10 rows sorted by mentions, then uses HTML webscraping to pull the article and outlet titles from the webpage. To prevent errors, a try-catch function is added which removes URLs that fail the webscraping test.

The 'choropleth_of_weighted_ave_tone.R' file uses information from the 'url_suffix_V3.R' file. (RUN 'url_suffix_V3.R' FIRST). Using this data, this file precomputes data that will be used to create a choropleth map of weighted average tone per country. 


"Capstone_Final.R"
Data Retrieval: It fetches GDELT data for the specified date range and saves it as a CSV file named "GdeltData.csv". 

Data Preprocessing: It reads the saved CSV file into a data frame (GdeltDF1) and processes the data to aggregate information based on specified columns like geographic coordinates, event type, and news source URLs. This aggregation includes summing up the number of mentions, sources, and articles for each event. 

Scoring Events: It calculates a score for each event based on the total mentions, sources, and articles associated with it. 

Sorting Events: It sorts the events based on their scores in descending order to identify the top trending events. 

Visualization: It creates a Leaflet map centered around the world and adds circle markers for the top ten trending events. Each marker represents an event's location, with the size of the marker indicating the event's significance. The pop-up for each marker contains the URL of the news source associated with the event. 


