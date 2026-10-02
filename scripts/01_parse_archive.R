# 01: Parse the 2020 archives into tidy tables and save them to data/processed/.
# Every later script starts from these CSVs, so no database is needed to explore.
library(dplyr)
library(readr)
library(here)

source(here("R", "signs.R"))
source(here("R", "parse_archive.R"))

raw <- read_legacy_archive(here("astrohistory"))
tables <- build_tables(raw)

dir.create(here("data", "processed"), recursive = TRUE, showWarnings = FALSE)
for (name in names(tables)) {
  write_csv(tables[[name]], here("data", "processed", paste0(name, ".csv")))
}

message(
  "Parsed ", nrow(tables$scopes), " horoscopes from ",
  n_distinct(raw$file), " files (",
  min(tables$scopes$date, na.rm = TRUE), " to ",
  max(tables$scopes$date, na.rm = TRUE), ")."
)
