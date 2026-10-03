# 00: Check that keras3 and its TensorFlow backend are installed and working.
# Run it after the chores in docs/chores/. Every line should start with "OK".
# It exits non-zero on the first failure, so it also works in CI or a pre-flight check.

check <- function(label, expr) {
  result <- tryCatch(expr, error = function(e) e)
  if (inherits(result, "error")) {
    message("FAIL  ", label, "\n      ", conditionMessage(result))
    quit(status = 1, save = "no")
  }
  message("OK    ", label, if (!is.null(result)) paste0(": ", result))
  invisible(result)
}

check("R package keras3 installed", {
  if (!requireNamespace("keras3", quietly = TRUE)) {
    stop("Not installed. See docs/chores/CH-01-install-keras-tensorflow.md")
  }
  as.character(utils::packageVersion("keras3"))
})

check("R package reticulate installed",
      as.character(utils::packageVersion("reticulate")))

check("using the keras Python environment", {
  source(here::here("R", "model_helpers.R"))
  if (!use_keras_env()) stop("No 'r-keras' virtualenv (or DZ_KERAS_ENV) found")
  Sys.getenv("DZ_KERAS_ENV", "r-keras")
})

check("Python found by reticulate", {
  cfg <- reticulate::py_config()
  paste(cfg$version, "at", cfg$python)
})

check("Python module tensorflow importable", {
  tf <- reticulate::import("tensorflow")
  tf$`__version__`
})

check("keras backend is tensorflow", {
  backend <- keras3::config_backend()
  if (backend != "tensorflow") stop("Backend is '", backend, "', expected 'tensorflow'")
  backend
})

check("tiny LSTM trains and predicts", {
  set.seed(42)
  x <- array(stats::runif(8 * 5 * 3), dim = c(8, 5, 3))
  y <- diag(3)[sample(1:3, 8, replace = TRUE), ]
  model <- keras3::keras_model_sequential(input_shape = c(5, 3)) |>
    keras3::layer_lstm(4) |>
    keras3::layer_dense(3, activation = "softmax")
  keras3::compile(model, loss = "categorical_crossentropy", optimizer = "rmsprop")
  keras3::fit(model, x, y, epochs = 1, verbose = 0)
  preds <- stats::predict(model, x, verbose = 0)
  if (!isTRUE(all.equal(rowSums(preds), rep(1, 8), tolerance = 1e-4))) {
    stop("Predictions are not probabilities")
  }
  paste(paste(dim(preds), collapse = "x"), "predictions")
})

check("GPU devices visible to TensorFlow (0 is fine on a CPU-only Mac)", {
  tf <- reticulate::import("tensorflow")
  length(tf$config$list_physical_devices("GPU"))
})

message("\nAll checks passed. scripts/05_train_model.R is ready to run.")
