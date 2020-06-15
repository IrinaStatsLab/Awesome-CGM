# This is the script for processing Anderson2016 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 13th, 2020 by Elizabeth Chun

# This study downloads as a folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Anderson2016"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# This is the relative path to the CGM file with original names
file.path <- "CTR3_Public_Dataset/Data Tables/CGM.txt"
# Alternatively, if the file structure has been changed, simply place the CGM.txt file into the created folder
# Then run the file path as follows:
# file.path <- "CGM.txt"

# Read the raw data in 
curr = read.table(file.path, header = TRUE, sep = "|")

# Reorder and keep only the columns we want
# See below for an important note on how which time to keep was chosen
curr = curr[c(1,5,4)]

# Renaming the columns with the standard format names
colnames(curr) = c("id","time","gl")

# Ensure glucose values are recorded as numeric
curr$gl = as.numeric(curr$gl)

# Standardize date and time
curr$"time" = as.POSIXct(curr$"time", format="%Y-%m-%d %H:%M:%S")

# Save the cleaned data to the created dataset folder
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
            row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
            append = T, sep = ",")

#DisplayTime is used because it is user-configurable, making it likely the time the user was living on.
#"The time displayed to the user on the receiver or phone. This time is assumed to be user-configurable."
# from https://developer.dexcom.com/glossary
