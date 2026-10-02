# 03: Quality checks on data/processed/scopes.csv. Prints a short report.
library(dplyr)
library(readr)
library(here)

scopes <- read_csv(here("data", "processed", "scopes.csv"), show_col_types = FALSE)
glimpse(scopes)

# Should be zero: one horoscope per site, per sign, per day.
dupes <- scopes |>
  count(date, source_id, sign_id) |>
  filter(n > 1)

# Same text published on different days (sites do recycle horoscopes).
recycled <- scopes |>
  group_by(scope) |>
  filter(n() > 1) |>
  arrange(scope, date) |>
  ungroup()

# Days where a site didn't give us all 12 signs.
incomplete_days <- scopes |>
  count(date, source_id) |>
  filter(n != 12)

missing <- scopes |> summarise(across(everything(), \(x) sum(is.na(x))))

message("Duplicate (date, source, sign) rows: ", nrow(dupes))
message("Recycled horoscope texts:           ", n_distinct(recycled$scope))
message("Incomplete site-days:                ", nrow(incomplete_days))
message("Missing values per column:")
print(missing)
