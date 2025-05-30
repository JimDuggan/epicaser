library(dplyr)
library(crayon)


#-------------------------------------------------------------------------------------
#' Takes the case line list and updates with hospitalisation information
#'
#' \code{generate_hospitalisation_data} Creates hospitalisation data that can be used for other modelling tasks
#'
#' @param epi_cases A tibble containing the case list of reported cases
#' @param h_risk A tibble that has the hospitalisation risk profiles for each age group
#' @param time_to_admit_mean The average time between diagnosis and admission to hospital
#' @param time_to_admit_sd The standard deviation for the average time
#' @param h_time Length of stay distribution information (normal distribution)
#' @param sources A vectors showing where the patient has come from before arriving at the hospital
#' @param source_prob The probability of each sourcing option
#' @param destinations Where the patient goes after their length of stay
#' @param destination_prob The probability of going to a destination
#' @param gender Gender of the patient
#' @param gender_prob Probability of each gender option
#' @param NL Netherlands flag, causes key fields to be renamed.
#' @param set_seed allows setting of the seed for sampling
#' @param seed_val set the seed value to be used if needed
#' @return hosp_cases A tibble with all hospitalisation data
#' @export


generate_hospitalisation_data <- function(
                  epi_cases,
                  h_risk=dplyr::tibble(AgeL=c(0,30,70),
                                AgeU=c(30,70,111),
                                HRisk=c(0.01,0.05,0.15)),
                 time_to_admit_mean=7,
                 time_to_admit_sd=2.1,
                 h_time=dplyr::tibble(AgeL=c(0,30,70),
                               AgeU=c(30,70,111),
                               Mean=c(5,10,20),
                               SD=c(1,2,5)),
                 sources=c("Home","Hospital","Other"),
                 source_prob=c(.80,.10,.10),
                 destinations=c("Home","Hospital","Death"),
                 destination_prob=c(0.85,0.13,0.02),
                 gender=c("M","F"),
                 gender_prob=c(0.49,0.51),
                 NL=FALSE,
                 set_seed=FALSE,
                 seed_val=100){
  
  if(set_seed == TRUE) set.seed(seed_val)
  
  cat(crayon::green("Calling generate_hospitalisation_data to generate synthetic hospital records...\n"))
  cat(crayon::blue("Hospital Risk information\n"))
  cat(crayon::red("\tAge Lower ",paste0(h_risk$AgeL, collapse = "*"),"\n"))
  cat(crayon::red("\tAge Upper ",paste0(h_risk$AgeU, collapse = "*"),"\n"))
  cat(crayon::red("\tHospitalisation Risks ",paste0(h_risk$HRisk, collapse = "*"),"\n"))
  
  cat(crayon::blue("Hospital LOS\n"))
  cat(crayon::red("\tAge Lower ",paste0(h_time$AgeL, collapse = "*"),"\n"))
  cat(crayon::red("\tAge Upper ",paste0(h_time$AgeU, collapse = "*"),"\n"))
  cat(crayon::red("\tMean LOS ",paste0(h_time$Mean, collapse = "*"),"\n"))
  cat(crayon::red("\tSD LOS ",paste0(h_time$SD, collapse = "*"),"\n"))
  
  cat(crayon::blue("Processing Updates...\n"))
          
  counter <- 1 
  cat(crayon::red("\t Processing EPI case",counter,"...\n"))
  get_risk <- function(age){
    if(counter %% 2500 == 0)
       cat(crayon::red("\t Processing EPI case",counter,"...\n"))
    counter <<- counter + 1
    dplyr::filter(h_risk,age>=AgeL,age<AgeU) %>% dplyr::pull(HRisk)
  }
  
  get_hospital_time <- function(age){
    ht <- dplyr::filter(h_time,age>=AgeL,age<AgeU)
    stats::rnorm(1,ht$Mean,ht$SD)
  }
  
  hosp_cases <- epi_cases %>%
                 dplyr::rowwise() %>%
                 dplyr::mutate(HRisk=get_risk(Age),
                        Hospitalised=as.logical(stats::rbinom(1,1,HRisk)),
                        TimeToAdmit=as.integer(ifelse(Hospitalised,stats::rnorm(1,
                                                              time_to_admit_mean,
                                                              time_to_admit_sd),NA)),
                        DateAdmitted=as.Date(ifelse(Hospitalised,Date+TimeToAdmit,NA)),
                        TimeInHospital=as.integer(ifelse(Hospitalised,get_hospital_time(Age),NA)),
                        DateDischarged=as.Date(ifelse(Hospitalised,DateAdmitted+TimeInHospital,NA)),
                        Source=ifelse(Hospitalised,sample(sources,1,prob=source_prob),NA),
                        Destination=ifelse(Hospitalised,sample(destinations,1,prob=destination_prob),NA),
                        Gender=ifelse(Hospitalised,sample(gender,1,prob=gender_prob),NA),) %>%
                dplyr::rename(DateTestedPositive=Date) %>%
                dplyr::select(CaseID,Source,Destination,DateAdmitted,DateDischarged,Age,Gender,dplyr::everything()) %>%
                dplyr::filter(Hospitalised==TRUE)
  
  
  if(NL==TRUE)
    hosp_cases <- hosp_cases %>%
                    dplyr::rename(Opname=CaseID,
                                  Herkomst=Source,
                                  Bestemming=Destination,
                                  startdatumtijd=DateAdmitted,
                                  einddatumtijd=DateDischarged,
                                  Leeftijd=Age,
                                  geslacht=Gender)
  
  prop_h <- round(nrow(hosp_cases)/nrow(epi_cases),3)
  cat(crayon::blue("Completed hospital data generation...\n"))
  cat(crayon::blue("Epi Cases= ",nrow(epi_cases),"Hospital Cases = ",nrow(hosp_cases),"Prop = ",prop_h,"\n"))
  
  hosp_cases
}