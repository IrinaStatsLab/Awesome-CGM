# This is the script for processing Shah 2019 data into the common format. 
# Author: Charlotte Xu
# Date: 9/30/24, edited by Neo Kok 10/8/24

# Load the necessary library
library(dplyr)
library(tidyverse)
library(haven)
library(readr)

T1DE_CGM <- read_csv("CGMND-af920dee-2d6e-4436-bc89-7a7b51239837/NonDiabDeviceCGM.csv") # CGM_reading: PtID = T1DE$id, DeviceTm = T1DE$time, Value = T1DE$gl
T1DE_screening <- read_csv("CGMND-af920dee-2d6e-4436-bc89-7a7b51239837/NonDiabScreening.csv") # PtID = T1DE$id,  Gender = NDChild$sex
T1DE_Patient<- read_csv("CGMND-af920dee-2d6e-4436-bc89-7a7b51239837/NonDiabPtRoster.csv") #AgeAsOfEnrollDt = T1DE$age

# Merging acquired variable information
T1DE <- T1DE_CGM %>%
  left_join(T1DE_screening, by = "PtID") %>%  # PtID corresponds to "id"
  left_join(T1DE_Patient, by = "PtID")        # joining by PtID and id

# To blind the exact study start date, we mask the outputs by only using the n-th dates. 
# For this purpose, we generate pseudo start dates, starting from January 1, 2017.
pseudo_start_date <- as.Date("2017-01-01")

# Prepare the T1DE_combined dataset by generating pseudo start dates and transforming variables
T1DE_combined <- T1DE %>%
  # Calculate the actual device date by adding the days from enrollment to the pseudo start date
  mutate(DeviceDate = pseudo_start_date + days(DeviceDtDaysFromEnroll),
         # Combine DeviceDate and DeviceTm to create a DateTime column
         DateTime = as.POSIXct(paste(DeviceDate, DeviceTm), format = "%Y-%m-%d %H:%M:%S")) %>%
  select(id = PtID, time = DateTime, gl = Value, sex = Gender, age = AgeAsOfEnrollDt) %>%
  mutate(time = as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S"),
         dataset = "shah2019",
         type = 0,  # Set "type" to indicate non-diabetic
         insulinModality = NA,  # Set insulin modality to NA as we don't have this information
         device = "Dexcom G6") %>% # Set the device type to "Dexcom G6" for all subjects according to study design
  group_by(id) %>%
  mutate(pseudoID = cur_group_id() + 9000) %>% # Generate unique pseudo IDs for each participant by adding 9000 to group IDs
  ungroup() %>%
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset)

write.csv(T1DE_combined, file = "csv_data/shah2019.csv", row.names = FALSE)
