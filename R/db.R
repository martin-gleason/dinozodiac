# Database connection. Credentials live in .env at the project root (copy
# .env.example) -- the same file the Python package reads.

#' Connect to the dinozodiac PostgreSQL database.
#'
#' Remember to `DBI::dbDisconnect(con)` when finished.
dz_connect <- function(env_file = here::here(".env")) {
  if (file.exists(env_file)) readRenviron(env_file)

  required <- c("DZ_DB_HOST", "DZ_DB_NAME", "DZ_DB_USER", "DZ_DB_PASSWORD")
  missing <- required[Sys.getenv(required) == ""]
  if (length(missing) > 0) {
    stop("Missing environment variables: ", toString(missing),
         ". Copy .env.example to .env and fill it in.", call. = FALSE)
  }

  DBI::dbConnect(
    RPostgres::Postgres(),
    host     = Sys.getenv("DZ_DB_HOST"),
    port     = as.integer(Sys.getenv("DZ_DB_PORT", "5432")),
    dbname   = Sys.getenv("DZ_DB_NAME"),
    user     = Sys.getenv("DZ_DB_USER"),
    password = Sys.getenv("DZ_DB_PASSWORD")
  )
}
