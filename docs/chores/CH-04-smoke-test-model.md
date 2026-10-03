# CH-04: Smoke-test the model script

**Why:** `scripts/05_train_model.R` was modernized to the keras3 API but has
never been run (see `docs/plans/2026-10-modernization.md`, "Not verified").
Before a long training run, make sure the whole script works on a tiny budget.

## Steps

1. Make sure `data/processed/scopes.csv` exists (run `scripts/01_parse_archive.R`).
2. In `05_train_model.R`, **temporarily** set:
   ```r
   max_sequences <- 2000
   ```
   Also change the training loop from `1:4` to `1:1`, and generate 50 characters instead of 400.
   Don't commit these values.
3. Run it line by line in Positron. Watch:
   - the shapes of `vectors$x` and `vectors$y` in the Variables pane. They should be `2000 × 20 × <vocab>` and `2000 × <vocab>`.
   - the training progress output from `fit()`
   - the generated text. Expect gibberish this early. You're checking that it *runs*, not that it's good.
4. Time a real epoch: restore the 400 characters, keep `1:1`, set
   `max_sequences <- 50000`, and time it with `system.time()`. Write the number down.
5. Fix anything that breaks, in its own commit. The keras3 port is the most likely
   culprit, especially `predict()` and the `dim(x) <- c(1, dim(x))` reshape.
6. Revert the temporary values and update `docs/plans/2026-10-modernization.md`:
   move `05_train_model.R` out of "Not verified" and note the epoch time and
   whether a GPU was used.

## Done when

- [ ] The smoke run finishes and writes `output/scopes_<date>.csv`
- [ ] The plan doc records the per-epoch time at 50k sequences
- [ ] `git diff scripts/05_train_model.R` shows only real fixes, not the smoke-test settings
