library(dplyr)
library(crayon)


#-------------------------------------------------------------------------------------
#' Takes the case line list and updates with hospitalisation information
#'
#' \code{generate_hospital_arrivals} Generates arrival timestamps for patients
#'
#' @param epi_cases A tibble containing the case list of reported cases
#' @param h_risk A tibble that has the hospitalisation risk profiles for each age group
#' @param time_to_admit_mean The average time between diagnosis and admission to hospital
#' @param time_to_admit_sd The standard deviation for the average time
#' @param sources A vectors showing where the patient has come from before arriving at the hospital
#' @param source_prob The probability of each sourcing option
#' @param gender Gender of the patient
#' @param gender_prob Probability of each gender option
#' @param set_seed allows setting of the seed for sampling
#' @param seed_val set the seed value to be used if needed
#' @return hosp_cases A tibble with all hospitalisation data
#' @export


generate_hospital_arrivals <- function(
                    epi_cases,
                    h_risk=dplyr::tibble(AgeL=c(0,30,70),
                                         AgeU=c(30,70,111),
                                         HRisk=c(0.03,0.08,0.15)),
                    time_to_admit_mean=7,
                    time_to_admit_sd=2.1,
                    sources=c("Own living environment","Other facility"),
                    source_prob=c(.80,.20),
                    gender=c("M","F"),
                    gender_prob=c(0.49,0.51),    
                    set_seed=FALSE,
                    seed_val=100){
  
  if(set_seed == TRUE) set.seed(seed_val)
  
  cat(crayon::green("Calling generate_hospitalisation_data to generate synthetic arrival records...\n"))
  cat(crayon::blue("Hospital Risk information\n"))
  cat(crayon::red("\tAge Lower ",paste0(h_risk$AgeL, collapse = "*"),"\n"))
  cat(crayon::red("\tAge Upper ",paste0(h_risk$AgeU, collapse = "*"),"\n"))
  cat(crayon::red("\tHospitalisation Risks ",paste0(h_risk$HRisk, collapse = "*"),"\n"))
  
  cat(crayon::blue("Processing Updates...\n"))
          
  counter <- 1 
  cat(crayon::red("\t Processing EPI case",counter,"...\n"))
  get_risk <- function(age){
    if(counter %% 2500 == 0)
       cat(crayon::red("\t Processing EPI case",counter,"...\n"))
    counter <<- counter + 1
    dplyr::filter(h_risk,age>=AgeL,age<AgeU) %>% dplyr::pull(HRisk)
  }
  
  hosp_cases <- epi_cases %>%
                 dplyr::rowwise() %>%
                 dplyr::mutate(HRisk=get_risk(Age),
                        Hospitalised=as.logical(stats::rbinom(1,1,HRisk)),
                        TimeToAdmit=as.integer(ifelse(Hospitalised,stats::rnorm(1,
                                                              time_to_admit_mean,
                                                              time_to_admit_sd),NA)),
                        DateAdmitted=as.Date(ifelse(Hospitalised,Date+TimeToAdmit,NA)),
                        Source=ifelse(Hospitalised,sample(sources,1,prob=source_prob),NA),
                        Gender=ifelse(Hospitalised,sample(gender,1,prob=gender_prob),NA),) %>%
                dplyr::rename(DateTestedPositive=Date) %>%
                dplyr::filter(Hospitalised==TRUE)

  
  hosp_cases <- hosp_cases %>%
                  dplyr::mutate(TimeAdmitted=generate_timestamp(DateAdmitted)) %>%
                  dplyr::select(CaseID,Source,DateAdmitted,TimeAdmitted,Age,Gender,dplyr::everything()) %>%
                  dplyr::select(-c(Hospitalised,TimeToAdmit)) %>%
                  dplyr::ungroup()

  
  prop_h <- round(nrow(hosp_cases)/nrow(epi_cases),3)
  cat(crayon::blue("Completed hospital arrivals generation...\n"))
  cat(crayon::blue("Epi Cases= ",nrow(epi_cases),"Hospital Cases = ",nrow(hosp_cases),"Prop = ",prop_h,"\n"))
  
  hosp_cases
}