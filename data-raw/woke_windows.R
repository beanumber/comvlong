# PURPOSE: Download and explore meaningful subsamples of data to showcase
# methodology for faiRPolicing package

# Load packages -----------------------------------------------------------

library(tidyverse)
library(hms)

# Download Police Data -----------------------------------------------------------

options(timeout = 120)
url <- "https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.csv"
dest <- tempfile(fileext = ".csv")
download.file(url, dest)

# Clean Police Data --------------------------------------------------------------

# initial name cleaning
raw <- dest |>
  read_csv() |>
  janitor::clean_names()

# manual name cleaning
offenses <- raw |>
  rename(disposition_desc = disposition_desc_15, sixteen_pass = x16pass) |>
  select(-c(disposition_desc_40))

codes <- offenses |>
  group_by(court_code) |>
  summarize(count = n())

# change so court code for J6 is consistent
offenses <- offenses |>
  mutate(court_code = ifelse(court_code == "CT_J06", "CT_J6", court_code))

# convert PM hours to 24-hour time hours... holding off on further analysis
# until I know what to do with weird times.
offenses <- offenses |>
  mutate(
    time_hh = as.integer(time_hh),
    time_mm = as.integer(time_mm),
    hour = case_when(
      am_pm == "PM" & time_hh != 0 &
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
times <- offenses |>
  group_by(time_hh, time_mm, am_pm) |>
  summarize(count = n())

# are dates always documented? Yes.
dates <- offenses |>
  group_by(event_date) |>
  summarize(count = n()) |>
  arrange(desc(count))

# how many people of each race?
offenses |>
  group_by(race) |>
  summarize(N = n()) |>
  arrange(desc(N))

# clean up race variable
offenses <- offenses |>
  mutate(
    race = case_when(
      race == "white" ~ "WHITE",
      race == "black" ~ "BLACK",
      race == "asian" ~ "ASIAN",
      race == "UNK" ~ "UNKNWN",
      TRUE ~ race)
  )
  
# what about after cleaning?
offenses |>
  group_by(race) |>
  summarize(N = n()) |>
  arrange(desc(N))

# Duplicates ----------------------------------------------

## Strip out offenses with missing data

## We want stops, not offenses

bad <- offenses |>
  group_by(citation_number) |>
  summarize(
    num_offenses = n(),
    has_missing_citation_number = sum(is.na(citation_number)),
    has_missing_location = sum(is.na(location_name)),
    has_missing_race = sum(is.na(race)),
    has_missing_officer_id = sum(is.na(officer_id)),
    has_missing_date = sum(is.na(event_date)),
    num_locations = n_distinct(location_name),
    num_races = n_distinct(race),
    num_officer_id = n_distinct(officer_id),
    num_dates = n_distinct(event_date)
  ) |>
  filter(
    has_missing_citation_number | has_missing_location |
      has_missing_race | has_missing_officer_id | has_missing_date |
      num_locations > 1 | num_races > 1 |
      num_officer_id > 1 | num_dates > 1
  )

good <- offenses |>
  anti_join(bad, by = "citation_number")


# Condense into stops, not offenses

bpd_stops_1120 <- good |>
  group_by(citation_number, officer_id, event_date, location_name, race) |>
  summarize(
    num_offenses = n()
  )

usethis::use_data(bpd_stops_1120, overwrite = TRUE)

# Sampling ----------------------------------------------


# sample the data
# boston_pd_offenses <- boston_pd_offenses |>
#   sample_n(150000)
bpd_offenses_20 <- offenses |>
  filter(year(event_date) %in% c(2020))

# 1.9 MB
usethis::use_data(bpd_offenses_20, overwrite = TRUE)


# Check summary statistics

bpd_offenses_20 |>
  mutate(year = lubridate::year(event_date)) |>
  group_by(year) |>
  summarize(count = n()) |>
  arrange(year)

bpd_stops_1120 |>
  mutate(year = lubridate::year(event_date)) |>
  group_by(year) |>
  summarize(count = n()) |>
  arrange(year)

# Officers ------------------------------------

bpd_officers <- offenses |>
  group_by(officer_id, officer_name) |>
  summarize(
    num_offenses = n(),
    num_stops = n_distinct(citation_number),
    num_locations = n_distinct(location_name),
    earliest_date = min(event_date),
    latest_date = max(event_date)
  )

# 1.9 MB
usethis::use_data(bpd_officers, overwrite = TRUE)

# Officer locations ----------------------------------------------

bpd_stops_summary <- bpd_stops_1120 |>
  group_by(officer_id, location_name) |>
  summarize(
    num_offenses = n(),
    num_stops = n_distinct(citation_number),
    num_locations = n_distinct(location_name),
    earliest_date = min(event_date),
    latest_date = max(event_date)
  )

# 1.9 MB
usethis::use_data(bpd_stops_summary, overwrite = TRUE)
