library(tidyverse)
library(DBI)
library(odbc)
library(tidytext)
library(keras)
library(here)
library(tokenizers)

dz <- config::get(file = 'connections/dinozodiac.yml')

con <- DBI::dbConnect(odbc::odbc(),
                      Driver = dz$dinozodiac$driver,
                      Servere = dz$dinozodiac$server,
                      UID = dz$dinozodiac$uid,
                      PWD = dz$dinozodiac$pwd,
                      Port = dz$dinozodiac$port,
                      Database = dz$dinozodiac$database
)

scopes <- dbReadTable(con, "scopes") %>%
  select(horoscope) %>%
  mutate(count = str_count(horoscope, "\\w+"),
         char_count = nchar(horoscope))

scopes_corpus <- scopes %>%
  select(horoscope) %>%
  pull() %>%
  str_c(collapse = " ") %>%
  tokenize_characters(lowercase = FALSE,
                      strip_non_alphanum = FALSE,
                      simplify = TRUE)


averages <- scopes %>%
  summarize(mean = mean(count),
            min = min(count),
            max = max(count),
            mean_char = mean(char_count),
            min_char = min(char_count),
            max_char = max(char_count))


print(sprintf("Corpus length: %d", length(scopes_text)))