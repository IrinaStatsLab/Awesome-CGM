# This script processes the "Breton2021" dataset into a common format.
# Author: Charlotte Xu
# Date: 9/22/24

library(tidyverse)
library(haven)

# Read in data files
CGM_reading <- read.table("DexcomClarityMeter.txt", sep = "|", header = TRUE)
Screening <- read.table("DiabScreening.txt", sep = "|", header = TRUE)
Patient <- read.table("PtRoster.txt", sep = "|", header = TRUE)

# Select and mutate data to match the required format
Output <- CGM_reading %>% 
  select(id = PtID, time = DataDtTm, gl = Meter) %>%
  mutate(time = as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S"),
         dataset = "breton2021", device = "Dexcom G6",
         insulinModality = factor(1), type = 1) %>%
  group_by(id) %>%
  mutate(weeks_span = as.numeric(difftime(max(time), min(time), units = "weeks"))) %>%
  ungroup()

# Join with Screening and Patient data for sex and age
Output <- Output %>%
  left_join(Screening %>% select(id = PtID, sex = Gender), by = "id") %>%
  left_join(Patient %>% select(id = PtID, age = AgeAtEnrollment), by = "id") %>%
  mutate(age = as.numeric(age), id = id + 4000)

# Final output and save to CSV
Output <- Output %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

write.csv(Output, file = "csv_data/Breton2021.csv", row.names = FALSE)
