# devtools::install_github("JimDuggan/epicaser")
library(epicaser)
library(ggplot2)
library(dplyr)

cases <- generate_epi_cases(staff_per_100K = 1000,
                            staff_recovery_delay = 6,
                            staff_absenteeism = 0.03)


ggplot(cases,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")+
  ggtitle("Cases")

ggplot(cases,aes(x=Date,y=cases$AvailableStaff))+
  geom_line()+
  geom_point()+
  geom_line(data=cases,mapping=aes(x=Date,y=Model_Available_Staff),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")+
  ggtitle("Available Staff")
