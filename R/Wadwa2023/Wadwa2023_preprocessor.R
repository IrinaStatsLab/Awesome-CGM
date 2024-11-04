# This is the script for processing Wadwa2023 data into the common format.
# Author: Samuel Tan, Neo Kok
# Date: 10/24/2024

library(tidyverse)
library(lubridate)


# The dataset is downloaded as a folder containing multiple data tables and forms.
# First, download the entire dataset. Do not rename the downloaded folder.

# Data folder is named "PEDAP Public Dataset - Release 3 - 2024-09-25"

# Differences in folder name due to future releases should be accounted for:
main_folder = list.dirs(full.names = TRUE, recursive = FALSE)
data_folder = main_folder[grepl("PEDAP Public Dataset - Release", main_folder)]

# Read in necessary data
cgmData <- read.table(paste0(data_folder, "/Data Files/PEDAPDexcomClarityCGM.txt"), sep = "|", header = TRUE)
demoData <- read.table(paste0(data_folder, "/Data Files/PEDAPDiabScreening.txt"), sep = "|", header = TRUE)
ageData <- read.table(paste0(data_folder, "/Data Files/PtRoster.txt"), sep = "|", header = TRUE)

# Merge demographic data with CGM data
merged_data <- cgmData %>%
  left_join(demoData, by = "PtID")

merged_data <- merged_data %>%
  left_join(ageData, by = "PtID")

# Time processing function for unique data quirk at midnight
add_time_if_missing <- function(x) {
  if (grepl("^\\d{1,2}/\\d{1,2}/\\d{4}$", x)) {
    return(paste(x, "12:00:00 AM"))
  } else {
    return(x)
  }
}

merged_data$DeviceDtTm <- sapply(merged_data$DeviceDtTm, add_time_if_missing)

# Add additional variables: specify the dataset, subject type, device used, and placeholder values
final_data <- merged_data %>%
  mutate(
    id = PtID,
    time = as.POSIXct(mdy_hms(DeviceDtTm), format = "%Y-%m-%d %H:%M:%S"),
    gl = as.numeric(CGM),
    age = as.numeric(AgeAsofEnrollDt),
    sex = Sex,
    insulinModality = as.numeric(1),
    type = as.numeric(1),
    device = "Dexcom G6",
    dataset = "wadwa2023"
  ) %>%
  group_by(id) %>%
  # Generate unique pseudo IDs for each participant by adding 2000 to group IDs
  mutate(pseudoID = cur_group_id() + 2000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  # Select necessary variables
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset)

# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

# Save the processed dataset to a CSV file in the 'csv_data' folder
write_csv(final_data, "csv_data/wadwa2023.csv")
