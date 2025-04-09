# ------------------- #
#  Load Dependencies  #
# ------------------- #
library(baseballr)
library(dplyr)
library(purrr)
library(lubridate)

# -------------------- #
#  Helper Function(s)  #
# -------------------- #

# This function downloads ALL pitcher data from Statcast, day-by-day,
# over a custom date range. It returns a single data frame.
get_statcast_data_range <- function(start_date, end_date, batch_size = 7) {
  start_date <- ymd(start_date)
  end_date <- ymd(end_date)
  
  # Create sequence of start dates every `batch_size` days
  batch_starts <- seq(start_date, end_date, by = paste(batch_size, "days"))
  
  all_data <- map_dfr(batch_starts, function(batch_start) {
    batch_end <- min(batch_start + days(batch_size - 1), end_date)
    message("Fetching: ", batch_start, " to ", batch_end)
    
    Sys.sleep(1)  # Keep 1s delay just in case
    
    tryCatch({
      data <- statcast_search(start_date = as.character(batch_start),
                              end_date = as.character(batch_end),
                              player_type = "pitcher")
      if (is.data.frame(data) && nrow(data) > 0) {
        return(data)
      } else {
        return(NULL)
      }
    }, error = function(e) {
      message("Error on ", batch_start, " to ", batch_end, ": ", e$message)
      return(NULL)
    })
  })
  
  return(all_data)
}

# ------------------------------ #
#  Main Function: Multi-Year DL  #
# ------------------------------ #

download_statcast_multi_year <- function(start_year, end_year, save_dir = getwd()) {
  
  # Define true regular season dates per year
  season_dates <- list(
    `2015` = c("2015-04-05", "2015-10-04"),
    `2016` = c("2016-04-03", "2016-10-02"),
    `2017` = c("2017-04-02", "2017-10-01"),
    `2018` = c("2018-03-29", "2018-10-01"),
    `2019` = c("2019-03-20", "2019-09-29"),
    `2020` = c("2020-07-23", "2020-09-27"),  # COVID season
    `2021` = c("2021-04-01", "2021-10-03"),
    `2022` = c("2022-04-07", "2022-10-05"),
    `2023` = c("2023-03-30", "2023-10-01"),
    `2024` = c("2024-03-20", "2024-09-30")
  )
  
  for (year in seq(start_year, end_year)) {
    year_chr <- as.character(year)
    
    if (!year_chr %in% names(season_dates)) {
      message("No season dates defined for ", year, "; skipping.")
      next
    }
    
    season_start <- season_dates[[year_chr]][1]
    season_end   <- season_dates[[year_chr]][2]
    
    message("===== Downloading year: ", year, " (", season_start, " to ", season_end, ") =====")
    
    year_data <- get_statcast_data_range(start_date = season_start,
                                         end_date   = season_end)
    
    if (nrow(year_data) == 0) {
      message("No data found for ", year, "; skipping save.")
      next
    }
    
    out_file <- file.path(save_dir, paste0("statcast_pitch_data_", year, ".csv"))
    message("Saving data for ", year, " to ", out_file)
    saveRDS(year_data, sub("\\.csv$", ".rds", out_file))
  }
}

# -------------------- #
#    Usage Example     #
# -------------------- #

# Download from 2015 through 2024
download_statcast_multi_year(start_year = 2015, end_year = 2024,
                             save_dir = "/Users/Lance/Desktop/sds_492")
