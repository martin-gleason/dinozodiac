# 08 (Python): `dinofy()` in Python: pure functions + parametrized tests

**Goal:** Port your R `dinofy()` from assignment 04 to Python, with the same
behaviour and the same test table. Then compare the two languages.

**You'll learn:** pure functions, compiled regexes, `re.sub` with a function
replacement, `pytest.mark.parametrize`, and doctests.

## Tasks

1. Create `src/dinozodiac/remix.py` with `dinofy(text: str) -> str`.
   - Build **one** compiled regex that matches any sign name with word boundaries, once, at module import time, not on every call.
   - Use `re.sub` with a *function* as the replacement, so the dinosaur is looked up from `DINO_SIGNS`.
   - Make the same case decision you made in R. They must agree.
2. Add `dinofy_many(texts: Iterable[str]) -> list[str]`. Python strings aren't vectorised the way R's are. Is a list comprehension the right tool here?
3. Put two examples in the docstring as doctests. Run them with `uv run pytest --doctest-modules src`.
4. Add `Horoscope.dino_text` (property) using `dinofy`.

## Tests (`tests/python/test_remix.py`)

Copy the table from assignment 04 into a single `@pytest.mark.parametrize` test. Python has no `NA`, so decide what `dinofy(None)` should do: raise `TypeError`, or return `None`? Pick one and test it.

## Reflect (3–5 sentences in your commit message)

Compare the R and Python versions. Which was easier to make vectorised?
Which regex flavour bit you? Which test framework did you prefer?

## Done when

- [ ] Every row of the 04 table passes in Python too
- [ ] `uv run pytest --doctest-modules src tests/python` passes
- [ ] The regex is compiled once (check that `re.compile` isn't inside the function)

**Stuck?** `re.compile(r"\b(" + "|".join(DINO_SIGNS) + r")\b")` and `pattern.sub(lambda m: ..., text)`
