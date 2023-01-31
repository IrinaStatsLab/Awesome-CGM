# This is the script for processing Marling2020 data into the common format. 
# Author: Elizabeth Chun
# Date: 1/30/23

library(tidyverse)
library(hms)
library(xml2)
library(XML)

# This study downloads containing 2018 and 2020 folders
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Marling2020"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# Here we list out the files within each folder
files = list.files(pattern = "xml", recursive = TRUE) 

# Now we loop through and process each file
nfiles = length(files)
for (i in 1:nfiles){
  
  # track progress
  print(files[i])
  print(str_split_1(str_split_1(files[i], "/")[3], "-")[1])
  
  # Read each file in
  curr = as_list(read_xml(files[i]))
  
  # extract glucose and time from list
  sub_data <- curr$patient$glucose_level
  
  out <- tibble::tibble(
    # id from filename
    id = str_split_1(str_split_1(files[i], "/")[3], "-")[1],
    # create empty vectors to be filled 
    gl = rep(0, length(sub_data)),
    time = NA_character_
  )
  
  # extract time and glucose from attributes
  for (j in 1:length(sub_data)) {
    out$time[j] <- attr(sub_data[[j]], "ts")
    out$gl[j] <- attr(sub_data[[j]], "value")
  }
  
  # ensure standard formatting for time and gl data types
  out <- out %>%
    mutate(
      time = as.POSIXct(time, format = "%d-%m-%Y %H:%M:%S"),
      gl = as.numeric(gl)
    ) %>%
    select(id, time, gl)
  
  # Write to the csv in the standard format
  # Appending so the program only has to load one csv in at a time
  write.table(out, file = paste(dataset, "_processed.csv", sep = ""), 
              row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
              append = T, sep = ",")
}
