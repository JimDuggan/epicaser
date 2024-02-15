# devtools::install_github("JimDuggan/epicaser")
library(epicaser)
library(ggplot2)
library(dplyr)

cases <- generate_epi_cases(R0 = 2,Poisson = FALSE,nb_size = 10,res_policy = T,res_duration = 10)


ggplot(cases,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")
