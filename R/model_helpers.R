# Pure helpers for the character-level LSTM in scripts/05_train_model.R.
# They don't need keras, so they can be unit tested quickly.

#' One-hot encode a vector of tokens: rows = tokens, columns = vocabulary.
one_hot <- function(tokens, vocab) {
  m <- matrix(0L, nrow = length(tokens), ncol = length(vocab))
  m[cbind(seq_along(tokens), match(tokens, vocab))] <- 1L
  m
}

#' Cut a character vector into overlapping windows of `max_length`, each paired
#' with the character that follows it.
make_sequences <- function(chars, max_length = 20, step = 3) {
  starts <- seq(1, length(chars) - max_length, by = step)
  list(
    sentence  = purrr::map(starts, \(s) chars[s:(s + max_length - 1)]),
    next_char = chars[starts + max_length]
  )
}

#' Build the x (n, max_length, vocab) and y (n, vocab) training arrays.
vectorize <- function(sequences, vocab, max_length) {
  n <- length(sequences$sentence)
  x <- array(0L, dim = c(n, max_length, length(vocab)))
  for (i in seq_len(n)) {
    x[i, , ] <- one_hot(sequences$sentence[[i]], vocab)
  }
  list(x = x, y = one_hot(sequences$next_char, vocab))
}

#' Sample the next character from model probabilities.
#'
#' Temperature < 1 plays it safe (repetitive); > 1 takes risks (weirder).
choose_next_char <- function(preds, vocab, temperature = 1) {
  preds <- exp(log(preds) / temperature)
  preds <- preds / sum(preds)
  vocab[which.max(stats::rmultinom(1, 1, preds))]
}

#' Point reticulate at the Python environment that has TensorFlow.
#'
#' `keras3::install_keras()` creates a virtualenv called "r-keras". Without this,
#' reticulate may pick up the project's uv `.venv` (which has no TensorFlow).
#' Set DZ_KERAS_ENV in .env to use a different environment name.
#' Must run before anything starts Python; once Python is up it's a no-op.
use_keras_env <- function(envname = Sys.getenv("DZ_KERAS_ENV", "r-keras")) {
  env_file <- here::here(".env")
  if (file.exists(env_file)) readRenviron(env_file) # before `envname` is evaluated
  if (reticulate::py_available(initialize = FALSE)) {
    return(invisible(FALSE))
  }
  if (!reticulate::virtualenv_exists(envname)) {
    warning("Python environment '", envname, "' not found. ",
            "See docs/chores/CH-01-install-keras-tensorflow.md", call. = FALSE)
    return(invisible(FALSE))
  }
  reticulate::use_virtualenv(envname, required = TRUE)
  invisible(TRUE)
}
