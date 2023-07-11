# Get circuit information
library(tidyverse)
library(lubridate)
library(jsonlite)
library(arrow)
library(rvest)


YEAR <- 2023


# Get circuits for given year ---------------------------------------------

# Use Ergast api
circuit_url <- paste0("https://ergast.com/api/f1/", YEAR, ".json")
circuits_df <- unnest(fromJSON(circuit_url)$MRData$RaceTable$Races, 
                      cols = c(Circuit, 
                               FirstPractice, 
                               SecondPractice, 
                               ThirdPractice, 
                               Qualifying, 
                               Sprint), 
                      names_sep = "_")


# Clean & Convert data types ----------------------------------------------
# Remove columns that are not relevant. Convert to correct types (numeric,
# datetime, etc.)
circuits_df <- circuits_df %>%
  select(season, round, url, raceName, Circuit_circuitId, date, time) %>%
  rename(CircuitId = Circuit_circuitId, RaceDate = date, RaceTime = time, Round = round, Season = season) %>%
  mutate(RaceDate = ymd(RaceDate),
         RaceTime = hms(RaceTime),
         Round = as.numeric(Round),
         Season = as.numeric(Season))


# # Define function to extract lap distance from Wikipedia race repo --------

# Use rvest to get the circuit length from the corresponding Wikipedia page (in
# url column)
get_lap_distance <- function(race_wiki_url){
  print(race_wiki_url)
  Sys.sleep(0.1)
  lapDistanceKm <- race_wiki_url %>%
    read_html() %>%
    html_element(
      xpath = '//*[@id="mw-content-text"]/div[1]/table[1]/tbody/tr[9]/td') %>%
    html_text2 %>%
    str_extract("^(.*)(?= km)") %>%
    as.numeric()
  return(lapDistanceKm)
}

# Get circuit type from Wikipedia page
# Use rvest again to get circuit type
get_circuit_type <- function(race_wiki_url) {
  print(race_wiki_url)
  Sys.sleep(0.1)
  circuitType <- race_wiki_url %>%
    read_html() %>%
    html_element(
      xpath = '//*[@id="mw-content-text"]/div[1]/table[1]/tbody/tr[8]/td') %>%
    html_text2()
}


# Append lap distances to circuits_df -------------------------------------
# Go through each row and call the previously defined functions, write to df
circuits_df <- circuits_df %>%
  rowwise() %>%
  mutate(lapDistance = ifelse(RaceDate < Sys.Date(), get_lap_distance(url), NA) ,
         circuitType = ifelse(RaceDate < Sys.Date(), get_circuit_type(url), NA))



# Write to parquet --------------------------------------------------------

path <- paste0("data/circuits_", YEAR, ".parquet")
write_parquet(circuits_df, path)





# LEGACY CODE -------------------------------------------------------------

# get_circuit_data <- function(race_wiki_url){
#   
#   url = list()
#   circuit_lap_dists = list()
#   circuit_types = list()
#   
#   
#   wiki_url <- race_wiki_url_vect[i]
#   wiki_html <- read_html(wiki_url)
#   
#   print(wiki_url)
#   
#   # Get track data table from wiki page
#   track_data_table <- wiki_html %>%
#     html_element(xpath = '//*[@id="mw-content-text"]/div[1]/table[1]') %>%
#     html_table() %>%
#     .[,1:2] %>%
#     rename(col1 = 1, col2 = 2)
#   
#   # Get track type
#   circuit_types[i] <- track_data_table %>%
#     filter(col1 == "Course") %>%
#     pull()
#   
#   # Get lap length
#   circuit_lap_dists[i] <- track_data_table %>%
#     filter(col1 == "Course length") %>%
#     pull() %>%
#     str_extract("^(.*)(?= km)") %>%
#     as.numeric()
#   
#   url[i] <- wiki_url
#   
#   for (i in 1:length(race_wiki_url_vect)) {
# 
#   }
#   tibble(url, circuit_lap_dists, circuit_types)
# }
# 
# # Access wiki pages and create dataframe
# circuit_data.df <- get_circuit_data(circuits_df %>% filter(raceDate < Sys.Date()) %>% .$url)
# 
# # Join dataframes
# circuits_df %>%
#   cbind(circuit_data.df)
# get_circuit_data <- function(race_wiki_url_vector){
#   
#   # Initialise lists
#   race_wiki_urls = list()
#   circuit_lap_dists = list()
#   circuit_types = list()
#   
#   
#   # Loop through each url in function argument
#   for (i in 1:length(race_wiki_url_vector)){
# 
#      race_wiki_urls[i] = race_wiki_url_vector[i]
# 
#      wiki_html <- read_html(race_wiki_url_vector[i])
#      # Get Lap Distance
#      circuit_lap_dists[i] <- wiki_html %>%
#        html_element(
#          xpath = '//*[@id="mw-content-text"]/div[1]/table[1]/tbody/tr[9]/td') %>%
#        html_text2 %>%
#        str_extract("^(.*)(?= km)") %>%
#        as.numeric()
#     
#      # Get Circuit Type
#      circuit_types[i] <- wiki_html %>%
#        html_element(
#          xpath = '//*[@id="mw-content-text"]/div[1]/table[1]/tbody/tr[8]/td') %>%
#        html_text2()
#   }
#   tibble(race_wiki_urls, circuit_lap_dists, circuit_types)
# }

# Use html_table()
