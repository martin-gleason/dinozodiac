# 09 (Python): Retries and fakes: testing network code offline

**Goal:** `fetch_html()` gives up on the first hiccup. Make it retry
transient failures with backoff, and *prove* it works without touching the internet.

**You'll learn:** separating I/O from logic, dependency injection (passing the
session in), pytest `monkeypatch`, writing a small fake object, and logging
assertions with `caplog`.

## Tasks

1. Change `fetch_html(url, session=None, retries=3, backoff=1.0)`:
   - Retry on connection errors, timeouts, and HTTP 429/500/502/503/504.
   - **Don't** retry on 404. Retrying won't fix it.
   - Wait `backoff * 2**attempt` seconds between tries, and log a warning on each retry.
   - After the last attempt, raise the last error.
2. Make the sleep **injectable** so tests don't actually wait. A `sleep=time.sleep` parameter is one way. `monkeypatch.setattr` is another. Pick one and explain why in a comment.
3. *(Stretch)* Compare with `requests.adapters.HTTPAdapter(max_retries=urllib3.util.Retry(...))`. Which would you keep? Why?

## Tests (`tests/python/test_fetch.py`)

Write a tiny `FakeSession` class whose `.get()` returns or raises from a
scripted list, e.g. `[ConnectionError(), FakeResponse(503), FakeResponse(200, "<p>hi</p>")]`.

- It succeeds on the third try, and the fake was called 3 times.
- A 404 raises immediately (called once).
- It always fails → raises after `retries` attempts.
- The waits were `[1, 2]` (record what your fake `sleep` was called with).
- `caplog` shows a warning per retry.

## Done when

- [ ] No test touches the network. Turn off Wi-Fi and run `uv run pytest` to prove it.
- [ ] The test file runs in well under a second
- [ ] `scrape_all()` still logs and skips a site that fails after all retries

**Stuck?** `FakeResponse` only needs `.status_code`, `.text`, and a
`raise_for_status()` that raises `requests.HTTPError(response=self)` when the status is 400 or higher.
