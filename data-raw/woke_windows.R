# PURPOSE: Download and explore meaningful subsamples of data to showcase
# methodology for faiRPolicing package

# Load packages -----------------------------------------------------------

library(tidyverse)
library(rio)
library(here)
library(hms)

# Download Police Data -----------------------------------------------------------

options(timeout=120)
url <- "https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.csv"
dest <- tempfile(fileext = ".csv")
download.file(url, dest)

# Clean Police Data --------------------------------------------------------------

# initial name cleaning
boston_pd_1120 <- dest |>
  read_csv() |>
  janitor::clean_names()

# manual name cleaning
boston_pd_1120 <- boston_pd_1120 |>
  rename(disposition_desc = disposition_desc_15, sixteen_pass = x16pass) |>
  select(-c(disposition_desc_40))

codes <- boston_pd_1120 |>
  group_by(court_code) |>
  summarize(count = n())

# change so court code for J6 is consistent
boston_pd_1120 <- boston_pd_1120 |>
  mutate(court_code = ifelse(court_code == "CT_J06", "CT_J6", court_code))

# convert PM hours to 24-hour time hours... holding off on further analysis
# until I know what to do with weird times.
boston_pd_1120 <- boston_pd_1120 |>
  mutate(time_hh = as.integer(time_hh),
         time_mm = as.integer(time_mm),
         hour = case_when(am_pm == "PM" & time_hh != 0 &
                              time_hh != 00 & time_hh != 12 ~ time_hh + 12,
                             am_pm == "AM" & time_hh == 12 ~ 0,
                             TRUE ~ time_hh),
         minute = ifelse(!is.na(hour) & is.na(time_mm), 0, time_mm),
         second = ifelse(is.na(hour), NA, 0),
         time = hms(seconds = second, minutes = minute, hours = hour)
  ) |>
  select(-c(hour, minute, second))

# times are not always documented. Also it is difficult to know what hour
# 0 means. Is this 12am or lazy police not entering a time?
times <- boston_pd_1120 |>
  group_by(time_hh, time_mm, am_pm) |>
  summarize(count = n())

# are dates always documented? Yes.
dates <- boston_pd_1120 |>
  group_by(event_date) |>
  summarize(count = n()) |>
  arrange(desc(count))

# how many of each race?
boston_pd_1120 |>
  group_by(race) |>
  summarize(N = n()) |>
  arrange(desc(N))

# clean up race variable
boston_pd_1120 <- boston_pd_1120 |>
  mutate(
    race = case_when(
      race == "white" ~ "WHITE",
      race == "black" ~ "BLACK",
      race == "asian" ~ "ASIAN",
      race == "UNK" ~ "UNKNWN",
      TRUE ~ race)
  )
  
# what about after cleaning?
boston_pd_1120 |>
  group_by(race) |>
  summarize(N = n()) |>
  arrange(desc(N))

# sample the data
boston_pd_1120 <- boston_pd_1120 |>
  sample_n(150000)

# 2.8 MB
usethis::use_data(boston_pd_1120, overwrite = TRUE)

# Court Codes -------------------------------------------------------------

# the data was copy and pasted from into a Google sheet and downloaded as a csv to
# one of the author's local machines to be read in and stored as an Rda.
court_codes <- import("data-raw/court-codes.csv")

# changing court codes so prefixes match police data codes
court_codes <- court_codes |>
  mutate(court_code = case_when(nchar(court_code) == 1 ~ paste0("CT_00", court_code), 
                                 str_detect(court_code, "J") ~ paste0("CT_", court_code),
                                 nchar(court_code) == 2 ~ paste0("CT_0", court_code),
                                 TRUE ~ paste0("CT_", court_code)
                                 )
         )
  

usethis::use_data(court_codes, overwrite = TRUE)
