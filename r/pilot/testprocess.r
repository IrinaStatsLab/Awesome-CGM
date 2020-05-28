# This is the script for processing the "Pilot" data into the common format. 
# Author: David Buchanan
# Date: January 31st, 2020


# Specifify the path to dataset for processing, e.g. 

dataset = "Pilot_Type1_30subjects" # Name of study

data.path = dataset # Directory where that study is located

setwd(data.path) # this makes this a current working directory
files = dir("RawData") # this should list all files within RawData directory of above

# If all the files are within that directory, one can just loop through the files to get
nfiles = length(files)

for (i in 1:nfiles){
  filename = files[i] # Get the file name

	# Read each csv in
	curr = read.csv(paste("RawData/",filename,sep = ""))


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

	# This dataset has some NA values for glucose readings, this filters them out
	curr = na.omit(curr)

	# Write to the csv in the standard format
	# Appending so the program only has to load one csv in at a time
	write.table(curr, file = paste("CleanData/", dataset, "_processed.csv", sep = ""), row.names=F, col.names = !file.exists(paste("CleanData/", dataset, "_processed.csv", sep = "")), append = T, sep = ",")
}
