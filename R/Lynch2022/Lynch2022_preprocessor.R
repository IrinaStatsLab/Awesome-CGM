# This is the script for processing Lynch2019 data into the common format.
# Author: Neo Kok
# Date: 10/24/2024

library(tidyverse)
library(haven)

# The dataset is downloaded as a folder containing multiple data tables and forms.
# First, download the entire dataset. Do not rename the downloaded folder.

# Data folder is named "IOBP2 RCT Public Dataset" - rename if downloaded file name changes

# Read in data
data <- read_sas("IOBP2 RCT Public Dataset/Data Tables in SAS/iobp2devicecgm.sas7bdat")
demo <- read_sas("IOBP2 RCT Public Dataset/Data Tables in SAS/iobp2diabscreening.sas7bdat")
age <- read_sas("IOBP2 RCT Public Dataset/Data Tables in SAS/iobp2ptroster.sas7bdat")

# Select only necessary variables
data = data %>% select(PtID, DeviceDtTm, Value)
demo = demo %>% select(PtID, InsModPump, Sex)
age = age %>% select(PtID, AgeAsofEnrollDt)

# Merge variables on id
data = left_join(data, demo, by = "PtID")
data = left_join(data, age, by = "PtID")

# Rename columns
df_final = data %>%
  select(id = PtID, time = DeviceDtTm, gl = Value, age = AgeAsofEnrollDt, sex = Sex, insulinModality = InsModPump) %>%
  mutate(# Ensure correct time format
         time = as.POSIXct(time, format = "%m/%d/%Y %I:%M:%S %p"),
         # Set diabetes type to type 1 for T1d
         type = as.numeric(1),
         # Set device type to Dexcom G6 for all subjects
         device = "Dexcom G6",
         # Set dataset type to be Lynch2022 for future reference when combined
         dataset = "lynch2022",
         # Set insulin modality to 0 for insulin injections, 1 for insulin pump
         insulinModality = as.numeric(ifelse(is.na(insulinModality), 0, 1))) %>%
  group_by(id) %>%
  mutate(pseudoID = cur_group_id() + 1000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset) # Reorder columns and select only the relevant ones for the output

# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

write.csv(df_final, "csv_data/lynch2022.csv", row.names = FALSE)
