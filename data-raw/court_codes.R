# Court Codes -------------------------------------------------------------

library(tidyverse)

# the data was copy and pasted from into a Google sheet and downloaded as a csv to
# one of the author's local machines to be read in and stored as an Rda.
court_codes <- read_csv("data-raw/court-codes.csv")

# changing court codes so prefixes match police data codes
court_codes <- court_codes |>
  mutate(court_code = case_when(
    nchar(court_code) == 1 ~ paste0("CT_00", court_code),
    str_detect(court_code, "J") ~ paste0("CT_", court_code),
    nchar(court_code) == 2 ~ paste0("CT_0", court_code),
    TRUE ~ paste0("CT_", court_code)
  ))

usethis::use_data(court_codes, overwrite = TRUE)
