# 01: Positron + Python workspace

**Goal:** Open the project in Positron with the project's own Python
environment. Run and debug the tests from the editor.

**You'll learn:** what `uv` and a `.venv` are, how Positron picks an
interpreter, workspace settings, Test Explorer, and breakpoints.

## Tasks

1. **Build the environment.** In Positron's terminal, run `uv sync`. Then answer in your notes:
   - What did it create? (`ls -a`)
   - What is `uv.lock` for, and how is it different from `pyproject.toml`?
   - Why does `.python-version` say 3.13 when `python3 --version` on your Mac says 3.14?
2. **Select the interpreter.** Use Positron's interpreter/session picker (top right) to start a Python session from `.venv`, not Homebrew's Python. In the console, run `import dinozodiac; dinozodiac.to_dino("Leo")`.
3. **Install extensions.** Install the **Ruff** extension from the Extensions view.
4. **Write `.vscode/settings.json`** (workspace settings, committed to git) so that:
   - pytest is the test framework
   - Python files format with Ruff on save
   - Ruff organizes imports on save

   Find the setting names by searching the Settings UI (Cmd+,). The gear icon on each setting has "Copy Setting ID".
5. **Run the tests from Test Explorer** (the beaker icon). All 12 should pass.
6. **Debug a test.** Set a breakpoint inside `parse_astrology_com_page` in `src/dinozodiac/scrapers.py`. Run the `pytest` configuration from Run and Debug (it's in `.vscode/launch.json`). When it stops, use the Debug Console to inspect `paragraph` and `date_span`. Step over `date_span.extract()` and watch `paragraph` change.
7. **Break it on purpose.** Add an unused import to `cli.py` and save. Ruff should remove it. Then type a long line and see what happens on save.

## Done when

- [ ] The Positron console shows a Python session running from `.venv`
- [ ] `.vscode/settings.json` is committed, and format-on-save works for `.py` files
- [ ] Test Explorer shows 12 passing tests
- [ ] You can explain in one sentence what `date_span.extract()` does to the soup (you saw it in the debugger)

**Stuck?** If Positron doesn't list `.venv`, check that `uv sync` finished.
Then use the picker's option to discover interpreters again, or point it at
`.venv/bin/python`.
