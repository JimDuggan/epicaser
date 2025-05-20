# devtools::install_github("JimDuggan/epicaser")
library(epicaser)
library(tidyverse)

# (1) Run SIR model to get case data, specify the measurement model as NB
cases <- generate_epi_cases(Poisson = FALSE,rep_fraction = .3,N = 1000000,I0 = 100)


ggplot(cases,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")


# (2) Stratify the cases into age cohorts
cases_age <- generate_cohort_epi_cases(cases$Date,cases$Cases)

cases_tidy <- cases_age |>
                pivot_longer(names_to="Age",
                             values_to="Incidence",
                             `00-19`:`100-110`)

ggplot(cases_tidy,aes(x=Index,y=Incidence,fill=Age))+
  geom_area()+ggtitle("Synthetic Data")

# (3) Create a synthetic epi case list
epi_cases <- generate_epi_case_list(cases_age)

# Check summaries
epi_sum <- epi_cases %>% 
            group_by(Date,CohortGroup) %>%
            summarise(Cases=n())

ggplot(epi_sum,aes(x=Date,y=Cases,fill=CohortGroup))+
  geom_area()+ggtitle("Check Case List")


# (4) Generate hospital list
hosp_cases <- generate_hospitalisation_data(epi_cases,NL=FALSE)


h_adm_sum <- hosp_cases %>%
              group_by(DateAdmitted,CohortGroup) %>%
              summarise(Admissions=n())50

h_dis_sum <- hosp_cases %>%
  group_by(DateDischarged,CohortGroup) %>%
  summarise(Discharges=n())

 
ggplot()+geom_area(data=h_adm_sum,mapping=aes(x=DateAdmitted,y=Admissions,fill=CohortGroup))+
  geom_area(data=h_dis_sum,mapping=aes(x=DateDischarged,y=Discharges,fill=CohortGroup))+
  xlab("Date")+ylab("Admissions and Discharges")




