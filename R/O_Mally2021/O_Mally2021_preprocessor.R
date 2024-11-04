# Author: Samuel Tan, Neo Kok
# Date: 10/24/2024

library(tidyverse)
library(haven)
library(lubridate)

# The dataset is downloaded as a folder containing multiple data tables and forms.
# First, download the entire dataset. Do not rename the downloaded folder.

# Data folder is named "DCLP3 Public Dataset - Release 3 - 2022-08-04" - rename if downloaded file name changes

# Differences in folder name due to future releases should be accounted for:
main_folder = list.dirs(full.names = TRUE, recursive = FALSE)
data_folder = main_folder[grepl("DCLP3 Public Dataset - Release", main_folder)]

# Read in necessary data
cgmData <- read.table(paste0(data_folder, "/Data Files/cgm.txt"), sep = "|", header = TRUE)
screeningData <- read.table(paste0(data_folder, "/Data Files/DiabScreening_a.txt"),
                            sep = "|", header = TRUE, fill = TRUE, fileEncoding = "UTF-16LE", stringsAsFactors = FALSE, na.strings = "")

# Merge demographic data with CGM data
merged_data <- cgmData %>%
  left_join(screeningData, by = "PtID")

# Add additional variables: specify the dataset, subject type, device used, and placeholder values
final_data <- merged_data %>%
  mutate(
    id = PtID,
    time = as.POSIXct(dmy_hms(DataDtTm), format = "%Y-%m-%d %H:%M:%S"),
    gl = as.numeric(CGM),
    age = AgeAtEnrollment,
    sex = Gender,
    insulinModality = 1,
    type = 1,
    device = "Dexcom G6",
    dataset = "o_mally2021"
  ) %>%
  group_by(id) %>%
  # Generate unique pseudo IDs for each participant by adding 5000 to group IDs
  mutate(pseudoID = cur_group_id() + 5000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  # Select necessary variables
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset)

# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

# Save the processed dataset to a CSV file in the 'csv_data' folder
final_data %>% write.csv("csv_data/o_mally2021.csv", row.names = FALSE)

