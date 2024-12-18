library(shiny)
library(shinyjs)
library(shinyFiles)
# library(git2r)
library(utils)
library(httr)  # To handle HTTP requests
library(glue)  # To simplify URL string construction
library(tools)
library(tidyverse)
library(magrittr)
library(readr)
library(DBI)
library(RSQLite)


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
# Define the message indication paths with expected dataset files
message_indication <- list(
  Broll2021 = "No dataset needed, just hit process and download :-)",
  Brown2019 = "DCLP3 Public Dataset - Release 3 - 2022-08-04.zip",
  Buckingham2007 = "DirecNetNavigatorPilotStudy.zip",
  Colas2019 = "S1.zip",
  Hall2018 = "pbio.2005143.s010, pbio.2005143.s014.db",
  Lynch2022 = "IOBP2 RCT Public Dataset.zip",
  Shah2019 = "CGMND-af920dee-2d6e-4436-bc89-7a7b51239837.zip",
  Wadwa2023 = "PEDAP Public Dataset - Release 3 - 2024-09-25.zip"
)
message_indication_with_links <- list(
  Broll2021 = "No dataset needed, just hit process and download :-). \n",
  Brown2019 = " DCLP3 Public Dataset - Release 3 - 2022-08-04.zip (https://public.jaeb.org/dataset/573) \n",
  Buckingham2007 = "DirecNetNavigatorPilotStudy.zip (https://public.jaeb.org/direcnet/stdy/166) \n",
  Colas2019 = "S1.zip (https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0225817#sec018) \n",
  Hall2018 = " pbio.2005143.s010, pbio.2005143.s014.db (https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005143#pbio.2005143.s010) \n",
  Lynch2022 = " IOBP2 RCT Public Dataset.zip (https://public.jaeb.org/dataset/579) \n",
  Shah2019 = " CGMND-af920dee-2d6e-4436-bc89-7a7b51239837.zip (https://public.jaeb.org/dataset/559) \n",
  Wadwa2023 = " PEDAP Public Dataset - Release 3 - 2024-09-25.zip (https://public.jaeb.org/dataset/599) \n"
)


options(shiny.maxRequestSize = 3 * 1024^3)  # 3GB

