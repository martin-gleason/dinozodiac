# testthat runs this before the tests: load the project's R functions.
for (f in list.files(here::here("R"), pattern = "\\.R$", full.names = TRUE)) {
  source(f)
}
