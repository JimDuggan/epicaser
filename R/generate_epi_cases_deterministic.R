library(purrr)
library(dplyr)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SIR model and Poisson/Negative Binomial
#' Staff absenteeism is proportional to the population attack rate (lambda)
#'
#' \code{generate_epi_cases_deterministic} Create synthetic case data based on SIR model (Novel Pathogen)
#'
#' @param N the population size for the SIR model (default 100000)
#' @param R0 the value for the reproduction number (default 2.0)
#' @param I0 the initial number of people infected (default 1)
#' @param RF Reporting fraction for surveillance (default 0.5)
#' @param sigma Inverse of exposure delay
#' @param gamma Inverse of infectious delay
#' @param start_time start of simulation time (default 0)
#' @param end_time end of simulation time (default 100)
#' @return res a tibble with day number and model output (cases)
#' @export

generate_epi_cases_deterministic <- function(N=100000,
                                             R0=2.0,
                                             I0=1,
                                             RF=0.5,
                                             sigma=0.5,
                               gamma=0.5,
                               start_time=0,
                               end_time=100){
  
  cat(crayon::green("Calling generate_epi_cases_deterministic to run SEIR model...\n"))
  sim <- run_sim_seir(N=N,
                      R0=R0,
                      I0=I0,
                      sigma=sigma,
                      gamma=gamma,
                      RF=RF,
                      start_time=start_time,
                      end_time=end_time)


  res <- tibble::tibble(Day=1:nrow(sim),
                        Model=sim$DI)
  
  res

}
