astro_file <- here::here("astrohistory", "astrologyCom_03_15_2020.txt")
horo_file  <- here::here("astrohistory", "hororscopecom_03_15_2020.txt")

test_that("astrology.com records parse into clean rows", {
  rows <- parse_archive_file(astro_file)
  first <- rows[1, ]

  expect_equal(first$sign, "Aries")
  expect_equal(first$date, as.Date("2020-03-15"))
  expect_match(first$scope, "^If you're tired")
  expect_no_match(rows$scope, "<|>") # no leftover HTML
  expect_false(anyNA(rows$date))
})

test_that("the doubled astrology.com records collapse to 12 after distinct()", {
  rows <- parse_archive_file(astro_file)
  expect_equal(nrow(rows), 24) # the 2020 bug: every sign saved twice
  expect_equal(nrow(dplyr::distinct(rows, sign, date, scope)), 12)
})

test_that("horoscope.com records parse into clean rows", {
  rows <- parse_archive_file(horo_file)

  expect_equal(nrow(rows), 12)
  expect_equal(rows$sign, names(dino_signs))
  expect_true(all(rows$date == as.Date("2020-03-15")))
  expect_match(rows$scope[2], "^Relationships with others")
})

test_that("unknown files are an error, not silent garbage", {
  expect_error(parse_archive_file("astrohistory/mystery_01_01_2020.txt"),
               "Don't know how to parse")
})
