library(shiny)
library(shinyjs)  

# Define UI
ui <- fluidPage(
  useShinyjs(),  # Initialize shinyjs
  
  titlePanel("Dataset Processor"),
  
  sidebarLayout(
    sidebarPanel(
      # Allow multiple dataset selection
      selectInput("datasets", "Choose Study Datasets:", 
                  choices = names(script_paths), multiple = TRUE),
      # Display dataset file requirements
      textOutput("datasetFileRequirements"),
      # File upload for multiple files, with special case for Hall2018
      # fileInput("files", "Upload Raw Datasheet Folders (as .zip or .db and other file for Hall2018):",
      #           multiple = TRUE, accept = c(".zip", ".db", ".")),
      fileInput("files", "Upload Raw Datasheet Folders (as .zip or .db and other file for Hall2018):",
                multiple = TRUE, accept = NULL),
      
      # shinyDirButton("directory", "Select Folder", "Please select a folder"),
      checkboxInput("applyMissingFilter", "Apply Missing Data Filter", value = FALSE),
      
      # Process button
      actionButton("process", "Process Datasets"),
      verbatimTextOutput("processStatus"),
      # Two separate buttons for downloading datasets
      downloadButton("downloadProcessedData", "Download Processed Datasets"),
      downloadButton("downloadFilteredData", "Download Processed & Filtered Datasets")
    ),
    
    mainPanel(
      verbatimTextOutput("processStatus")
    )
  )
)