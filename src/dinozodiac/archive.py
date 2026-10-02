"""Save scraped horoscopes to disk so a day's scrape is never lost.

2020 archives are .txt files of raw HTML (R/parse_archive.R reads those).
New archives are tidy CSVs: one row per horoscope.
"""

from __future__ import annotations

import csv
from collections.abc import Iterable
from datetime import date
from pathlib import Path

from dinozodiac.scrapers import Horoscope

FIELDS = ["source", "url", "sign", "date", "text"]


def archive_path(directory: Path, source: str, day: date) -> Path:
    """e.g. astrohistory/astrology.com_2026-10-02.csv (ISO dates sort correctly)."""
    return directory / f"{source}_{day.isoformat()}.csv"


def write_archive(
    horoscopes: Iterable[Horoscope], directory: Path, day: date | None = None
) -> list[Path]:
    """Write one CSV per source. Returns the paths written."""
    day = day or date.today()
    directory.mkdir(parents=True, exist_ok=True)

    by_source: dict[str, list[Horoscope]] = {}
    for h in horoscopes:
        by_source.setdefault(h.source, []).append(h)

    written = []
    for source, rows in by_source.items():
        path = archive_path(directory, source, day)
        with path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDS)
            writer.writeheader()
            writer.writerows(h.to_dict() for h in rows)
        written.append(path)
    return written
