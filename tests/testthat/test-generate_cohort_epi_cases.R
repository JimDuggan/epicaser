test_that("Testing generate cohort epi cases", {
  cases <- generate_epi_cases(Poisson = FALSE,RF = .3,N = 100000,I0 = 10,seed = T)
  cases_age <- generate_cohort_epi_cases(cases$Date,cases$Cases)
  expect_equal(sum(apply(cases_age[,4:9],1,sum)), sum(cases_age$Input))
})
