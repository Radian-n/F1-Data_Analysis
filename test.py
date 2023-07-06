import sys
import fastf1
import pandas as pd
import pyarrow.parquet as pq
from pathlib import Path
from datetime import datetime


schedule = fastf1.get_event_schedule(2023)
remaining = fastf1.get_events_remaining(datetime.now())
num_rounds = schedule.shape[0] - remaining.shape[0]
print(num_rounds)