# CH-03: Lock the versions down

**Why:** renv records your *R* packages, but the TensorFlow install lives in a
Python virtualenv that renv knows nothing about. Without a record, "works on my
machine" lasts until the next `install_keras()` pulls a newer TensorFlow.

## Steps

1. **R side.** Snapshot so `renv.lock` includes keras3, reticulate, and tensorflow:
   ```r
   renv::snapshot()
   renv::status()   # should report no issues
   ```
   Check `renv.lock`: search for `"keras3"`.
2. **Python side.** Save the exact Python packages to a requirements file in the repo:
   ```r
   py <- reticulate::virtualenv_python("r-keras")
   system2(py, c("-m", "pip", "freeze"), stdout = "requirements-keras.txt")
   ```
   Open it and confirm that `tensorflow==` and `keras==` are pinned.
3. **Rebuild instructions.** Add a "Model setup" section to `README.md` that shows
   how to recreate the env from the lock file instead of whatever's newest:
   ```r
   reticulate::virtualenv_create("r-keras", requirements = "requirements-keras.txt")
   ```
   Also record the Python version (`reticulate::py_config()$version`). The pins
   only work with a matching Python.
4. **Prove it** (optional, but it's the real test): rename your env
   (`mv ~/.virtualenvs/r-keras ~/.virtualenvs/r-keras-old`), rebuild from the
   README instructions, and rerun CH-02. Delete `r-keras-old` once it passes.

## Done when

- [ ] `renv.lock` contains keras3 and reticulate
- [ ] `requirements-keras.txt` is committed, with pinned tensorflow and keras versions
- [ ] README's "Model setup" section rebuilds a working env (CH-02 passes on it)

Next: CH-04.
