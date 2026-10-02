# 05 (R): Tidy evaluation: `sentiment_by()`

**Goal:** The old `scope_analysis.R` had a hard-coded `tidy_cancer`,
`cancer_positive`, and `cancer_joy`, plus the comment *"next version use quo
and !! to make more robust."* This is that next version. Modern tidy eval uses
`{{ }}` and `...`, not `quo()` and `!!`.

**You'll learn:** writing dplyr-style functions that take bare column names,
`{{ }}` ("embrace"), passing `...` through, and returning ggplot objects from functions.

## Tasks

Create `R/sentiment.R` with:

1. `tokenize_scopes(scopes)`: one row per word, stop words removed. Pull this out of `04_sentiment.R`.
2. `sentiment_by(words, ..., lexicon = c("bing", "afinn"))`
   - `...` are bare grouping columns: `sentiment_by(words, dinoname)`, `sentiment_by(words, date, dinoname)`, `sentiment_by(words)` (overall).
   - `lexicon` is checked with `rlang::arg_match()`. Read about why that beats `match.arg()`.
   - Returns one row per group with `positive`, `negative`, `net` columns for bing. For afinn, return the summed `value` as `net`. (afinn needs the `textdata` package. It will ask to download once.)
3. `plot_sentiment(sentiment, x, facet = NULL)`: `x` is a bare column, and `facet` is optional. Returns the ggplot. Doesn't print or save it.
4. Rewrite `scripts/04_sentiment.R` to use these. It should get *shorter*.
5. **Bug hunt:** run the current `04_sentiment.R` and look at the most common
   negative words. "cancer" is in the top 10, so every Cancer horoscope scores more
   negative than it should. Fix it inside `tokenize_scopes()`: drop sign names
   (all 12, from `dino_signs`) before the sentiment join. Then check how much the
   Ankylosaurus panel changes.
6. Replace the deleted Cancer analysis with one line: which dinosaur has the most positive horoscopes overall?

## Done when

- [ ] `sentiment_by(words, dinoname)` and `sentiment_by(words, date, dinoname)` both work
- [ ] `sentiment_by(words, lexicon = "nrc")` gives a helpful error naming the valid choices
- [ ] Tests check the column names of the result and that `net == positive - negative`
- [ ] "cancer" no longer appears in the negative-word counts
- [ ] `plot_sentiment()` is tested with `expect_s3_class(p, "ggplot")`

**Stuck?** Inside `sentiment_by()`, `dplyr::group_by(...)` just works: `...`
passes straight through. `{{ }}` is for when you have one named argument:
`aes(x = {{ x }})`.
