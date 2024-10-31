# colas_proc <- "../R/Colas2019/Colas2019_preprocessor.R"
# response <- GET(colas_processing_url)
# status_code(response)
# 
# script_dest <- tempfile(fileext = ".R")
# writeBin(content(response, 'raw'), file_dest)


# library(devtools)
# devtools::source_url(colas_processing_url)

# this file is under the folder: 'GUI/demo.R'

#   'R/Colas2019/Colas2019_preprocessor.R' and put it in folder: 'GUI/processors_fn'

file.copy("R/Colas2019/Colas2019_preprocessor.R", "GUI/processors_fn/Colas2019_preprocessor.R")


# TODO: add indication message of the file name correponding to the study dataset and the download link

# TODO: explain the missingness filter - minimal exclusion criteria


unzip(files_zipped, exdir = files_zipped_name)


extract_paths <- list(
  Buckingham2007 = "DirecNetNavigatorPilotStudy",
  Colas2019 = "S1",
  Lynch2022 = "IOBP2 RCT Public Dataset", # actual database file should be: "IOBP2 RCT Public Dataset.zip"  
  O_Mally2021 = "DCLP3 Public Dataset", # "DCLP3 Public Dataset.zip
  Shah2019 = "CGMND-af920dee-2d6e-4436-bc89-7a7b51239837",
  Wadwa2023 = "PEDAP Public Dataset" # PEDAP Public Dataset.zip
)
for (i in 1:length(files_zipped_name)) {
  
  extract_subfolder <- extract_paths[ files_zipped_name[i] ] #TODO
  print(extract_subfolder)
  extract_path <- file.path('local_dir', extract_subfolder)
  unzip(files_zipped[i], exdir = extract_path)
}
