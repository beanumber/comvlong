# PURPOSE: Download and explore meaningful subsamples of data to showcase
# methodology for faiRPolicing package

# Load packages -----------------------------------------------------------

library(tidyverse)
library(rio)
library(here)
library(hms)
library(lubridate)

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
         time = hms::hms(seconds = second, minutes = minute, hours = hour)
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


## stops, not offenses

bad_locations <- boston_pd_1120 |>
  group_by(citation_number) |>
  summarize(
    num_offenses = n(),
    locations = n_distinct(location_name)
  ) |>
  filter(locations > 1)



# sample the data
# boston_pd_1120 <- boston_pd_1120 |>
#   sample_n(150000)
boston_pd_1120 <- boston_pd_1120 |>
  filter(year(event_date) %in% c(2011, 2012, 2013, 2014, 2015))

# 2.8 MB
usethis::use_data(boston_pd_1120, overwrite = TRUE)


years <- boston_pd_1120 |>
  mutate(year = lubridate::year(event_date)) |>
  group_by(year) |>
  summarize(count = n()) |>
  arrange(year)
