# boston pd data
test_that("boston_pd_1120 works", {
  expect_s3_class(bpd_offenses_20, "tbl_df")
  expect_s3_class(bpd_offenses_20, "data.frame")
  expect_equal(nrow(bpd_offenses_20), 42993)
  expect_equal(ncol(bpd_offenses_20), 44)
})
# court codes
test_that("court_codes works", {
  expect_s3_class(court_codes, "data.frame")
  expect_equal(nrow(court_codes), 174)
  expect_equal(ncol(court_codes), 2)
})