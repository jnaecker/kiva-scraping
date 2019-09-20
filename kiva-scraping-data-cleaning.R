#### PACKAGES ####
library(dplyr)
library(jsonlite)
library(lubridate)
library(stringr)
library(purrr)
library(tidyr)

#### FUNCTIONS ####
extract_data <- function(x, quietly = T) {
  if (!quietly) {cat("Extracting data from", x, "\n")}
  json <- fromJSON(x, flatten = T)
  json$data$lend$loans$values
}

count_switches <- function(
  matching_on # a vector of T/F values
){
  
  # set counter
  switch_count <- 0
  
  if (length(matching_on) > 1) {
    
    # loop over all transactions after the first (the intial state doesn't count as a switch)
    for (i in 2:length(matching_on)) {
      
      # get current matched status and check against last
      if (matching_on[i] != matching_on[i-1]) {switch_count <- switch_count + 1}
    }
  }
  
  # return counter
  switch_count
}

#### SCRIPT ####

# read in json data
observations <- 
  tibble(file = list.files("data", full.names = T, pattern = "*.json")) %>%
  mutate(
    time = ymd_hms(file),
    gender = str_extract(file, "(male)|(female)")
  ) %>%
  filter(time >= "2019-09-12 00:00:01" & time <= "2019-09-20 00:00:01") %>%
  mutate(loans = map(file, ~extract_data(., quietly = F))) %>%
  unnest() %>%
  mutate(
    fundraisingDate       = ymd_hms(fundraisingDate),
    plannedExpirationDate = ymd_hms(plannedExpirationDate),
    fundedAmount          = as.numeric(loanFundraisingInfo.fundedAmount),
    loanAmount            = as.numeric(loanAmount),
    percentFunded         = fundedAmount / loanAmount,
    daysRemaining         = (plannedExpirationDate - time) / ddays(1)
  ) %>%
  select(-loanFundraisingInfo.fundedAmount)

## calculate loan-level stats
loans <- 
  observations %>%
  group_by(id) %>%
  summarize(
    loanAmount             = loanAmount[1],
    plannedExpirationDate  = plannedExpirationDate[1],
    fundraisingDate        = fundraisingDate[1],
    totalObservations      = n(),
    matchedObservations    = sum(isMatchable, na.rm = T),
    percentTimeMatched     = matchedObservations/totalObservations,
    everMatchable          = TRUE %in% isMatchable,
    numSwitches            = count_switches(isMatchable),
    startsWithMatch        = isMatchable[1],
    firstObservationDate   = time[1],
    matchedInFirst5Days    = sum(isMatchable[(time - firstObservationDate)/ddays(1) <= 5]) > 0,
    switchesInFirst5Days   = count_switches(isMatchable[(time - firstObservationDate)/ddays(1) <= 5]),
    switchInFirst5Days     = switchesInFirst5Days > 0
  )

## import pilot data
## to get most recent data, log in to Kiva account > Transaction history > Export
pilot_results <- 
  readr::read_csv("data/Kiva_Transactions_2019-09-19-22-10-24.csv") %>%
  as_tibble()

## save data
save(observations, loans, pilot_results, file = "data/clean-data.rda")