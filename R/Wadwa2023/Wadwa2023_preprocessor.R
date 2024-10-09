# This is the script for processing Wadwa2023 data into the common format. 
# Author: Samuel Tan, Neo Kok
# Date: 10/7/2024

library(tidyverse)
library(lubridate)


cgmData <- read.table("PEDAPDexcomClarityCGM.txt", sep = "|", header = TRUE)

demoData <- read.table("PEDAPDiabScreening.txt", sep = "|", header = TRUE)

ageData <- read.table("PtRoster.txt", sep = "|", header = TRUE)

merged_data <- cgmData %>%
  left_join(demoData, by = "PtID")

merged_data <- merged_data %>%
  left_join(ageData, by = "PtID")

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
    id = PtID + 2000,
    time = mdy_hms(DeviceDtTm),
    gl = as.numeric(CGM),
    age = AgeAsofEnrollDt,
    sex = Sex,
    insulinModality = 1,
    type = 1,
    device = "Dexcom G6",
    dataset = "wadwa2023"
  ) %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

write_csv(final_data, "csv_data/wadwa2023.csv")