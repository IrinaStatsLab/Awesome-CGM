# script for processing Weinstock(2016)
# Author: Sangaman Senthil
# Date: February 5th, 2020, edited June 14th, by Elizabeth Chun

import pandas as pd

# This study downloads as a zipped folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset = 'Weinstock2016'
# If you have a different naming method, you will need to adjust this, eg.
# dataset = "insert_your_name"

# using the original file path exactly as downloaded
filepath = dataset + '/BSevereHypoDataset/Data Tables/BDataCGM.txt'

# reading csv from raw data
df = pd.read_csv(filepath, sep = "|", low_memory=False)
# alternatively, if file paths have been changed simply read in the CGM data file

# drop unwanted columns
df = df.drop(columns=['RecID', 'BCGMDeviceType', 'BFileType', 'CalBG'])
# rename columns
df = df.rename(columns={'PtID': 'id', 'DeviceDaysFromEnroll': 'time', 'DeviceTm': 'tm', 'Glucose': 'gl'})

# meeting format standards
function = lambda x: "1990-01-" + str(x+1)
# applying function to each element in Days Been column
df['time'] = df['time'].apply(function)

# combining the time and date column into one
df['time'] = df['time'] + " " + df['tm']
# dropping unwanted time column since date and time have been combine
df = df.drop(columns=['tm'])


# export final data set as csv (index = False drops the index column when exporting to csv)
newfile = dataset+'/'+dataset+'_processed.csv'
df.to_csv(newfile, index=False)

