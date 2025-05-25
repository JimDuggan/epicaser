test_that("Test SEIR model", {
  res <- run_sim_seir()
  expect_equal(res$Checksum[1], 100000)
})
