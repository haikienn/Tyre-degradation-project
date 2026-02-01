

library(readr)
library(dplyr)
library(ggplot2)

# Load datasets and specify columns type facilitating calculations
lap_times <- read_csv("lap_times.csv",
                      col_types = cols(
                        season = col_integer(),
                        round = col_integer(),
                        driverId = col_character(),
                        lapNumber = col_integer(),
                        position = col_integer(),
                        time = col_character()
                      )
) %>%
  rename(lapPosition = position, lapTime = time)

pitstops <- read_csv("pitstops.csv",
                     col_types = cols(
                       season = col_integer(),
                       round = col_integer(),
                       driverId = col_character(),
                       lap = col_integer(),
                       stop = col_integer(),
                       duration = col_character()
                     )
) %>%
  rename(pitLap = lap, pitNumber = stop, pitDuration = duration) %>%
  select(season, round, driverId, pitLap, pitNumber, pitDuration)

race_results <- read_csv("race_results.csv") %>%
  select(season, round, driverId, driverName, constructorName, position, points, grid, status) %>%
  rename(finalPosition = position, startingGrid = grid)

races <- read_csv("races.csv") %>% select(season, round, raceName)

drivers <- read_csv("drivers.csv") %>% select(driverId, code)

# Function to convert times to seconds
convert_time <- function(x) {
  if (is.na(x) | x == "") return(NA_real_)
  parts <- strsplit(x, ":")[[1]]
  if (length(parts) == 2) {
    mins <- as.numeric(parts[1])
    secs <- as.numeric(parts[2])
  } else {
    mins <- 0
    secs <- as.numeric(parts[1])
  }
  mins * 60 + secs
}

lap_times <- lap_times %>% mutate(lapTime_sec = sapply(lapTime, convert_time))
pitstops <- pitstops %>% mutate(pitDuration_sec = sapply(pitDuration, convert_time))

# Merge datasets
df <- lap_times %>%
  inner_join(races, by = c("season", "round")) %>%
  left_join(pitstops, by = c("season", "round", "driverId", "lapNumber" = "pitLap")) %>%
  left_join(race_results, by = c("season", "round", "driverId")) %>%
  left_join(drivers, by = "driverId") %>%
  arrange(season, round, driverId, lapNumber)

# calculate pit_flag
df <- df %>%
  group_by(season, round, driverId) %>%
  mutate(pit_flag = ifelse(!is.na(pitNumber), 1, 0)) %>%
  ungroup()

# identify stint
df <- df %>%
  group_by(season, round, driverId) %>%
  mutate(stint = 1 + cumsum(pit_flag)) %>%
  ungroup()


# Filter for Bahrain GP 2024, Hamilton
df_focus <- df %>%
  filter(season == 2024,
         raceName == "Bahrain Grand Prix",
         code == "HAM") %>%
  arrange(lapNumber)

# Choose a single stint for analysis 
df_focus %>% count(stint)

# For example stint 3
stint_data <- df_focus %>%
  filter(stint == 3) %>%
  mutate(lap_stint = row_number())   # lap numbers relative to stint

# Visualize degradation 
ggplot(stint_data, aes(x = lap_stint, y = lapTime_sec)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Lap Time Evolution – Bahrain GP, Hamilton, Stint 3",
    x = "Lap Number in Stint",
    y = "Lap Time (seconds)"
  )

# Exclude the first 2 abnormal lap times
stint_data_clean <- stint_data %>% filter(lap_stint > 2)

# Calculate degradation with linear regression
model <- lm(lapTime_sec ~ lap_stint, data = stint_data_clean)
summary(model)

ggplot(stint_data_clean, aes(x = lap_stint, y = lapTime_sec)) +
  geom_point() +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Tyre Degradation – Bahrain GP, Hamilton, Stint 3",
       x = "Lap Number in Stint",
       y = "Lap Time (seconds)"
      ) +
  theme_minimal()   

base_lap <- coef(model)[1]       # intercept = lap time start of stint
degradation <- coef(model)[2]    # cost in seconds per lap

# Simulation of total race time for different pit strategies
pit_cost <- 24                 # assumption pit stop cost in seconds
race_laps <- max(df_focus$lapNumber)

total_race_time <- function(pit_lap) {
  #laps before pit
  laps_before <- 1:pit_lap
  time_before <- sum(base_lap + degradation * laps_before)
  
  #laps after pit
  laps_after <- 1:(race_laps - pit_lap)
  time_after <- sum(base_lap + degradation * laps_after)
  
  #total time
  time_before + pit_cost + time_after
}

#all possible pits
pit_laps <- 1:race_laps
total_time <- numeric(length(pit_laps))  

for (i in 1:length(pit_laps)) {
  total_time[i] <- total_race_time(pit_laps[i])
}

results <- data.frame(pit_lap = pit_laps, total_time = total_time)

# Optimal pit lap 
min_time <- min(results$total_time)
optimal_pit <- results[results$total_time == min_time, ][1, ] #take first match

# Graph: total race time vs pit lap
ggplot(results, aes(x = pit_lap, y = total_time)) +
  geom_line() +
  geom_vline(xintercept = optimal_pit$pit_lap,
             linetype = "dashed",
             color = "red") +
  theme_minimal() +
  labs(
    title = "Simulated Total Race Time vs Pit Lap",
    x = "Pit Lap",
    y = "Total Race Time (seconds)"
  ) + 
  xlim(0,56)



