# 07 (Python): Dataclasses and round-tripping: `read_archive()`

**Goal:** `archive.write_archive()` saves `Horoscope` objects to CSV, but
nothing reads them back into Python. Write the inverse, and add a couple of
useful properties to the dataclass.

**You'll learn:** `@dataclass(frozen=True)`, properties, `@classmethod`
constructors, type hints, `csv.DictReader`, `pathlib.Path.glob`, and
round-trip testing with pytest's `tmp_path`.

## Tasks

1. In `scrapers.py`, add to `Horoscope`:
   - a `dino` **property** that returns the dinosaur for `self.sign`. Reuse `signs.to_dino`. Don't copy the dict.
   - a `word_count` property.
   - a `from_dict(cls, row: dict[str, str]) -> Horoscope` **classmethod** that turns a CSV row (all strings!) back into a `Horoscope` with a real `date`. Empty date strings become `None`.
2. In `archive.py`, write `read_archive(directory: Path) -> list[Horoscope]` that reads every `*.csv` archive, sorted by date then source.
3. Try `h.sign = "Leo"` on a Horoscope in the console. What happens, and why is that useful for data you scraped?

## Tests (`tests/python/test_archive.py`)

- **Round trip:** write a list of Horoscopes with `write_archive(..., tmp_path)`, read them back with `read_archive(tmp_path)`, and assert they're `==` to the originals. Dataclasses give you `__eq__` for free.
- `from_dict` with `date=""` gives `date is None`.
- `Horoscope(..., sign="Leo", ...).dino == "Tyrannosaurus Rex"`.
- An empty directory returns `[]`.

## Done when

- [ ] `uv run pytest` and `uv run ruff check .` both pass
- [ ] Every new function has type hints and a one-line docstring
- [ ] The round-trip test passes. (If it fails on `date`, you've found exactly why the test exists.)

**Stuck?** `date.fromisoformat("2026-01-01")`. And the archive's `.txt`
files are not CSVs, so make sure your glob only picks up `*.csv`.
