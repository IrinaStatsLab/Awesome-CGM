# Load necessary libraries
library(readr)
library(dplyr)
library(lubridate)
library(tools)


# Function to process a single dataset
process_dataset <- function(file_path) {
  # Read the dataset
  data <- read_csv(file_path)
  print(file_path)
  # Convert 'time' column to datetime and extract date
  data$time <- as.POSIXct(data$time)
  data$date <- as.Date(data$time)
  
  # Calculate time span for each subject
  subject_time_span <- data %>%
    group_by(id) %>%
    summarise(min_time = min(date, na.rm = T),
              max_time = max(date, na.rm = T)) %>%
    mutate(time_span_days = as.numeric(difftime(max_time, min_time, units = "days")) + 1)
  
  # Calculate the number of distinct days with data entries for each subject
  distinct_days <- data %>%
    group_by(id) %>%
    summarise(distinct_days_with_data = n_distinct(date))
  
  # Function to calculate inclusion based on your criteria
  calculate_inclusion <- function(time_span_days, distinct_days_with_data, total_entries, file_path) {
    if(file_path == "csv_data/buckingham2007.csv"){
      if (is.na(time_span_days)) {
        return(0)
      } else if (time_span_days == 1) {
        expected_entries <- 144
        return(ifelse(total_entries >= 0.9 * expected_entries, 1, 0))
      } else if (time_span_days > 1 & time_span_days <= 14) {
        required_days <- 0.7 * time_span_days
        return(ifelse(distinct_days_with_data >= required_days, 1, 0))
      } else if (time_span_days > 14) {
        required_days <- 0.7 * 14
        return(ifelse(distinct_days_with_data >= required_days, 1, 0))
      } else {
        return(0)
      }
    }else{
      if (is.na(time_span_days)) {
        return(0)
      } else if (time_span_days == 1) {
        expected_entries <- 288
        return(ifelse(total_entries >= 0.9 * expected_entries, 1, 0))
      } else if (time_span_days > 1 & time_span_days <= 14) {
        required_days <- 0.7 * time_span_days
        return(ifelse(distinct_days_with_data >= required_days, 1, 0))
      } else if (time_span_days > 14) {
        required_days <- 0.7 * 14
        return(ifelse(distinct_days_with_data >= required_days, 1, 0))
      } else {
        return(0)
      }
    }
  }
  
  # Count total entries per subject
  total_entries_per_subject <- data %>%
    group_by(id) %>%
    summarise(total_entries = n())
  
  # Join all data into one table
  subject_metrics <- subject_time_span %>%
    left_join(distinct_days, by = "id") %>%
    left_join(total_entries_per_subject, by = "id")
  
  # Apply the inclusion criteria to each subject
  subject_metrics <- subject_metrics %>%
    mutate(inclusion = mapply(calculate_inclusion, 
                              time_span_days, 
                              distinct_days_with_data, 
                              total_entries,
                              file_path),
           missingness_proportion = 1 - total_entries / (time_span_days * 144))
  
  # List the subjects that need to be excluded (inclusion = 0) and their missingness proportion
  exclusion_ids <- subject_metrics %>%
    filter(inclusion == 1) %>%
    pull(id)
  
  # Filter out ids that have too high of missingness
  filtered_data = data %>% filter(id %in% exclusion_ids)
  
  # Add "_filtered.csv" to the file path for final data
  new_file_path <- paste0(file_path_sans_ext(file_path), "_filtered.csv")
  print(nrow(data))
  print(nrow(filtered_data))
  # Save the filtered data with the new file name
  write_csv(filtered_data, new_file_path)
}

# Function to process all datasets in the 'csv_data' folder and save the results
process_all_datasets <- function(folder_path, output_file, output_vector) {
  # Get the list of CSV files in the folder
  file_list <- list.files(folder_path, pattern = "*.csv", full.names = TRUE)

  # Loop through every dataset for processing
  for(file_path in file_list){
    print(paste("Processing file:", basename(file_path)))
    process_dataset(file_path)
  }
}

# Run the function to process all datasets and save results to 'Exclusion_check.txt' and save removeable ids
process_all_datasets("csv_data")

