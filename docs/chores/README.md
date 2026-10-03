# Chores

Setup and maintenance jobs. They aren't learning exercises (those are in
`docs/assignments/`), but they have to be done before something else will work.
Do them in order. Each has a **Done when** you can check.

| ID | Chore | Unblocks | Status |
|----|-------|----------|--------|
| CH-01 | [Install keras3 and TensorFlow](CH-01-install-keras-tensorflow.md) | CH-02 | ☐ |
| CH-02 | [Verify the install](CH-02-verify-keras.md) | CH-03, CH-04 | ☐ |
| CH-03 | [Lock the versions down](CH-03-pin-keras-versions.md) | reproducible installs | ☐ |
| CH-04 | [Smoke-test the model script](CH-04-smoke-test-model.md) | `scripts/05_train_model.R` | ☐ |

Tick the Status box (☐ → ☑) in this table as part of the commit that finishes each chore.

**Prerequisite:** assignment 02 (renv set up). If you do these first, that's
fine. CH-03 just has a little more to snapshot.
