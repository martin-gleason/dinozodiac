# Dinozodiac

Wherein we build a text-generating AI to create dinosaur-based horoscopes.

Python scrapes the daily horoscopes, R cleans and analyses them, and a
character-level LSTM (R + keras3) writes new ones. Aries is an Allosaurus now.

## Layout

```
src/dinozodiac/      Python package: scrapers, archive writer, DB loader, CLI
tests/python/        pytest tests + saved HTML fixtures (no network needed)
R/                   R functions (sourced by scripts and tests)
scripts/             R pipeline, run in order: 01_parse → 02_load_db → 03_qa → 04_sentiment → 05_train_model
tests/testthat/      R tests
astrohistory/        Raw 2020 scrape archives (.txt) + new CSV archives
sql/                 Handy queries for the Postgres database
data/processed/      Generated tables (gitignored; rebuild with scripts/01_parse_archive.R)
output/              Plots and generated horoscopes
docs/specs/          What the project is (architecture)
docs/plans/          What changed and what's next
docs/assignments/    Learning assignments
```

## Quick start

**Python** (needs [uv](https://docs.astral.sh/uv/)):

```sh
uv sync                     # creates .venv and installs everything
uv run pytest               # run the tests
uv run ruff check .         # lint
uv run dinozodiac scrape    # scrape today's horoscopes into astrohistory/
```

**R** (R 4.1 or newer). Install the packages once:

```r
install.packages(c("tidyverse", "here", "tidytext", "tokenizers",
                   "DBI", "RPostgres", "testthat", "lintr"))
testthat::test_dir("tests/testthat")   # run the tests
source("scripts/01_parse_archive.R")   # build data/processed/*.csv
```

**Database** (optional): copy `.env.example` to `.env`, fill it in, then
`uv run dinozodiac scrape --to-db` or `source("scripts/02_load_db.R")`. Python and R read the same `.env`.

## Status

The 2020 archive (Feb 12 to Apr 14, 2020; 1,452 horoscopes) is the corpus.
As of 2026-10-02, the horoscope.com scraper still works. The astrology.com scraper
needs updating (its daily URL now returns 404).
