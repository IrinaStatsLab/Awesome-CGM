# This is the script for processing children200 GWB data into the common format. 
# Author: Elizabeth Chun
# Date: September 23rd, 2020

# This study downloads as a folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Chase2005"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# This is the relative path to the Cygnus Glucowatch biographer CGM file with original names
file.path <- "DirecNetOupatientRandomizedClinicalTrial/DataTables/tblCDataGWB.csv"
# Alternatively, if the file structure has been changed, simply place the CGM.txt file into the created folder
# Then run the file path as follows:
# file.path <- "tblCDataCGMS.csv"

# Read the raw data in 
curr = read.csv(file.path, header = TRUE, stringsAsFactors = FALSE)

# combine date and time into standard format
curr$time = as.POSIXct(paste(as.Date(curr$ReadingDt), curr$ReadingTm),
                       format = "%Y-%m-%d %H:%M")

# reorder and select only id, time, gl columns
curr = curr[, c(2,7,6)]

# Renaming the columns with the standard format names
colnames(curr) = c("id","time","gl")

# Convert glucose to numeric
curr$gl = as.numeric(curr$gl)

# Save the cleaned data to the created dataset folder
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "GWB_processed.csv", sep = ""), row.names = F, 
            col.names = !file.exists(paste(dataset, "GWB_processed.csv", sep = "")), 
            sep = ",")
