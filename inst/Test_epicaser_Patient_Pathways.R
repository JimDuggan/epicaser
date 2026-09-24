# devtools::install_github("JimDuggan/epicaser")
library(epicaser)
library(tidyverse)
library(ggplot2)

# (1) Run SIR model to get case data, specify the measurement model as NB
# cases <- generate_epi_cases(Poisson = FALSE,RF = .3,N = 10000,I0 = 10)

# Only call to run a model. If model is already run, read in from CSV and
# go straight to generate_epi_cases_stochastic()
cases_d <- generate_epi_cases_deterministic(RF = .3,N = 100000,I0 = 10)

cases   <- generate_epi_cases_stochastic(cases_d,Poisson=FALSE)


ggplot(cases,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  # geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")


# (2) Stratify the cases into age cohorts
cases_age <- generate_cohort_epi_cases(cases$Date,cases$Cases)

cases_tidy <- cases_age |>
                pivot_longer(names_to="Age",
                             values_to="Incidence",
                             `00-19`:`100-110`)

ggplot(cases_tidy,aes(x=Date,y=Incidence,fill=Age))+
  geom_area()+ggtitle("Synthetic Case Data")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")

# (3) Create a synthetic epi case list
epi_cases <- generate_epi_case_list(cases_age)

# Check summaries
epi_sum <- epi_cases %>% 
            group_by(Date,CohortGroup) %>%
            summarise(Cases=n())

ggplot(epi_sum,aes(x=Date,y=Cases,fill=CohortGroup))+
  geom_area()+ggtitle("Check Case List")


# (4) Generate hospital list
# hosp_cases <- generate_hospitalisation_data(epi_cases,NL=FALSE)
arrivals <- generate_hospital_arrivals(epi_cases)

arr_sum <- arrivals %>% 
  group_by(DateAdmitted,CohortGroup) %>%
  summarise(Cases=n())

ggplot(arr_sum,aes(x=DateAdmitted,y=Cases,fill=CohortGroup))+
  geom_area()+ggtitle("Hospital Arrivals")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")

# pathways <- generate_patient_pathways(arrivals)
pathways_NL <- generate_patient_pathways_NL(arrivals)

# Joining epi and hospital dataset for overall information on cases
dataset_all <- left_join(arrivals,pathways_NL,by=c("CaseID"="admission"),keep = T) %>%
                 mutate(Duration=difftime(enddatetime,startdatetime,units="days"))



