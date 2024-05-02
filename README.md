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

# mappingtopTen.Rmd explanation
The file mappingTopTen.Rmd was an attempt to display one event's average tone for as many countries in the world as possible on a map.

After importing all necessary libraries, the GDELT dataset is downloaded for one day.
The dataset is organized by GLOBALEVENTID. There are many duplicate URLs so the first step is to organize all rows in the database into what is considered an event. I chose to use the columns named EventCode, Actor1Geo_Lat, Actor1Geo_Long, ActionGeo_Lat, and ActionGeo_Long to define an event. The code organizes the list of events by number of total mentions while keeping each URL with its AvgTone in lists.

In the spirit of creating a top ten list, I slice off the ten events with the most mentions and assign them index values 1-10. The unnest command displays every URL with its average tone now paired with its index number in the top ten. The domain(URLs) command pulls the domain for each website (ex. cnn.com or bbc.co.uk).

I found a list of country domains paired with their country of origin on Wikipedia and the next chunk joins these two things together. The problem with this strategy is that most of the websites are .com and it is not clear what the country of origin is. In the next chunk I opted to remove the NAs which are created when the .com URLs are removed.

It occured to me that to map tone for the ten most mentioned articles would require the display of ten maps which would be possible if it were desired. I opted to focus only on the event with the most mentions (index 1) and continue working with that.

To get to a map of average tone by country I grouped the list of URLs and Avg Tones by country and ordered them by Avg Tone. The next chunk slices off the articles with the highest and lowest tone for further examination. In order to obtain something that is easier to work with, I wrote a function that pulls the HTML title of each webpage from its URL. I used lapply to run this function on both URLs from the countries with highest and lowest average tone. I was hoping for something recognizable but instead got an article with the highest tone, "SOFAZ acquires about 3 tons of gold this year," and an article with the lowest tone, "Report highlights insolvency risks in mobile money sector" from Azerbaijan and France respectively.

I used sf and ggplot2 to create the map of Avg Tone for the top event by country. This involves reading in the shape files for each country. In previous iterations of this project it was necessary to rename the countries of Iran, China, and the US to match their names in the shape files so I left that code in for reference.

A simple join connects the average tone for each country with the shape files. The mapping code is found in the final chunk.
# mappingtopTen.Rmd explanation end

# GDELT_Dash.Rmd 
Must run the Capstone_Final.R code first to get the file used in the dashboard -- this file is too large to uploadn 
