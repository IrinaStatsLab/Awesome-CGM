library(shiny)
library(shinyjs)
library(shinyFiles)
library(git2r)
library(utils)
library(httr)  # To handle HTTP requests
library(glue)  # To simplify URL string construction
library(tools)

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
# Define the message indication paths with expected dataset files
message_indication <- list(
  Broll2021 = "No dataset needed, just hit process and download :-)",
  Buckingham2007 = "DirecNetNavigatorPilotStudy.zip",
  Colas2019 = "S1.zip",
  Hall2018 = "pbio.2005143.s010, pbio.2005143.s014.db",
  Lynch2022 = "IOBP2 RCT Public Dataset.zip",
  O_Malley2021 = "DCLP3 Public Dataset - Release 3 - 2022-08-04.zip",
  Shah2019 = "CGMND-af920dee-2d6e-4436-bc89-7a7b51239837.zip",
  Wadwa2023 = "PEDAP Public Dataset - Release 3 - 2024-09-25.zip"
)

options(shiny.maxRequestSize = 523 * 1024^2)

# Define Server logic
server <- function(input, output, session) {

  messages <- reactiveVal("")
  output$message_text <- renderPrint({
    cat(messages())
  })
  observeEvent(input$clear_messages, {
    messages("")
  })

  local_dir <- file.path(getwd(), 'Awesome-CGM_download')
  # temp_dir <- tempdir()
  # local_dir <- file.path(temp_dir, "Awesome-CGM_Download")
  dir.create(local_dir, showWarnings = FALSE, recursive = TRUE)

  # Initialize shinyFiles settings to allow folder selection
  shinyDirChoose(input, "directory", roots = c(home = "~"), session = session)

  disable("downloadProcessedData")
  disable("downloadFilteredData")

  # Define GitHub base URL for scripts
  base_url <- "https://raw.githubusercontent.com/IrinaStatsLab/Awesome-CGM/master/R"

  # List of scripts by dataset name
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

  for (dataset in names(script_paths)) {
    script_name <- script_paths[[dataset]][1]

    script_url <- glue("{base_url}/{dataset}/{script_name}")
    local_script_path <- file.path(local_dir, script_name)
    tryCatch({
      download.file(script_url, local_script_path, method = "curl")
      messages(paste0(messages(), "Downloaded {script_name} for {dataset} successfully.\n"))
       }, error = function(e) {
      # messages(paste0(messages(), "Failed to download {script_name} for {dataset}: {e$message}\n"))
    })
  }

  observeEvent(input$datasets, {
    selected_datasets <- input$datasets

    if (is.null(selected_datasets) || length(selected_datasets) == 0) {
      output$datasetFileRequirements <- renderText("Please select one or more datasets.")
    } else {
      indication_messages <- sapply(selected_datasets, function(dataset) {
        paste("Dataset:", dataset, "-> Expected Files:", message_indication[[dataset]])
      })

      output$datasetFileRequirements <- renderText(paste(indication_messages, collapse = "\n"))
    }
  })


  observeEvent(input$process, {
    csv_data_dir <- file.path(local_dir, 'csv_data')
    if (!dir.exists(csv_data_dir)) {
      dir.create(csv_data_dir, recursive = TRUE)
    }
    # Proceed with the rest of the dataset processing code
    uploaded_files <- input$files
    selected_datasets <- input$datasets

    if (is.null(uploaded_files) || nrow(uploaded_files) == 0) {
      # output$processStatus <- renderText("No files selected.")
      messages(paste0(messages(), "No files selected.\n"))

      return()
    }
    if (is.null(selected_datasets) || length(selected_datasets) == 0) {
      # output$processStatus <- renderText("No datasets selected.")
      messages(paste0(messages(), "No datasets selected.\n"))

      return()
    }

    files_zipped_name <- uploaded_files$name[grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_nonzip_name <- uploaded_files$name[!grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_zipped <- uploaded_files$datapath[grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]
    files_nonzip <- uploaded_files$datapath[!grepl('*.zip$', uploaded_files$name, ignore.case=TRUE)]

    # non_zip file copy # Copy each file to local_dir with its original name
    Map(function(src, dest_name) {
      file.copy(src, file.path(local_dir, dest_name))
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
        messages(paste0(messages(), "Unzipping...\n"))
        unzip(zip, exdir = local_dir)
        # message(paste("Unzipped", zip, "to", local_dir))
        messages(paste0(messages(), paste("Unzipped", zip, "to", local_dir,'\n')))

      }
      else {
        messages(paste0(messages(), "Unzipping...\n"))
        unzip(zip, exdir = exdir)
        messages(paste0(messages(), paste("Unzipped", zip, "to", exdir,'\n')))

      }
    }, files_zipped, extract_path)

    # Run all downloaded scripts concurrently
    tryCatch({
      lapply(selected_datasets, function(dataset) {
        script_path <- file.path(local_dir, script_paths[[dataset]][1])

        if (file.exists(script_path)) {
          source(script_path)
          messages(paste0(messages(), paste("Processing", dataset, "...\n")))

        }
        if (input$applyMissingFilter && file.exists("filter_missing_data.R")) {
          source("filter_missing_data.R")
          messages(paste0(messages(), paste("Filtering Missingness for", dataset, "...\n")))

        }
        # status_messages <<- c(status_messages, paste("Processed dataset:", dataset))

        messages(paste0(messages(), paste("Finished Processed", dataset, "!\n")))

      })
      # setwd(original_wd)

      # Enable appropriate download buttons
      if (input$applyMissingFilter) {
        enable("downloadFilteredData")
        disable("downloadProcessedData")
      } else {
        enable("downloadProcessedData")
        disable("downloadFilteredData")
      }

    }, error = function(e) {
      # Restore the original working directory in case of an error
      # setwd(original_wd)

      # Display the error
      messages(paste0(messages(), paste("Error processing datasets:", e$message , '\n\n')))
   })
  })


# Download handler for processed datasets
output$downloadProcessedData <- downloadHandler(
  filename = function() {
    "processed_datasets.zip"
  },
  content = function(file) {
    csv_data_dir <- file.path(local_dir, 'csv_data')

    # Get the list of CSV files with relative paths (processed datasets)
    csv_files <- list.files(pattern = "*.csv$", full.names = FALSE)

    # Create the zip file with relative paths
    zip::zip(zipfile = file, files = csv_files, root = csv_data_dir, recurse = FALSE)
  }
)

# Download handler for processed & filtered datasets
output$downloadFilteredData <- downloadHandler(
  filename = function() {
    "processed_filtered_datasets.zip"
  },
  content = function(file) {
    csv_data_dir <- file.path(local_dir, 'csv_data')

    # Get the list of CSV files with relative paths (processed datasets)
    csv_files <- list.files(pattern = "*_filtered.csv$", full.names = FALSE)

    # Create the zip file with relative paths
    zip::zip(zipfile = file, files = csv_files, root = csv_data_dir, recurse = FALSE)

  }
)
}
