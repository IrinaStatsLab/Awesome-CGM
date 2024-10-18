# This is the script for processing Hall2018 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 14th, 2020 by Elizabeth Chun, edited October 2nd, 2024 by Charlotte Xu, edited October 7th by Neo Kok

# Load the necessary library for data manipulation
library(dplyr)
# Here we list the filename for the data exactly as downloaded. 
filename <- "pbio.2005143.s010" 
# If for some reason the filename has changed, simply set filename <- "newname"

# Read the raw data in
df = read.table(filename, header = TRUE, sep = "\t")

# Reorder and trim the columns to follow format
df = df[c(3,1,2)] 

# Renaming the columns the standard format names
colnames(df) = c("id","time","gl")

# Ensure glucose values are recorded as numeric
df$gl = as.numeric(as.character(df$gl))

# Reformat the time to standard
df$"time" = as.POSIXct(df$time, format="%Y-%m-%d %H:%M:%S") 

# New Processing steps - updated October 2024

# Part A. Read in Raw Dataset and additional covariates and merge if multiple sheets/files
# Provided by original coding part

# Part B. Processing for Validation Dataset Feature and Quality

# Use example_data_hall from iglu package to identify diabetic type for profiles
df_combined = left_join(df, (iglu::example_data_hall %>% select(id, diagnosis) %>% distinct()), by = c('id')) %>%
  mutate(diagnosis = case_when(is.na(diagnosis) ~ 0, diagnosis == "diabetic" ~ 2, diagnosis == "pre-diabetic" ~ 0.5))

df_final <- df_combined %>%
  # Convert the 'id' column into numeric by assigning unique sequential numbers to each unique 'id'
  # Add 8000 to each 'id' to ensure distinctiveness across datasets when combined
  mutate(id = as.numeric(factor(id, levels = unique(id))) + 8000,
         # Specify the dataset name for future reference
         dataset = "hall2018",
         # Set 'type' to 0 (this could represent a particular subject type, such as non-diabetic)
         type = diagnosis,
         # Specify the CGM device used in the study ("Dexcom G4" in this case)
         device = "Dexcom G4",
         # Assign 'sex' as NA (assuming sex information is missing or unavailable)
         sex = NA,
         # Keep 'age' from the original data (it assumes 'Age' exists in the dataset)
         age = NA,
         # Assign 'insulinModality' as NA (this could be added later if information is available)
         insulinModality = NA) %>%
  # Select and reorder the columns to match the desired format
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

# Write the processed data into a CSV file in the 'csv_data' folder
# The file will be named "Hall2018.csv", and row names will not be included
write.csv(df_final, file = "csv_data/hall2018.csv", row.names = FALSE)
