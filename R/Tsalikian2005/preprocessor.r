# This is the script for processing Tsalikian2005 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020; edited June 13th, 2020 by Elizabeth Chun

# This study downloads as a folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Tsalikian2005"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# This is the relative path to the CGM file with original names
file.path <- paste("DirecNetInPtExercise", "DataTables/", sep = "/")
# Depending on how you have unzipped the file, you may need to edit this slightly

# This is the relative path to the CGM file with original names
# Depending on how you have unzipped the file, you may need to edit this slightly
file.path <- "DirecNetInPtExercise/DataTables/tblDDataCGMS.csv"
# Alternatively, if the file structure has been changed, simply place the tblDDataCGMS.csv file into the created folder
# Then run the file path as follows:
# file.path <- "tblDDataCGMS.csv"

# Read the table in
curr = read.csv(file.path)

# Standardize date and time
# Convert the 12-hour time to 24
curr$ReadingTm = strftime(strptime(curr$ReadingTm, "%I:%M %p"), format = "%H:%M:%S", tz="") 
# Remove the time information from the date
curr$ReadingDt = strftime(curr$ReadingDt, format = "%Y-%m-%d", tz="") 
# Combine the two into a standard formatted time object
curr$time = as.POSIXct(paste(curr$ReadingDt, curr$ReadingTm), format="%Y-%m-%d %H:%M:%S") #combine the date and time into one column

# Reorder and keep only the columns we want
curr = curr[c(2,7,6)]

# Renaming the columns the standard format names
colnames(curr) = c("id","time","gl")

#Ensure glucose values are recorded as numeric
curr$gl = as.numeric(curr$gl)

# Save the cleaned data to the created dataset folder
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
            row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
            append = T, sep = ",")
