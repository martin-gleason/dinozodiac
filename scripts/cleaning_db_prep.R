#cleaning and saving to df
library(tidyverse)
library(here)

url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
date_pattern <- "(?<=<span class=date>)(.*?)(?=:)"
paragraph_pattern <- "(?<=<p>)(.*?)(?=</p>)"


astrology <- read.delim("astrohistory/astrologyCom_02_12_2020.txt")

source <- astrology$X1. %>% str_extract(url_pattern) %>%
  na.omit()

date <- str_extract(astrology$X1., date_pattern) %>%
  na.omit() %>%
  as.Date.character("%b %d, %Y")

scope <- str_extract(astrology$X1., paragraph_pattern) %>% 
  str_remove("<span class=date>(.*?)</span>") %>% 
  str_trim() %>%
  na.omit()

sign <- basename(source) %>% 
  str_remove(".html") %>% 
  str_to_title()


astrology_df <- tibble(source, date, scope, sign)


View(astrology_df)

