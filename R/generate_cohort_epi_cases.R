library(tidyverse)
library(p2synthr)
library(crayon)

#-------------------------------------------------------------------------------------
#' Takes a time series of cases and stratifies into groups
#' Groups and proportions are provided as inputs
#' Makes us of the package p2synthr
#'
#' \code{generate_cohort_epi_cases} Stratify epi cases by predefined cohorts
#'
#' @param dates the times for each case
#' @param cases the case data
#' @param groups the age cohort groups
#' @param probs the probability of being in each group
#' @param setSeed allows setting of the seed for sampling
#' @param seedValue set the seed value to be used if needed
#' @return tibble with results, including original value. Each stratified group has its own column.
#' @export

generate_cohort_epi_cases <- function(dates,
                                      cases,
                                      groups=c("00-19",
                                               "20-39",
                                               "40-59",
                                               "60-79",
                                               "80-99",
                                               "100-110"),
                                      probs=c(0.15,
                                              0.20,
                                              0.20,
                                              0.25,
                                              0.15,
                                              0.05),
                                      setSeed=F, 
                                      seedValue=100){
  
  cat(green("Calling generate_cohort_epi_cases to stratify incidence by age cohort...\n"))
  cat(blue("\tGroups ",paste0(groups, collapse = "*"),"\n"))
  cat(red("\tProbs ",paste0(probs, collapse = "*"),"\n"))

  
  cases_cohort <- p2synthr::synth1(cases,
                                   group_names=groups,
                                   group_prob=probs,
                                   setSeed = setSeed,
                                   seedValue = seedValue) |>
                  dplyr::mutate(Date=dates) |>
                  dplyr::select(Date,Index,everything())
  
}
