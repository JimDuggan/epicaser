library(deSolve)
library(dplyr)

sirm <- function(time, stocks, auxs){
  with(as.list(c(stocks, auxs)),{
    # Parameters: R0, Recovery_Delay, Minimum_Mobility, N
    # Activation_Percentage, Restrictions_Policy, Restrictions_Duration
    # Reporting_Fraction, Reporting_AT, Mobility_AT
    # Minimum_Mobility
    
    Beta   <- R0/Recovery_Delay
    lambda <- M*Beta*I/N
    Mobility_Goal <- 1-RS*(1-Minimum_Mobility)
    Activation_Threshold <-Activation_Percentage*N

    # Integrals:
    #   S - Susceptible
    
    dS_dt     <- -lambda * S
    dI_dt     <- lambda * S - I/Recovery_Delay
    dR_dt     <- I/Recovery_Delay
    dM_dt     <- (Mobility_Goal-M)/Mobility_AT
    dTI_dt    <- lambda * S * Reporting_Fraction
    dRI_dt    <- (dTI_dt - RI)/Reporting_AT
    if(RS == 0 & RI >= Activation_Threshold){
          dRS_dt_in <- Restrictions_Policy*1/DT
          TIME_START <<- time
     } else dRS_dt_in <- 0
    
    if(RS==1 & (time - TIME_START) >= Restrictions_Duration){
      dRS_dt_out <- 1/DT
      TIME_END <<- time
    } else dRS_dt_out <- 0
    
    dRS_dt     <- dRS_dt_in - dRS_dt_out
  

    return (list(c(dS_dt,
                   dI_dt,
                   dR_dt,
                   dM_dt,
                   dTI_dt,
                   dRI_dt,
                   dRS_dt),
                 TS=TIME_START,
                 TE=TIME_END,
                 auxs,
                 IR=lambda * S,
                 RR=I/Recovery_Delay))
  })
}


#------------------------------------------------------------------------------
# A function to run the model, parameterised
run_sim_sirm <- function(N=100000,
                         R0=2.0,
                         I0=1,
                         res_policy=FALSE,
                         res_duration=7,
                         act_percentage=0.015,
                         start_time=0,
                         end_time=100){
  
  TIME_START <<- 1000 # Needed for restrictions logic
  TIME_END   <<- -1 # Needed for restrictions logic

  simtime <- seq(start_time,end_time,by=0.125)
  

  stocks  <- c(S=N-I0,
               I=I0,
               R=0,
               M=1,
               TI=0,
               RI=0,
               RS=0)

  auxs    <- c(N=N,
               R0=R0,
               Recovery_Delay=2,
               Minimum_Mobility=0.5,
               Activation_Percentage=act_percentage,
               Restrictions_Policy=as.integer(res_policy),
               Restrictions_Duration=res_duration,
               Reporting_Fraction=0.5,
               Reporting_AT=2,
               Mobility_AT=2,
               DT=0.125)
  
  # Note we add on daily cases as a lagged difference of 1/step between cumulative cases
  res <- deSolve::ode(y=stocks,
                      times=simtime,
                      func = sirm,
                      parms=auxs,
                      method="euler") |>
         base::data.frame() |>
         dplyr::as_tibble()
  
  res <- res |>
    dplyr::filter(time %% 1 == 0) |>
    dplyr::mutate(DI=TI-dplyr::lag(TI,1,default = 0))
}


