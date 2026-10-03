# Skipped automatically until keras3 + TensorFlow are installed
# (see docs/chores/CH-01-install-keras-tensorflow.md), so the rest of the
# suite still runs on machines without them.

test_that("keras3 can build and run the model shape used in 05_train_model.R", {
  skip_if_not_installed("keras3")
  suppressWarnings(use_keras_env())
  skip_if_not(reticulate::py_module_available("tensorflow"),
              "TensorFlow Python module not available")

  vocab <- letters[1:5]
  s <- make_sequences(rep(vocab, 10), max_length = 4, step = 2)
  v <- vectorize(s, vocab, max_length = 4)

  model <- keras3::keras_model_sequential(input_shape = c(4, length(vocab))) |>
    keras3::layer_lstm(8) |>
    keras3::layer_dense(length(vocab), activation = "softmax")
  keras3::compile(model, loss = "categorical_crossentropy", optimizer = "rmsprop")
  keras3::fit(model, v$x, v$y, epochs = 1, verbose = 0)

  preds <- stats::predict(model, v$x[1, , , drop = FALSE], verbose = 0)
  expect_equal(dim(preds), c(1, length(vocab)))
  expect_equal(sum(preds), 1, tolerance = 1e-4)
  expect_true(choose_next_char(preds, vocab, 0.5) %in% vocab)
})
