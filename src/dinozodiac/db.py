"""PostgreSQL connection settings and writes.

Credentials come from environment variables, usually loaded from a `.env`
file at the project root (copy `.env.example`). The R scripts read the same file.
"""

from __future__ import annotations

import os
from collections.abc import Iterable

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import URL, Engine, create_engine

from dinozodiac.scrapers import Horoscope

REQUIRED_VARS = ["DZ_DB_HOST", "DZ_DB_NAME", "DZ_DB_USER", "DZ_DB_PASSWORD"]


def database_url() -> URL:
    """Build the connection URL from DZ_DB_* environment variables."""
    load_dotenv()  # no-op if there is no .env file
    missing = [name for name in REQUIRED_VARS if not os.environ.get(name)]
    if missing:
        raise RuntimeError(
            f"Missing environment variables: {', '.join(missing)}. "
            "Copy .env.example to .env and fill it in."
        )
    # URL.create escapes special characters in passwords; string formatting doesn't.
    return URL.create(
        "postgresql+psycopg",
        username=os.environ["DZ_DB_USER"],
        password=os.environ["DZ_DB_PASSWORD"],
        host=os.environ["DZ_DB_HOST"],
        port=int(os.environ.get("DZ_DB_PORT", "5432")),
        database=os.environ["DZ_DB_NAME"],
    )


def make_engine() -> Engine:
    return create_engine(database_url())


def to_frame(horoscopes: Iterable[Horoscope]) -> pd.DataFrame:
    return pd.DataFrame([h.to_dict() for h in horoscopes])


def append_to_staging(
    horoscopes: Iterable[Horoscope], engine: Engine, table: str = "staging"
) -> int:
    """Append rows to the staging table. Returns the number of rows written."""
    frame = to_frame(horoscopes)
    frame.to_sql(table, engine, if_exists="append", index=False)
    return len(frame)
