# CH-01: Install keras3 and TensorFlow

**Why:** `scripts/05_train_model.R` (the dinosaur horoscope generator) needs the
**keras3** R package. keras3 is a thin R layer over Python Keras, which runs on
**TensorFlow**. So there are three layers to install:

```
R: keras3 + reticulate  →  Python 3.x virtualenv "r-keras"  →  tensorflow + keras
```

The project's uv `.venv` is for the scraper and is deliberately separate.
Don't put TensorFlow in it.

## Steps

All in the Positron **R console**, from the project root:

1. Install the R packages (renv records them):
   ```r
   renv::install(c("keras3", "reticulate"))
   ```
2. Create the Python environment with TensorFlow:
   ```r
   keras3::install_keras(backend = "tensorflow")
   ```
   This makes a virtualenv called `r-keras` under `~/.virtualenvs/`. If no
   suitable Python exists, it will offer to download one. Say yes. The download is
   several hundred MB, so expect a few minutes.
3. **Restart R** (Positron: Session → Restart R Session). reticulate binds to one
   Python per R session, and you want a fresh one.
4. Copy the new line from `.env.example` into your `.env`:
   ```
   DZ_KERAS_ENV=r-keras
   ```
   `use_keras_env()` in `R/model_helpers.R` reads this, so reticulate uses
   `r-keras` and not the project's `.venv`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `install_keras()` complains about the Python version | Let it install its own Python (`reticulate::install_python()`), then rerun step 2. TensorFlow lags behind the newest Python releases. |
| Python is already initialized with `.venv/bin/python` | Python started before `use_keras_env()` ran. Restart R and make sure nothing calls reticulate first. Positron's own Python session doesn't count. |
| `ModuleNotFoundError: tensorflow` | Wrong env picked up. Run `reticulate::py_config()` to see which Python it's using. It should be `~/.virtualenvs/r-keras/...`. |
| Want the Apple GPU (optional) | `reticulate::virtualenv_install("r-keras", "tensorflow-metal")`. Skip this until CPU training works. CH-02's last check shows whether it worked. |

## Done when

- [ ] `reticulate::virtualenv_exists("r-keras")` is `TRUE`
- [ ] `packageVersion("keras3")` prints a version
- [ ] `.env` has `DZ_KERAS_ENV`

Next: CH-02.
