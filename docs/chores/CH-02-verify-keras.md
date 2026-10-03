# CH-02: Verify the install

**Why:** "It installed without errors" doesn't mean "it works." This chore runs
the real thing end to end: a tiny model trains and predicts.

## Steps

1. From a terminal at the project root:
   ```sh
   Rscript scripts/00_check_keras.R
   ```
   Every line should start with `OK`. The script stops at the first `FAIL` and
   tells you why. Fix that, go back to CH-01 if needed, and rerun.

   Expected output (versions will differ):
   ```
   OK    R package keras3 installed: 1.x.x
   OK    R package reticulate installed: 1.x.x
   OK    using the keras Python environment: r-keras
   OK    Python found by reticulate: 3.x at ~/.virtualenvs/r-keras/bin/python
   OK    Python module tensorflow importable: 2.x.x
   OK    keras backend is tensorflow: tensorflow
   OK    tiny LSTM trains and predicts: 8x3 predictions
   OK    GPU devices visible to TensorFlow (0 is fine on a CPU-only Mac): 0
   ```
2. Run the test suite. The keras test, which used to show as **SKIP**, should now pass:
   ```r
   testthat::test_dir("tests/testthat")
   # [ FAIL 0 | WARN 0 | SKIP 0 | PASS 29 ]
   ```
3. Write down the versions from step 1. You'll need them in CH-03.

## Done when

- [ ] `00_check_keras.R` prints all `OK` and exits with status 0 (`echo $?`)
- [ ] testthat reports **SKIP 0**

Next: CH-03.
