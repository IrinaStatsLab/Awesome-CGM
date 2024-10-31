library(shiny)
library(shinyFiles)
library(git2r)  
library(utils) 
library(shinyjs)  # Add this line


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

# Define UI
ui_main <- fluidPage(
  useShinyjs(),  # Initialize shinyjs
  
  titlePanel("Dataset Processor"),
  
  
  sidebarLayout(
    sidebarPanel(
      # Select the dataset
      selectInput("dataset", "Choose a Study Dataset:", 
                  choices = names(script_paths)),
      
      # Conditional UI for selecting script version (will show up if multiple scripts exist)
      uiOutput("scriptVersionUI"),
      
      # File upload or folder selection
      # File upload for multiple files, with special case for Hall2018
      fileInput("files", "Upload Raw Datasheet Folders (as .zip or .db and other file for Hall2018):", 
                multiple = TRUE, accept = c(".zip", ".db", "")),
      
      # fileInput("File", "Upload Raw Datasheet Folder (as zip):", 
      #           multiple = TRUE, accept = c(".zip", )),
      shinyDirButton("directory", "Select Folder", "Please select a folder"),
      checkboxInput("applyMissingFilter", "Apply Missing Data Filter", value = FALSE),
      # Process button
      actionButton("process", "Process Dataset"),
      
      # Two separate buttons for downloading datasets
      downloadButton("downloadProcessedData", "Download Processed Dataset"),
      downloadButton("downloadFilteredData", "Download Processed & Filtered Dataset")

    ),
    
    mainPanel(
      verbatimTextOutput("processStatus")
    )
  )
)
# Define Server logic
server_main <- function(input, output, session) {
  local_dir <- file.path("~/Desktop", "Colas2019")
  
  if (!dir.exists(local_dir)) {
    dir.create(local_dir, recursive = TRUE)
  }
  
  # Initialize shinyFiles settings to allow folder selection
  shinyDirChoose(input, "directory", roots = c(home = "~"), session = session)
  
  # Disable download buttons initially
  disable("downloadProcessedData")
  disable("downloadFilteredData")
  
  # Dynamically show script version selection if more than one script is available
  output$scriptVersionUI <- renderUI({
    selected_dataset <- input$dataset
    
    # Get available script versions for the selected dataset
    available_scripts <- script_paths[[selected_dataset]]
    
    if (length(available_scripts) > 1) {
      selectInput("scriptVersion", "Choose Processing Script:", choices = available_scripts)
    }
  })
  # Process datasets upon button click
  observeEvent(input$process, {
    # Get uploaded files
    zip_file <- if (!is.null(input$File)) {
      input$File$datapath
    } else {
      NULL
    }
    
    # Ensure there is a zip file to process
    if (is.null(zip_file)) {
      output$processStatus <- renderText("No zip file selected.")
      return()
    }
    
    extract_path <- file.path(local_dir)
    if (!dir.exists(extract_path)) {
      dir.create(extract_path, recursive = TRUE)
    }
    
    # Unzip the uploaded file to the specified path
    unzip(zip_file, exdir = extract_path)
    
    # Get the selected dataset and script
    selected_dataset <- input$dataset
    selected_script <- if (length(script_paths[[selected_dataset]]) > 1) {
      input$scriptVersion  # Use the selected script version if multiple exist
    } else {
      script_paths[[selected_dataset]][1]  # Default to the only script
    }
    
    # Construct GitHub link for the selected script
    script_url <- paste0("https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R/", 
                         selected_dataset, "/", selected_script)
    
    # Fetch the script from GitHub and save it locally
    local_script_path <- file.path(local_dir, selected_script)
    download.file(script_url, local_script_path, method = "curl")
    # Fetch the optional missing filter script from GitHub
    filter_script_url <- "https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R/filter_missing_data.R"
    filter_script_path <- file.path(local_dir, "filter_missing_data.R")
    download.file(filter_script_url, filter_script_path, method = "curl")
    
    # Run the downloaded script
    tryCatch({
      # Save the current working directory
      original_wd <- getwd()
      
      # Change the working directory to local_dir
      setwd(local_dir)
      
      # Source the main processing script
      source(local_script_path)
      
      # Apply missing data filter if the checkbox is selected
      if (input$applyMissingFilter) {
        source(filter_script_path)
      }
      
      # Restore the original working directory
      setwd(original_wd)
      
      # Update the process status
      output$processStatus <- renderText({
        paste("Processing using", script_url, "for", selected_dataset, "dataset...", 
              if (input$applyMissingFilter) {
                "Missing data filter applied."
              } else {
                "No missing data filter applied."
              },
              "Processing complete! Files and script saved and executed successfully in:", local_dir)
      })
      
      # Enable the download buttons after processing is complete
      enable("downloadProcessedData")
      enable("downloadFilteredData")
    }, error = function(e) {
      # Restore the original working directory in case of an error
      setwd(original_wd)
      
      output$processStatus <- renderText(paste("Error running the script:", e$message))
    })
  })
  
  # Download handler for the processed dataset
  output$downloadProcessedData <- downloadHandler(
    filename = function() {
      paste(input$dataset, "_processed", ".csv", sep = "")
    },
    content = function(file) {
      # Construct the path to the processed data file
      processed_file_path <- file.path(local_dir, "csv_data", paste0(input$dataset, ".csv"))
      
      # Check if the processed file exists
      if (file.exists(processed_file_path)) {
        # Copy the processed file to the destination specified by the user download
        file.copy(processed_file_path, file)
      } else {
        # If the file doesn't exist, create a message or error
        stop("Processed file not found at: ", processed_file_path)
      }
    }
  )
  
  # Download handler for the processed and filtered dataset
  output$downloadFilteredData <- downloadHandler(
    filename = function() {
      paste(input$dataset, "_filtered", ".csv", sep = "")
    },
    content = function(file) {
      # Construct the path to the processed and filtered data file
      filtered_file_path <- file.path(local_dir, "csv_data", paste0(input$dataset, "_filtered.csv"))
      
      # Check if the processed and filtered file exists
      if (file.exists(filtered_file_path)) {
        # Copy the processed and filtered file to the destination specified by the user download
        file.copy(filtered_file_path, file)
      } else {
        # If the file doesn't exist, create a message or error
        stop("Processed and filtered file not found at: ", filtered_file_path)
      }
    }
  )
}
  

# Run the application 
# shinyApp(ui = ui, server = server)