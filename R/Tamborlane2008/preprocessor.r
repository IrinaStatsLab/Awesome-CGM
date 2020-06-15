# This is the script for processing the Tabmborlane2008 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 13th, 2020 by Elizabeth Chun

# This study downloads as a folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Tamborlane2008"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)


# This is the relative path to the CGM files with original names
file.path <- paste("RT-CGM Randomized Clinical Trial", "DataTables/", sep = "/")
# Depending on how you have unzipped the file, you may need to edit this slightly

# This will list only the files of CGM data
files <- dir(file.path, pattern = "RTCGM")

# One can then loop through the files
nfiles = length(files)

for (i in 1:2){
  filename = files[i] # Get the file name
  
  # Read each csv in
  curr = read.csv(paste(file.path, filename, sep = ""))
  
  # We don't need this column, so we'll delete it
  curr$"RecID" = NULL 
  
  # Rename columns to standard column names
  colnames(curr) = c("id","time","gl") 
  
  # Convert datetime to standardized format
  curr$"time" = strptime((curr$"time"), format = "%Y-%m-%d %H:%M:%S", tz="")
  
  #Ensure glucose values are recorded as numeric
  curr$gl = as.numeric(curr$gl)
  
  # Save the cleaned data to the created dataset folder
  # The cleaned file will be named "dataset"_processed.csv
  write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
              row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
              append = T, sep = ",")
}
