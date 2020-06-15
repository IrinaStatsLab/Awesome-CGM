# This is the script for processing Hall2018 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 14th, 2020 by Elizabeth Chun

# For this study, there is only one raw CGM data file (S1 Data)

# First, you must download the data and save it in a folder for this dataset.
# Here we have named the dataset by first author last name and date of the original paper
dataset <- "Hall2018"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# Then we set the working directory to this folder
setwd(dataset)

# Here we list the filename for the data exactly as downloaded. 
filename <- "journal.pbio.2005143.s010" 
# If for some reason the filename has changed, simply set filename <- "newname"

# Read the raw data in
curr = read.table(filename, header = TRUE, sep = "\t")

# Reorder and trim the columns to follow format
curr = curr[c(3,1,2)] 

# Renaming the columns the standard format names
colnames(curr) = c("id","time","gl")

# Ensure glucose values are recorded as numeric
curr$gl = as.numeric(as.character(curr$gl))

# Reformat the time to standard
curr$"time" = as.POSIXct(curr$time, format="%Y-%m-%d %H:%M:%S") 

# Save the cleaned data to same folder that the raw data file is in
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
            row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
            append = T, sep = ",")
