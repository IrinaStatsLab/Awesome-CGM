# This is the script for processing Colas2019 data into the common format. 
# Author: Elizabeth Chun
# Date: 1/30/23, edited 10/7/24 by Neo Kok

library(tidyverse)
library(hms)

# This study downloads with a csv file for each subject
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- "Colas2019"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# We will set the working directory here in the created folder
setwd(dataset)

# Here we list out the csv files
files = list.files(pattern = "csv") 

# next we loop through each file
nfiles = length(files)
for (i in 1:nfiles){
  
  # track progress
  print(files[i])
  print(str_split_1(str_split_1(files[i], " +")[2], "\\.")[1])
  
  # Read each csv in
  curr = read.csv(files[i])
  curr = curr %>%
    mutate(
      # extract id from csv filename
      id = str_split_1(str_split_1(files[i], " +")[2], "\\.")[1]
    ) %>%
    select(id, time = hora, gl = glucemia) %>%
    # time is only listed in hms format, to process into datetime we do the following:
    # calculate the time differences between points, in case of an uneven grid
    # for points that cross midnight (i.e. timediff is negative), convert to positive
    # next a basedate will be chosen and the timediffs cumulatively summed
    mutate(
      time = as_hms(time),
      # time diffs in minutes
      timediffs = c(0, diff(time, units = "seconds")/60),
      timediffs_adj = dplyr::if_else(timediffs < 0, 24*60 + timediffs, timediffs)
    )
  
  # base date chosen as January 1st of the year data collection began
  base_date <- as.POSIXct("2012-01-01 00:00:00", format="%Y-%m-%d %H:%M:%S")
  cu_min <- lubridate::minutes(cumsum(as.integer(curr$timediffs_adj)))
  
  # format time as cumulative sum of time differences from basedate
  curr$time = base_date + cu_min
  
  curr <- curr %>%
    select(id, time, gl) %>%
    filter(!is.na(gl))
  
  # Write to the csv in the standard format
  # Appending so the program only has to load one csv in at a time
  write.table(curr, file = paste(dataset, "_processed.csv", sep = ""), 
              row.names=F, col.names = !file.exists(paste(dataset, "_processed.csv", sep = "")),
              append = T, sep = ",")
}


# Read in data
data <- read.csv("Colas2019_processed.csv")
demo <- read.table("clinical_data.txt", sep = "", header = TRUE) %>% select(age, sex = gender, T2DM)

# Add id based on column row
demo = rowid_to_column(demo, "id")

# Merge data
df_merged = left_join(data, demo, by = "id")


# Finalize data
df_final = df_merged %>% mutate(time = ifelse(nchar(time) == 10, paste0(time, " 00:00:00"), time), # adds hms to entries without it
                                time = as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S"), # Ensure correct time format
                               # Increase ids by 1000 to keep separate from other datasets
                               id = id + 3000,
                               # Set sex to M if 0 and F if 1
                               sex = ifelse(sex == 0, "M", "F"),
                               # Set insulin modality to NA as we don't have that information, set as numeric to keep consistent with other datasets
                               insulinModality = as.numeric(NA),
                               # Set type to 0 if not diabetic and 2 if T2d
                               type = ifelse(T2DM, 2, 0),
                               # Set device type to Medtronic iPro for all subjects
                               device = "Medtronic iPro",
                               # Set dataset type to be Lynch2022 for future reference when combined
                               dataset = "colas2019") %>% select (-T2DM)
  

write.csv(df_final, "../csv_data/colas2019.csv", row.names = FALSE)
