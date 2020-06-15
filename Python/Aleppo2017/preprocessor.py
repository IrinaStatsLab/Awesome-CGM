# This is the script for processing Aleppo2017 data into the common format. 
# Author: David Buchanan
# Date: Febuary 4th, 2020, edited June 14th, by Elizabeth Chun

import datetime
# For working with dates and times

# This study downloads as a zipped folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset = 'Aleppo2017'
# If you have a different naming method, you will need to adjust this, eg.
# dataset = "insert_your_name"

# using the original file path exactly as downloaded
file = dataset + '/Protocol_H/Data Tables/HDeviceCGM.txt'
# alternatively, if file paths have been changed simply set file = the CGM file

basedate = datetime.date(2015, 5, 22) 
#The data has days as days since study start
#Establishing a base date to work from

newfile = dataset+'_processed.csv'
with open(file) as file: #Open the data file
	with open(newfile, "w") as export: #Open the file for the processed data
		isheader = True
		#Flag to mark when the header is being read

		for line in file:
			#Work line by line within the file

			if isheader:
				#Executes on the first iteration i.e. when reading the header
				
				isheader = False
				#All future lines will not be header lines

				export.write("\"id\",\"time\",\"gl\"\n")
				#Write the export file's header

				continue
				#Move to the next iteration without executing the rest of the code

			line = line.split('|')
			#Split the data by delimiting character so it can be worked with

			day = datetime.timedelta(days = int(line[4]))
			#obtain the "number of days since enrolled in study" field in a way useful for doing date arithmetic 

			thisdate = basedate + day
			#Create the date that will get written to the file

			thistime = datetime.datetime.strptime(line[5], "%H:%M:%S").time()
			#Read the reading time as a time object

			thedatetime = datetime.datetime.combine(thisdate,thistime)
			#Combine the read date and time objects

			val = line[9]

			export.write(str(line[2]) + "," + str(thedatetime) + "," + line[9][0:3] + "\n")
			#Write all the data to the export file in the working directory
            
# this is a large dataset, so do not be surprised is the runtime is somewhat long