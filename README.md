# gdelt_project
This project is for the data seminar 2024 class. Our goal is to create an interactive dashboard using data collected from the gdelt website.

The 'url_suffix_V3.R' file takes a single date as input and uses the suffixes of the URLs to determine where the article originated from. In this file, the weighted average tone over all events for that day is found per country.

The 'webscraping_v4.R' file finds the top-10 rows sorted by mentions, then uses HTML webscraping to pull the article and outlet titles from the webpage. To prevent errors, a try-catch function is added which removes URLs that fail the webscraping test.

The 'choropleth_of_weighted_ave_tone.R' file uses information from the 'url_suffix_V3.R' file. (RUN 'url_suffix_V3.R' FIRST). Using this data, this file precomputes data that will be used to create a choropleth map of weighted average tone per country. 
