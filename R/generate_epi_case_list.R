library(tidyverse)
library(p2synthr)
library(crayon)

#-------------------------------------------------------------------------------------
#' Creates an individual list of cases based on the input cohorts. 
#' This structure will then form the basis for the hospitalisation structure
#' 
#'
#' \code{generate_epi_case_list} Create an epi case list based on model outputs
#'
#' @param cohort_data Cohort case data via SIR model and age cohort breakdown
#' @return tibble with results, including original value. Each group has a column.
#' @return res a tibble with day number, date, model output, cases, and available staff
#' @export

generate_epi_case_list <- function(cohort_data,
                                   TS=FALSE){
  
  cat(green("Calling generate_epi_case_list create an individual case list...\n"))
  
  case_list <- tibble(CaseID=integer(),
                      CohortGroup = character(),
                      Index = integer(),
                      Age = integer(),
                      SynGenTime=character())
  

  make_longer <-  names(cohort_data)[!(names(cohort_data) %in% c("Date","Index","Input"))]
  
  case_data <- pivot_longer(cohort_data,
                            cols = make_longer,
                            names_to = "Cohort",
                            values_to = "Cases") %>%
               filter(Cases > 0) %>%
               mutate(CohortGroup=Cohort) %>%
               separate_wider_delim(Cohort,
                                    delim = "-",
                                    names=c("AgeL","AgeU")) %>%
               mutate(AgeL=as.integer(AgeL),
                      AgeU=as.integer(AgeU))
  
  case_id <- 1
  
  for(i in 1:nrow(case_data)){
    # Extract row data that is needed
    n_cases      <- pull(case_data[i,"Cases"])
    index        <- pull(case_data[i,"Index"])
    cohort_group <- pull(case_data[i,"CohortGroup"])
    age_l        <- pull(case_data[i,"AgeL"])
    age_u        <- pull(case_data[i,"AgeU"])
    

    cat(red("\tProcessing Day number ",index,"Number of cases generated", case_id,"...\n"))
    
    for(j in 1:n_cases){
      case_list <- add_row(case_list,
                           CaseID=case_id,
                           CohortGroup=cohort_group,
                           Index=index,
                           Age=sample(age_l:age_u,1),
                           SynGenTime=format(Sys.time(), "%a %b %d %X %Y"))
     case_id <- case_id + 1
    }
  }
  
  date_join <- case_data %>%
                 select(Date,Index) %>%
                 distinct()
  
  if (TS == FALSE) case_list$SynGenTime <- NULL
  final_case_list <- left_join(case_list,date_join) %>%
                        select(Date,CaseID,Age,CohortGroup,everything()) %>%
                        select(-Index)
      
}
