# This is the script for processing Hall2018 data into the common format.
# Author: David Buchanan
# Date: January 31st, 2020, edited June 14th, 2020 by Elizabeth Chun, edited October 2nd, 2024 by Charlotte Xu, edited October 24th by Neo Kok

# Load the necessary library for data manipulation
library(tidyverse)

# First, download the entire dataset. Do not rename the downloaded file
# Data folder is named "pbio.2005143.s010" # S1 Data from the study

filename <- "pbio.2005143.s010"
# If for some reason the filename has changed, simply set filename <- "newname"


# Load additional covariates from SQLite database
dbfile <- 'pbio.2005143.s014.db' # S5 Data from the study

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

con <- DBI::dbConnect(RSQLite::SQLite(), dbfile)

# Query the 'clinical' table and load additional covariate data
raw_covs <- DBI::dbGetQuery(con, "SELECT * FROM clinical")

# Close the database connection
DBI::dbDisconnect(con)

# Merge additional covariates if they exist
if("Age" %in% colnames(raw_covs)) {
  df <- df %>%
    left_join(raw_covs %>% select(id = userID, Age, diagnosis), by = "id")
}

# Transform the 'id' column and add new variables
df_final <- df_combined %>%
  # Convert the 'id' column into numeric by assigning unique sequential numbers to each unique 'id'
  mutate(id = as.numeric(factor(id, levels = unique(id))),
         # Specify the dataset name for future reference
         dataset = "hall2018",
         # Set 'type' to 0 (this could represent a particular subject type, such as non-diabetic)
         type = diagnosis,
         # Specify the CGM device used in the study ("Dexcom G4" in this case)
         device = "Dexcom G4",
         # Assign 'sex' as NA (assuming sex information is missing or unavailable)
         sex = NA,
         # Keep 'age' from the original data (it assumes 'Age' exists in the dataset)
         age = Age,
         # Assign 'insulinModality' as NA (this could be added later if information is available)
         insulinModality = NA) %>%  group_by(id) %>%
  mutate(pseudoID = cur_group_id() + 8000) %>%
  # Ungroup the dataset after creating pseudoID
  ungroup() %>%
  select(id = pseudoID, time, gl, age, sex, insulinModality, type, device, dataset) # Reorder columns and select only the relevant ones for the output


# Check if 'csv_data' folder exists, create if not
if (!dir.exists("csv_data")) {
  dir.create("csv_data")
}

# Write the processed data into a CSV file in the 'csv_data' folder
write.csv(df_final, file = "csv_data/hall2018.csv", row.names = FALSE)
