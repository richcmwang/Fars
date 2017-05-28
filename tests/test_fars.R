# This is a test file
library(testthat)
setwd("/Users/Richard/Documents/R projects/Coursera/Create Packages/Fars/inst/extdata")
expect_that(make_filename(2014), is_a("character"))
expect_that(fars_read(make_filename(2014)), is_a("data.frame"))
expect_that(fars_read_years(c(2018)), gives_warning())
expect_that(fars_summarize_years(c(2018)), throws_error())
