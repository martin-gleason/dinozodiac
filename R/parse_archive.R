# Parse the 2020 scrape archives in astrohistory/ into one tidy tibble.
#
# Each .txt file holds numbered records ("1:", "2:", ...) of raw HTML. The old
# version extracted every URL, every date, and every paragraph from a whole
# file *separately* and glued the vectors together, hoping they lined up. Here
# each record is parsed on its own, so a malformed record can't shift the rest.

url_pattern       <- "https?://\\S+"
site_pattern      <- "^https?://[^/]+"
astro_date        <- '(?<=<span class="date">)[^<]+?(?=:?</span>)'
horoscope_date    <- "(?<=<strong>)[^<]+(?=</strong>)"
paragraph_pattern <- "(?s)(?<=<p>).*?(?=</p>)"
header_pattern    <- "(?<=<h1>).*?(?=</h1>)"

#' Split one archive file into a character vector, one element per record.
read_records <- function(path) {
  lines <- readr::read_lines(path)
  record_number <- cumsum(stringr::str_detect(lines, "^\\d+:$"))
  records <- split(lines, record_number)
  records <- records[names(records) != "0"] # anything before "1:"
  purrr::map_chr(records, \(r) paste(r, collapse = "\n")) |>
    unname()
}

#' Strip HTML tags and squash whitespace.
clean_html_text <- function(x) {
  x |>
    stringr::str_remove_all("<[^>]+>") |>
    stringr::str_squish()
}

#' Parse one astrology.com record into a one-row tibble.
parse_astrology_com <- function(record) {
  url <- stringr::str_extract(record, url_pattern)
  paragraph <- stringr::str_extract(record, paragraph_pattern)

  tibble::tibble(
    source = "astrology.com",
    url    = url,
    sign   = url |>
      basename() |>
      stringr::str_remove("\\.html$") |>
      stringr::str_to_title(),
    date   = as.Date(stringr::str_extract(paragraph, astro_date), "%b %d, %Y"),
    scope  = paragraph |>
      stringr::str_remove('<span class="date">.*?</span>') |>
      clean_html_text()
  )
}

#' Parse one horoscope.com record into a one-row tibble.
parse_horoscope_com <- function(record) {
  paragraph <- stringr::str_extract(record, paragraph_pattern)

  tibble::tibble(
    source = "horoscope.com",
    url    = stringr::str_extract(record, url_pattern),
    sign   = stringr::str_extract(record, header_pattern) |>
      stringr::str_remove("Horoscope") |>
      stringr::str_trim(),
    date   = as.Date(stringr::str_extract(paragraph, horoscope_date), "%b %d, %Y"),
    scope  = paragraph |>
      stringr::str_remove("<strong>.*?</strong>") |>
      clean_html_text() |>
      stringr::str_remove("^- ")
  )
}

#' Parse one archive file. The parser is chosen from the file name.
parse_archive_file <- function(path) {
  parser <- switch(
    stringr::str_extract(basename(path), "^[a-zA-Z]+"),
    astrologyCom  = parse_astrology_com,
    hororscopecom = parse_horoscope_com,
    stop("Don't know how to parse ", basename(path), call. = FALSE)
  )
  read_records(path) |>
    purrr::map(parser) |>
    purrr::list_rbind() |>
    dplyr::mutate(file = basename(path))
}

#' Read every legacy archive in a directory into one tibble.
#'
#' Exact duplicate horoscopes are dropped: the 2020 astrology.com scraper
#' saved every sign twice from 2020-03-01 onward.
read_legacy_archive <- function(dir = here::here("astrohistory")) {
  paths <- list.files(dir, pattern = "\\.txt$", full.names = TRUE)
  if (length(paths) == 0) stop("No .txt archives in ", dir, call. = FALSE)

  paths |>
    purrr::map(parse_archive_file) |>
    purrr::list_rbind() |>
    dplyr::distinct(source, sign, date, scope, .keep_all = TRUE)
}

#' Turn parsed archives into the three database tables: signs, sources, scopes.
build_tables <- function(raw) {
  signs <- build_signs()

  sources <- raw |>
    dplyr::distinct(url = stringr::str_extract(url, site_pattern)) |>
    dplyr::mutate(source_id = dplyr::row_number(), .before = url)

  scopes <- raw |>
    dplyr::mutate(site = stringr::str_extract(url, site_pattern)) |>
    dplyr::left_join(sources, by = dplyr::join_by(site == url)) |>
    dplyr::left_join(signs, by = dplyr::join_by(sign == greekname)) |>
    dplyr::arrange(date, source_id, sign_id) |>
    dplyr::mutate(scope_id = dplyr::row_number()) |>
    dplyr::select(scope_id, source_id, date, scope, sign_id)

  list(signs = signs, sources = sources, scopes = scopes)
}
