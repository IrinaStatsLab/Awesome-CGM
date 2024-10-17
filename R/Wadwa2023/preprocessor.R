# This is the script for processing Wadwa2023 data into the common format. 
# Author: Samuel Tan, Neo Kok
# Date: 10/7/2024

library(tidyverse)
library(lubridate)

# Part A. Read in Raw Dataset and merge if multiple sheets/files
cgmData <- read.table("PEDAPDexcomClarityCGM.txt", sep = "|", header = TRUE)
demoData <- read.table("PEDAPDiabScreening.txt", sep = "|", header = TRUE)
ageData <- read.table("PtRoster.txt", sep = "|", header = TRUE)

merged_data <- cgmData %>%
  left_join(demoData, by = "PtID")

merged_data <- merged_data %>%
  left_join(ageData, by = "PtID")

# Part B. Processing for Validation Dataset Feature and Quality

# Define a function to add a midnight missingness in timestamp record
# This function checks if the entry missing a time, and if so, adds "12:00:00 AM" as the Midnight Gap
add_time_if_missing <- function(x) {
  if (grepl("^\\d{1,2}/\\d{1,2}/\\d{4}$", x)) {
    return(paste(x, "12:00:00 AM"))
  } else {
    return(x)
  }
}

merged_data$DeviceDtTm <- sapply(merged_data$DeviceDtTm, add_time_if_missing)

final_data <- merged_data %>%
  mutate(
    id = PtID + 2000,               # Create a new 'id' by adding 2000 to the 'PtID' value
    time = mdy_hms(DeviceDtTm),      # Convert the 'DeviceDtTm' column (date-time string) to proper date-time format using 'mdy_hms'
    gl = as.numeric(CGM),            # Convert the 'CGM' column (glucose values) to numeric format
    age = AgeAsofEnrollDt,           # Rename the 'AgeAsofEnrollDt' column to 'age' for clarity
    sex = Sex,                       # Rename 'Sex' column to 'sex'
    insulinModality = 1,             # Assign 1 to 'insulinModality' indicating use of insulin pump
    type = 1,                        # Assign 1 to 'type' indicating Type I Diabetic
    device = "Dexcom G6",            # Assign a constant value "Dexcom G6" to 'device' 
    dataset = "wadwa2023"            # Assign the dataset name ("wadwa2023")
 ) %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

write_csv(final_data, "csv_data/wadwa2023.csv")
