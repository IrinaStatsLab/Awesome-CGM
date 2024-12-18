library(shiny)
library(shinyjs)

# Define the script paths for multiple datasets
script_paths <- list(
  Broll2021 = c("Broll2021_preprocessor.R"),
  Brown2019 = c("Brown2019_preprocessor.R"),
  Buckingham2007 = c("Buckingham2007_preprocessor.R"),
  Colas2019 = c("Colas2019_preprocessor.R"),
  Hall2018 = c("Hall2018_preprocessor.R"),
  Lynch2022 = c("Lynch2022_preprocessor.R"),

  Shah2019 = c("Shah2019_preprocessor.R"),
  Wadwa2023 = c("Wadwa2023_preprocessor.R")
)
# Define UI
ui <- fluidPage(
  useShinyjs(),

  titlePanel(
    title = "AwesomeCGM - Data Processor GUI",
    windowTitle = "AwesomeCGM"
  ),
  div(
    p("Welcome to the AwesomeCGM - Data Processor GUI! This tool is designed to assist users in processing validation datasets efficiently and effectively.
       It provides a convenient way to run scripts and streamline
       data preprocessing while ensuring consistency and accuracy."),
    p("For more information about AwesomeCGM, visit our ",
      tags$a(href = "https://github.com/IrinaStatsLab/Awesome-CGM", "GitHub repository", target = "_blank"), "."),
    style = "margin-bottom: 20px; font-size: 14px; color: #555;"
  ),

  sidebarLayout(
    sidebarPanel(
      # Allow multiple dataset selection
      selectInput("datasets", "Choose Study Datasets:",
                  choices = names(script_paths), multiple = TRUE),

      fileInput("files", "Upload Raw Datasheet Folders (as .zip or .db and other file for Hall2018):",
                multiple = TRUE, accept = NULL),

      # Missing data filter
      checkboxInput(
        "applyMissingFilter",
        "Apply Missingness Filter (minimum exclusion criteria)",
        value = FALSE
      ),

      div(
        p("Minimal exclusion criteria for data quality checks:"),
        p("- 90% non-missing data for 1-day records, 70% non-missing data for records spanning 2–14 days"),
        p("- 70% non-missing days for data with more than 14 days to 3 months study duration."),
        style = "font-size: 12px; color: #555; margin-bottom: 20px;"
      ),

      # Process button
      actionButton("process", "Process Datasets"),
      # Processing information note
      div(
        strong("Note:"),
        p("Each procedure could take up to 10-30 seconds for large dataset files. Please be patient."),
        style = "font-size: 12px; color: #888;margin-top: 20px;margin-bottom: 20px;"
      ),

      # Display process status
      h4("Current Status:"),
      textOutput("processStatus"),
      # Two separate buttons for downloading datasets
      downloadButton("downloadProcessedData", "Download Processed Datasets"),
      downloadButton("downloadFilteredData", "Download Processed & Filtered Datasets"),

      actionButton("clearAll", "Clear and Start Over")

    ),

    mainPanel(
      verbatimTextOutput("datasetFileRequirements"),  # Use verbatimTextOutput for better formatting

      h3("Processing Log:"),
      verbatimTextOutput("processStatus"),
      verbatimTextOutput("processLog"),  # Accumulating message log

      div(
        tags$hr(),
        p(
          "Developed by the AwesomeCGM Team at IrinaStatsLab. Visit us at ",
          tags$a(href = "https://github.com/IrinaStatsLab/Awesome-CGM", "GitHub", target = "_blank"),
          ".",
          style = "font-size: 12px; color: #888;"
        )
      )
    )
  )
)
