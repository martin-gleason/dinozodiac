test_that("one_hot puts a single 1 in each row", {
  m <- one_hot(c("b", "a", "b"), vocab = c("a", "b", "c"))
  expect_equal(dim(m), c(3, 3))
  expect_equal(rowSums(m), c(1, 1, 1))
  expect_equal(m[1, ], c(0L, 1L, 0L))
})

test_that("make_sequences pairs each window with the next character", {
  s <- make_sequences(letters[1:10], max_length = 3, step = 2)
  expect_equal(s$sentence[[1]], c("a", "b", "c"))
  expect_equal(s$next_char[1], "d")
  expect_equal(length(s$sentence), length(s$next_char))
})

test_that("vectorize builds arrays with the right shapes", {
  s <- make_sequences(letters[1:10], max_length = 3, step = 1)
  v <- vectorize(s, letters[1:10], max_length = 3)
  expect_equal(dim(v$x), c(7, 3, 10))
  expect_equal(dim(v$y), c(7, 10))
})

test_that("choose_next_char at a very low temperature picks the favourite", {
  set.seed(1)
  picks <- replicate(20, choose_next_char(c(0.1, 0.8, 0.1), c("x", "y", "z"), 0.05))
  expect_true(all(picks == "y"))
})
