# This is the script for processing Dubosson2018 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 13th, 2020 by Elizabeth Chun

# This study downloads as a folder containing a diabetes subset and a healthy subset
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Dubosson2018"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# This is the relative path to the CGM file folders with original names
file.path <- paste("D1NAMO", "diabetes_subset/", sep = "/")

# Here we list out the files
files = dir(file.path) # this should list all files within directory above

# If all the files are within that directory, one can just loop through the files to get
nfiles = length(files)
for (i in 1:nfiles){
  # Because of this dataset's unique file structure, the filename and path had to be altered. 
  # This gets the "glucose.csv" datafile from each individual folder
  filename = paste(file.path, files[i], "/glucose.csv", sep = "")
  
  # Read each csv in
  curr = read.csv(filename)
  
  # Standardize date and time 
  curr$"time" = as.POSIXct(paste(curr$date, curr$time), format="%Y-%m-%d %H:%M:%S")
  
  # No "id" field exists by default in the data. 
  # Assuming the script accesses the subjects in order this will assign them ids
  curr$"id" = files[i]
  
  # Reorder and keep only the columns we want
  curr = curr[c(6,2,3)]
  
  # Rename the columns to follow format
  colnames(curr) = c("id","time","gl")
  
  # Convert glucose readings from mmol/l to mg/dl
  curr$gl = 18*(as.numeric(curr$gl))
  
  # Write to the csv in the standard format
  # Appending so the program only has to load one csv in at a time
  write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
              row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
              append = T, sep = ",")
}
