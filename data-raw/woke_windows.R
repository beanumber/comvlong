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

# how many races? Which ones are meaningful, which can we take out?
boston_pd_1120 %>%
  group_by(race) %>%
  summarize(N = n()) |>
  arrange(desc(N))

# 4.1 MB
usethis::use_data(boston_pd_1120, overwrite = TRUE)









library(here)
library(rio)

# list of races with large sample sizes and clear-ish definition,
# some races to be combines
races <- c("WHITE", "white", "BLACK", "black", "AFRICA", "HISP",
           "NATIVE", "INDIAN", "ASIAN", "asian")
# getting observations with specified races only and renaming
race_filtered <- citations %>%
  filter(race %in% races) %>%
  mutate(race = case_when( race == "WHITE" ~ "white",
                           race == "BLACK" | race == "AFRICA" ~ "black",
                           race == "HISP" ~ "hispanic",
                           race == "NATIVE" ~ "native",
                           race == "INDIAN" ~ "indian",
                           race == "ASIAN" ~ "asian",
                           TRUE ~ race)) %>%
  select(-race)
# data check
race_filtered %>%
  group_by(race) %>%
  summarize(count = n())

# getting list of officer IDs for officers with most citations
top_officers <- race_filtered %>%
  group_by(OfficerID) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  filter(count >= 1000, OfficerID != "") %>%
  pull(OfficerID)

# dataset with specified races and top officers
officers_data <- race_filtered %>%
  filter(OfficerID %in% top_officers) #%>%
  # group_by(`Officer Cert`) %>%
  # summarize(count = n())

# summary stats
modelsummary::datasummary_skim(officers_data)
skimr::skim(officers_data)

# no officer cited only white people
officers_data %>%
  group_by(OfficerID) %>%
  summarise(total = n(),
    pct_white = sum(ifelse(race == "white", 1, 0))/total,
    pct_black = sum(ifelse(race == "black", 1, 0))/total,
    pct_asian = sum(ifelse(race == "asian", 1, 0))/total,
    pct_indian = sum(ifelse(race == "indian", 1, 0))/total,
    pct_native = sum(ifelse(race == "native", 1, 0))/total
    ) %>%
  arrange(desc(pct_black))

# still 29.6 MB, which is way too large.
write.csv(officers_data, here("faiRpolice/data/filtered_data.csv"))

# what if we dropped a lot of columns? This ends up being 4.6 MB, but
# I'm guessing we're missing a lot of relevant info.
# officers_data %>%
#   select(`Issuing Agency`, OfficerID, race) %>%
#   write.csv(here("faiRpolice/data/filtered_data.csv"))


# 1.2 MB
saveRDS(officers_data, here("faiRpolice/data/officers.Rda"), compress = "xz")
# 4 MB
saveRDS(race_filtered, here("faiRpolice/data/race_filtered.Rda"), compress = "xz")

