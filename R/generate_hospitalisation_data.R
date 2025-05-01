library(tidyverse)
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
#' @param htime Length of stay distribution information (normal distribution)
#' @param sources A vectors showing where the patient has come from before arriving at the hospital
#' @param sources_prob The probability of each sourcing option
#' @param destinations Where the patient goes after their length of stay
#' @param gender Gender of the patient
#' @param gender_prob Probability of each gender option
#' @param NL Netherlands flag, causes key fields to be renamed.
#' @return hosp_cases A tibble with all hospitalisation data
#' @export

generate_hospitalisation_data <- function(
                  epi_cases,
                  h_risk=tibble(AgeL=c(0,30,70),
                                AgeU=c(30,70,111),
                                HRisk=c(0.01,0.05,0.15)),
                 time_to_admit_mean=5.2,
                 time_to_admit_sd=2.1,
                 h_time=tibble(AgeL=c(0,30,70),
                               AgeU=c(30,70,111),
                               Mean=c(5,10,20),
                               SD=c(1,2,5)),
                 sources=c("Home","Hospital","Other"),
                 source_prob=c(.80,.10,.10),
                 destinations=c("Home","Hospital","Death"),
                 destination_prob=c(0.85,0.13,0.02),
                 gender=c("M","F"),
                 gender_prob=c(0.49,0.51),
                 NL=FALSE){
  
  cat(green("Calling generate_hospitalisation_data to generate synthetic hospital records...\n"))
  cat(blue("Hospital Risk information\n"))
  cat(red("\tAge Lower ",paste0(h_risk$AgeL, collapse = "*"),"\n"))
  cat(red("\tAge Upper ",paste0(h_risk$AgeU, collapse = "*"),"\n"))
  cat(red("\tHospitalisation Risks ",paste0(h_risk$HRisk, collapse = "*"),"\n"))
  
  cat(blue("Hospital LOS\n"))
  cat(red("\tAge Lower ",paste0(h_time$AgeL, collapse = "*"),"\n"))
  cat(red("\tAge Upper ",paste0(h_time$AgeU, collapse = "*"),"\n"))
  cat(red("\tMean LOS ",paste0(h_time$Mean, collapse = "*"),"\n"))
  cat(red("\tSD LOS ",paste0(h_time$SD, collapse = "*"),"\n"))
  
  cat(blue("Processing Updates...\n"))
          
  counter <- 1 
  cat(red("\t Processing EPI case",counter,"...\n"))
  get_risk <- function(age){
    if(counter %% 2500 == 0)
       cat(red("\t Processing EPI case",counter,"...\n"))
    counter <<- counter + 1
    filter(h_risk,age>=AgeL,age<AgeU) %>% pull(HRisk)
  }
  
  get_hospital_time <- function(age){
    ht <- filter(h_time,age>=AgeL,age<AgeU)
    rnorm(1,ht$Mean,ht$SD)
  }
  
  hosp_cases <- epi_cases %>%
                 rowwise() %>%
                 mutate(HRisk=get_risk(Age),
                        Hospitalised=as.logical(rbinom(1,1,HRisk)),
                        TimeToAdmit=as.integer(ifelse(Hospitalised,rnorm(1,
                                                              time_to_admit_mean,
                                                              time_to_admit_sd),NA)),
                        DateAdmitted=as.Date(ifelse(Hospitalised,Date+TimeToAdmit,NA)),
                        TimeInHospital=as.integer(ifelse(Hospitalised,get_hospital_time(Age),NA)),
                        DateDischarged=as.Date(ifelse(Hospitalised,DateAdmitted+TimeInHospital,NA)),
                        Source=ifelse(Hospitalised,sample(sources,1,prob=source_prob),NA),
                        Destination=ifelse(Hospitalised,sample(destinations,1,prob=destination_prob),NA),
                        Gender=ifelse(Hospitalised,sample(gender,1,prob=gender_prob),NA),) %>%
                rename(DateTestedPositive=Date) %>%
                select(CaseID,Source,Destination,DateAdmitted,DateDischarged,Age,Gender,everything()) %>%
                filter(Hospitalised==TRUE)
  
  
  if(NL==TRUE)
    hosp_cases <- hosp_cases %>%
                    rename(Opname=CaseID,
                    Herkomst=Source,
                    Bestemming=Destination,
                    startdatumtijd=DateAdmitted,
                    einddatumtijd=DateDischarged,
                    Leeftijd=Age,
                    geslacht=Gender)
  
  prop_h <- round(nrow(hosp_cases)/nrow(epi_cases),3)
  cat(blue("Completed hospital data generation...\n"))
  cat(blue("Epi Cases= ",nrow(epi_cases),"Hospital Cases = ",nrow(hosp_cases),"Prop = ",prop_h,"\n"))
  
  hosp_cases
}