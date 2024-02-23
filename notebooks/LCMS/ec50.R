# Install and load drc package
# install.packages("drc") # Uncomment if not already installed
library(drc)

# Mock data
doses <- c(0.1, 0.2, 0.5, 1.0, 2.0, 5.0)
responses <- c(5, 10, 20, 50, 60, 70)
data <- data.frame(doses, responses)

# Fitting the model
model <- drm(responses ~ doses, data = data, fct = LL.4())

# Plotting
plot(model, type = "all")

# Calculating EC50
ec50 <- ED(model, 50, interval = "none")
summary(ec50)

# My data
library(here)
library(data.table)
library(drc)
library(ggplot2)

# Get the final data
data <- readRDS(here("notebooks/LCMS/data_processed/final_data.rds"))

# Subset data for just IL-6 and 0.5 hours incubation. 
data <- data[treatment_group %chin% c("IL-6", "control") & time_incubation == 0.5]

# Remove the 24-hour treatment duration data points
data[time_treatment != 24]

# Calculate the mean relative amount for each IL-6 concentration
data_means <- aggregate(mean_relative_amount ~ concentration, data = data, FUN = mean)

# Fit the dose-response model using the mean relative amounts
model <- drm(mean_relative_amount ~ concentration, data = data_means, fct = LL.4())

# Plot the dose-response curve
plot(model, type = "all")

# Calculate EC50 from the model
ec50 <- ED(model, 50, interval = "delta")

# Get a summary which includes the EC50 value and its confidence interval
summary(ec50)

# If you want to extract just the EC50 value
ec50_value <- coef(ec50)[1]



