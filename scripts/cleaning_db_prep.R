#cleaning and saving to df
library(tidyverse)
library(here)

url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
date_pattern <- "(?<=<span class=date>)(.*?)(?=:)"
paragraph_pattern <- "(?<=<p>)(.*?)(?=</p>)"
strong_date_pattern <- "(?<=<strong>)(.*?)(?=</strong>)"
sign_header <- "(?<=<h1>)(.*?)(?=</.*?>)"
h_scope <- "Horoscope"
url_site <- "^(([^:/?#]+):)?(//([^/?#]*))?"


#create list of files function
data_files <- function(dir = "astrohistory", filename, sep = "/"){
  fp <- paste0(dir, sep, filename)
  list_of_files <- lapply(Sys.glob(fp), read.delim)
  return(list_of_files)
}

files <- data_files("astrohistory", "astrologyCom*.txt")

bulk_read <- function(files = files){
  source <- files %>% 
    str_extract_all(pattern = url_pattern) %>%
    unlist()
  
  date <- files %>% 
    str_extract_all(date_pattern) %>%
    unlist() %>%
    as.Date.character("%b %d, %Y")
    
  scope <- files %>% 
    str_extract_all(paragraph_pattern) %>%
    unlist() %>%
    str_remove("<span class=date>(.*?)</span>") %>% 
    str_trim() %>%
    na.omit()
  
  sign <- basename(source) %>% 
    str_remove(".html") %>% 
    str_to_title()
  
  df <- tibble(source, date, scope, sign)
  
  return(df)
}

astrology_com <- bulk_read(files)

## horoscope.com
dat <- data_files("astrohistory", "horor*.txt")



hscope <- function(files){
  
  scope <- files %>% 
    str_extract_all(paragraph_pattern) %>% 
    unlist() %>%
    na.omit()
  
  source <- files %>% 
    str_extract_all(url_pattern) %>% 
    unlist() %>%
    na.omit()
  
  date <- scope %>%
    str_extract_all(strong_date_pattern) %>%
    unlist() %>%
    as.Date.character("%b %d, %Y") %>%
    na.omit()
  
  sign <- files %>% 
    str_extract_all(sign_header) %>% 
    unlist() %>% 
    str_remove(h_scope) %>% 
    str_trim() %>%
    na.omit()
  
  scope <- scope %>%
    str_remove_all(strong_date_pattern) %>%
    str_remove("<strong>") %>%
    str_remove("</strong>") %>%
    str_remove(" - ")
  
  df <- tibble(source, date, scope, sign)
  
  return(df)
}

hororscope_com <- dat %>% hscope()

all_scopes <- hororscope_com %>% bind_rows(astrology_com)


signs_cleaned <- all_scopes$sign %>% unique()

dino_signs <- c("Allosaurus","Triceratops","Pterodactylus",
                "Ankylosaurus", "Tyrannosaurus Rex", "Brontosaurus", 
                "Rhamphorhynchus", "Spinosaurus", "Velociraptor",
               "Stegosaurus", "Quetzalcatlus", "Mosasaurus")


matched_signs <- tibble(signs_cleaned, dino_signs) %>%
  mutate(sign_id = 1:nrow(.)) %>%
  select(sign_id, greekname = signs_cleaned, dinoname = dino_signs)


 matched_signs %>% select(sign_id)


url <- all_scopes$source %>%
  str_extract(url_site) %>%
  unique()

url_id <- length(url)

sources <- url %>%
  tibble(url = .,
         sourceid = seq(1:url_id)) %>%
  select(source_id = sourceid, url)


all_scopes <- all_scopes %>%
  left_join(matched_signs, by = c("sign" = "greekname"))

all_scopes <- all_scopes %>%
  mutate(source_site = str_extract(source, url_site)) %>%
  left_join(sources, by = c("source_site" = "url")) %>%
  mutate(scope_id = 1:nrow(.)) %>%
  select(scope_id, source_id, date, scope, sign_id)

#QA
today <- all_scopes %>%
  filter(date == lubridate::today())

all_scopes$sign_id %>% unique()

write_csv(matched_signs, path = "output/matched_signs.csv")

#sigle use/learning how to do
#files <- lapply(Sys.glob("astrohistory/astrologyCom*.txt"), read.delim)
#astrology <- read.delim(file)
# source <- astrology$X1. %>% str_extract(url_pattern) %>%
#   na.omit()
# 
# date <- str_extract(astrology$X1., date_pattern) %>%
#   na.omit() %>%
#   as.Date.character("%b %d, %Y")
# 
# scope <- str_extract(astrology$X1., paragraph_pattern) %>% 
#   str_remove("<span class=date>(.*?)</span>") %>% 
#   str_trim() %>%
#   na.omit()
# 
# sign <- basename(source) %>% 
#   str_remove(".html") %>% 
#   str_to_title()
#astrology_df <- tibble(source, date, scope, sign)
