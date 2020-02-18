#idytext and modeling
library(tidyverse)
library(DBI)
library(odbc)
library(tidytext)
library(keras)
library(here)
library(tokenizers)


#install_keras(method = "conda")
dz <- config::get(file = 'connections/dinozodiac.yml')

con <- DBI::dbConnect(odbc::odbc(),
                      Driver = dz$dinozodiac$driver,
                      Servere = dz$dinozodiac$server,
                      UID = dz$dinozodiac$uid,
                      PWD = dz$dinozodiac$pwd,
                      Port = dz$dinozodiac$port,
                      Database = dz$dinozodiac$database
)

max_length <- 44

scopes_text <- dbReadTable(con, "scopes") %>%
  select(horoscope) %>%
  pull() %>%
  str_c(collapse = " ") %>%
  tokenize_characters(lowercase = FALSE,
                      strip_non_alphanum = FALSE,
                      simplify = TRUE)
  
chars <- scopes_text %>%
  unique() %>%
  sort()

q
dinoset <- map(
  seq(1, length(scopes_text) - max_length -1, by = 3),
  ~list(sentence = scopes_text[.x:(.x + max_length - 1)],
        next_char = scopes_text[.x + max_length])
)

dinoset <- transpose(dinoset)

vectorize <- function(data, chars, max_length){
  x <- array(0, dim = c(length(data$sentence), 
                        max_length, length(chars)))
  y <- array(0, dim = c(length(data$sentence), length(chars)))

  for(i in 1:length(data$sentence)){
    x[i,,] <- sapply(chars, function(x){
      as.integer((x == data$sentence[[i]]))
    })
    y[i,] <- as.integer(chars == data$next_char[[i]])
  }
  
  list(y = y,
       x = x)
  }

vectors <- vectorize(dinoset, chars, max_length)
