library(tidyverse)
library(crayon)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SIR model and Poisson/Negative Binomial
#' Staff absenteeism is proportional to the population attack rate (lambda)
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
#' @param staff_per_100K number of staff resources per 100K of population
#' @param staff_recovery_delay average recovery time for absent staff
#' @param staff_absenteeism average absenteeism rate for staff
#' @return res a tibble with day number, date, model output, cases, and available staff
#' @export

generate_epi_cases <- function(N=100000,
                               R0=2.0,
                               I0=1,
                               rep_fraction=0.5,
                               res_policy=FALSE,
                               res_duration=7,
                               end_time=100,
                               start_day="2025-03-01",
                               seed=FALSE,
                               seed_val=100,
                               Poisson=TRUE,
                               nb_size=10,
                               staff_per_100K=1200,
                               staff_recovery_delay=6,
                               staff_absenteeism=0.02){
  
  
  cat(green("Calling generate_epi_cases to run SIR model and generate data...\n"))
  sim <- run_sim_sirm(N=N,
                      R0=R0,
                      I0=I0,
                      rep_fraction=rep_fraction,
                      res_policy=res_policy,
                      res_duration=res_duration,
                      end_time=end_time,
                      staff_per_100K=staff_per_100K,
                      staff_recovery_delay=staff_recovery_delay,
                      staff_absenteeism=staff_absenteeism)

  if(seed)
    set.seed(seed_val)

  if(Poisson)
     syn_cases <- purrr::map_dbl(sim$DI,~rpois(1,lambda = .x))
  else
     syn_cases <- purrr::map_dbl(sim$DI,~rnbinom(1,mu=.x,size=nb_size))
  
  syn_available_staff <- purrr::map_dbl(sim$AS,~rpois(1,lambda = .x))
  


  day_1 <- as.Date(start_day)

  res <- tibble::tibble(Day=1:length(syn_cases),
                        Date=day_1+(Day-1),
                        Model=sim$DI,
                        Cases=syn_cases,
                        AvailableStaff=syn_available_staff,
                        Model_Available_Staff=sim$AS,
                        Model_Unavailable_Staff=sim$UAS)

  
  res

}
