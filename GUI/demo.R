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


# unzip('S1.zip', exdir = 'S1')
message_indication <- list(
  Broll2021 = list(
    name = "Broll2021",
    link = "https://example.com/Broll2021",
    path = "/path/to/Broll2021",
    description = "No dataset needed, just hit process and download."
  ),
  Buckingham2007 = list(
    name = "Buckingham2007",
    link = "https://public.jaeb.org/direcnet/stdy/download/166",
    path = "/path/to/Buckingham2007",
    description = "Required file: DirecNetNavigatorPilotStudy.zip; Must enter name, email, institution and purpose upon download"
  ),
  Colas2019 = list(
    name = "Colas2019",
    link = "https://doi.org/10.1371/journal.pone.0225817.s001",
    path = "/path/to/Colas2019",
    description = "Required file: S1.zip"
  ),
  Hall2018 = list(
    name = "Hall2018",
    link = "https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005143#pbio.2005143.s010",
    path = "/path/to/Hall2018",
    description = "Requires two files: pbio.2005143.s010 and pbio.2005143.s014.db;
      Download ' S1 Data. Continuous glucose monitor recordings.' and ' S5 Data. Glucotype and clinical variables.'"
  ),
  Lynch2022 = list(
    name = "Lynch2022",
    link = "https://example.com/Lynch2022",
    path = "/path/to/Lynch2022",
    description = "Required file: IOBP2 RCT Public Dataset.zip"
  ),
  O_Mally2021 = list(
    name = "O'Mally2021",
    link = "https://example.com/O_Mally2021",
    path = "/path/to/O_Mally2021",
    description = "Required file: DCLP3 Public Dataset - Release 3 - 2022-08-04.zip"
  ),
  Shah2019 = list(
    name = "Shah2019",
    link = "https://example.com/Shah2019",
    path = "/path/to/Shah2019",
    description = "Required file: CGMND-af920dee-2d6e-4436-bc89-7a7b51239837.zip"
  ),
  Wadwa2023 = list(
    name = "Wadwa2023",
    link = "https://example.com/Wadwa2023",
    path = "/path/to/Wadwa2023",
    description = "Required file: PEDAP Public Dataset - Release 3 - 2024-09-25.zip"
  )
)
# 

