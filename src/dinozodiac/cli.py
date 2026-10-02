"""Command line entry point: `uv run dinozodiac --help`."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

from dinozodiac import archive, db, scrapers


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="dinozodiac", description=__doc__)
    parser.add_argument("-v", "--verbose", action="store_true", help="debug logging")
    sub = parser.add_subparsers(dest="command", required=True)

    scrape = sub.add_parser("scrape", help="scrape today's horoscopes")
    scrape.add_argument(
        "--archive-dir",
        type=Path,
        default=Path("astrohistory"),
        help="where to save CSV archives (default: astrohistory)",
    )
    scrape.add_argument(
        "--to-db", action="store_true", help="also append to the staging table"
    )
    return parser


def run_scrape(args: argparse.Namespace) -> int:
    horoscopes = scrapers.scrape_all()
    if not horoscopes:
        logging.error("Nothing scraped. The sites' HTML may have changed.")
        return 1

    for path in archive.write_archive(horoscopes, args.archive_dir):
        logging.info("Wrote %s", path)

    if args.to_db:
        count = db.append_to_staging(horoscopes, db.make_engine())
        logging.info("Appended %d rows to staging", count)
    return 0


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s %(name)s: %(message)s",
    )
    if args.command == "scrape":
        return run_scrape(args)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
