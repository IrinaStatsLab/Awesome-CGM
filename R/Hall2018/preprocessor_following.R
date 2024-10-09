# This script processes the "hall2018" dataset into a common format.
# Author: Charlotte Xu
# Date: 10/2/24

# Load the necessary library for data manipulation
library(dplyr)

# Read your data from the "Hall2018.csv" file
# Assuming this is a CGM dataset with 'id', 'time', 'gl', 'age', and other columns
df <- read.csv("Pre-Processing/hall2018/Hall2018.csv")
# df <- read.csv("Hall2018.csv")

# Transform the 'id' column and add new variables
df <- df %>%
  # Convert the 'id' column into numeric by assigning unique sequential numbers to each unique 'id'
  # Add 8000 to each 'id' to ensure distinctiveness across datasets when combined
  mutate(id = as.numeric(factor(id, levels = unique(id))) + 8000,
         # Specify the dataset name for future reference
         dataset = "hall2018",
         # Set 'type' to 0 (this could represent a particular subject type, such as non-diabetic)
         type = 0,
         # Specify the CGM device used in the study ("Dexcom G4" in this case)
         device = "Dexcom G4",
         # Assign 'sex' as NA (assuming sex information is missing or unavailable)
         sex = NA,
         # Keep 'age' from the original data (it assumes 'Age' exists in the dataset)
         age = Age,
         # Assign 'insulinModality' as NA (this could be added later if information is available)
         insulinModality = NA) %>%
  # Select and reorder the columns to match the desired format
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

# Write the processed data into a CSV file in the 'csv_data' folder
# The file will be named "Hall2018.csv", and row names will not be included
write.csv(df, file = "csv_data/Hall2018.csv", row.names = FALSE)
