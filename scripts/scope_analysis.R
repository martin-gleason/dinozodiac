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

#creating tables signs and horoscopes aka scopes
signs <- dbReadTable(con, "signs")

#corpus of horoscopes
scopes <- dbReadTable(con, "scopes") %>%
  select(scope) %>%
  mutate(count = str_count(scope, "\\w+"),
         char_count = nchar(scope))

glimpse(scopes)

#character corpus
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


#Analysis

dino_scopes_full <- dbReadTable(con, "scopes") %>%
  left_join(signs, by = c("sign_id" = "sign_id"))

#for analyzing horoscopes.com
dino_h <- dino_scopes_full %>%
  filter(source_id == 1)

#for astrology.net
dino_astrology <- dino_scopes_full %>%
  filter(source_id == 2)

#custom function for divvying up by sign
#next version use quo and !! to make more robust
by_sign <- function(df,...){
  ds <- df %>% select(sign_id) %>% 
    unique() %>% 
    max()
  list_of_signs <- vector(mode = "list", length = ds)
  list_of_signs <- split(df, f = df$sign_id)
  names(list_of_signs) <- df %>% select(greekname) %>%
    unique() %>%
    pull()
   
   return(list_of_signs)
}

