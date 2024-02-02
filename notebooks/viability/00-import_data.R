
# Setup -------------------------------------------------------------------
library(readxl)
library(fs)
library(data.table)

# Load excel data --------------------------------------------------------

# Get files
via_files <- dir_ls("notebooks/viability/data_raw")

#### Donor 1: AS0003 ####
# NOTE FROM EXCEL: 
# Day 5 should be ignored. Did not pipette enough we in the wells, 
# so calculations are off. Maybe dont do relative to day 5 since this is to 
# high in ATP.

# Read excel data
via_data <- read_excel(path = via_files[1])

# Save as RDS file
saveRDS(
  object = via_data,
  file = "notebooks/viability/data_processed/AS0003_viability.rds"
  )

#### Donor 2: AS0006 ####
# Read excel data
via_data <- read_excel(path = via_files[2])

# Save as RDS file
saveRDS(
  object = via_data,
  file = "notebooks/viability/data_processed/AS0006_viability.rds"
  )

#### Donor 2: AS0012 ####
# Read excel data
via_data <- read_excel(path = via_files[3])

# Save as RDS file
saveRDS(
  object = via_data,
  file = "notebooks/viability/data_processed/AS0012_viability.rds"
  )


# Combine dataframes ------------------------------------------------------
rm(list = ls())

file_paths <- dir_ls("notebooks/viability/data_processed")

dfs_list <- lapply(file_paths, readRDS)

final_df <- rbindlist(dfs_list)

saveRDS(final_df, "notebooks/viability/data_processed/final_viability.rds")
