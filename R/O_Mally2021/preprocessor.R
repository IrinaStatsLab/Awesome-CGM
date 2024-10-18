# This is the script for processing O_Mally2021 data into the common format. 
# Author: Samuel Tan
# Date: 10/10/2024

# Part A. Read in Raw Dataset and additional covariates and merge if multiple sheets/files

library(tidyverse)
library(haven)
library(lubridate)

cgmData <- read.table("cgm.txt", sep = "|", header = TRUE)
screeningData <- read.table("DiabScreening_a.txt", sep = "|", header = TRUE, fill = TRUE, fileEncoding = "UTF-16LE", stringsAsFactors = FALSE, na.strings = "")

# Merge the CGM data and screening data based on the "PtID" column
merged_data <- cgmData %>%
  left_join(screeningData, by = "PtID")

# Part B. Processing for Validation Dataset Feature and Quality

# Create a final dataset with new variables and selected columns
final_data <- merged_data %>%
  mutate(
    id = PtID + 5000,              # Create a new 'id' by adding 5000 to the 'PtID' column
    time = dmy_hms(DataDtTm),      # Convert the 'DataDtTm' column (date-time string) to a proper date-time format using 'lubridate'
    gl = as.numeric(CGM),          # Convert the 'CGM' column to a numeric data type 
    age = AgeAtEnrollment,         # Rename 'AgeAtEnrollment' to 'age'
    sex = Gender,                  # Rename 'Gender' to 'sex' 
    insulinModality = 1,           # Assign a constant value of 1 (as using Insulin Pump) 
    type = 1,                      # Assign a constant value of 1 (as Type 1 Diabetic) 
    device = "Dexcom G6",          # Assign the CGM device used ("Dexcom G6")
    dataset = "o_mally2021"        # Label the dataset with the source or study name ('o_mally2021') 
   ) %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

# Save the processed dataset to a CSV file in the 'csv_data' folder
final_data %>% write_csv("csv_data/o_mally2021.csv")


