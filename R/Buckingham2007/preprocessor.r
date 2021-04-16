# This is the script for processing Buckingham CGMS data into the common format. 
# Author: Rucha Bhat, edited by Shaun Cass
# Date: April 16, 2021

library(tidyverse)
library(magrittr)

# This study downloads as a folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Buckingham2007"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# This is the relative path to the Medtronic CGMS CGM file with original names
file.path <- "DirecNetNavigatorPilotStudy/DataTables/tblFNavGlucose.csv"
# Alternatively, if the file structure has been changed, simply place the CGM.txt file into the created folder
# Then run the file path as follows:
# file.path <- "tblCDataCGMS.csv"

# Read the raw data in 
curr = read.csv(file.path, header = TRUE, stringsAsFactors = FALSE)

# combine date and time into standard format (POSIX1t format)
curr$time = strptime(paste(as.Date(curr$NavReadDt), curr$NavReadTm),
                     format = "%Y-%m-%d %H:%M:%S")

# reorder and select only id, time, gl columns
curr = curr[, c(2,6,5)]

# Renaming the columns with the standard format names
colnames(curr) = c("id","time","gl")

#Ensure glucose values are recorded as numeric
curr$gl = as.numeric(curr$gl)

# Change all values less than 32 mg/dL and above 450 mg/dL to NA
curr$gl[curr$gl <= 32] <- NA
curr$gl[curr$gl > 450] <- NA

# This dataset has some NA values for glucose readings, 
# If you would like to filter them out, simply uncomment this code:
# curr = na.omit(curr)

# The following function is used to remove regions of zero variability
# These regions likely arise from cgm sensor errors.

zero.remove = function(tab){
  tab %>%
    mutate(diff = gl - lag(gl)) %>% 
    filter(diff != 0, diff != lag(diff), diff != lag(diff, 2)) %>%
    select(-diff)
}

curr = curr %>% group_split(id) %>% map_dfr(zero.remove)

# Save the cleaned data to the created dataset folder
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), row.names = F, 
            col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")), 
            sep = ",")

# If instead you want to save the cleaned dataset as an .RData file uncomment:
# save(curr, file = paste(dataset, "_processed.RData", sep = ""))
