# This is the script for processing Aleppo2017 data into the common format.
# It follows the steps taken in the preprocessor.py created by David Buchanan.
# Additionally, it also provides an extra processing section for troublesome
# data within Aleppo.
# Author: Shaun Cass, Rucha Bhat (provided the chunking algorithm, lines 118 - 167)
# Date: April 18th, 2021


# This study downloads as a zipped folder containing data tables and forms
# First download the entire dataset. Do not rename the downloaded folder
# Place the downloaded folder into a folder of your creation specific for this dataset
# You may name your created folder however you like
# Here we have named the created folder by first author last name and date of the original paper
dataset <- 'Aleppo2017'
# If you have a different naming method, you will need to adjust this, eg.
# dataset = "insert_your_name"

# using the original file path exactly as downloaded
file <- paste0(dataset, '/Protocol_H/Data Tables/HDeviceCGM.txt') 
# alternatively, if file paths have been changed simply set file = the CGM file

newfile <- paste0(dataset, "_processed.csv")

# This file is decently large so reading/writing it will take a minute or two.
aleppo <- read.table(file, header = TRUE, sep = "|")

# The data has days as days since study start 
# Establishing a base date to work from
basedate <- as.Date("2015-05-22", format = "%Y-%m-%d")
# Using the basedate + the days from enroll to get the correct date
dates <- basedate + aleppo$DeviceDtTmDaysFromEnroll

# Use the dates + times to create a datetime string
aleppo$time <- paste(dates, aleppo$DeviceTm, sep = " ")
names(aleppo)[names(aleppo) == "PtID"] <- "id"
names(aleppo)[names(aleppo) == "GlucoseValue"] <- "gl"

# Write the processed data into a csv file in the working directory
## Skip this step/comment it out if you wish to do the additional
## preprocessing in the next commented section.
write.csv(aleppo[,c("id", "time", "gl")], file = newfile, row.names = FALSE)

# The next section is additional cleaning that was implemented in a project
# under the supervision of Dr. Gaynanova.

# If you wish to use the additional cleaning then please comment out the above
# write.csv() line and uncomment the following # sections (## are comments).
# If you use Rstudio you can highlight a code chunk and ust ctrl+shift+c to 
# uncomment it.

## The additional cleaning will require a few packages. If you need to install 
## them then please use install.packages("package_name")
## i.e. install.packages("tidyverse") before running the code below.

# library(tidyverse)
# library(magrittr)
# library(iglu)
# library(lubridate)
# 
# Aleppo <- aleppo[,c("id", "time", "gl")]
# rm("aleppo")

## Figuring out the maximum gap in time for each subject 

# Aleppo <- Aleppo %>%
#   mutate(time = as_datetime(time)) %>%
#   arrange(id, time) # this is crucial for the next loop.
# Alep_ids <- unique(Aleppo$id)
# max_time_gap <- rep(0, length(Alep_ids))

# for(i in seq_along(Alep_ids)){
#   a <- Aleppo %>%
#     filter(id == Alep_ids[i])
#   max_time_gap[i] <- max(as.duration(a$time[2:length(a$time)] - a$time[-length(a$time)]),
#                          na.rm = TRUE)
#   print(i) # Figure out how long it is taking. There are 226 ids in total.
# }


# Aleppo <- full_join(Aleppo,
#                     data.frame("id" = Alep_ids, "max_time_gap" = max_time_gap),
#                     by = "id")

## It was decided that a maximum time gap greater than 3 months (90 days)
## was too large for this dataset and glucose metrics on subjects
## with this long of a  time gap may be inaccurate.
## 13 subjects in total get removed from the dataset under this criteria.
## Also, the study used a Dexcom G4 Platinum which only measures glucose 
## in the 40 - 400 mg/dL range so readings outside this range were set to NA.

# Aleppo <- Aleppo %>%
#   # Assuming 30 days = 1 month.
#   filter(max_time_gap/(60*60*24*30) <= 3) %>% # max_time_gap is in seconds
#   mutate(gl = replace(gl, gl > 400, NA)) %>%
#   mutate(gl = replace(gl, gl < 40, NA)) %>%
#   select(-max_time_gap)

