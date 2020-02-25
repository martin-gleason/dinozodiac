library(tidyverse)
library(DBI)
library(odbc)
library(tidytext)
library(keras)
library(here)
library(tokenizers)

min_target <- 100000
preferred <- 1000000

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
  select(scope) %>%
  mutate(count = str_count(scope, "\\w+"),
         char_count = nchar(scope))

scopes_corpus <- scopes %>%
  select(scope) %>%
  pull() %>%
  str_c(collapse = " ") %>%
  tokenize_characters(lowercase = FALSE,
                      strip_non_alphanum = FALSE,
                      simplify = TRUE)

print(sprintf("Corpus length: %d", length(scopes_corpus)))


averages <- scopes %>%
  summarize(`avg words` = mean(count),
            `fewest words` = min(count),
            `most words` = max(count),
            mean_char = mean(char_count),
            min_char = min(char_count),
            max_char = max(char_count))


length(scopes_corpus)/min_target
hscope_number <- min_target/averages$mean_char
per_sign <- hscope_number * 12

