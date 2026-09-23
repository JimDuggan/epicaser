library(dplyr)
library(crayon)


#-------------------------------------------------------------------------------------
#' Takes the case line list and updates with hospitalisation information
#'
#' \code{generate_patient_pathways} Generates arrival timestamped pathwats for all patients
#'
#' @param arrivals A tibble containing patient arrivals at the hospital
#' @param pathway_logic A tibble that contains the pathway logic for each age group
#' @param set_seed allows setting of the seed for sampling
#' @param seed_val set the seed value to be used if needed
#' @return  A tibble with the pathways for each patient
#' @export


generate_patient_pathways <- function(
      arrivals,
      pathway_logic=dplyr::tibble(Pathway_ID=c("P1","P2","P3","P4","P5","P6"),
                                  AgeL=c(0,0,30,30,70,70),
                                  AgeU=c(30,30,70,70,111,111),
                                  Pathway=list(c("Ward","Home"),          # Age 00-30,  Pathway 1/2
                                               c("Ward","ICU","Home"),    # Age 00-30,  Pathway 2/2
                                               c("Ward","Home"),          # Age 30-70,  Pathway 1/2
                                               c("Ward","ICU","Home"),    # Age 30-70,  Pathway 2/2
                                               c("Ward","Home"),          # Age 70-111, Pathway 1/2
                                               c("Ward","ICU","Home")),   # Age 70-111, Pathway 1/2
                                  Probabilities=c(0.95, # Prob(P1) for 00-30
                                                  0.05, # Prob(P2) for 00-30
                                                  0.90, # Prob(P1) for 30-70
                                                  0.10, # Prob(P2) for 30-70
                                                  0.50, # Prob(P1) for 70-111
                                                  0.50),
                                  Durations=list(c(1,3*24),       # Average (hours) interstage durations P1 Age 00-30 
                                                 c(1,2*24,10*24), # Average interstage durations P2 Age 00-30 
                                                 c(1,5*24),
                                                 c(1,7*24,15*24),
                                                 c(1,10*24),
                                                 c(1,3*24,25*24))),
      set_seed=TRUE,
      seed_val=100){
  
  if(set_seed == TRUE) set.seed(seed_val)
  
  cat(crayon::green("Calling generate_patient_pathways to build process data for patient journeys...\n"))
  cat(crayon::blue("Hospital Pathway Logic\n"))
  
  # This will be a list of tibbles
  patient_list <- vector(mode="list",length=nrow(arrivals))
  names(patient_list) <- arrivals$CaseID
  
  generate_random_pathway <- function(age){
    pway_rows <- dplyr::filter(pathway_logic,age >= AgeL & age < AgeU)
    index <- sample(1:nrow(pway_rows),1,prob=pway_rows$Probabilities)
    p_way<-unlist(pway_rows$Pathway[[index]])
    pmean_times<-unlist(pway_rows$Durations[[index]])
    list(Pathway=p_way,
         Times=pmean_times)
  }
  
  for(i in seq_along(patient_list)){
    # Sample the patient pathway
    process_data <- generate_random_pathway(arrivals$Age[i])
    
    # Generate a new tibble, first row start time will be copied from arrivals
    pathway_patient <- dplyr::tibble(
      CaseID = numeric(),
      Age = numeric(),
      Gender = character(),
      Pathway_Step = numeric(),
      Origin = character(),
      Destination = character(),
      StartTime = POSIXct(),
      EndTime = POSIXct(),
      DurationDays = numeric(),
      ICU_Admission = logical()
    )
    
    # Add first row
    pathway_patient <- dplyr::add_row(pathway_patient,
                                      CaseID=arrivals$CaseID[i],
                                      Age=arrivals$Age[i],
                                      Gender=arrivals$Gender[i],
                                      Pathway_Step=1,
                                      Origin=arrivals$Source[i],
                                      Destination=process_data$Pathway[1],
                                      StartTime=arrivals$TimeAdmitted[i],
                                      EndTime=StartTime+lubridate::hours(process_data$Times[1]),
                                      DurationDays=as.numeric(difftime(EndTime,StartTime,units="days")),
                                      ICU_Admission=process_data$Pathway[1]=="ICU")
    
    # cat("Adding first row ",CaseID=arrivals$CaseID[i],"\n")
    
    # Add other rows for remaining steps
    if(length(process_data$Pathway) > 1){
      
      for(j in 2:length(process_data$Pathway)){
        # cat("Adding row ",CaseID=arrivals$CaseID[i], "J=",j,"\n")
        pathway_patient <- dplyr::add_row(pathway_patient,
                                          CaseID=arrivals$CaseID[i],
                                          Age=arrivals$Age[i],
                                          Gender=arrivals$Gender[i],
                                          Pathway_Step=j,
                                          Origin=pathway_patient$Destination[j-1],
                                          Destination=process_data$Pathway[j],
                                          StartTime=pathway_patient$EndTime[j-1],
                                          EndTime=StartTime+lubridate::hours(process_data$Times[j]),
                                          DurationDays=as.numeric(difftime(EndTime,StartTime,units="days")),
                                          ICU_Admission=process_data$Pathway[j]=="ICU")
        
        # cat("\t>>> check rows = ",nrow(pathway_patient),"\n")
        
      } #End of j loop
      
    } #End of if statement
    
    # Update list
    # print(pathway_patient)
    patient_list[[i]] <- pathway_patient
    
  } #End of i loop
  
  dplyr::bind_rows(patient_list)
}