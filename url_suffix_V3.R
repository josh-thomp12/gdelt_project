### Importing necessary Libraries ###
library(GDELTtools) 
library(urltools)
library(rvest)
library(magrittr)
library(dplyr)
library(stringr)
library(tidyverse)

### Pre-defined Webscraping Function ###
# The following funciton takes no inputs. When called, the function will scrape
# the pre-defined website and return a dataframe containing information about
# URL suffixes and their associated countries of origin.
get_suffixes_and_countries <- function() {
  # The following url's webpage contains a nice table that we will scrape information
  # about url suffixes and their countries from.
  url_for_scraping <-'https://worldpopulationreview.com/country-rankings/domain-extensions-by-country'
  # Scraping the table from the html of the webpage and converting the tibble to
  # a dataframe
  country_suffix_info <- read_html(url_for_scraping) %>% 
    html_nodes('table') %>%  
    html_table() %>%
    as.data.frame()
  # Returning the dataframe
  return(country_suffix_info)
}

### Get URL Suffixes Function ###
# This function takes a dataframe as input and returns the suffix of each URL
# contained in the dataframe. The list containing the suffixes of the urls is
# returned.
get_url_suffixes <- function(df) {
  # Selecting the urls column
  urls <- df$SOURCEURL
  # Extracting url info using the urltools package and selecting the suffix info.
  url_suffix_info <- suffix_extract(domain(urls))['suffix']
  # Returning the list of suffixes
  return(url_suffix_info)
}

### Clean Suffixes Function ###
# This function takes a dataframe as input, specifically 'url_suffix_info'. Some of
# the suffixes are similar to '.gov.au', but we just care about the '.au' part. 
# So, the function returns a list of suffixes, but some of them are slightly 
# modified to match those in the country_suffix_info dataframe.
clean_suffixes <- function(df) {
  # Calculating the number of iterations our loop will go through
  iterations <- nrow(df)
  # Each 'i' value corresponds to the index of a row in url_suffix_info
  for (i in 1:iterations){
    # The suffix of the current iteration is stored temporarily.
    temp_suffix <- df[i,]
    # If no period appears in the suffix, then all we need to do is paste a
    # period to the beginning of the string.
    if (grepl('.',temp_suffix,fixed = TRUE)==FALSE){
      df[i,] <- paste('.',temp_suffix,sep='')
    }
    # Else, there must be a period present in the suffix. This means it is of the
    # wrong type, like 'gov.uk'. So, we select every character after the period,
    # then paste the period back to the front. So 'gov.uk' is now just '.uk'.
    else{
      temp_suffix_slice <- sub('.*\\.', '', temp_suffix)
      df[i,] <- paste('.',temp_suffix_slice,sep='')
    }
  }
  # Returning the modified dataframe
  return(df)
}

### Find Country Match ###
# The following function takes two dataframes as input. The first contains information
# about which country corresponds to each url suffix. The other input contains the 
# suffixes we wish to find information for.
find_country_match <- function(info_df, modifiable_df) {
  # Creating a list to store the match info
  country_match <- list()
  # Setting the number of iteration to the number of rows in the modifiable df
  iterations <- nrow(modifiable_df)
  # Looping through each row of the modifiable df
  for (i in 1:iterations){
    # Calculating the length of the country_match list
    len <- length(country_match)
    # If the currently selected suffix is contained in the info_df, then
    # we know the country of origin of the article and put the country name
    # in the country_match list.
    if (modifiable_df[i,] %in% info_df$Domain == TRUE){
      index <- match(modifiable_df[i,], info_df$Domain)
      country_match[[len+1]] <- info_df[index,1]
    }
    # Else, the currently selected suffix is not in the info_df, so NA is put
    # into the list.
    else{
      country_match[len+1] <- NA
    }
  }
  # Converting the country match list into a vector
  country_match_vector <- unlist(country_match)
  # Creating a new column in the modifiable df containing the country associated
  # with the suffix of the url.
  modifiable_df$COUNTRY_MATCH <- country_match_vector
  # Returning the modified df
  return(modifiable_df)
}


