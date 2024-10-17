# This is the script generating plot_glu() pdf for each subjects in each dataset for quality check purpose
# Author: Charlotte Xu
# Date: 10/11/2024

# Load necessary libraries
library(readr)
library(dplyr)
library(iglu)
library(tools)

# Function to process a single dataset and generate PDFs for each subject
process_dataset <- function(file_path) {
  # Load the dataset
  data <- read_csv(file_path)
  
  # Convert 'time' column to datetime if needed
  data$time <- as.POSIXct(data$time, format = "%Y-%m-%d %H:%M:%S")
  
  # Extract the dataset name from the file path (without extension)
  dataset_name <- file_path_sans_ext(basename(file_path))
  
  # Create a folder named after the dataset in the QC/plot_glu_output folder
  output_folder <- file.path("QC/plot_glu_output", dataset_name)
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }
  
  # Loop through each unique subject (id)
  for(subject in unique(data$id)) {
    # Subset data for the current subject
    subject_data <- data %>% filter(id == subject)
    
    # Ensure the subset is in the correct format for plot_glu
    subject_data_formatted <- subject_data %>%
      select(id, time, gl)
    
    # Create a PDF file for the current subject, named by subject's ID
    pdf(file.path(output_folder, paste0(subject, "_glucose_profile.pdf")), onefile = TRUE)
    
    # Explicitly print the plot inside the PDF device
    print(plot_glu(subject_data_formatted))
    
    # Close the PDF device after plotting
    dev.off()
  }
  
  # Print message indicating completion for this dataset
  cat("PDFs saved in folder:", output_folder, "\n")
}

# Function to process all datasets in the 'csv_data' folder
process_all_datasets <- function(folder_path) {
  # Get the list of CSV files in the folder
  file_list <- list.files(folder_path, pattern = "*.csv", full.names = TRUE)
  
  # Process each dataset
  for(file_path in file_list) {
    process_dataset(file_path)
  }
}

# Run the function to process all datasets in 'csv_data' folder
process_all_datasets("csv_data")
