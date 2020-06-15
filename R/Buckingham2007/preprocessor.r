# This is the script for processing Buckingham2007 data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020, edited June 13th, 2020 by Elizabeth Chun

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

# This is the relative path to the CGM files with original names
original <- "DirecNetNavigatorPilotStudy"
file.path <- paste(original, original, "OneMinuteData/", sep = "/")

# This will list only the csv files of CGM data
files <- dir(file.path, pattern = ".csv")

# One can then loop through the files 
nfiles = length(files)

for (i in 1:nfiles){
  filename = files[i] # Get the file name
  
  # Read each csv in
  curr = read.csv(paste(file.path, filename, sep = ""))
  
  # Getting the dates and times from the csv
  dates = as.Date(curr$Date,"%m/%d/%Y")
  times = strftime(strptime(curr$Time, "%I:%M %p"), format = "%H:%M:%S", tz="")
  
  # Creating the standard format "time" column
  curr$"time" = as.POSIXct(paste(dates, times), format="%Y-%m-%d %H:%M:%S")
  
  # Reordering the dataframe to have only the columns we want in the order we want
  curr = curr[c(1,22,5)]
  
  # Renaming the columns the standard format names
  colnames(curr) = c("id","time","gl")
  
  #Ensure glucose values are recorded as numeric
  curr$gl = as.numeric(curr$gl)
  
  # This dataset has some NA values for glucose readings, 
  # If you would like to filter them out, simply uncomment this code:
  # curr = na.omit(curr)
  
  # Write to the csv in the standard format
  # Appending so the program only has to load one csv in at a time
  write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
              row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
              append = T, sep = ",")
}
