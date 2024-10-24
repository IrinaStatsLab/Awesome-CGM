# This is the script for processing Buckingham CGMS data into the updated format. 
# Author: Rucha Bhat, Shaun Cass, edited by Charlotte Xu and Neo Kok
# Date: October 24, 2024

library(tidyverse)
library(magrittr)
library(readr)

# The dataset is downloaded as a folder containing multiple data tables and forms.
# First, download the entire dataset. Do not rename the downloaded folder.

# Data folder is named "DirecNetNavigatorPilotStudy" - rename if downloaded file name changes

# Reading the raw CGM data from a CSV file into 'curr'.
curr <- read_csv("DirecNetNavigatorPilotStudy/DirecNetNavigatorPilotStudy/DataTables/tblFNavGlucose.csv")

# Combine the date and time columns into a single 'time' column using POSIX1t format (standard time format in R).
curr$time = strptime(paste(as.Date(curr$NavReadDt), curr$NavReadTm), 
                     format = "%Y-%m-%d %H:%M:%S")

# Select only the relevant columns (ID, time, glucose), and reorder them.
curr = curr[, c(2, 6, 5)]

# Rename the columns for clarity and consistency (id, time, and glucose level 'gl').
colnames(curr) = c("id", "time", "gl")

# Ensure that the glucose values are numeric. This is crucial for further data manipulation.
curr$gl = as.numeric(curr$gl)

# Replace glucose values that are either below 32 mg/dL or above 450 mg/dL with NA.
# These values are considered outside the reliable range for CGM data.
curr$gl[curr$gl <= 32] <- NA
curr$gl[curr$gl > 450] <- NA

# Optionally, remove rows with NA glucose values. Uncomment if needed.
# curr = na.omit(curr)

# The following function is used to remove regions of zero variability in glucose measurements.
# These regions are likely caused by CGM sensor errors. The function removes periods
# where glucose readings do not change (i.e., sensor malfunction).
zero.remove = function(tab) {
  tab %>%
    mutate(diff = gl - lag(gl)) %>%
    filter(diff != 0, diff != lag(diff), diff != lag(diff, 2)) %>%
    select(-diff)
}

# Apply the zero variability removal function to each patient's data group, and combine the results.
curr = curr %>% group_split(id) %>% map_dfr(zero.remove)

# >>>> Adding additional variables

# Load the enrollment data which includes gender and other patient details.
Screening <- read_csv("DirecNetNavigatorPilotStudy/DirecNetNavigatorPilotStudy/DataTables/tblFEnrollment.csv")

# Load the patient roster data to retrieve insulin modality and age at baseline.
Patient <- read_csv("DirecNetNavigatorPilotStudy/DirecNetNavigatorPilotStudy/DataTables/tblFPtRoster.csv")

# Filter patients who have 'Completed' status and summarize their insulin modality
# (1 for pump users, 0 for others) and age at baseline.
Patient_filtered <- Patient %>%
  filter(PtStatus == 'Completed') %>%
  group_by(PtID) %>%
  summarise(insulinModality = ifelse(any(CurrInsMod == "pump"), 1, 0),
            age = first(AgeAtBaseline)) %>%
  ungroup()

# Filter CGM data to include only patients who appear in the filtered Patient list (i.e., completed patients).
CGM_filtered <- curr %>% filter(id %in% Patient_filtered$PtID)

# Prepare the final output, combining the CGM data and patient information.
Output <- CGM_filtered %>%
  mutate(time = as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S")) %>% 
  select(id = id, time = time, gl = gl) %>%
  mutate(device = 'FreeStyle Navigator', type = 1, dataset = "buckingham2007") %>%
  # Merge with Patient_filtered to add insulinModality and age information.
  left_join(Patient_filtered %>% select(id = PtID, insulinModality = insulinModality, age = age), by = "id") %>%
  # Merge with Screening to add gender (sex) information.
  left_join(Screening %>% select(id = PtID, sex = Gender), by = "id")

# Update the IDs by adding 6000 to each id for uniqueness within this dataset.
Output <- Output %>%
  group_by(id) %>%
  mutate(pseudoID = cur_group_id() + 6000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset) # Reorder columns and select only the relevant ones for the output

# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

# Write the final cleaned and processed dataset to a CSV file for further analysis.
write.csv(Output, file = "csv_data/buckingham2007.csv", row.names = FALSE)
