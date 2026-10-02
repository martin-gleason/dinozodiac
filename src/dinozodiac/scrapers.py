"""Fetch and parse daily horoscopes from astrology.com and horoscope.com.

Design rule: *fetching* (network) and *parsing* (pure functions on HTML strings)
are kept apart. Parsers can then be tested with saved HTML and no internet.

These sites were scraped in 2020. Their HTML has almost certainly changed since,
so a live scrape may return nothing until the parsers are updated. The tests in
tests/python pin down the 2020 page structure.
"""

from __future__ import annotations

import logging
import re
from dataclasses import asdict, dataclass
from datetime import date, datetime
from pathlib import PurePosixPath
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

log = logging.getLogger(__name__)

ASTROLOGY_COM_INDEX = "https://www.astrology.com/horoscope/daily/"
HOROSCOPE_COM_PAGE = (
    "https://horoscope.com/us/horoscopes/general/"
    "horoscope-general-daily-today.aspx?sign={n}"
)
USER_AGENT = "dinozodiac/0.2 (hobby project; polite scraper)"
TIMEOUT_SECONDS = 15


@dataclass(frozen=True)
class Horoscope:
    """One horoscope for one sign on one day from one website."""

    source: str
    url: str
    sign: str
    date: date | None
    text: str

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


# --- fetching ---------------------------------------------------------------


def make_session() -> requests.Session:
    """A requests Session reuses one connection for many pages to the same site."""
    session = requests.Session()
    session.headers["User-Agent"] = USER_AGENT
    return session


def fetch_html(url: str, session: requests.Session | None = None) -> str:
    """Download a page and return its HTML. Raises on HTTP errors."""
    session = session or make_session()
    response = session.get(url, timeout=TIMEOUT_SECONDS)
    response.raise_for_status()
    return response.text


# --- parsing helpers ------------------------------------------------------------


def parse_date(raw: str) -> date | None:
    """Parse "Mar 15, 2020" or "Mar 4, 2020:". Returns None if unparseable."""
    cleaned = raw.strip().rstrip(":").strip()
    try:
        return datetime.strptime(cleaned, "%b %d, %Y").date()
    except ValueError:
        log.warning("Could not parse date %r", raw)
        return None


def _clean_text(text: str) -> str:
    """Collapse runs of whitespace and strip a leading ' - ' separator."""
    text = re.sub(r"\s+", " ", text).strip()
    return text.removeprefix("- ").strip()


# --- astrology.com --------------------------------------------------------------


def parse_astrology_com_index(
    html: str, base_url: str = ASTROLOGY_COM_INDEX
) -> list[str]:
    """Return the unique, absolute links to each sign's page, in page order.

    The 2020 scraper appended every link twice, which doubled the data from
    March 2020 on. Deduplicating here stops that from happening again.
    """
    soup = BeautifulSoup(html, "html.parser")
    main = soup.find("main")
    if main is None:
        log.warning("astrology.com index has no <main>; page layout changed?")
        return []
    links = [urljoin(base_url, a["href"]) for a in main.find_all("a", href=True)]
    return list(dict.fromkeys(links))  # dedupe, keep order


def parse_astrology_com_page(html: str, url: str) -> Horoscope:
    """Parse one sign's page, e.g. .../daily/aries.html."""
    soup = BeautifulSoup(html, "html.parser")
    paragraph = soup.find("p")
    if paragraph is None:
        raise ValueError(f"No <p> found on {url}")

    date_span = paragraph.find("span", class_="date")
    day = parse_date(date_span.get_text()) if date_span else None
    if date_span:
        date_span.extract()  # drop the date so it isn't part of the text

    sign = PurePosixPath(urlparse(url).path).stem.title()  # 'aries.html' -> 'Aries'
    return Horoscope(
        source="astrology.com",
        url=url,
        sign=sign,
        date=day,
        text=_clean_text(paragraph.get_text()),
    )


def scrape_astrology_com(session: requests.Session | None = None) -> list[Horoscope]:
    session = session or make_session()
    links = parse_astrology_com_index(fetch_html(ASTROLOGY_COM_INDEX, session))
    return [parse_astrology_com_page(fetch_html(link, session), link) for link in links]


# --- horoscope.com --------------------------------------------------------------


def parse_horoscope_com_page(html: str, url: str) -> Horoscope:
    """Parse one sign's page. The sign comes from '<h1>Aries Horoscope</h1>'."""
    soup = BeautifulSoup(html, "html.parser")
    header = soup.find("h1")
    paragraph = soup.find("p")
    if header is None or paragraph is None:
        raise ValueError(f"Missing <h1> or <p> on {url}")

    strong = paragraph.find("strong")
    day = parse_date(strong.get_text()) if strong else None
    if strong:
        strong.extract()

    return Horoscope(
        source="horoscope.com",
        url=url,
        sign=header.get_text().replace("Horoscope", "").strip(),
        date=day,
        text=_clean_text(paragraph.get_text()),
    )


def scrape_horoscope_com(session: requests.Session | None = None) -> list[Horoscope]:
    """horoscope.com numbers the signs 1 (Aries) to 12 (Pisces) in the URL."""
    session = session or make_session()
    urls = [HOROSCOPE_COM_PAGE.format(n=n) for n in range(1, 13)]
    return [parse_horoscope_com_page(fetch_html(url, session), url) for url in urls]


# --- everything ---------------------------------------------------------------


SCRAPERS = {
    "astrology.com": scrape_astrology_com,
    "horoscope.com": scrape_horoscope_com,
}


def scrape_all() -> list[Horoscope]:
    """Run every scraper. A failing site is logged and skipped, not fatal."""
    session = make_session()
    results: list[Horoscope] = []
    for name, scraper in SCRAPERS.items():
        try:
            found = scraper(session)
        except (requests.RequestException, ValueError) as err:
            log.error("Scraping %s failed: %s", name, err)
            continue
        log.info("%s: %d horoscopes", name, len(found))
        results.extend(found)
    return results
