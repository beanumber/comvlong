test_that("boston_pd_1120 works", {
  expect_s3_class(boston_pd_1120, "tbl_df")
  expect_s3_class(boston_pd_1120, "data.frame")
  expect_equal(nrow(boston_pd_1120), 328141)
  expect_equal(ncol(boston_pd_1120), 45)
})
