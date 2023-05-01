# boston pd data
test_that("boston_pd_1120 works", {
  expect_s3_class(boston_pd_1120, "tbl_df")
  expect_s3_class(boston_pd_1120, "data.frame")
  expect_equal(nrow(boston_pd_1120), 194462)
  expect_equal(ncol(boston_pd_1120), 44)
})
# court codes
test_that("court_codes works", {
  expect_s3_class(court_codes, "data.frame")
  expect_equal(nrow(court_codes), 174)
  expect_equal(ncol(court_codes), 2)
})