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
  rename(circuitId = Circuit_circuitId, raceDate = date, raceTime = time) %>%
  mutate(raceDate = ymd(raceDate), 
         raceTime = hms(raceTime), 
         round = as.numeric(round), 
         season = as.numeric(season))


# Define function to extract lap distance from Wikipedia race repo --------

# Use rvest to get the circuit length from the corresponding Wikipedia page (in
# url column)
get_lap_distance <- function(race_wiki_url){
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
  mutate(lapDistance = ifelse(raceDate < Sys.Date(), get_lap_distance(url), NA) ,
         circuitType = ifelse(raceDate < Sys.Date(), get_circuit_type(url), NA))



# Write to parquet --------------------------------------------------------

path <- paste0("data/circuits_", YEAR, ".parquet")
write_parquet(circuits_df, path)



