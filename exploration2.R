library(tidyverse)
library(lubridate)
library(jsonlite)
library(xml2)

query_template <- "https://ergast.com/api/f1/<season>/<round>/..."


# XML
url.xml <- "https://ergast.com/api/f1/2023/1/pitstops"
temp2 <- read_xml(url1)


# JSON
url.json <- "https://ergast.com/api/f1/2023/1/pitstops.json"
temp <- fromJSON(url.json)


r1_pitstops <- temp$MRData$RaceTable$Races$PitStops[[1]]



s2023_1_lap_1.url <- "https://ergast.com/api/f1/2023/1/laps/1.json"
s2023_1_lap_1.json <- fromJSON(s2023_1_lap_1.url)
s2023_1_lap_1.df <- s2023_1_lap_1.json$MRData$RaceTable$Races$Laps[[1]]$Timings[[1]]
s2023_1_lap_1.df

s2023_1_lap_2.url <- "https://ergast.com/api/f1/2023/1/laps/2.json"
s2023_1_lap_2.json <- fromJSON(s2023_1_lap_2.url)
s2023_1_lap_2.df <- s2023_1_lap_2.json$MRData$RaceTable$Races$Laps[[1]]$Timings[[1]]
s2023_1_lap_2.df

total_laptimes.url <- "https://ergast.com/api/f1/2023/1/laps.json?limit=100"
total_laptimes.json <- fromJSON(total_laptimes.url)
total_laptimes.df <- total_laptimes.json$MRData$RaceTable$Races$Laps[[1]]$Timings

total_laptimes.json$MRData$RaceTable$Races$Laps[[1]]$Timings[[3]]



pitstops.url <- "https://ergast.com/api/f1/2021/1/pitstops.json"

pitstops.json <- fromJSON(pitstops.url)
temp <- pitstops.json$MRData$RaceTable$Races$PitStops[[1]]

ggplot(temp) +
  geom_point(aes(y = driverId, x = duration))





# ===============================

temp.url <- "https://ergast.com/api/f1/2021/1/results.json"
temp.json <- fromJSON(temp.url)
temp.df <- temp.json$MRData$RaceTable$Races$Results[[1]]


# Get No. of races in season
races.url <- "https://ergast.com/api/f1/2021.json"
races.json <- fromJSON(races.url)
num_races.int <-strtoi(races.json$MRData$total)

# Get pitstops from season
pitstops.df <- map_df(1:num_races.int, function(i){
  
  # Admin
  cat("Accessing Round", i)
  Sys.sleep(1)
  
  
  # Access pitstop data for round i
  pitstops.url <- paste0("https://ergast.com/api/f1/2021/", i, "/pitstops.json")
  pitstops.json <- fromJSON(pitstops.url)
  
  
  # Get round from JSON data (important for seasons where races were cancelled)
  round <- pitstops.json$MRData$RaceTable$round
  
  
  # Create round data frame
  temp_pitstops.df <- pitstops.json$MRData$RaceTable$Races$PitStops[[1]]
  
  
  # Include round number in dataframe
  temp_pitstops.df$round = round
  
  
  return(temp_pitstops.df)
  
})

# Get driver & constructor info and combine
results.url <- "https://ergast.com/api/f1/2021/1/results.json"
results.json <- fromJSON(results.url)
driver_data.df <- results.json$MRData$RaceTable$Races$Results[[1]]$Driver
constructor_data.df <- results.json$MRData$RaceTable$Races$Results[[1]]$Constructor
driver_constructor.df <- cbind(driver_data.df, constructor_data.df)
driver_constructor.df <- driver_constructor.df %>%
  rename(driverUrl = 4, constructorUrl = 10, driverNationality = 8, constructorNationality = 12)

FULL_pitstops.df <- left_join(pitstops.df, driver_constructor.df, by = "driverId")

# Convert strings to numbers
FULL_pitstops.df <- FULL_pitstops.df %>%
  mutate(lap = as.numeric(lap),
         stop = as.numeric(stop),
         round = as.numeric(round),
         permanentNumber = as.numeric(permanentNumber),
         duration = as.numeric(duration))



FULL_pitstops.df <- FULL_pitstops.df %>%
  filter(round != 12) %>%       # Remove round 12 (Spa rained out no racing)
  filter(driverId != "kubica")  # Kubica was a stand in for a few rounds

temp <- FULL_pitstops.df %>%
  select(round, driverId, constructorId, duration) %>%
  group_by(driverId, constructorId) %>%
  summarise(mean_pit_duration = mean(duration, na.rm = T),
            pitstops = n()) %>%
  arrange(constructorId)


temp %>% 
  group_by(constructorId) %>%
  mutate(difference_meant_pit = max(mean_pit_duration) - min(mean_pit_duration),
         corrected_difference = ifelse(mean_pit_duration == max(mean_pit_duration), difference_meant_pit, 0-difference_meant_pit)) %>%
  ungroup()




FULL_pitstops.df %>%
  filter(constructorId == "red_bull") %>%
  ggplot() + 
  geom_point(aes(group = driverId, y = round, x = duration, colour = driverId))

                                                                 