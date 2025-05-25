test_that("Test Cohort Creation", {

  cases <- c(10,20,30,40,50)
  
  cases_d <- synth1(cases,
                    group_names = c("A","B"),
                    group_prob  = c(0.5,0.5),
                    setSeed=T,
                    seedValue=99)
  
  expect_equal(sum(cases_d$A+cases_d$B == cases), length(cases))
})
