test_that("there are 12 signs and 12 different dinosaurs", {
  signs <- build_signs()
  expect_equal(nrow(signs), 12)
  expect_equal(anyDuplicated(signs$dinoname), 0)
  expect_equal(signs$sign_id, 1:12)
})

test_that("to_dino is vectorised and forgiving about case", {
  expect_equal(to_dino(c("leo", " Aries ")), c("Tyrannosaurus Rex", "Allosaurus"))
  expect_true(is.na(to_dino("Ophiuchus")))
})
