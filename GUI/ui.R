library(shiny)
library(shinyjs)

# Define the script paths for multiple datasets
script_paths <- list(
  Broll2021 = c("Broll2021_preprocessor.R"),
  Buckingham2007 = c("Buckingham2007_preprocessor.R"),
  Colas2019 = c("Colas2019_preprocessor.R"),
  Hall2018 = c("Hall2018_preprocessor.R"),
  Lynch2022 = c("Lynch2022_preprocessor.R"),
  O_Malley2021 = c("O_Malley2021_preprocessor.R"),
  Shah2019 = c("Shah2019_preprocessor.R"),
  Wadwa2023 = c("Wadwa2023_preprocessor.R")
)
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
      verbatimTextOutput("datasetFileRequirements"),  # Use verbatimTextOutput for better formatting

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
      actionButton('clear_messages', 'Clear Messages'),
      h3("Processing Log:"),
      textOutput("processStatus"),
      verbatimTextOutput("processLog")  # Accumulating message log
      # verbatimTextOutput with renderPrint
      # screentext <- reactiveVal("")
      # in any of the observers, the screen_text()
      # renderText() <-
      # Accumulate a variable for printing context; appending the message into the variable; and
      # After each appending, renderPrint the string variable
    )
  )
)
