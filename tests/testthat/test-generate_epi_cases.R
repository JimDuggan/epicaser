test_that("Test EPI Case Generatuion", {
  cases <- generate_epi_cases(Poisson = FALSE,RF = .3,N = 100000,I0 = 10,seed = T)
  expect_equal(sum(cases$Cases), 23417)
})
