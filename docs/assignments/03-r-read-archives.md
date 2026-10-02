# 03 (R): Read both archive formats

**Goal:** The Python scraper now writes CSVs (`astrology.com_2026-10-02.csv`),
but the R pipeline only reads the 2020 `.txt` files. Make R read both.

**You'll learn:** writing functions with sensible defaults, `readr` column
types, `list.files()` patterns, `purrr::map()` + `list_rbind()`, and keeping two data sources in the same shape.

## Setup

Make a sample CSV archive so you have something to read:
```sh
mkdir -p tests/testthat/fixtures
```
Then run `uv run dinozodiac scrape --archive-dir tests/testthat/fixtures`.
horoscope.com still scrapes, so this gives you a real `horoscope.com_<today>.csv`.
Trim it to 2–3 rows to keep the fixture small. Also hand-write a second file
with an empty `date` cell, because real data has gaps.

## Tasks

In `R/parse_archive.R`, write:

1. `read_csv_archive(dir)`: reads every `*.csv` archive in `dir` and returns a tibble with **exactly the same columns and types as `read_legacy_archive()`**: `source, url, sign, date, scope, file`.
   - The CSV calls the text column `text`, not `scope`.
   - `date` must come out as a `Date`, not a character. Look at `readr::cols()` / `col_date()`.
   - `file` should be the base name, as in the legacy reader.
   - If there are no CSVs, return a zero-row tibble with the right columns. Don't error, because most days there won't be any yet.
2. `read_archive(dir = here::here("astrohistory"))`: combines both readers and removes duplicates the same way `read_legacy_archive()` does.
3. Switch `scripts/01_parse_archive.R` to use `read_archive()`.

Tests go in `tests/testthat/test-read_archive.R`:
- The CSV reader returns the right column names *in the right order* (`expect_named()`).
- `date` is a Date (`expect_s3_class()`).
- An empty directory gives zero rows, not an error (`withr::local_tempdir()` is handy).
- Legacy + CSV rows bind without type errors.

## Done when

- [ ] All tests pass, old and new
- [ ] `source("scripts/01_parse_archive.R")` still reports the same number of 2020 horoscopes as before
- [ ] `lintr::lint("R/parse_archive.R")` is clean

**Stuck?** For the empty case, `tibble::tibble(source = character(), date = as.Date(character()), ...)` is a zero-row tibble with types.
