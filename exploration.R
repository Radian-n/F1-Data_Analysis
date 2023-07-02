library(tidyverse)
library(lubridate)

lap_times.df <- read_csv("raw_csvs/lap_times.csv")
pitstops.df <- read_csv("raw_csvs/pit_stops.csv")
drivers.df <- read_csv("raw_csvs/drivers.csv")
circuits.df <- read.csv("raw_csvs/circuits.csv")
races.df <- read_csv("raw_csvs/races.csv")
qualifying.df <- read_csv("raw_csvs/qualifying.csv")
driver_standings.df <- read_csv("raw_csvs/driver_standings.csv")
sprints.df <- read_csv("raw_csvs/sprint_results.csv")



lap_times_temp <- inner_join(lap_times.df, drivers.df, by = "driverId")
lap_times_temp <- inner_join(lap_times_temp, races.df, by = "raceId")
pitstop_temp <- inner_join(pitstops.df, drivers.df, by = "driverId")
pitstop_temp <- inner_join(pitstop_temp, races.df, by = "raceId")


lap_times_temp <- lap_times_temp %>%
  mutate(laptime_seconds = milliseconds / 1000)


lap_times_canada <- lap_times_temp %>%
  filter(circuitId == 7) %>%
  group_by(raceId) %>%
  mutate(year_min_laptime = min(laptime_seconds))
  # group_by(raceId, lap) %>%
  # summarise(lap_times_ms = milliseconds)


ggplot(data = lap_times_canada) +
  geom_point(aes(x = year, y = year_min_laptime, group = code, color = code))



driver_standings.df %>%
  