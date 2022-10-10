# This is the script for processing children200 CGMS data into the common format. 
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

# This is the relative path to the Medtronic CGMS CGM file with original names
file.path <- "DirecNetOupatientRandomizedClinicalTrial/DataTables/tblCDataCGMS.csv"
# Alternatively, if the file structure has been changed, simply place the CGM.txt file into the created folder
# Then run the file path as follows:
# file.path <- "tblCDataCGMS.csv"

# Read the raw data in 
curr = read.csv(file.path, header = TRUE, stringsAsFactors = FALSE)
old = curr

# Figure out automatically which values have AM/PM indicator
indexAM = grep("AM", curr$ReadingTm)
indexPM = grep("PM", curr$ReadingTm)
timeInfo = paste(as.Date(curr$ReadingDt), curr$ReadingTm)

# problem - original table codes some times as AM/PM; and some times as 24 hours
time = rep(as.POSIXct(NA), length(timeInfo))
# part of the conversion doesn't work because of time zone,
# need to figure out which one is correct
# definitely not CST, EST seems to work
# by default - use AM/PM conversion first
tz = "EST"
time[indexAM] = as.POSIXct(timeInfo[indexAM], format = "%Y-%m-%d %I:%M %p", tz = "EST")
time[indexPM] = as.POSIXct(timeInfo[indexPM], format = "%Y-%m-%d %I:%M %p", tz = "EST")
# Then substitute anything that is NA by 24  hour conversion
newtime = as.POSIXct(timeInfo, format = "%Y-%m-%d %H:%M", tz = "EST")
time[is.na(time)] = newtime[is.na(time)]


# combine date and time into standard format
curr$time = time



# reorder and select only id, time, gl columns
curr = curr[, c(2,7,6)]

# Renaming the columns with the standard format names
colnames(curr) = c("id","time","gl")

# Convert glucose to numeric
curr$gl = as.numeric(curr$gl)

# Save the cleaned data to the created dataset folder
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "CGMS_processed.csv", sep = ""), row.names = F, 
            col.names = !file.exists(paste(dataset, "CGMS_processed.csv", sep = "")), 
            sep = ",")
