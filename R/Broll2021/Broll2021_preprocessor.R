# This script processes the "Broll2021" dataset into a common format.
# Author: Charlotte Xu
# Date: 10/2/24, edited 10/24/24 by Neo Kok

# Load the necessary library
library(tidyverse)
library(readr)

# Read your data - assuming it's a CSV file for example
#df2 <- read_csv("Broll2021.csv")

# Alternatively, data can be accessed using CRAN iglu package
df2 <- iglu::example_data_5_subject

# Transform the 'id' column
df2 <- df2 %>%
  # Convert the 'id' column by removing "Subject " and converting it to numeric
  mutate(id = as.numeric(sub("Subject ", "", id)),
         # Add additional variables: specify the dataset, subject type, device used, and placeholder values
         dataset = "broll2021",  # Set dataset label
         type = as.numeric(2),  # Set subject type to 2 (e.g., for T2D)
         device = "Dexcom G4",  # Specify the device used for glucose measurement
         sex = NA_character_,  # Placeholder for sex (unknown or missing)
         age = NA_integer_,  # Placeholder for age (unknown or missing)
         insulinModality = NA_integer_) %>% # Placeholder for insulin modality (unknown or missing)
  group_by(id) %>%
  mutate(pseudoID = cur_group_id() + 7000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset) # Reorder columns and select only the relevant ones for the output

# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

# Save the processed dataset to a CSV file in the 'csv_data' folder
write.csv(df2, file = "csv_data/broll2021.csv", row.names = FALSE)
