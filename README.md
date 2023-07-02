<<<<<<< HEAD
# Formula 1 Data Analysis Project
Matthew Kirk


## Currently working on:
Creating a model to predict tire/laptime falloff, based on historical data track data. In the future, this model will be run live with realtime data and will be used as the basis for a live pit stop strategy visualisation. 

I am currently using the [Ergast F1 API](https://ergast.com/mrd/) to access the main historical data. I will be using [FastF1](https://docs.fastf1.dev/) Python library to access some data no available in the Ergast API, and will also be relying on the FastF1 API for live data during races to run the real time models.


Currently this model uses the following factors to predict laptime:
- Tire age
- Driver
- Constructor/Team
- Previous lap time

Working on adding the following factors:
- Tire compound (C0 - C5, inter, wet, other)
- True tire age (i.e. if the tire was run in a previous session)
- Weather (temperature, etc.)
- Street Circuit / Traditional Circuit
- Group tracks based on downforce level/corner speeds/some other metric. OR just account for circuits individually?

Things the model will need to account for:
- Differences in lap distance for tracks
- Normalise laptimes in a reversable way to enable cross-track comparisons (i.e Austria quali ~64s, Spa quali ~103s)
=======
# Formula 1 Data Analysis Project
Matthew Kirk


## Currently working on:
Creating a model to predict tire/laptime falloff, based on historical data track data. In the future, this model will be run live with realtime data and will be used as the basis for a live pit stop strategy visualisation. 

I am currently using the [Ergast F1 API](https://ergast.com/mrd/) to access the main historical data. I will be using [FastF1](https://docs.fastf1.dev/) Python library to access some data no available in the Ergast API, and will also be relying on the FastF1 API for live data during races to run the real time models.


Currently this model uses the following factors to predict laptime:
- Tire age
- Driver
- Constructor/Team
- Previous lap time

Working on adding the following factors:
- Tire compound (C0 - C5, inter, wet, other)
- True tire age (i.e. if the tire was run in a previous session)
- Weather (temperature, etc.)
- Street Circuit / Traditional Circuit
- Group tracks based on downforce level/corner speeds/some other metric. OR just account for circuits individually?

Things the model will need to account for:
- Differences in lap distance for tracks
- Normalise laptimes in a reversable way to enable cross-track comparisons (i.e Austria quali ~64s, Spa quali ~103s)
>>>>>>> 813ff45817866c6471e854adcf7b3b41e1d98256
