# Architecture

## Data flow

```
websites ──(Python: dinozodiac scrape)──► astrohistory/*.csv ──┐
                                      └─► Postgres "staging"   │
2020 archives: astrohistory/*.txt ─────────────────────────────┤
                                                               ▼
                        (R: scripts/01_parse_archive.R) data/processed/{signs,sources,scopes}.csv
                                                               │
           ┌──────────────────────┬────────────────────────────┼───────────────────┐
           ▼                      ▼                            ▼                   ▼
   02_load_db.R → Postgres   03_qa.R (checks)        04_sentiment.R (plot)   05_train_model.R (LSTM)
```

## Tables

| table   | columns                                      | notes                              |
|---------|----------------------------------------------|------------------------------------|
| signs   | sign_id, greekname, dinoname                 | fixed: 12 rows, Aries = 1          |
| sources | source_id, url                               | one row per website                |
| scopes  | scope_id, source_id, date, scope, sign_id    | unique on (date, source_id, sign_id) |
| staging | source, url, sign, date, text                | raw rows appended by the Python CLI  |

## Rules

- **The sign mapping lives in two places**: `src/dinozodiac/signs.py` and `R/signs.R`. Keep them identical.
- **Fetching and parsing are kept apart.** Parsers take an HTML string, so tests use saved fixtures and never touch the network.
- **Scripts only orchestrate.** Logic lives in functions (`R/`, `src/dinozodiac/`) where tests can reach it.
- **Credentials come from `.env`** (gitignored), shared by both languages.
- **Analysis starts from `data/processed/`**, not the database, so the DB is optional.
