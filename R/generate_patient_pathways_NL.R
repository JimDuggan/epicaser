library(dplyr)
library(crayon)


#-------------------------------------------------------------------------------------
#' Takes the case line list and updates with hospitalisation information
#'
#' \code{generate_patient_pathways_NL} Generates arrival timestamped pathwats for all patients
#'
#' @param arrivals A tibble containing patient arrivals at the hospital
#' @param pathway_logic A tibble that contains the pathway logic for each age group
#' @param set_seed allows setting of the seed for sampling
#' @param seed_val set the seed value to be used if needed
#' @return  A tibble with the pathways for each patient
#' @export


generate_patient_pathways_NL <- function(
      arrivals,
      pathway_logic=dplyr::tibble(Pathway_ID=c("P1","P2","P3","P4","P5","P6"),
                                  AgeL=c(0,0,30,30,70,70),
                                  AgeU=c(30,30,70,70,111,111),
                                  Internal_Pathway=list(c("Ward"),          # Age 00-30,  Pathway 1/2
                                                        c("Ward","ICU"),    # Age 00-30,  Pathway 2/2
                                                        c("Ward"),          # Age 30-70,  Pathway 1/2
                                                        c("Ward","ICU"),    # Age 30-70,  Pathway 2/2
                                                        c("Ward"),          # Age 70-111, Pathway 1/2
                                                        c("Ward","ICU")),   # Age 70-111, Pathway 1/2
                                  Final_Destination=c("Home",
                                                      "Home",
                                                      "Home",
                                                      "Nursing home",
                                                      "Home",
                                                      "Home"
                                                ),
                                  Probabilities=c(0.95, # Prob(P1) for 00-30
                                                  0.05, # Prob(P2) for 00-30
                                                  0.90, # Prob(P1) for 30-70
                                                  0.10, # Prob(P2) for 30-70
                                                  0.50, # Prob(P1) for 70-111
                                                  0.50),
                                  Durations=list(c(3*24),       # Average (hours) interstage durations P1 Age 00-30 
                                                 c(2*24,10*24), # Average interstage durations P2 Age 00-30 
                                                 c(5*24),
                                                 c(7*24,15*24),
                                                 c(10*24),
                                                 c(3*24,25*24))),
      set_seed=TRUE,
      seed_val=100){
  
  if(set_seed == TRUE) set.seed(seed_val)
  
  cat(crayon::green("Calling generate_patient_pathways to build process data for patient journeys...\n"))
  cat(crayon::blue("Hospital Pathway Logic\n"))
  
  # This will be a list of tibbles
  patient_list <- vector(mode="list",length=nrow(arrivals))
  names(patient_list) <- arrivals$CaseID
  
  generate_random_pathway <- function(age,s){
    pway_rows <- dplyr::filter(pathway_logic,age >= AgeL & age < AgeU)
    index <- sample(1:nrow(pway_rows),1,prob=pway_rows$Probabilities)
    p_way<-unlist(pway_rows$Internal_Pathway[[index]])
    pmean_times<-unlist(pway_rows$Durations[[index]])
    p_final_dest <- pway_rows$Final_Destination[[index]]
    
    list(Internal_Pathway=p_way,
         Number_Stages=length(p_way),
         Times=pmean_times,
         Source=s,
         In_ICU=p_way=="ICU",
         Final_External_Dest=p_final_dest)
  }
  
  for(i in seq_along(patient_list)){
    # Sample the patient pathway
    process_data <- generate_random_pathway(arrivals$Age[i],arrivals$Source[i])

    
    # Generate a new tibble, first row start time will be copied from arrivals
    nl_pathway_patient <- dplyr::tibble(
      admission = numeric(),
      # Age = numeric(),
      # Gender = character(),
      # Pathway_Step = numeric(),
      Origin = character(),
      Destination = character(),
      startdatetime = POSIXct(),
      enddatetime = POSIXct(),
      # DurationDays = numeric(),
      ICU_admittance = logical()
    )
    
    for(j in 1:process_data$Number_Stages){
      
      destination <- "TBD"
      # If it's the first record
      if(j == 1){
        origin <- process_data$Source
        start_timestamp <- arrivals$TimeAdmitted[i]
        if(sum(process_data$In_ICU) > 0)
          destination <- "ICU"
        else
          destination <- process_data$Final_External_Dest
      }
      else{
        origin <- process_data$Internal_Pathway[j-1]
        destination <- process_data$Final_External_Dest
        start_timestamp <- nl_pathway_patient$enddatetime[j-1]
      }
      
      # Add the new row of data
      nl_pathway_patient <- dplyr::add_row(nl_pathway_patient,
                                            admission=arrivals$CaseID[i],
                                            Origin=origin,
                                            Destination=destination,
                                            startdatetime=start_timestamp,
                                            enddatetime=startdatetime+
                                                        lubridate::hours(process_data$Times[j]),
                                            ICU_admittance=process_data$In_ICU[j])
    } # end of j loop
    
    patient_list[[i]] <- nl_pathway_patient
    
  } #End of i loop
  
  dplyr::bind_rows(patient_list)
}