### Importing necessary Libraries ###
library(GDELTtools) 
library(rvest)
library(stringr)
library(tidyr)


### Error-handling Function ###
# Creating the error handling tryCatch function
error_handling <- function(url) {
  # The tryCatch function will catch errors and do something else with them
  tryCatch(
    {
      # Grabbing the title from the webpage of the url
      title <- read_html(url) %>%
        html_nodes('head') %>%
        html_nodes('title')
      # If the url is successfully read, then return FALSE since later this
      # will be returned to a variable called is_error
      return(FALSE)
      # Suppressing the warnings so they do not get shown to the console
      suppressWarnings(get_titles_top10(date))
    } ,
    # If reading the html title throws an error or a warning, then return TRUE
    error = function(cond) {
      return(TRUE)
    } ,
    warning = function(cond) {
      return(TRUE)
    }
  )
}


### Get Titles From URL Function ###
# This function takes a dataframe as input. It will return a dataframe with
# the titles of the urls as a column
get_titles_from_url <- function(df) {
  # Getting a list of the return_urls
  urls <- data.frame(df$SOURCEURL)
  # Creating an empty list to store the titles
  titles <- list()
  # Looping through each row of the df
  for (i in 1:10){
    # Selecting the url of the row
    url <- urls[i,]
    # Using webscrapping to gather the title of the urls webpage
    title <- read_html(url) %>%
      html_nodes('head') %>%
      html_nodes('title') %>%
      html_text()
    # Finding the length of the titles list and appending the new value to the 
    # list
    len <- length(titles)
    titles[[len+1]] <- title
  }
  # Converting the list of titles into a vector
  title_vector <- unlist(titles)
  # Creating a new column of the df that contains webpage titles
  df$WEBPAGE_TITLES <- title_vector
  # Returning the moified df
  return(df)
}


### MAIN ### 
### Get Titles Function ###
# This function takes in a date as input, then grabs the top 25 mentioned
# sources from that date. Then, it uses the error_handling function to test the 
# returns from the url. Finally, it will take the top 10 sources that do not
# return NA as their url title.
get_titles <- function(date) {
  # Using the built-in function GetGDELT to grab the all of the information from
  # the input date
  gdelt_totaldf <- GetGDELT(date)
  # Sorting the information by total number of mentions
  gdelt_sorted_mentions <- gdelt_totaldf[order(-gdelt_totaldf$NumMentions),]
  # Taking only the top-25 rows of information
  gdelt_sorted_mentions_top25 <- gdelt_sorted_mentions[1:25,]
  # Grabbing the urls of the top-25
  urls_sorted_mentions <- gdelt_sorted_mentions_top25$SOURCEURL
  # Creating an empty list as a place to store our urls
  return_urls <- list()
  # Looping through the list of the top-50 urls in to utilize our error-handling
  # function
  for (i in 1:25){
    # Grabbing a specific url from the list using index notation
    url <- urls_sorted_mentions[i]
    # Using the error_handling function (which returns TRUE or FALSE) to test
    # if the url is 'good' or 'bad'
    is_error <- error_handling(url)
    # If there is no error with the url, this block will run
    if (is_error == FALSE){
      # Grabbing the length of the return_urls list
      len <- length(return_urls)
      # Appending the url to the list
      return_urls[[len+1]] <- urls_sorted_mentions[i]
    }
    # else, there must be some kind of error, so this block runs
    else{
      # Grabbing the length of the return_urls list
      len <- length(return_urls)
      # Appending NA to the list since the url returned an error
      return_urls[[len+1]] <- NA
    }
  }
  # Converting the list of urls into a vector so they are easier to work with
  urls_vector <- unlist(return_urls)
  # Appening the urls_vector to the existing df
  gdelt_sorted_mentions_top25$RETURN_URLS <- urls_vector
  # Removing the rows with NA in the return_urls column
  gdelt_sorted_mentions_notNA <- gdelt_sorted_mentions_top25 %>%
    drop_na(RETURN_URLS)
  # Selecting the top-10 rows
  gdelt_sorted_mentions_top10 <- gdelt_sorted_mentions_notNA[1:10,]
  # Getting the titles of each of the urls in the df
  gdelt_sorted_mentions_top10_titles <- get_titles_from_url(
    gdelt_sorted_mentions_top10)
  return(gdelt_sorted_mentions_top10_titles)
}


### Compilation an Execution ###
# Gathering the date from user input
date <- readline(
  prompt = "Enter the date you wish to know about in yyyy-mm-dd format: "
)
# Running the program on the input date
test <- get_titles(date)
# Printing the result to the console
test
