library(deSolve)
library(dplyr)


seir <- function(time, stocks, auxs){
  with(as.list(c(stocks, auxs)),{
    # Parameters: N, R0, sigma, gamma, RF

    Beta   <- R0*gamma
    lambda <- Beta*I/N
    
    # Integrals:
    #   S - Susceptible
    
    dS_dt     <- -lambda * S
    dE_dt     <- lambda * S - E*sigma
    dI_dt     <- E * sigma - I*gamma
    dR_dt     <- I * gamma
    dC_dt     <- E * sigma * RF

    return (list(c(dS_dt,
                   dE_dt,
                   dI_dt,
                   dR_dt,
                   dC_dt),
                 auxs,
                 Lambda=lambda,
                 ER=lambda*S,
                 IR=E*sigma,
                 RR=I*gamma,
                 Checksum=S+E+I+R))
  })
}


#------------------------------------------------------------------------------
# A function to run the model, parameterised
run_sim_seir <- function(N=100000,
                         R0=2.0,
                         I0=1,
                         RF=0.5,
                         sigma=0.5,
                         gamma=0.5,
                         start_time=0,
                         end_time=100){
  
  simtime <- seq(start_time,end_time,by=0.125)
  

  stocks  <- c(S=N-I0,
               E=0,
               I=I0,
               R=0,
               C=0)
  
  auxs    <- c(N=N,
               R0=R0,
               sigma=sigma,
               gamma=gamma,
               RF=RF)

  # Note we add on daily cases as a lagged difference of 1/step between cumulative cases
  res <- deSolve::ode(y=stocks,
                      times=simtime,
                      func = seir,
                      parms=auxs,
                      method="euler") |>
         base::data.frame() |>
         dplyr::as_tibble()
  
  res <- res |>
    dplyr::filter(time %% 1 == 0) |>
    dplyr::mutate(DI=C-dplyr::lag(C,1,default = 0))
}
