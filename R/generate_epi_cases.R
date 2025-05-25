library(purrr)
library(dplyr)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SIR model and Poisson/Negative Binomial
#' Staff absenteeism is proportional to the population attack rate (lambda)
#'
#' \code{generate_epi_cases} Create synthetic case data based on SIR model (Novel Pathogen)
#'
#' @param N the population size for the SIR model (default 100000)
#' @param R0 the value for the reproduction number (default 2.0)
#' @param I0 the initial number of people infected (default 1)
#' @param RF Reporting fraction for surveillance (default 0.5)
#' @param sigma Inverse of exposure delay
#' @param gamma Inverse of infectious delay
#' @param start_time start of simulation time (default 0)
#' @param end_time end of simulation time (default 100)
#' @param start_day YYYY-MM-DD string format for start of simulation
#' @param seed True or False for using a seed (default FALSE)
#' @param seed_val value of seed (default 100)
#' @param Poisson Signifies whether to use the Poisson distribution synthetic data creation
#' @param nb_size size parameter for negative binomial distribution (default 10)
#' @return res a tibble with day number, date, model output, cases, and available staff
#' @export

generate_epi_cases <- function(N=100000,
                               R0=2.0,
                               I0=1,
                               RF=0.5,
                               sigma=0.5,
                               gamma=0.5,
                               start_time=0,
                               end_time=100,
                               start_day="2025-03-01",
                               seed=FALSE,
                               seed_val=100,
                               Poisson=TRUE,
                               nb_size=10){
  
  cat(crayon::green("Calling generate_epi_cases to run SEIR model and generate data...\n"))
  sim <- run_sim_seir(N=N,
                      R0=R0,
                      I0=I0,
                      sigma=sigma,
                      gamma=gamma,
                      RF=RF,
                      start_time=start_time,
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
