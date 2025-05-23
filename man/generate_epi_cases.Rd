% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_epi_cases.R
\name{generate_epi_cases}
\alias{generate_epi_cases}
\title{Creates synthetic epi data using SIR model and Poisson/Negative Binomial
Staff absenteeism is proportional to the population attack rate (lambda)}
\usage{
generate_epi_cases(
  N = 1e+05,
  R0 = 2,
  I0 = 1,
  rep_fraction = 0.5,
  res_policy = FALSE,
  res_duration = 7,
  end_time = 100,
  start_day = "2025-03-01",
  seed = FALSE,
  seed_val = 100,
  Poisson = TRUE,
  nb_size = 10,
  staff_per_100K = 1200,
  staff_recovery_delay = 6,
  staff_absenteeism = 0.02
)
}
\arguments{
\item{N}{the population size for the SIR model (default 100000)}

\item{R0}{the value for the reproduction number (default 2.0)}

\item{I0}{the initial number of people infected (default 1)}

\item{rep_fraction}{Reporting fraction for surveillance (default 0.5)}

\item{res_policy}{Whether or not to activate a simple restrictions policy (default FALSE)}

\item{res_duration}{Duration for restrictions (default 7)}

\item{end_time}{end of simulation time (default 100)}

\item{start_day}{YYYY-MM-DD string format for start of simulation}

\item{seed}{True or False for using a seed (default FALSE)}

\item{seed_val}{value of seed (default 100)}

\item{nb_size}{size parameter for negative binomial distribution (default 10)}

\item{staff_per_100K}{number of staff resources per 100K of population}

\item{staff_recovery_delay}{average recovery time for absent staff}

\item{staff_absenteeism}{average absenteeism rate for staff}
}
\value{
res a tibble with day number, date, model output, cases, and available staff
}
\description{
\code{generate_epi_cases} Create synthetic case data based on SIR model (Novel Pathogen)
}
