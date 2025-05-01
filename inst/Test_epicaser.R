# devtools::install_github("JimDuggan/epicaser")
# devtools::install_github("JimDuggan/p2synthr")
library(epicaser)
library(ggplot2)
library(dplyr)
library(p2synthr)

cases <- generate_epi_cases(Poisson = F)


ggplot(cases,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")


cases_age <- synth1(cases$Cases,
                    group_names=c("00-19","20-39","40+"),
                    group_prob = c(0.20,0.40,0.40))
