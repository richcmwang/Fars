context("test Fars functions")

test_that("test Fars functions",  {
  expect_that(make_filename(2014), is_a("character"))
  expect_that(fars_read(make_filename(2014)), is_a("data.frame"))
  # expect_that(fars_read_years(c(2018)), gives_warning())
  # expect_that(fars_summarize_years(c(2018)), throws_error())
  # expect_that(fars_summarize_years(c(2014)), is_a("tbl_df"))

})


