# Modernization: October 2026

Status: **done** (branch `modernize`). Learning follow-ups are in `docs/assignments/`.

## Bugs found and fixed

1. **astrology.com saved every horoscope twice from 2020-03-01 on.** `scrapeAstrologyCom.py` appended each link in two separate loops. The new scraper dedupes links, and `read_legacy_archive()` drops exact duplicates. This is where the duplicates investigated in `qa_script.R` and `find_dupes.sql` came from.
2. **The zodiac→dinosaur mapping depended on file read order.** `unique(sign)` was paired by position with a vector of dinosaurs. It is now a named lookup.
3. **The R parsers zipped separately extracted vectors** (all URLs, all dates, all paragraphs) and assumed they lined up. They also ran regex over a deparsed `read.delim` data frame. Each record is now parsed on its own.
4. **`Servere =` typo** in every `dbConnect()` call (the server argument was ignored).
5. `ohmystars.py` used an undefined `testUrl`, and `astrostyle.py` saved its output as `astrologyCom_*.txt`, which would overwrite real archives. Both are removed.
6. `dbSendQuery()` was used for DDL and the results were never cleared. Now `dbExecute()` runs inside a transaction.
7. Hard-coded `/Users/marty/Local Dev Projects/...` paths (the folder has since moved). Paths now use `here()` and `pathlib`.

## Modernization

| Area | Before | After |
|------|--------|-------|
| Python layout | loose scripts that scrape on import | `src/dinozodiac/` package, `pyproject.toml`, `uv.lock` |
| Python tooling | none | uv, pytest (12 tests), ruff lint + format |
| HTTP | `requests.get` without a timeout | shared Session, timeout, User-Agent, `raise_for_status` |
| DB (Py) | psycopg2 + `.ini` + string-formatted URL | SQLAlchemy 2 + psycopg 3 + `.env` + `URL.create` |
| Archive format | `.txt` of raw HTML | tidy CSV (`{source}_{YYYY-MM-DD}.csv`) |
| R style | `%>%`, `function(x)` | native `|>`, `\(x)`, `join_by()`, `pivot_wider()` |
| R DB | odbc + config.yml | RPostgres + `.env`; identity columns, PK/FK/UNIQUE |
| R structure | everything top-level in scripts | functions in `R/`, numbered scripts, testthat tests |
| keras | `keras` + `lr =` + `array_reshape` | `keras3` API, `learning_rate =`, base `dim<-` |
| ggplot | `guides(alpha = FALSE)`, `geom_bar(stat="identity")` | `geom_col()`, `show.legend = FALSE` |

## Removed

These are recoverable from git history (`git show 1fc78b9:<path>`):
`scraping/*.py` (9 near-duplicate scrapers), `db.py`, `scripts/old_dby`, `scripts/pysql.py` (fragment),
`scripts/insert_scopes.SQL` (incomplete), `scripts/staging.sql` (duplicate of the export query),
`scripts/to_azure.R` (`azuremlsdk` is retired), `scripts/install_keras.R` (now a comment in 05),
`scripts/carpentry.R`, `drivers/chromedriver` (unused binary), `astrologyComCSV/` (duplicate file),
`__pycache__/`, `.DS_Store`, `.Rhistory`, and the `SELECT * FROM signs;.sql` file.

## Not verified

- Live scraping, partly. On 2026-10-02, **horoscope.com still works** (12/12 parsed). **astrology.com returns 404** for `/horoscope/daily/`, so its URL and layout have changed.
- `02_load_db.R` and `--to-db` (no database available during the refactor).
- `05_train_model.R` (needs a keras3 + TensorFlow install). See chores CH-01 to CH-04.
  `scripts/00_check_keras.R` and `tests/testthat/test-keras-backend.R` verify the install. Both are confirmed to fail or skip cleanly when keras3 is absent.

## Next

- Assignments 01 and 02 set up `renv.lock` and `.vscode/settings.json`.
- Fix the astrology.com scraper: find the new URL, save fresh HTML as a fixture, and update `parse_astrology_com_*`.
