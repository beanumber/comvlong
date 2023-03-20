# PURPOSE: Download and explore meaningful subsamples of data to showcase
# methodology for faiRPolicing package

# Load packages -----------------------------------------------------------

library(tidyverse)
library(rio)
library(here)

# Download Police Data -----------------------------------------------------------

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

# convert PM hours to 24-hour time hours... holding off on further analysis
# until I know what to do with weird times.
boston_pd_1120 <- boston_pd_1120 |>
  mutate(time_hh = as.integer(time_hh),
         time_hh = ifelse(am_pm == "PM", time_hh + 12, time_hh)
  ) 

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

court_codes <- import("~/Desktop/faiRpolice-court-codes.csv")

# court code issue: court prefixes in the police data indicate what? 
# Everything is CT_... except for NH_907. What is this?

usethis::use_data(court_codes, overwrite = TRUE)
