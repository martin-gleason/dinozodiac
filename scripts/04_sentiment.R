# 04: Sentiment of each dinosaur's horoscopes over time (bing lexicon).
library(tidyverse)
library(tidytext)
library(here)

signs  <- read_csv(here("data", "processed", "signs.csv"),  show_col_types = FALSE)
scopes <- read_csv(here("data", "processed", "scopes.csv"), show_col_types = FALSE) |>
  left_join(signs, by = join_by(sign_id))

# --- Corpus size: how much text do we have to train on? ---------------------
min_target <- 100000 # characters; a char-RNN wants at least this many

corpus_stats <- scopes |>
  summarise(
    n_scopes   = n(),
    avg_words  = mean(str_count(scope, "\\w+")),
    avg_chars  = mean(nchar(scope)),
    total_chars = sum(nchar(scope))
  )
print(corpus_stats)
message("Corpus is ", round(corpus_stats$total_chars / min_target, 1),
        "x the minimum target.")

# --- Sentiment ------------------------------------------------------------
bing <- get_sentiments("bing")

tidy_words <- scopes |>
  unnest_tokens(word, scope) |>
  anti_join(stop_words, by = join_by(word))

daily_sentiment <- tidy_words |>
  # a few words appear in bing as both positive and negative
  inner_join(bing, by = join_by(word), relationship = "many-to-many") |>
  count(date, dinoname, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(sentiment = positive - negative)

daily_sentiment |> slice_min(sentiment, n = 3)

gg_scope <- ggplot(daily_sentiment, aes(date, sentiment, fill = dinoname)) +
  geom_col(alpha = 0.7, show.legend = FALSE) +
  facet_wrap(vars(dinoname)) +
  labs(x = "Date of horoscope", y = "Sentiment (positive - negative words)",
       title = "Dinozodiac sentiment analysis") +
  theme_minimal()

gg_scope

ggsave(here("output", "scope_sentiment_eda.png"), gg_scope,
       width = 15, height = 8.5, units = "in")

# Most common sentiment words overall
tidy_words |>
  inner_join(bing, by = join_by(word), relationship = "many-to-many") |>
  count(word, sentiment, sort = TRUE)
