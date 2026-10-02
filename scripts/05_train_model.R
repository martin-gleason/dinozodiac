# 05: Train a character-level LSTM on the horoscopes and generate new ones.
#
# Needs keras3 plus a Python TensorFlow backend. One-time setup in the console:
# install the keras3 package, then run its install_keras() function.
# Training on a CPU is slow; start with a small `max_sequences` and 1 epoch.
library(tidyverse)
library(tokenizers)
library(keras3)
library(here)

source(here("R", "model_helpers.R"))

max_length    <- 20     # characters of context the model sees
step          <- 3      # characters between window starts
max_sequences <- 50000  # cap memory use: x is n * max_length * vocab numbers

scopes_text <- read_csv(here("data", "processed", "scopes.csv"), show_col_types = FALSE) |>
  pull(scope) |>
  str_c(collapse = " ") |>
  tokenize_characters(lowercase = FALSE, strip_non_alphanum = FALSE, simplify = TRUE)

vocab <- sort(unique(scopes_text))

sequences <- make_sequences(scopes_text, max_length, step)
keep <- head(seq_along(sequences$next_char), max_sequences)
sequences <- list(sentence = sequences$sentence[keep], next_char = sequences$next_char[keep])
vectors <- vectorize(sequences, vocab, max_length)

# --- Model -------------------------------------------------------------------
create_model <- function(vocab, max_length) {
  model <- keras_model_sequential(input_shape = c(max_length, length(vocab))) |>
    layer_lstm(128) |>
    layer_dense(length(vocab), activation = "softmax")
  model |> compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_rmsprop(learning_rate = 0.01)
  )
  model
}

generate_phrase <- function(model, text, vocab, max_length, temperature, n_chars = 400) {
  start <- sample(seq_len(length(text) - max_length), size = 1)
  sentence <- text[start:(start + max_length - 1)]
  generated <- character(n_chars)

  for (i in seq_len(n_chars)) {
    x <- one_hot(sentence, vocab)
    dim(x) <- c(1, dim(x)) # add the batch dimension
    preds <- predict(model, x, verbose = 0)
    generated[i] <- choose_next_char(preds, vocab, temperature)
    sentence <- c(sentence[-1], generated[i])
  }
  str_c(generated, collapse = "")
}

model <- create_model(vocab, max_length)

for (iteration in 1:4) {
  message(sprintf("--- iteration %02d ---", iteration))
  model |> fit(vectors$x, vectors$y, batch_size = 128, epochs = 1)
  for (temperature in c(0.5, 1)) {
    message(sprintf("temperature %.1f: %s", temperature,
                    generate_phrase(model, scopes_text, vocab, max_length, temperature)))
  }
}

# --- Save a sample of generated horoscopes ----------------------------------
capture <- tibble(temperature = rep(c(0.5, 0.9), 4)) |>
  mutate(phrase = map_chr(temperature,
                          \(t) generate_phrase(model, scopes_text, vocab, max_length, t))) |>
  arrange(temperature)

write_csv(capture, here("output", glue::glue("scopes_{Sys.Date()}.csv")))
