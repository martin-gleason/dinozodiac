#database
library(tidyverse)
library(config)
library(odbc)
library(DBI)
library(here)

dz <- config::get(file = 'connections/dinozodiac.yml')

con <- DBI::dbConnect(odbc::odbc(),
                      Driver = dz$dinozodiac$driver,
                      Servere = dz$dinozodiac$server,
                      UID = dz$dinozodiac$uid,
                      PWD = dz$dinozodiac$pwd,
                      Port = dz$dinozodiac$port,
                      Database = dz$dinozodiac$database
                      )



dbWriteTable(con, "signs", matched_signs, overwrite = TRUE)
dbWriteTable(con, "sources", sources, overwrite = TRUE)
dbWriteTable(con, "scopes", all_scopes, overwrite = TRUE)

