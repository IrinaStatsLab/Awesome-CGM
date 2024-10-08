library(tidyverse)
library(haven)
library(lubridate)


cgmData <- read.table("cgm.txt", sep = "|", header = TRUE)
screeningData <- read.table("DiabScreening_a.txt", sep = "|", header = TRUE, fill = TRUE, fileEncoding = "UTF-16LE", stringsAsFactors = FALSE, na.strings = "")

merged_data <- cgmData %>%
  left_join(screeningData, by = "PtID")

final_data <- merged_data %>%
  mutate(
    id = PtID + 5000,
    time = dmy_hms(DataDtTm),
    gl = as.numeric(CGM),
    age = AgeAtEnrollment,
    sex = Gender,
    insulinModality = 1,
    type = 1,
    device = "Dexcom G6",
    dataset = "o_mally2021"
  ) %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

final_data %>% write_csv("csv_data/o_mally2021.csv")


  # Summary statistics
# individual_stats <- final_data %>%
#   group_by(id) %>%
#   summarise(
#     Age = first(age),  # Assuming age is constant for each individual
#     Sex = first(sex),  # Assuming sex is constant for each individual
#     InsulinModality = first(insulinModality),  # Assuming insulin modality is constant for each individual
#     Device = first(device),  # Assuming device is constant for each individual
#     Duration_Weeks = as.numeric(difftime(max(time), min(time), units = "weeks")), # Duration in weeks for each individual
#     gl_Mean = mean(gl, na.rm = TRUE), # Mean glycemic level
#     gl_SD = sd(gl, na.rm = TRUE) # SD of glycemic level
#   )
# 
# # Calculate summary statistics for the overall dataset
# summary_stats <- individual_stats %>%
#   summarise(
#     N = n(),
#     Age_Mean = mean(Age, na.rm = TRUE),
#     Age_SD = sd(Age, na.rm = TRUE),
#     Age_Min = min(Age, na.rm = TRUE),
#     Age_Max = max(Age, na.rm = TRUE),
#     Duration_Mean = mean(Duration_Weeks, na.rm = TRUE),
#     Duration_SD = sd(Duration_Weeks, na.rm = TRUE),
#     Duration_Min = min(Duration_Weeks, na.rm = TRUE),
#     Duration_Max = max(Duration_Weeks, na.rm = TRUE),
#     gl_Mean = mean(gl_Mean, na.rm = TRUE),
#     gl_SD = mean(gl_SD, na.rm = TRUE),
#     gl_Min = min(gl_Mean, na.rm = TRUE),
#     gl_Max = max(gl_Mean, na.rm = TRUE),
#     Male = sum(Sex == "M") / N * 100,
#     Female = sum(Sex == "F") / N * 100,
#     Pump = sum(InsulinModality == 1) / N * 100,  # Assuming 1 = Pump, adjust if necessary
#     Injection = sum(InsulinModality == 0) / N * 100,  # Assuming 0 = Injection, adjust if necessary
#     Dexcom = sum(Device == "Dexcom G6") / N * 100,
#     Medtronic = sum(Device == "Medtronic") / N * 100
#   )
# 
# gl_stats <- final_data %>%
#   summarise(
#     gl_Mean = mean(gl, na.rm = TRUE),
#     gl_SD = sd(gl, na.rm = TRUE),
#     gl_Min = min(gl, na.rm = TRUE),
#     gl_Max = max(gl, na.rm = TRUE)
#   )
