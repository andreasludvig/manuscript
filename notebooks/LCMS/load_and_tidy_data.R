# Setup -------------------------------------------------------------------
library(readxl)
library(data.table)
library(ggplot2)
library(here)
library(fs)

# AS0013B -----------------------------------------------------------------
## Load raw data -----------------------------------------------------------
# Ignore warnings. Just NA's as expected
data <-
  read_excel(
    path = "notebooks/LCMS/data_raw/230628RAVERSION_Short.xlsx",
    sheet = "Hydroxymidazolam",
    skip = 4,
    col_types = c(
      "text", "skip", "skip", "skip",
      "skip", "skip", "skip", "skip",
      "numeric", "skip", "skip", "text",
      "skip", "skip", "skip", "skip"
    ),
    col_names = c("sample_name", "amount", "peak_status")
  )

metabolite <- "Hydroxymidazolam"
data$metabolite <- metabolite

# Set as DT, and get only samples
setDT(data)
data <- data[grepl("AS", data$sample_name)] # get samples of interest


## Merge with sample info --------------------------------------------------
sample_info <- read_excel("notebooks/LCMS/data_raw/AS0013B_sample_info.xlsx")

tidy_data <- merge.data.table(data, sample_info, by = "sample_name")

# Check dt structure
str(tidy_data)

# Make treatment and time factors
tidy_data[
  ,
  treatment := factor(
    treatment,
    levels = c(
      "control",
      "medium",
      "0.01 ng/ml IL-6",
      "0.1 ng/ml IL-6",
      "1 ng/ml IL-6",
      "10 ng/ml IL-6",
      "0.01 ng/ml IL-1B",
      "0.1 ng/ml IL-1B",
      "1 ng/ml IL-1B",
      "10 ng/ml IL-1B"
    ),
    ordered = TRUE
  )
]

tidy_data[, time_treatment := factor(time_treatment, ordered = TRUE)]


## Peak status' ------------------------------------------------------------
# Check peak status' for any amounts below what below/above the limit of our
# standard curve.
# Check peak status'
unique(tidy_data$peak_status)
# Find any that is not NA
peak_status_data <- tidy_data[!is.na(peak_status)]


### Peaks are not removed here! See thought in LCMS.qmd
# Save the bad peaks for viewing in LCMS.qmd
saveRDS(peak_status_data, here("notebooks/LCMS/data_processed/AS0013_peak_status.rds"))

## Mean and relative activity ----------------------------------------------
# Calculate the mean amount of replicates
tidy_data[,
          mean_amount := mean(amount, na.rm = TRUE),
          by = .(treatment, time_treatment, time_incubation)
]

# Add column with control/calibrator means:
tidy_data[,
          control_mean := mean(amount[treatment == "control"], na.rm=TRUE),
          by = .(time_treatment, time_incubation)]



# Calculate amounts relative to the control
tidy_data[, relative_amount := amount / control_mean]


tidy_data[,
          mean_relative_amount := mean(relative_amount, na.rm = TRUE),
          by = .(treatment, time_treatment, time_incubation)
]



## Save the data -----------------------------------------------------------

saveRDS(tidy_data, "notebooks/LCMS/data_processed/AS0013.rds")

rm(list = ls())




# AS0008 -----------------------------------------------------------------
## Load raw data -----------------------------------------------------------
# Ignore warnings. Just NA's as expected
data <-
  read_excel(
    path = "notebooks/LCMS/data_raw/220506_AS008_v1_Short.xlsx",
    sheet = "Hydroxymidazolam",
    skip = 4,
    col_types = c(
      "text", "skip", "skip", "skip",
      "skip", "skip", "skip", "skip",
      "numeric", "skip", "skip", "text",
      "skip", "skip", "skip", "skip"
    ),
    col_names = c("sample_name", "amount", "peak_status")
  )

metabolite <- "Hydroxymidazolam"
data$metabolite <- metabolite

# Set as DT, and get only samples
setDT(data)
data <- data[grepl("AS", data$sample_name)] # get samples of interest


## Merge with sample info --------------------------------------------------
sample_info <- read_excel("notebooks/LCMS/data_raw/AS0008_sample_info.xlsx")

tidy_data <- merge.data.table(data, sample_info, by = "sample_name")

# Check dt structure
str(tidy_data)

# Make treatment and time factors
tidy_data[
  ,
  treatment := factor(
    treatment,
    levels = c(
      "control",
      "medium",
      "0.01 ng/ml IL-6",
      "0.1 ng/ml IL-6",
      "1 ng/ml IL-6",
      "10 ng/ml IL-6",
      "0.01 ng/ml IL-1B",
      "0.1 ng/ml IL-1B",
      "1 ng/ml IL-1B",
      "10 ng/ml IL-1B"
    ),
    ordered = TRUE
  )
]

tidy_data[, time_treatment := factor(time_treatment, ordered = TRUE)]


## Peak status' ------------------------------------------------------------
# Check peak status' for any amounts below what below/above the limit of our
# standard curve.
# Check peak status'
unique(tidy_data$peak_status)
# Find any that is not NA
peak_status_data <- tidy_data[!is.na(peak_status)]

# Save the bad peaks for viewing in LCMS.qmd
saveRDS(peak_status_data, here("notebooks/LCMS/data_processed/AS0008_peak_status.rds"))


# Remove samples 152, 153, 162, 163, 172, and 173 as no baselcocktail was added
# to these wells, and that is why there are no peaks
# Remove sample 171, as there was no spheroid in this well.
# Note that two are left with "response low".
remove_samples <- tidy_data[!is.na(peak_status)][-c(1, 9)]
tidy_data <- tidy_data[!remove_samples, on = "sample_name"]


## Mean and relative activity ----------------------------------------------
# Calculate the mean amount of replicates
tidy_data[,
  mean_amount := mean(amount, na.rm = TRUE),
  by = .(treatment, time_treatment, time_incubation)
]

# Add column with control/calibrator means:
tidy_data[,
          control_mean := mean(amount[treatment == "control"], na.rm=TRUE),
          by = .(time_treatment, time_incubation)]



# Calculate amounts relative to the control
tidy_data[, relative_amount := amount / control_mean]


tidy_data[,
          mean_relative_amount := mean(relative_amount, na.rm = TRUE),
          by = .(treatment, time_treatment, time_incubation)
          ]



## Save the data -----------------------------------------------------------
saveRDS(tidy_data, "notebooks/LCMS/data_processed/AS0008.rds")

rm(list = ls())



# Combine data ------------------------------------------------------------

files <- dir_ls(here("notebooks/LCMS/data_processed"),
         regexp = "AS")
files <- files[!grepl("_peak_status", files)] 

data <- lapply(files, readRDS)

final_data <- rbindlist(data, idcol = "file")

final_data[, 
           file := gsub(pattern = "notebooks/LCMS/data_processed/",
                        replacement = "", file)
           ]

# Split treatment column to get a column with concentrations as numeric
final_data[, c("concentration", "treatment_group") := tstrsplit(treatment, " ng/ml (IL-6|IL-1B|control)", fixed = FALSE, keep = 1L)]
final_data[, concentration := as.numeric(concentration)]
final_data[is.na(concentration), concentration := 0]

# Fix the treatment group column
final_data[, 
           treatment_group := 
             fcase(grepl("IL-6", treatment), "IL-6",
                   grepl("IL-1B", treatment), "IL-1B",
                   grepl("control", treatment), "control",
                   grepl("medium", treatment), "medium")]

# Save the final data.frame
saveRDS(final_data, file = here("notebooks/LCMS/data_processed/final_data.rds"))


