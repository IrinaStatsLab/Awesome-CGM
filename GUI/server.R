library(shiny)
library(shinyjs)  
library(shinyFiles)
library(git2r)
library(utils)

# Define the script paths for multiple datasets
script_paths <- list(
  Broll2021 = c("Broll2021_preprocessor.R"),
  Buckingham2007 = c("Buckingham2007_preprocessor.R"),
  Colas2019 = c("Colas2019_preprocessor.R"),
  Hall2018 = c("Hall2018_preprocessor.R"),
  Lynch2022 = c("Lynch2022_preprocessor.R"),
  O_Mally2021 = c("O_Mally2021_preprocessor.R"),
  Shah2019 = c("Shah2019_preprocessor.R"),
  Wadwa2023 = c("Wadwa2023_preprocessor.R")
)

options(shiny.maxRequestSize = 200*1024^2)

# Define Server logic
server <- function(input, output, session) {
  # current_wd <- getwd() 
  # 
  # # Define the path for the "download" subfolder
  # local_dir <- file.path(current_wd, "GUI/download")
  # # Create the "download" subfolder if it does not exist
  # if (!dir.exists(local_dir)) {
  #   dir.create(local_dir)
  # }
  
  local_dir <- file.path(getwd(), 'Awesome-CGM_download')
  
  # Clear the "Awesome-CGM_download" subfolder if it exists
  if (dir.exists(local_dir)) {
    unlink(local_dir, recursive = TRUE)  # Remove all contents
  }
  
  # Recreate the "Awesome-CGM_download" directory
  # dir.create(local_dir, recursive = TRUE)
  
  # Initialize shinyFiles settings to allow folder selection
  shinyDirChoose(input, "directory", roots = c(home = "~"), session = session)
  
  # Disable download buttons initially
  disable("downloadProcessedData")
  disable("downloadFilteredData")
  
  # Process datasets upon button click
  observeEvent(input$process, {
    # Get uploaded files
    uploaded_files <- if (!is.null(input$files)) {
      input$files
    } else {
      NULL
    }
    
    # Ensure there are files to process
    if (is.null(uploaded_files) || nrow(uploaded_files) == 0) {
      output$processStatus <- renderText("No files selected.")
    }
    
    # Get the selected datasets
    selected_datasets <- input$datasets
    if (is.null(selected_datasets) || length(selected_datasets) == 0) {
      output$processStatus <- renderText("No datasets selected.")
    }
    
    # Track the processing status for multiple datasets
    status_messages <- c()
    
    # Loop over each selected dataset to prepare directories and download scripts
    for (dataset in selected_datasets) {
      dataset_name <- dataset
      
      # Ensure a separate subdirectory for each dataset under local_dir
      dataset_dir <- file.path(local_dir, dataset_name)
      if (!dir.exists(dataset_dir)) {
        dir.create(dataset_dir, recursive = TRUE)
      }
      
      # if (dir.exists(dataset_dir)) {
      #   unlink(dataset_dir, recursive = TRUE)  
      #   }
      # dir.create(dataset_dir, recursive = TRUE)
      
      # Special handling for Hall2018 dataset
      if (dataset_name == "Hall2018") {
        # Identify .db and suffix-less files
        db_file <- uploaded_files$datapath[grepl("*.db$", uploaded_files$name)]
        suffix_less_file <- uploaded_files$datapath[uploaded_files$type == "application/octet-stream"]
        
        # Check if exactly one .db file and one without an extension were provided
        if (length(db_file) != 1 || length(suffix_less_file) != 1) {
          status_messages <- c(status_messages, "Hall2018 requires exactly two files: one .db and one without an extension.")
          next
        }
        
        # Move Hall2018 files to dataset directory
        file.copy(db_file, file.path(dataset_dir, basename(uploaded_files$name[uploaded_files$datapath == db_file])))
        file.copy(suffix_less_file, file.path(dataset_dir, basename(uploaded_files$name[uploaded_files$datapath == suffix_less_file])))
        
      } else {
        # Ensure the uploaded files are .zip for other datasets
        zip_files <- uploaded_files$datapath[grepl("*.zip$", uploaded_files$name)]
        
        # Check for valid .zip files
        if (length(zip_files) == 0) {
          status_messages <- c(status_messages, paste("No .zip file found for dataset:", dataset_name))
          next
        }
        
        # Unzip the uploaded file to the dataset directory
        unzip(zip_files, exdir = dataset_dir)
        # unzip(zip_files, exdir = local_dir)
      }
      
      # Get the appropriate script for the dataset
      selected_script <- script_paths[[dataset]][1]  # Only one script per dataset in this setup
      
      # Construct GitHub link for the selected script
      script_url <- paste0("https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R/", 
                           dataset_name, "/", selected_script)
      
      # Fetch the script from GitHub and save it locally
      
      local_script_path <- file.path(dataset_dir, selected_script)
      # local_script_path <- file.path(local_dir, selected_script)
      download.file(script_url, local_script_path, method = "curl")
      
      # Fetch the optional missing filter script from GitHub
      filter_script_url <- "https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R/filter_missing_data.R"
      filter_script_path <- file.path(dataset_dir, "filter_missing_data.R")
      download.file(filter_script_url, filter_script_path, method = "curl")
    }
    
    # Run all downloaded scripts concurrently
    tryCatch({
      # Save the current working directory
      original_wd <- getwd()
      
      # Run the main processing and filter scripts for each dataset in parallel
      lapply(selected_datasets, function(dataset) {
        dataset_dir <- file.path(local_dir, dataset)
        script_path <- file.path(dataset_dir, script_paths[[dataset]][1])
        filter_script_path <- file.path(dataset_dir, "filter_missing_data.R")
        
        # Execute the scripts concurrently
        setwd(dataset_dir)
        source(script_path)
        
        # Apply missing data filter if the checkbox is selected
        if (input$applyMissingFilter) {
          source(filter_script_path)
        }
        
        # Return to original directory after running each script
        setwd(original_wd)
        
        # Update status message for the current dataset
        status_messages <<- c(status_messages, paste("Processed dataset:", dataset))
      })
      
      # Restore the original working directory
      setwd(original_wd)
      
      # Enable the download buttons after processing is complete
      enable("downloadProcessedData")
      enable("downloadFilteredData")
      
      # Display the accumulated status messages
      output$processStatus <- renderText(paste(status_messages, collapse = "\n"))
      
    }, error = function(e) {
      # Restore the original working directory in case of an error
      setwd(original_wd)
      
      # Display the error
      output$processStatus <- renderText(paste("Error processing datasets:", e$message))
    })
  })
  
  # Adjust the download handler for each dataset's processed CSV
  output$downloadProcessedData <- downloadHandler(
    filename = function() {
      paste("processed_datasets.zip", sep = "")
    },
   
      content = function(file) {
        csv_files <- c()
        rel_paths <- c() 
        
        old_wd <- setwd(local_dir)
        on.exit(setwd(old_wd))  
        
        for (dataset in input$datasets) {
          csv_dir <- file.path(dataset, "csv_data")
          filtered_csv_files <- list.files(csv_dir, pattern = "*.csv", full.names = TRUE)
          
          csv_files <- c(csv_files, filtered_csv_files)
          rel_paths <- c(rel_paths, file.path(csv_dir, basename(filtered_csv_files)))
        }
        
        zip::zip(zipfile = file, files = rel_paths, recurse = FALSE)
    }
  )

  
  output$downloadFilteredData <- downloadHandler(
    filename = function() {
      "processed_filtered_datasets.zip"
    },
    content = function(file) {
      csv_files <- c()
      rel_paths <- c() 
      
      old_wd <- setwd(local_dir)
      on.exit(setwd(old_wd))  
      
      for (dataset in input$datasets) {
        csv_dir <- file.path(dataset, "csv_data")
        filtered_csv_files <- list.files(csv_dir, pattern = "*_filtered.csv", full.names = TRUE)
        
        csv_files <- c(csv_files, filtered_csv_files)
        rel_paths <- c(rel_paths, file.path(csv_dir, basename(filtered_csv_files)))
      }
      
      zip::zip(zipfile = file, files = rel_paths, recurse = FALSE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)