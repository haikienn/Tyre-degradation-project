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
https://github.com/haikienn/Tyre-degradation-project/blob/29ef447e55d6a139ee6d00aed41e59628722372e/Tyre%20Degradation%20-%20Bahrain%20GP%2C%20Hamilton%2C%20Stint%203.png


## Pit Stop Simulation
We simulated total race time assuming a single pit stop at different laps.  
**Pit stop cost:** 24 s  

The plot below shows the total race time depending on the pit lap. The red dashed line indicates the optimal pit lap according to our simplified model.
https://github.com/haikienn/Tyre-degradation-project/blob/31c6de84493e81250f17fdb53676d26252445fc3/Simulated%20Total%20Race%20Time%20vs%20Pit%20Lap.png


## Interpretation, Limitations, and Broader Context

The analysis shows that tyre degradation, when measured purely in lap time loss, is minimal in the analyzed stint. The estimated degradation rate is too small to justify a pit stop based solely on time recovery, as the time lost during a pit stop cannot be recovered within a realistic number of laps.

This result highlights a key limitation of time-based degradation models: lap time alone is not sufficient to explain pit stop decisions in Formula 1.

In reality, pit stops are influenced by several additional factors not captured in this simplified model, including:

- Structural integrity and safety limits of the tyres
- FIA regulations (e.g., mandatory tyre usage rules)
- Strategic interactions such as undercut and overcut
- Track conditions and asphalt grip evolution
- Weather variability
- Traffic and race context
- Driver-specific factors such as aggression and tyre management style

Therefore, while the model provides a useful quantitative framework for understanding tyre degradation trends, it should be interpreted as a partial explanation rather than a full representation of real-world race strategy.

This limitation is not a weakness of the analysis but an important insight: it shows that Formula 1 strategy emerges from the interaction of physics, regulation, and competition, not from degradation alone.
