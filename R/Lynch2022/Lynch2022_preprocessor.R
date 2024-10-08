# This is the script for processing Lynch2019 data into the common format. 
# Author: Neo Kok
# Date: 10/7/2024

library(tidyverse)
library(haven)

# Read in data
data <- read_sas("iobp2devicecgm.sas7bdat")
demo <- read_sas("iobp2diabscreening.sas7bdat")
age <- read_sas("iobp2ptroster.sas7bdat")

surgery <- read_sas(".sas7bdat")

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
  # Increase ids by 1000 to keep separate from other datasets
  mutate(id = id + 1000,
         # Ensure correct time format
         time = as.POSIXct(time, format = "%m/%d/%Y %I:%M:%S %p"),
         # Set diabetes type to type 1 for T1d
         type = 1, 
         # Set device type to Dexcom G6 for all subjects
         device = "Dexcom G6",
         # Set dataset type to be Lynch2022 for future reference when combined
         dataset = "lynch2022",
         # Set insulin modality to 0 for insulin injections, 1 for insulin pump
         insulinModality = ifelse(is.na(insulinModality), 0, 1))

write.csv(df_final, "csv_data/lynch2022.csv", row.names = FALSE)
