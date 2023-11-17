# This is the script for processing Hall2018 meals data
# Author: Elizabeth Chun
# Date: November 7th, 2023

if (!require('dplyr')) install.packages('dplyr')
library(dplyr)

# First, you must download the data and save it in a folder for this dataset.
# Here we have named the dataset by first author last name and date of the original paper
dataset <- "Hall2018"
# If you have a different naming method, you will need to adjust this, eg.
# dataset <- "insert_your_name"

# Then we set the working directory to this folder
setwd(dataset)

# Here we list the filename for the data exactly as downloaded.
filename <- "pbio.2005143.s015.tsv"
# If for some reason the filename has changed, simply set filename <- "newname"

# Read the raw data in
curr = read.table(filename, header = TRUE, sep = "\t")

# Reorder and trim the columns to follow format
curr = curr[c(2:4, 1)]

# Renaming the columns the standard format names
colnames(curr) = c("id","time","gl", "meal")

# Ensure glucose values are recorded as numeric
curr$gl = as.numeric(as.character(curr$gl))

# Reformat the time to standard
curr$"time" = as.POSIXct(curr$time, format="%Y-%m-%d %H:%M:%S", "")

curr = curr %>%
  dplyr::arrange(id, time)

# select mealtime as 30 minutes after first recording (see paper)
meals = curr %>%
  dplyr::group_by(id, meal) %>%
  dplyr::summarise(
    id = id[1],
    meal = meal[1],
    mealtime = min(time) + 30*60,
    .groups = 'drop'
  ) %>%
  dplyr::arrange(id, mealtime)


# Save the cleaned data to same folder that the raw data file is in
# The cleaned file will be named "dataset"_processed.csv
write.table(curr, file = paste(dataset, "_meals.csv", sep = ""),
            row.names=F, col.names = !file.exists(paste(dataset, "_meals.csv", sep = "")),
            append = T, sep = ",")


### get db file
library("RSQLite")

## connect to db
filename = '' # insert your path for db file
con <- dbConnect(drv=RSQLite::SQLite(),
                 dbname=filename)

## list all tables
tables <- dbListTables(con)
clinical = dbGetQuery(conn=con, statement=paste0("Select * FROM '", tables[[1]], "'"))

subset = clinical %>%
  dplyr::filter(diagnosis %in% c("diabetic", 'pre-diabetic')) %>%
  dplyr::select(id = userID, diagnosis = diagnosis)

example_data_hall = read.csv('Hall2018_processed.csv') %>%
  dplyr::right_join(subset, by = "id")

### to create a subset of meals and cgm data for example testing
id_intersect = intersect(unique(meals$id), unique(example_data_hall$id))
id_sub = subset %>%
  dplyr::filter(id %in% id_intersect) %>%
  dplyr::filter(diagnosis == 'diabetic')
example_meals_hall = meals %>%
  dplyr::filter(id %in% id_sub$id) %>%
  dplyr::filter(grepl('1', meal))

tmp = meal_metrics(example_data_hall, example_meals_hall)

save(example_data_hall, file = 'example_data_hall.rda', version = 2)
save(example_meals_hall, file = 'example_meals_hall.rda', version = 2)
