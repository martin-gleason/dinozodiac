# 02: Positron + R workspace

**Goal:** Give R a reproducible, project-local package library with renv,
then use Positron's data tools on the real horoscopes.

**You'll learn:** renv, `here()`, running code line by line, the Variables pane, the Data Explorer, the Plots pane, and the Air formatter.

## Tasks

1. **Start an R session** in Positron (interpreter picker → R 4.6). Run `here::here()`. If it errors, that's the point: renv will fix it.
2. **Set up renv.**
   - `install.packages("renv")`, then `renv::init()`. Read what it says. It scans the code for `library()` and `pkg::` calls.
   - Did it find `RPostgres`, `tidytext`, and `keras3`? Look in `renv.lock`.
   - Install anything missing with `renv::install()`, then `renv::snapshot()`.
   - Answer in your notes: What goes in git (`renv.lock`, `renv/activate.R`, `.Rprofile`) and what doesn't (`renv/library/`)? Check `.gitignore` and `renv/.gitignore`.
   - Skip `keras3` for now if TensorFlow gives you trouble. Note it as a follow-up.
3. **Run the tests:** `testthat::test_dir("tests/testthat")`. All should pass.
4. **Run `scripts/01_parse_archive.R` one line at a time** (Cmd+Enter), not by sourcing it.
   - After `raw <- ...`, find `raw` in the **Variables** pane and open it in the **Data Explorer**.
   - In the Data Explorer, filter to `sign == "Leo"` and sort by `date`. How many Leo horoscopes are there? Which date has none?
   - Use the column summary to find the shortest and longest `scope`.
5. **Plots pane.** Run `scripts/04_sentiment.R` line by line. Pop the plot out, resize it, and export it from the Plots pane.
6. **Formatting.** Install the **Air** extension (Posit's R formatter) if it isn't already bundled. Add R format-on-save to your `.vscode/settings.json` from assignment 01. Mess up the indentation in `R/signs.R` and save.
7. **`.env`:** `cp .env.example .env`. You don't need a real database. Run `source("R/db.R"); dz_connect()` and read the error. Is it helpful? (You'll write better ones in 06.)

## Done when

- [ ] `renv.lock` is committed, and `renv::status()` reports no problems
- [ ] `testthat::test_dir("tests/testthat")` passes
- [ ] You know the Leo count and the missing date (write them in the commit message)
- [ ] R files format on save

**Stuck?** If `renv::init()` asks about a DESCRIPTION file or "explicit"
snapshots, choose the implicit option. This project isn't a package.