## Additionally, through the use of plot_glu() graphics from the iglu package,
## we found that 6 subjects (id = 147, 203, 223, 249, 275, 281) had some sections
## of extremely sparse data. To counteract this, we used a chunking algorithm 
## to select the best section of data based on the number of active days. 
## This worked well for three of the subjects (223, 249, 281), but not so well
## for the other three subjects (147, 203, 275).
## For these remaining three subjects we had to manually truncate the data.
## This was done by manually looking over the data and truncating it when the 
## glucose readings became frequent i.e. multiple readings per day instead of
## just one or two.

## The following chunking algorithm excluding the manual truncation at the end
## was provided by Rucha Bhat.

# extra_filt_ids <- c(147, 203, 223, 249, 275, 281)
# a_list <- Aleppo %>%
#   filter(id %in% extra_filt_ids) %>%
#   group_split(id)

## Creating a function to split data from a single id into chunks
## Chunks are defined such that any gaps within the data are not more than 4 weeks long and 
## time gaps between chunks are greater than 4 weeks

# chunk.split = function(tab){
  
  ## difftime  - calculates the timejump between each row
  ## Type      - anything less than 1 week is a Short timegap
  ##           - anything between 1-4 weeks is a Medium timegap
  ##           - anything longer than 4 weeks is a Long timegap
  ##           - DST (Daylight Savings Time), these throw an error in 
  ##             calculating the time difference, so they are just reclassified
  
  # tab %<>% arrange(time) %>%
  #   mutate(diff = difftime(time, lag(time), units = 'weeks'),
  #          Type = case_when(is.na(diff) & row_number() == 1 ~ 'First',
  #                           diff <= 1 ~ 'Short',
  #                           is.na(diff) & row_number() != 1 ~ 'DST',
  #                           diff <= 4 ~ 'Medium',
  #                           TRUE ~ 'Long'))
  # 

  ## Assigns the data into "chunk"s

#   tab %>% filter(Type %in% c('First','Long')) %>%
#     mutate(chunk = row_number()) %>% full_join(.,tab) %>%
#     arrange(time) %>% mutate(chunk = cumsum(!is.na(chunk))) %>%
#     select(-diff, -Type) %>%
#     group_split(chunk, .keep = F)
#   
# }


# a_list %<>% map(chunk.split)

## Creating a function to calculate the active_percent and active_days of each chunk

# chunk.active = function(tab){
#   chunk.split(tab) %>% map_dfr(active_percent) %>% mutate(active_days = active_percent/100*ndays)
# }

## Calculate active_percent and active_days within each chunk

# id.chunks <- Aleppo %>% filter(id %in% extra_filt_ids) %>%
#   group_split(id) %>% map_dfr(chunk.active)

# best.chunk <- id.chunks %>% group_split(id) %>% 
#   map_dbl(~ pull(., active_days) %>% which.max)

## Filter the troublesome Aleppo subject data for the best chunks by id

# extrafiltids_bestchunksonly <- map2_dfr(a_list, best.chunk, ~ .x[[.y]])
# 
# subset_147 <- extrafiltids_bestchunksonly %>%
#   filter(id == 147) %>%
#   filter(date(time) >= "2015-04-08")
# 
# subset_203 <- extrafiltids_bestchunksonly %>%
#   filter(id == 203) %>%
#   filter(date(time) >= "2015-03-29")
# 
# subset_275 <- extrafiltids_bestchunksonly %>%
#   filter(id == 275) %>%
#   filter(date(time) >= "2015-04-08")
# subset_list <- list(subset_147, subset_203, subset_275)
# 
# extrafiltids_bestchunksonly <- extrafiltids_bestchunksonly %>%
#   filter(!(id %in% c(147, 203, 275)))
# 
# Aleppo <- Aleppo %>%
#   filter(!(id %in% extra_filt_ids))
# 
# Aleppo <- bind_rows(Aleppo,
#                     extrafiltids_bestchunksonly,
#                     subset_list)

## Write the cleaned Aleppo dataset to a csv.

# write.csv(Aleppo, file = newfile, row.names = FALSE)
