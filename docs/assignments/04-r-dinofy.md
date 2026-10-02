# 04 (R): `dinofy()`: vectorised string functions

**Goal:** The horoscopes still say "Taurus, you're feeling social today."
Write `dinofy()` so they say "Triceratops, you're feeling social today."

**You'll learn:** vectorised functions, named vectors as lookup tables, regex
word boundaries, and edge-case-driven tests.

## Tasks

Create `R/dinofy.R` with:

```r
dinofy <- function(text) { ... }
```

- Replaces every zodiac sign name in `text` with its dinosaur, using `dino_signs` from `R/signs.R`. Don't retype the mapping.
- Is **vectorised**: `dinofy(c("Hi Leo", "Hi Aries"))` returns 2 strings, without a `for` loop.
- Handles these cases. Write each as a test *before* you write the code:

| input | expected |
|-------|----------|
| `"Leo, rest today."` | `"Tyrannosaurus Rex, rest today."` |
| `"Leonard is a Leo."` | `"Leonard is a Tyrannosaurus Rex."` (don't touch "Leonard") |
| `"aries energy"` | `"allosaurus energy"`? or `"Allosaurus energy"`? **You decide**, then document it in a comment |
| `"Cancer season"` | `"Ankylosaurus season"` (ok, but what about "cancer research"? Write down the trade-off; no need to solve it) |
| `NA` | `NA` |
| `character(0)` | `character(0)` |

Then add a `dino_text` column in `scripts/04_sentiment.R` and look at a few rows.

## Hints

- `stringr::str_replace_all()` accepts a **named vector** of `pattern = replacement`. Read `?str_replace_all`.
- The names of `dino_signs` are the patterns. How do you add `\\b` around each one?
- `stats::setNames()` is your friend.

## Done when

- [ ] `tests/testthat/test-dinofy.R` covers every row of the table, and all tests pass
- [ ] `dinofy()` has no loops and no `if` on individual elements
- [ ] A roxygen-style comment (`#'`) above the function explains the case-sensitivity choice

**Stuck?** `paste0("\\b", names(dino_signs), "\\b")`
