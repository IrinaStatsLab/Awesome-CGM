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