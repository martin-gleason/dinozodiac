# 06 (R): Defensive functions: `validate_scopes()`

**Goal:** `scripts/03_qa.R` prints numbers and leaves it to you to notice when
they're wrong. Turn those checks into a function that *fails loudly* when the
data is bad, with a message that tells you what to fix.

**You'll learn:** input validation, `cli::cli_abort()` messages with inline
markup, early returns, returning a "problems" tibble vs. throwing, and testing errors.

## Tasks

Create `R/validate.R` with:

1. `find_problems(scopes)`: returns a tibble with columns `check`, `n`, `example`. There's one row per check that found something:
   - `"duplicate"`: more than one row per (date, source_id, sign_id)
   - `"missing_date"`, `"missing_sign"`: NA in those columns
   - `"empty_text"`: `scope` is NA or under 50 characters
   - `"future_date"`: date after today

   A clean data set returns a **zero-row** tibble.
2. `validate_scopes(scopes, error = TRUE)`:
   - First checks that `scopes` is a data frame with the needed columns. If not, it errors with `cli::cli_abort()`, naming the missing columns (`{.field {missing}}`).
   - Calls `find_problems()`. If `error = TRUE` and there are problems, aborts with a bulleted message, one bullet per check. If `error = FALSE`, warns instead.
   - Returns `scopes` **invisibly** on success, so it works in a pipe: `read_csv(...) |> validate_scopes() |> ...`
3. Use it in `scripts/03_qa.R` (with `error = FALSE`) and at the end of `01_parse_archive.R` (with `error = TRUE`).
4. Go back to `dz_connect()` in `R/db.R` and convert its `stop()` to `cli_abort()` in the same style.

## Done when

- [ ] Tests build small broken tibbles by hand, one per check, and `expect_error(..., class = ...)` or `expect_snapshot(error = TRUE)` each one
- [ ] A clean tibble passes, and `validate_scopes()` returns it unchanged (`expect_identical()`)
- [ ] `01_parse_archive.R` still runs on the real data. If it doesn't, you found a real data problem: decide whether to fix the data or the rule, and write down why.

**Stuck?** Give your error a class (`cli_abort(..., class = "dz_invalid_scopes")`) so tests can check *which* error was thrown, not the exact wording.
