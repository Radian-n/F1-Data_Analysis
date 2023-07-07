import sys
import fastf1
import pandas as pd
import pyarrow.parquet as pq
from pathlib import Path
from datetime import datetime

"""
Run script from command line with the year as the only agrument. Writes dataframe
to a .parquet file in /data

Command line example:
    python get_race_data.py 2023

"""

def get_race_data(YEAR: int, roundNum: int) -> pd.DataFrame:
    # Get session data. Exits script if no data exists for year/round
    try:
        session = fastf1.get_session(YEAR, roundNum, "R")
    except ValueError:
        sys.exit("Invalid YEAR or ROUND_NUMBER provided")

    session.load(weather=True, telemetry=False)

    # Get weather data
    weather_data = session._laps.get_weather_data()
    
    # Get laps data
    laps = session.laps

    # Prepare laps and weather data for joining
    laps = laps.reset_index(drop=True)
    weather_data = weather_data.reset_index(drop=True)

    # Join the two tables into a pandas df. Note: FastF1 uses Pandas under the hood
    lap_weather_race_df = pd.concat([laps, weather_data.loc[:, ~(weather_data.columns == 'Time')]], axis=1)

    # Encode the round into dataframe
    lap_weather_race_df["Round"] = roundNum
    lap_weather_race_df["Season"] = YEAR

    return lap_weather_race_df


def get_completed_num_rounds():
    schedule = fastf1.get_event_schedule(datetime.now().year)
    remaining = fastf1.get_events_remaining(datetime.now())
    num_rounds = schedule.shape[0] - remaining.shape[0]     # difference of rows
    return num_rounds


def write_parquet(dataframe) -> None:
    filepath = Path(f'data/races_{arg_year_str}.parquet')  
    filepath.parent.mkdir(parents=True, exist_ok=True)
    dataframe.to_parquet(filepath, index=False)
    return


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Incorrect number of arguments: fastf1_testing.py YEAR ROUND_NUMBER") 
    
    # Acquiring year and round arguments & convert to int
    try:
        arg_year_int = int(sys.argv[1])
    except ValueError:
        sys.exit("Incorrect argument type: fastf1_testing.py int int")

    # Loop over completed rounds and store in an array
    rounds_df_list = []     # We'll concatenate the dataframes together in one go later

    if datetime.now().year == arg_year_int:
        num_rounds = get_completed_num_rounds()
    else:
        num_rounds = fastf1.get_event_schedule(arg_year_int).shape[0]
    print(num_rounds)

    for round_num in range(1, num_rounds):      # Include final round (Round 0 is testing)
        print("Getting round:", round_num, "----------------")
        round_data = get_race_data(arg_year_int, round_num)
        rounds_df_list.append(round_data)
    
    # Combine dataframes stored in array
    season_laptime_df = pd.concat(rounds_df_list)
    print(season_laptime_df.shape)

    # Output parquet file
    write_parquet(season_laptime_df)

