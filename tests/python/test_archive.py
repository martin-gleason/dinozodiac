import csv
from datetime import date

from dinozodiac.archive import write_archive
from dinozodiac.scrapers import Horoscope


def test_write_archive_one_file_per_source(tmp_path):
    rows = [
        Horoscope("astrology.com", "u1", "Aries", date(2026, 1, 1), "Roar."),
        Horoscope("horoscope.com", "u2", "Leo", date(2026, 1, 1), "Stomp."),
    ]
    paths = write_archive(rows, tmp_path, day=date(2026, 1, 1))

    assert sorted(p.name for p in paths) == [
        "astrology.com_2026-01-01.csv",
        "horoscope.com_2026-01-01.csv",
    ]
    with paths[0].open() as f:
        records = list(csv.DictReader(f))
    assert records[0]["sign"] == "Aries"
    assert records[0]["date"] == "2026-01-01"
