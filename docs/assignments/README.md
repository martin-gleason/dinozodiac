# Assignments

Ten exercises built on the modernized codebase. Each one ends with a
**Done when** checklist you can verify yourself. Each one also adds real code
to the project, not a throwaway exercise.

| # | Track | Assignment | Builds on |
|---|-------|-----------|-----------|
| 01 | Positron | [Python workspace: uv, interpreter, tests, debugger](01-positron-python.md) | none |
| 02 | Positron | [R workspace: renv, console, Data Explorer, plots](02-positron-r.md) | none |
| 03 | R | [Read both archive formats](03-r-read-archives.md) | 02 |
| 04 | R | [`dinofy()`: vectorised string functions](04-r-dinofy.md) | 02 |
| 05 | R | [Tidy evaluation: `sentiment_by()`](05-r-tidy-eval.md) | 02 |
| 06 | R | [Defensive functions: `validate_scopes()`](06-r-validate.md) | 03 |
| 07 | Python | [Dataclasses and round-tripping: `read_archive()`](07-py-dataclasses.md) | 01 |
| 08 | Python | [`dinofy()` in Python: pure functions + parametrized tests](08-py-dinofy.md) | 01, 04 |
| 09 | Python | [Retries and fakes: testing network code offline](09-py-retries.md) | 01 |
| 10 | Python | [Capstone: a `today` CLI command](10-py-cli.md) | 07, 08 |

**Suggested order:** 01 → 02 → 03 → 07 → 04 → 08 → 05 → 06 → 09 → 10.
Doing 04 and 08 back to back lets you solve the same problem in both languages.

**Workflow for each one:** make a branch (`git switch -c a03-read-archives`),
write the test first if you can, make it pass, run the linters, then commit.

Ground rules:
- The answer is not in this repo. Use the hints, the docs (`?function` in R, `help()` in Python), and the existing code as a style guide.
- If you get stuck for more than 20 minutes, read the "Stuck?" hint. It's a nudge, not a solution.
