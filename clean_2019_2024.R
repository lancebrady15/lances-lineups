# Set working directory
setwd("/Users/Lance/Desktop/sds_492")

# Load data
data_2019 <- readRDS("statcast_pitch_data_2019.rds")
data_2024 <- readRDS("statcast_pitch_data_2024.rds")

# Convert game_date to Date class
data_2019$game_date <- as.Date(data_2019$game_date)
data_2024$game_date <- as.Date(data_2024$game_date)

# Define special game_pks
special_pks_2019 <- c(566083, 566084)
special_pks_2024 <- c(745444, 746175)

# Filter 2019
filtered_2019 <- subset(data_2019,
                        game_date >= as.Date("2019-03-28") |
                          game_pk %in% special_pks_2019)

# Filter 2024
filtered_2024 <- subset(data_2024,
                        game_date >= as.Date("2024-03-28") |
                          game_pk %in% special_pks_2024)

# Save filtered datasets
saveRDS(filtered_2019, "statcast_2019.rds")
saveRDS(filtered_2024, "statcast_2024.rds")
