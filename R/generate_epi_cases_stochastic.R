library(purrr)
library(dplyr)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SIR model and Poisson/Negative Binomial
#' Staff absenteeism is proportional to the population attack rate (lambda)
#'
#' \code{generate_epi_cases_stochastic} Create synthetic case data based on model input
#'
#' @param model_cases Output from the infectious disease model
#' @param start_day YYYY-MM-DD string format for start of simulation
#' @param seed True or False for using a seed (default FALSE)
#' @param seed_val value of seed (default 100)
#' @param Poisson Signifies whether to use the Poisson distribution synthetic data creation
#' @param nb_size size parameter for negative binomial distribution (default 10)
#' @return res a tibble with day number, date, model output, cases, and available staff
#' @export

generate_epi_cases_stochastic <- function(model_cases,
                                          start_day="2026-09-24",
                                          seed=FALSE,
                                          seed_val=100,
                                          Poisson=TRUE,
                                          nb_size=10){

  cat(crayon::green("Calling generate_epi_cases_stochastic to generate data...\n"))

  if(seed)
    set.seed(seed_val)

  if(Poisson)
     syn_cases <- purrr::map_dbl(model_cases$Cases,~rpois(1,lambda = .x))
  else
     syn_cases <- purrr::map_dbl(model_cases$Cases,~rnbinom(1,mu=.x,size=nb_size))
  
  day_1 <- as.Date(start_day)

  res <- tibble::tibble(Date=day_1+(model_cases$Day-1),
                        Cases=syn_cases)

  
  res

}
