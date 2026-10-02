# 10 (Python): Capstone: a `today` CLI command

**Goal:** Add a subcommand that prints a dino horoscope from the archive:

```sh
$ uv run dinozodiac today --sign leo
Tyrannosaurus Rex · 2020-04-14 · horoscope.com
Tyrannosaurus Rex, your energy is high today...
```

**You'll learn:** argparse subcommands and `choices`, wiring modules together,
exit codes, and testing a CLI end to end with `capsys`.

## Tasks

1. In `cli.py`, add a `today` subparser with:
   - `--sign` (required, case-insensitive). Reject unknown signs *at parse time* with a helpful list. `choices=` plus `type=str.title` is one way.
   - `--source` (optional): `astrology.com` or `horoscope.com`
   - `--archive-dir` (default `astrohistory`)
   - `--date YYYY-MM-DD` (optional, default: latest available). Use `type=date.fromisoformat`.
2. Write `run_today(args) -> int`. It uses `read_archive` (07) and `dinofy` (08). Keep the logic in a pure function, `pick_horoscope(horoscopes, sign, source=None, day=None) -> Horoscope | None`, so you can test it without the CLI.
3. Exit codes: `0` when found, `1` when there's no match. On 1, print a friendly message to **stderr** saying which dates *are* available.
4. The archive only has `.txt` files from 2020 until you run a scrape. Run `uv run dinozodiac scrape` to get today's horoscope.com CSV. (astrology.com will log a 404: its site moved. Fixing that scraper is a good bonus round.)

## Tests (`tests/python/test_cli.py`)

- `pick_horoscope` with a hand-built list: latest date wins, `source` filters, `None` when nothing matches.
- `main(["today", "--sign", "LEO", "--archive-dir", str(tmp_path)])` prints the dinosaur name (`capsys.readouterr().out`) and returns 0.
- An unknown sign raises `SystemExit` with code 2 (argparse's behaviour). Use `pytest.raises(SystemExit)`.
- No match → returns 1 and writes to stderr.

## Done when

- [ ] `uv run dinozodiac today --help` documents every option
- [ ] All tests pass, and ruff is clean
- [ ] `README.md` has a usage example for the new command
- [ ] You've merged all ten assignment branches. Archive this folder as `docs/assignments/2026-10-archive/` per the docs convention.

**Stuck?** Test `pick_horoscope` first. Once it's right, the CLI is about 15 lines of glue.
