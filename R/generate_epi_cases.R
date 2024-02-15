library(dplyr)
library(purrr)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SIR model and Poisson/Negative Binomial
#'
#' \code{generate_epi_cases} Create synthetic case data based on SIR model (Novel Pathogen)
#'
#' @param N the population size for the SIR model (default 100000)
#' @param R0 the value for the reproduction number (default 2.0)
#' @param I0 the initial number of people infected (default 1)
#' @param rep_fraction Reporting fraction for surveillance (default 0.5)
#' @param res_policy Whether or not to activate a simple restrictions policy (default FALSE)
#' @param res_duration Duration for restrictions (default 7)
#' @param end_time end of simulation time (default 100)
#' @param start_day YYYY-MM-DD string format for start of simulation
#' @param seed True or False for using a seed (default FALSE)
#' @param seed_val value of seed (default 100)
#' @param nb_size size parameter for negative binomial distribution (default 10)
#' @return res a tibble with day number, date, model output and cases
#' @export

generate_epi_cases <- function(N=100000,
                               R0=2.0,
                               I0=1,
                               rep_fraction=0.5,
                               res_policy=FALSE,
                               res_duration=7,
                               end_time=100,
                               start_day="2024-03-01",
                               seed=FALSE,
                               seed_val=100,
                               Poisson=TRUE,
                               nb_size=10){
  
  
  sim <- run_sim_sirm(N=N,
                      R0=R0,
                      I0=I0,
                      rep_fraction=rep_fraction,
                      res_policy=res_policy,
                      res_duration=res_duration,
                      end_time=end_time)

  if(seed)
    set.seed(seed_val)

  if(Poisson)
     syn_cases <- purrr::map_dbl(sim$DI,~rpois(1,lambda = .x))
  else
     syn_cases <- purrr::map_dbl(sim$DI,~rnbinom(1,mu=.x,size=nb_size))

  day_1 <- as.Date(start_day)

  res <- tibble::tibble(Day=1:length(syn_cases),
                        Date=day_1+(Day-1),
                        Model=sim$DI,
                        Cases=syn_cases)
  
  res

}
