# F1 Tyre Degradation Analysis – Bahrain GP 2024, Hamilton
By _Haikien Nguyen_

This project analyzes F1 telemetry data to estimate tyre degradation and simulate the impact of pit stops on total race time. The goal is to understand how total race time varies depending on the pit lap, using a simplified linear degradation model.

Analysis is carried using Rstudio and it requires the following libraries: 
```
readr
ggplot2
dplyr
```

## Tyre Degradation Analysis
We focused on Lewis Hamilton during the Bahrain GP 2024, analyzing stint 3.  
A linear regression was applied to the stable laps (excluding the first two anomalous laps) to estimate tyre degradation per lap:
**Regression results:**

- Base lap time (`base_lap`): 94.88 s  
- Average degradation per lap (`degradation`): 0.038 s

The plot below shows the lap times and the regression line:

Tyre Degradation – Bahrain GP, Hamilton, Stint 3.png




