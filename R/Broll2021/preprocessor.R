# This script processes the "Broll2021" dataset into a common format.
# Author: Charlotte Xu
# Date: 10/2/24, edited 10/8/24 by Neo Kok

# Part A. Read in Raw Dataset and additional covariates and merge if multiple sheets/files

library(dplyr)
#df2 <- read.csv("Broll2021.csv")
# Data can be accessed using CRAN iglu package
df2 <- iglu::example_data_5_subject

# Part B. Processing for Validation Dataset Feature and Quality

# Transform the 'id' column
df2 <- df2 %>%
  # Convert the 'id' column by removing "Subject " and converting it to numeric, then adding 7000 to differentiate IDs
  mutate(id = as.numeric(sub("Subject ", "", id)) + 7000,
         # Add additional variables: specify the dataset, subject type, device used, and placeholder values
         dataset = "broll2021",  # Set dataset label
         type = 2,  # Set subject type to 2 (e.g., for T2D)
         device = "Dexcom G4",  # Specify the device used for glucose measurement
         sex = NA,  # Placeholder for sex (unknown or missing)
         age = NA,  # Placeholder for age (unknown or missing)
         insulinModality = NA)  # Placeholder for insulin modality (unknown or missing)

# Reorder columns and select only the relevant ones for the output
df2 <- df2 %>%
  select(id, time, gl, age, sex, insulinModality, type, device, dataset)

# Save the processed dataset to a CSV file in the 'csv_data' folder
write.csv(df2, file = "csv_data/broll2021.csv", row.names = FALSE)