### Find USA Match ###
# The following function takes one dataframe as input. It is the dataframe containing
# the country match column
find_usa_match <- function(df) {
  # Hard-coding the top ten usa news outlets' domain
  outlets <- c('news.yahoo.com', 'news.google.com', 'huffpost.com', 'cnn.com',
               'nytimes.com', 'foxnews.com', 'nbcnews.com', 'washingtonpost.com',
               'theguardian.com', 'chicagotribune.com', 'abcnews.go.com', 'cbsnews.com',
               'msnbc.com', 'wsj.com', 'npr.org', 'apnews.com', 'usatoday.com',
               'nypost.com', 'people.com', 'usmagazine.com', 'sfgate.com',
               'metrowestdailynews.com', 'eagletribune.com', 'azcentral.com',
               'startribune.com', 'cjonline.com', 'fremonttribune.com',
               'salemnews.com', 'wcnc.com', 'democratandchronicle.com',
               'kabc.com', 'thenorthwestern.com', 'natlawreview.com', 'wesh.com',
               '987jack.com', 'sciencedaily.com', 'clickondetroit.com', 'latimes.com',
               'ktar.com', 'usni.com', 'wvua23.com', 'weartv.com', 'baltimoresun.com',
               'rep-am.com', 'krdo.com', 'kezj.com', 'abc17news', 'al.com', 'carsonnow.org',
               'local3news.com', 'idahopress.com', 'mynewsla.com', 'abc7ny.com',
               'kitv.com', 'outdoorlife.com', 'fox13memphis.com', 'foxweather.com',
               'readingeagle.com', 'orlandosentinel.com', 'omaha.com')
  # Setting the number of iteration to the number of rows in the modifiable df
  iterations <- nrow(df)
  # Looping through each row of the modifiable df
  for (i in 1:iterations){

    if ((TRUE %in% str_detect(df$SOURCEURL[i], outlets))){
      df$COUNTRY_MATCH[i] <- 'USA'
    }
  }
  # Returning the modified df
  return(df)
}

### MAIN ###
# The following function takes a date as input and runs the functions above on 
# the Gdelt table from the input date
find_country_associated_with_url <- function(date) {
  # Getting the predefined information about which country a url suffix
  # corresponds to
  suffixes_and_countries <- get_suffixes_and_countries()
  # Importing the Gdelt information from the input date
  gdelt_base_df <- GetGDELT(date)
  # Getting the suffixes of the urls in the gdelt_base_df
  url_suffixes <- get_url_suffixes(gdelt_base_df)
  # Cleaning the suffixes so we can work with them easier
  cleaned_url_suffixes <- clean_suffixes(url_suffixes)
  # Finding which country is associated with the suffix from each url
  country_matches <- find_country_match(suffixes_and_countries, cleaned_url_suffixes)
  # Adding the country matches as a column to the gdelt_base_df
  gdelt_base_df$COUNTRY_MATCH <- country_matches$COUNTRY_MATCH
  # Finding USA matches by news outlet
  gdelt_modified_df <- find_usa_match(gdelt_base_df)
  return(gdelt_modified_df)
}

# The following function takes a dataframe as input, specifically the one returned
# from the find_country_associated_with_url function. The weighted average tone
# will be found and stored for every relevant country. A tibble containing the new
# information will be returned.
get_wavg_tone <- function(df){
  # This is the df that will be modified and returned.
  new_df <- df %>% group_by(COUNTRY_MATCH)
  new_df2 <- new_df %>% summarize(n = n())
  # This df gathers information we wish to use later.
  temp_df <- new_df %>% summarize(
    n = n(),
    avtone = mean(AvgTone),
    TotalMentions = sum(NumMentions),
    mentions = NumMentions,
    tone = AvgTone
  )
  # Initializing an empty list to hold the weighted average tone values as they 
  # are calculated
  wavg_tone = c()
  # Looping through each unique country that appeared as a country match
  for (i in new_df2$COUNTRY_MATCH){
    # The following code calculates the weighted average tone per country, weighted
    # by total mentions corresponding to the current country. 
    summ_tibble <- dplyr::filter(temp_df, COUNTRY_MATCH == i) %>% 
      dplyr::mutate(weighted_tone = mentions * tone) %>% 
      dplyr::summarize(
      weighted_average_tone = sum(weighted_tone) / TotalMentions
    )
    # Gathering the weighted average tone value
    temp_avgtone <- summ_tibble$weighted_average_tone[1]
    # Calculating the length of the list and appending the new value to the end
    # of the list.
    len<-length(wavg_tone)
    wavg_tone[len+1] <- temp_avgtone
  }
  # Returning a df that contains each country that appeared as a match, the number
  # of times that country appeared as a match, and the weighted average tone of all
  # articles returning a match to the specific country.
  return(new_df2 %>% add_column(weighted_avg_tone = wavg_tone))
}

# Getting the date from user input
date <- '2024-04-24'

countries_with_urls <- find_country_associated_with_url(date)
wavgtone <- get_wavg_tone(countries_with_urls)
