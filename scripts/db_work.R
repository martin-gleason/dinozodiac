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
max_source_number <- dbGetQuery(con, "SELECT MAX(source_id) FROM sources;")

create_source_sequence <- paste0("CREATE SEQUENCE source_range MINVALUE ", max_source_number+1, ";")
set_new_source_default <- "ALTER TABLE sources ALTER source_id SET DEFAULT nextval('source_range');"
set_source_seq_owner <- "ALTER SEQUENCE source_range OWNED BY sources.source_id;"

dbSendQuery(con, create_source_sequence)
dbSendQuery(con, set_new_source_default)
dbSendQuery(con, set_source_seq_owner)

dbWriteTable(con, "scopes", all_scopes, overwrite = TRUE)
#alter column to serial
number <- dbGetQuery(con, "SELECT MAX(scope_id) FROM scopes;")
create_sequence <- paste0("CREATE SEQUENCE scope_range MINVALUE ", number+1, ";")
set_new_default <- "ALTER TABLE scopes ALTER scope_id SET DEFAULT nextval('scope_range');"
set_seq_owner <- "ALTER SEQUENCE scope_range OWNED BY scopes.scope_id;"


dbSendQuery(con, create_sequence)
dbSendQuery(con,set_new_default)
dbSendQuery(con,set_seq_owner)
dbDisconnect(con)
