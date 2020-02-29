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

allscopes <- dino_scopes_full %>% by_sign()
#token by word


bing <- get_sentiments("bing")
nrc <- get_sentiments("nrc")
nrc_sentiments <- nrc$sentiment %>% unique()
nrc_positive <- nrc %>%
  filter(sentiment == "positive")

nrc_joy <- nrc %>%
  filter(sentiment == "joy")

tidy_cancer <- allscopes$Cancer %>% 
  unnest_tokens(word, scope) %>%
  select(date, dinoname, word) %>%
  anti_join(stop_words)
  
cancer_positive <-tidy_cancer %>%
  inner_join(nrc_positive) %>%
  count(word, sort = TRUE)

cancer_joy <- tidy_cancer %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)

scope_sentiment <- dino_scopes_full %>%
  unnest_tokens(word, scope) %>%
  select(date, dinoname, word) %>%
  anti_join(stop_words) %>%
  inner_join(bing) %>%
  group_by(date)%>%
  count(word, dinoname, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

min_sentiment <- min(scope_sentiment$sentiment)
max(scope_sentiment$sentiment)

scope_sentiment %>%
  filter(sentiment == min_sentiment)

gg_scope <-scope_sentiment %>% ggplot(aes(x = date, y = sentiment, fill = dinoname)) +
  geom_bar(stat = "identity", aes(alpha = .5)) +
  facet_wrap(~dinoname)+
  theme_minimal()

View(scope_sentiment %>% count(word, sort = TRUE))

ggsave("output/scope_sentiment_eda.png", gg_scope, width = 15, height = 8.5, units = "in")
