test_that("Test Hospitalisations", {
  cases <- generate_epi_cases(Poisson = FALSE,RF = .3,N = 100000,I0 = 10,seed = T,seed_val = 99)
  cases_age <- generate_cohort_epi_cases(cases$Date,cases$Cases)
  epi_cases <- generate_epi_case_list(cases_age,set_seed = T)
  hosp_cases <- generate_hospitalisation_data(epi_cases,set_seed = TRUE)
  expect_equal(sum(hosp_cases$Gender=="M"), 824)
})
