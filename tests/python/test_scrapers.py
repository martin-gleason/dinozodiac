from datetime import date

from dinozodiac.scrapers import (
    parse_astrology_com_index,
    parse_astrology_com_page,
    parse_date,
    parse_horoscope_com_page,
)


def test_parse_date_handles_trailing_colon():
    assert parse_date("Mar 4, 2020:") == date(2020, 3, 4)


def test_parse_date_returns_none_for_garbage():
    assert parse_date("yesterday-ish") is None


def test_index_links_are_absolute_unique_and_inside_main(read_fixture):
    links = parse_astrology_com_index(read_fixture("astrology_com_index.html"))
    assert links == [
        "https://www.astrology.com/horoscope/daily/aries.html",
        "https://www.astrology.com/horoscope/daily/taurus.html",
    ]


def test_astrology_com_page(read_fixture):
    url = "https://www.astrology.com/horoscope/daily/aries.html"
    h = parse_astrology_com_page(read_fixture("astrology_com_aries.html"), url)
    assert h.source == "astrology.com"
    assert h.sign == "Aries"
    assert h.date == date(2020, 3, 4)
    assert h.text.startswith("If you're tired")
    assert "\n" not in h.text
    assert "Mar 4" not in h.text


def test_horoscope_com_page(read_fixture):
    url = "https://horoscope.com/...?sign=2"
    h = parse_horoscope_com_page(read_fixture("horoscope_com_taurus.html"), url)
    assert h.sign == "Taurus"
    assert h.date == date(2020, 3, 15)
    assert h.text.startswith("Relationships")
