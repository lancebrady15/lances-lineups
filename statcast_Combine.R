# Set working directory
setwd("/Users/Lance/Desktop/sds_492")

# List all relevant statcast files (statcast_2015.rds to statcast_2024.rds)
file_names <- list.files(pattern = "^statcast_\\d{4}\\.rds$")

# Load and combine all files
combined_statcast <- do.call(rbind, lapply(file_names, readRDS))

# Optional: Check structure
str(combined_statcast)
# Optional: Check total number of games or rows
cat("Total rows:", nrow(combined_statcast), "\n")

# Save as a single RDS
saveRDS(combined_statcast, "statcast_all_years.rds")
