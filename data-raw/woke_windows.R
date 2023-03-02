# PURPOSE: Download and explore meaningful subsamples of data to showcase
# methodology for faiRPolicing package

# Load packages -----------------------------------------------------------

library(tidyverse)

# Download data -----------------------------------------------------------

url <- "https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.csv"
dest <- tempfile(fileext = ".csv")
download.file(url, dest)

boston_pd_1120 <- dest |>
  read_csv() |>
  janitor::clean_names()



boston_pd_1120 %>%
  group_by(race) %>%
  summarize(N = n()) |>
  arrange(desc(N))

boston_pd_1120 <- boston_pd_1120 |>
  mutate(
    race_clean = case_when(
      race == "white" ~ "WHITE",
      race == "black" ~ "BLACK",
      race == "asian" ~ "ASIAN",
      race == "UNK" ~ "UNKNWN",
      TRUE ~ race)
  )

boston_pd_1120 %>%
  group_by(race_clean) %>%
  summarize(N = n()) |>
  arrange(desc(N))

# 4.2 MB
usethis::use_data(boston_pd_1120, overwrite = TRUE)
