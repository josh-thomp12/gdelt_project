### Importing necessary Libraries ###
library(GDELTtools) 
library(rvest)
library(stringr)
library(tidyr)


### Error-handling Function ###
# Creating the error handling try-catch function
error_handling <- function(url) {
  # The try-catch function will catch errors and do something else with them
  tryCatch(
    {
      # Attempting to grab the title from the webpage of the URL
      title <- read_html(url) %>%
        html_nodes('head') %>%
        html_nodes('title')
      # If the URL is successfully read, then return FALSE since later this
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

### Get Outlet From URL Function ###
# This function takes a data frame as input. It will return a data frame with
# the main outlet titles of the URLs as a column
get_outlet_from_url <- function(df){
  # Getting a list of the source URLs
  urls <- data.frame(df$SOURCEURL)
  # Creating a list, denoted 'base_urls', to hold the base URLs that we will 
  # create later in the function
  base_urls <- list()
  # Creating a loop with an iteration per row of the data frame. By construction,
  # there are only 10 rows.
  for (i in 1:10){
    # Selecting the URL of the row
    url <- urls[i,]
    # Splitting the string into parts, separated by '/'
    temp_split <- str_split(url, '/')
    # Pasting the wanted parts together, re-adding '/' when necessary
    temp_url <- paste(temp_split[[1]][1], '/', '/',  temp_split[[1]][3], sep='')
    # Finding the length of the 'base_url' list and appending the new value to 
    # the list
    len <- length(base_urls)
    base_urls[[len+1]] <- temp_url
  }
  # Converting the list of base URLs into a vector, so we can add the information
  # to the data frame as a new column
  base_urls_vector <- unlist(base_urls)
  # Creating a new column of the data frame that contains the main outlet URLs
  df$MAIN_OUTLET <- base_urls_vector
  # Getting the titles of the main outlet URLs
  new_df <- get_titles_from_url(df, 'MAIN_OUTLET')
  # Returning the modified data frame
  return(new_df)
}
  
### Get Titles From URL Function ###
# This function takes a data frame as input. It will return a data frame with
# the titles of the URLs as a column
get_titles_from_url <- function(df, from_col) {
  # Getting a list of the URLs, based on the input from_col, the URLs selected
  # are either from the SOURCEURL column or the MAIN_OUTLET column
  if (from_col == 'SOURCEURL') {
    urls <- data.frame(df$SOURCEURL)
  } else if (from_col == 'MAIN_OUTLET') {
    urls <- data.frame(df$MAIN_OUTLE)
  }
  # Creating an empty list to store the titles
  titles <- list()
  # Looping through each row of the data frame
  for (i in 1:10){
    # Selecting the URL of the row
    url <- urls[i,]
    # Using web scraping to gather the title of the URLs webpage
    title <- read_html(url) %>%
      html_nodes('head') %>%
      html_nodes('title') %>%
      html_text()
    # Finding the length of the titles list and appending the new value to the 
    # end of the list
    len <- length(titles)
    titles[[len+1]] <- title
  }
  # Converting the list of titles into a vector
  title_vector <- unlist(titles)
  # Creating a new column of the data frame that contains the new information,
  # note that the new columns title depends on the input from_col
  if (from_col == 'SOURCEURL') {
    df$WEBPAGE_TITLES <- title_vector
  } else if (from_col == 'MAIN_OUTLET') {
    df$OUTLET_TITLES <- title_vector
  }
  # Returning the modified data frame
  return(df)
}


### MAIN ### 
### Get Titles Function ###
# This function takes in a date as input, then grabs the top 25 mentioned
# sources from that date. Then, it uses the error_handling function to test the 
# returns from the URL. Finally, it will take the top 10 sources that do not
# return NA as their URL title.
get_titles <- function(date) {
  # Using the built-in function 'GetGDELT' to grab the all of the information 
  # from the input date
  gdelt_totaldf <- GetGDELT(date)
  # Sorting the information by total number of mentions
  gdelt_sorted_mentions <- gdelt_totaldf[order(-gdelt_totaldf$NumMentions),]
  # Taking only the top-25 rows of information
  gdelt_sorted_mentions_top25 <- gdelt_sorted_mentions[1:25,]
  # Grabbing the URLs of the top-25
  urls_sorted_mentions <- gdelt_sorted_mentions_top25$SOURCEURL
  # Creating an empty list as a place to store our URLs
  return_urls <- list()
  # Looping through the list of the top-50 URLs in to utilize our error-handling
  # function
  for (i in 1:25){
    # Grabbing a specific URL from the list using index notation
    url <- urls_sorted_mentions[i]
    # Using the error_handling function (which returns TRUE or FALSE) to test
    # if the URL is 'good' or 'bad'
    is_error <- error_handling(url)
    # If there is no error with the URL, this block will run
    if (is_error == FALSE){
      # Grabbing the length of the 'return_urls' list
      len <- length(return_urls)
      # Appending the URL to the list
      return_urls[[len+1]] <- urls_sorted_mentions[i]
    }
    # else, there must be some kind of error, so this block runs
    else{
      # Grabbing the length of the 'return_urls' list
      len <- length(return_urls)
      # Appending NA to the list since the URL returned an error
      return_urls[[len+1]] <- NA
    }
  }
  # Converting the list of URLs into a vector so they are easier to work with
  urls_vector <- unlist(return_urls)
  # Appending the 'urls_vector' to the existing data frame
  gdelt_sorted_mentions_top25$RETURN_URLS <- urls_vector
  # Removing the rows with NA in the 'RETURN_URLS' column
  gdelt_sorted_mentions_notNA <- gdelt_sorted_mentions_top25 %>%
    drop_na(RETURN_URLS)
  # Selecting the top-10 rows
  gdelt_sorted_mentions_top10 <- gdelt_sorted_mentions_notNA[1:10,]
  # Getting the titles of each of the URLs in the data frame
  gdelt_sorted_mentions_top10_titles <- get_titles_from_url(
    gdelt_sorted_mentions_top10, 'SOURCEURL')
  # Getting the outlet names from the webpages
  gdelt_sorted_mentions_top10_titles <- get_outlet_from_url(
    gdelt_sorted_mentions_top10_titles)
  # Returning the modified data frame
  return(gdelt_sorted_mentions_top10_titles)
}

# Function to precompute and save data
precompute_data <- function(date, output_file) {
  # Running the program on the input date.
  titles <- get_titles(date)
  titles <- titles[ , c('WEBPAGE_TITLES', 'OUTLET_TITLES', 'SOURCEURL')]
  # Save sorted data to file
  saveRDS(titles, file = output_file)
  # Return top ten trending events
  return(titles)
}

### Compilation and Execution ###
# Gathering the date from user input
date <- '2024-04-24'

# Running the program on the input date
precomputed_data <- precompute_data(date, 'topTenByMention_WithTitles.rds')
