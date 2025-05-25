test_that("Test epi case list", {
  cases <- generate_epi_cases(Poisson = FALSE,RF = .3,N = 100000,I0 = 10,seed = T)
  cases_age <- generate_cohort_epi_cases(cases$Date,cases$Cases)
  epi_cases <- generate_epi_case_list(cases_age)
  expect_equal(sum(epi_cases$Age == 5), 191)
})
