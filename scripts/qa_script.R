#QA
library(here)
library(config)
library(odbc)
library(DBI)
library(tidyverse)

dz <- config::get(file = 'connections/dinozodiac.yml')

con <- DBI::dbConnect(odbc::odbc(),
                      Driver = dz$dinozodiac$driver,
                      Servere = dz$dinozodiac$server,
                      UID = dz$dinozodiac$uid,
                      PWD = dz$dinozodiac$pwd,
                      Port = dz$dinozodiac$port,
                      Database = dz$dinozodiac$database
)

scopes <- dbReadTable(con, 'scopes')

glimpse(scopes)



by_date <- scopes %>%
  group_by(date, source_id) %>%
  mutate(count = 1:n()) %>%
  filter(count > 12) %>% 
  arrange(date, sign_id) %>%
  ungroup()

View(by_date)

dupes <- scopes[duplicated(scopes$scope),]
glimpse(dupes)
View(dupes$scope)

dupes

dupes_dplyr <- scopes %>%
  distinct(scope)

glimpse(dupes_dplyr)

scopes_test <- scopes %>% distinct(scope)
glimpse(scopes_test)
nrow(dupes_dplyr)
nrow(scopes)

glimpse(scopes)

nrow(scopes_test)

anti_scope <- scopes %>% anti_join(dupes, by = c("scope_id" = "scope_id"))

glimpse(anti_scope)



p_dupes <- 

dupes_text <- dupes$scope

scope_dupes <- scopes %>%
  filter(scope %in% dupes_text) %>%
  arrange(date, sign_id)
view(scope_dupes)

