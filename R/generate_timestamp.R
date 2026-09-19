library(lubridate)
#-------------------------------------------------------------------------------------
#' Generates a random timestamp for a specific date
#'
#' \code{generate_timestamp} Generates timestamp for a specific date
#'
#' @param date The date (Date object)
#' @param hours A range of hours to generate the hour
#' @param mins A range of minutes to generate the minute
#' @param secs A range of seconds to generate the second
#' @return timestamp The combined timestamp to use in the patient record
#' @export

generate_timestamp <- function(date,hours=8:22,mins=0:59,secs=0:59){
  hour <- sample(hours,1)
  if (hour < 10)
    hour <- paste0("0",hour)
  else
    hour <- as.character(hour)
  
  minute<- sample(mins,1)
  if (minute < 10)
    minute <- paste0("0",minute)
  else
    minute <- as.character(minute)
  
  sec <- sample(secs,1)
  if (sec < 10)
    sec <- paste0("0",sec)
  else
    sec <- as.character(sec)
  
  
  ds <- paste0(as.character(date)," ",hour,":",minute,":",sec, "UTC")
  ts <- lubridate::ymd_hms(paste0(as.character(date)," ",hour,":",minute,":",sec))
  
}