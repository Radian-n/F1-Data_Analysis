library(tidyverse)
library(lubridate)
library(jsonlite)




# Laptime Data ------------------------------------------------------------
YEAR = 2023
ROUND = 1

# Gets lap times from 2023, round 1:
# TODO: do an api request, and use 'total' key to figure out how many for loop iterations below
r1_laptimes_raw.df <- map_df(0 : 1, function(i){
  Sys.sleep(0.5)
  
  # Generate offset
  offset_x = i * 1000
  
  # Round 1
  r1_laptimes.url <- paste0("https://ergast.com/api/f1/", YEAR, "/", ROUND, "/laps.json?limit=1000&offset=", offset_x)
  
  # get json from url, navigate json to lap times, then unnest 
  r1_lap.df <- unnest(fromJSON(r1_laptimes.url)$MRData$RaceTable$Races$Laps[[1]])
  
  return(r1_lap.df)
})

# Clean laptime data
r1_laptimes_clean.df <- r1_laptimes_raw.df %>%
  rename(lap = number, laptime = time) %>%
  mutate(lap = as.numeric(lap), 
         position = as.numeric(position),
         laptime_lub = ms(laptime),
         laptime_seconds = as.numeric(laptime_lub))




# Team/Constructor data ---------------------------------------------------

driver_constructors.url <- "http://ergast.com/api/f1/2023/driverStandings.json"
driver_constructors_full.df <- unnest(fromJSON(driver_constructors.url)$MRData$StandingsTable$StandingsLists$DriverStandings[[1]])

# Clean constructor data
# Remove unneeded info from driver_constructors and rename some variables
driver_constructors_reduced.df <-  driver_constructors_full.df%>%
  select(-position, -positionText, -points, -wins, -url, -url1) %>%
  rename(driverNationality = nationality, constructorName = name, constructorNationality = nationality1) %>%
  mutate(dateOfBirth = ymd(dateOfBirth))




# Pitstop Data ------------------------------------------------------------

pitstops.url <- "http://ergast.com/api/f1/2023/1/pitstops.json?limit=60"
pitstops.df <- fromJSON(pitstops.url)$MRData$RaceTable$Races$PitStops[[1]]

# Clean pitstop data
pitstops_clean.df <- pitstops.df %>%
  mutate(lap_pitted = as.numeric(lap),
         stop_number = as.numeric(stop),
         pit_duration_secs = as.numeric(duration),
         time_pitted = hms(time)) %>%
  select(-time, -duration, -lap, -stop)

# Create temp df denoting pit in-laps
pitstops_in.df <- pitstops_clean.df %>%
  select(driverId, lap_pitted) %>%
  rename(pit_in_lap = lap_pitted) %>%
  mutate(is_in_lap = 1)

# Create temp df denoting pit out-laps
pitstops_out.df <- pitstops_in.df %>%
  mutate(pit_out_lap = pit_in_lap + 1) %>%
  rename(is_out_lap = is_in_lap) %>%
  select(-pit_in_lap) 


# Join Laptime & Team/Constructor & pitstop Data --------------------------

# Join teams
r1_laptimes_constructor.df <- r1_laptimes_clean.df %>%
  left_join(driver_constructors_reduced.df, by="driverId")


# Join pitstops
r1_laptimes_constructor_pits.df <- r1_laptimes_constructor.df %>%
  left_join(pitstops_in.df,
            by = join_by(driverId == driverId, lap == pit_in_lap)) %>%
  left_join(pitstops_out.df,
            by = join_by(driverId == driverId, lap == pit_out_lap))

# Clean pitstop data
r1_laptimes_constructor_pits.df <- r1_laptimes_constructor_pits.df %>%
  mutate(is_in_lap = ifelse(is.na(is_in_lap), 0, 1),
         is_out_lap = ifelse(is.na(is_out_lap), 0, 1)) %>%
  group_by(driverId, lap) 

# Further Cleaning --------------------------------------------------------

# Flag safety cars/yellow flags:


# Analysis ----------------------------------------------------------------

redbull_pits <- r1_laptimes_constructor_pits.df %>%
  filter(constructorId == "red_bull", pitted_this_lap == 1)

r1_laptimes_constructor_pits.df %>%
  filter(constructorId == "red_bull") %>%
  ggplot() +
  geom_point(aes(x=lap, y = laptime_seconds, group = driverId, color = driverId)) +
  geom_vline(aes(xintercept = lap, color = driverId), data = redbull_pits)
  theme(legend.position="none")
  