# Define Server logic
server <- function(input, output, session) {

  temp_dir <- tempdir()
  local_dir <- file.path(temp_dir, "Awesome-CGM_Download")
  dir.create(local_dir, recursive = TRUE)

  # Reactive value to store log messages
  log_messages <- reactiveVal("")
  append_to_log <- function(new_message) {
    current_log <- log_messages()
    log_messages(paste(current_log, new_message, sep = "\n"))
  }
  output$processLog <- renderPrint({
    cat(log_messages())
  })
  observeEvent(input$clear_messages, {
    messages("")
  })

  # Initialize shinyjs
  useShinyjs()

  statusMessage <- reactiveVal("Ready to start.")

  # Reactive values to track the state of the app
  appState <- reactiveValues(
    fileUploaded = FALSE,
    processing = FALSE,
    downloadAvailable = FALSE
  )

  disable("process")
  # Monitor file uploads
  observeEvent( {input$files
    input$datasets},
{
    if (!is.null(input$files) ||  "Broll2021" %in% input$datasets ){
      appState$fileUploaded <- TRUE
      enable("process")  # Enable 'Process Datasets' button
      statusMessage("File uploaded successfully. Ready to process datasets.")

    } else {
      appState$fileUploaded <- FALSE
        # Keep 'Process Datasets' disabled
      statusMessage("Please upload a file to proceed.")

    }
  })



  # Initialize shinyFiles settings to allow folder selection
  shinyDirChoose(input, "directory", roots = c(home = "~"), session = session)
  enable("clearAll")

  disable("downloadProcessedData")
  disable("downloadFilteredData")

  # Define GitHub base URL for scripts
  base_url <- "https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R"
  for (dataset in names(script_paths)) {
    script_name <- script_paths[[dataset]][1]

    script_url <- glue("{base_url}/{dataset}/{script_name}")
    local_script_path <- file.path(local_dir, script_name)
    tryCatch({
      download.file(script_url, local_script_path, method = "curl")
    }, error = function(e) {
    })
  }

  additional_script_url <- glue("{base_url}/filter_missing_data.R")
  additional_local_path <- file.path(local_dir, "filter_missing_data.R")

  tryCatch({
    download.file(additional_script_url, additional_local_path, method = "curl")
    message("Successfully downloaded filter_missing_data.R")
  }, error = function(e) {
    message(glue("Failed to download filter_missing_data.R: {e$message}"))
  })

  observeEvent(input$datasets, {
    selected_datasets <- input$datasets

    if (is.null(selected_datasets) || length(selected_datasets) == 0) {
      output$datasetFileRequirements <- renderText("Please select one or more datasets.")
    } else {
      indication_messages <- sapply(selected_datasets, function(dataset) {
        paste0("Dataset: ", dataset, " -> Expected Files:", message_indication_with_links[[dataset]])
      })
      output$datasetFileRequirements <- renderText(paste(indication_messages, collapse = "\n"))
    }
  })


  observeEvent(input$process, {

    if (appState$fileUploaded
        ) {
      # Disable other inputs while processing
      disable("datasets")
      disable("files")
      disable("applyMissingFilter")
      disable("process")

      appState$processing <- TRUE
      statusMessage("Processing datasets...")
      output$processStatus <- renderText({
        statusMessage()
      })

    csv_data_dir <- file.path(local_dir, 'csv_data')
    if (!dir.exists(csv_data_dir)) {
      dir.create(csv_data_dir, recursive = TRUE)
    }
    # Proceed with the rest of the dataset processing code
    uploaded_files <- input$files
    selected_datasets <- input$datasets

    if (length(selected_datasets) == 1 && selected_datasets == "Broll2021") {
      output$processStatus <- renderText("Processing Broll2021: No files needed, just hit process.")
      enable("process")

      appState$downloadAvailable <- TRUE
    } else {
      # Check for uploaded files
      if (is.null(uploaded_files) || nrow(uploaded_files) == 0) {
        append_to_log("Error: No files uploaded.")
        return()
      }
    }

    if (is.null(selected_datasets) || length(selected_datasets) == 0) {
      append_to_log("Error: No datasets uploaded.")
      return()
    }

    append_to_log(sprintf("Selected datasets: %s", paste(selected_datasets, collapse = ', ')))
    Sys.sleep(1)  # Simulate
    append_to_log("Processing uploaded files...")

    files_zipped_name <- uploaded_files$name[grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_nonzip_name <- uploaded_files$name[!grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_zipped <- uploaded_files$datapath[grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_nonzip <- uploaded_files$datapath[!grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]

    # non_zip file copy # Copy each file to local_dir with its original name
    Map(function(src, dest_name) {
      file.copy(src, file.path(local_dir, dest_name))
      # con <- dbConnect(RSQLite::SQLite(), dbname = "my_database.sqlite")
    }, files_nonzip, files_nonzip_name)

    # Zipped file copy
    files_zipped_name <- sapply(files_zipped_name, function(file) {
      file_path_sans_ext(basename(file))
    })

    # Define extraction paths using local_dir and modified names
    extract_path <- file.path(local_dir, files_zipped_name)

    mapply(function(zip, exdir) {
      if (!dir.exists(exdir)) {
        dir.create(exdir, recursive = TRUE)
      }
      if (basename(exdir)=='S1'){
        append_to_log(sprintf("Unzipping file: %s", zip))

        unzip(zip, exdir = local_dir)
      }
      else {
        append_to_log(sprintf("Unzipping file: %s", zip))

        unzip(zip, exdir = exdir)
        message(paste("Unzipped", zip, "to", exdir))
      }
    }, files_zipped, extract_path)

    tryCatch({
      # Save the current working directory
      setwd(local_dir)
      lapply(selected_datasets, function(dataset) {
        script_path <- file.path(local_dir, script_paths[[dataset]][1])

        if (file.exists(script_path)) {
          append_to_log(sprintf("Running script for dataset: %s", dataset))
          if (dataset == "Hall2018") {
            con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "pbio.2005143.s014.db")
            append_to_log("Database connection established for Hall2018.")

            # Ensure the database connection is closed after sourcing the script
            on.exit(DBI::dbDisconnect(con), add = TRUE)
          } else { source(script_path) }
          append_to_log(sprintf("Completed processing for dataset: %s", dataset))

        } else {
          append_to_log(sprintf("Error: Script not found for dataset: %s", dataset))
        }
        if (input$applyMissingFilter && file.exists("filter_missing_data.R")) {
          source("filter_missing_data.R")
          append_to_log(sprintf("Error: Script not found for dataset: %s", dataset))

        }
        append_to_log("Processing completed.")
      })

      # Enable appropriate download buttons
      if (input$applyMissingFilter) {
        enable("downloadFilteredData")
        disable("downloadProcessedData")
      } else {
        enable("downloadProcessedData")
        disable("downloadFilteredData")
      }


    }, error = function(e) {
      append_to_log(sprintf("Error: %s", e$message))

    })

    statusMessage("Processing complete.")
    output$processStatus <- renderText({
      statusMessage()
    })
    appState$processing <- FALSE
    appState$downloadAvailable <- TRUE

    # Enable download button and reset clearAll
    # enable("downloadProcessed")
    enable("clearAll")
    }
  })

  # Disable inputs when download is available
  observeEvent(appState$downloadAvailable, {
    if (appState$downloadAvailable) {
      disable("datasets")
      disable("files")
      disable("applyMissingFilter")
      disable("process")
    }

  })

observeEvent(input$clearAll, {
    appState$fileUploaded <- FALSE
    appState$processing <- FALSE
    appState$downloadAvailable <- FALSE

    # Reset all inputs
    reset("datasets")
    reset("files")
    updateCheckboxInput(session, "applyMissingFilter", value = FALSE)
    append_to_log("Selections cleared. Ready to start over.")

    # Re-enable initial inputs
    enable("datasets")
    enable("files")
    enable("applyMissingFilter")
    disable("process")
    disable("downloadProcessedData")
    disable("downloadFilteredData")
  })

  # Function to append messages to the process log
  process_log <- reactiveVal("")
  append_to_log <- function(message) {
    current_log <- process_log()
    process_log(paste(current_log, message, sep = "\n"))
  }

  # Render the process log
  output$processStatus <- renderText({
    statusMessage()
  })


# Download handler for processed datasets
output$downloadProcessedData <- downloadHandler(

  filename = function() {
    "processed_datasets.zip"
  },
  content = function(file) {
    csv_data_dir <- file.path(local_dir, 'csv_data')
    csv_files <- list.files(csv_data_dir, pattern = "*.csv$", full.names = FALSE)
    zip::zip(zipfile = file, files = csv_files, root = csv_data_dir)

    on.exit({
      unlink(csv_data_dir, recursive = TRUE)  # Delete all files in the directory
    })

  }
)

# Download handler for processed & filtered datasets
output$downloadFilteredData <- downloadHandler(
  filename = function() {
    "processed_filtered_datasets.zip"
  },
  content = function(file) {
    csv_data_dir <- file.path(local_dir, 'csv_data')
    csv_files <- list.files(csv_data_dir, pattern = "*_filtered.csv$", full.names = FALSE)
    zip::zip(zipfile = file, files = csv_files, root = csv_data_dir)
    on.exit({
      unlink(csv_data_dir, recursive = TRUE)  # Delete all files in the directory
      # log_messages("")  # Clear the message log
    })
  }
)
}



