library(lubridate)
library(dplyr)
library(stringr)
library(janitor)
library(readr)
library(magrittr)

utils::globalVariables(c("agent_branch", "agent_team", "policy_number", "payment_date"))

#' A function that imports all payment
#'
#' @param prod_month The production month
#' @param data_after A cut off data to filter the data by
#'
#' @returns A data frame of all payment data
#' @export
#'
#' @importFrom lubridate ymd mdy year month
#'
#' @importFrom dplyr mutate mutate_at vars matches filter group_by ungroup case_when if_else
#'
#' @importFrom janitor make_clean_names
#'
#' @importFrom stringr str_detect str_sub
#'
#' @importFrom readr read_delim
#'
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' prod_month <- as.Date('2024-11-01')
#' read_pmt(prod_month)
read_pmt <- function(prod_month, data_after = as.Date('2013-01-01')) {

month_year <- paste0(toupper(month(prod_month, label = TRUE)), year(prod_month))
root_folder <- paste0(getwd(),"/raw_data/",
                      month_year,
                      "/")
check_file <- str_detect(dir(root_folder), paste0("PAYMENT", ".*", month_year, ".txt$"))


file_path <- paste0(root_folder, dir(root_folder)[check_file])

df <- read_delim(file_path,
                 delim = ";",
                 trim_ws = TRUE,
                 name_repair = make_clean_names) %>%
  mutate_at(vars(matches("date$")), mdy) %>%
  mutate(
    agent_branch = if_else(str_detect(agent_branch, "NABCO"), agent_team, agent_branch),
    agent_branch = if_else(str_detect(agent_branch, "TEAM 2"), "KUMASI", agent_branch),
    agent_branch = if_else(
      str_detect(agent_branch, "NON AGENTS"),
      "TELESALES",
      agent_branch
    )
  ) %>%
  filter(str_detect(
    str_sub(policy_number, 1, 4),
    "EMFP|EMSP|EFPP|EPPP|PDG0",
    negate = TRUE
  )) %>%
  group_by(policy_number) %>%
  mutate(inception_date = min(payment_date)) %>%
  ungroup() %>%
  mutate(
    channel =
      case_when(
        str_detect(agent_branch, "BANCASSU") ~ "Banca",
        str_detect(agent_branch, "PRU.*ADVISOR") ~ "PruAdvisor",
        str_detect(agent_branch, "TELESALES") ~ "TELESALES",
        str_detect(agent_branch, "BROKER|RISCOVERY|CONSULT") ~ "Broker",
        .default = "Agency"

      )
  ) %>%
  filter(
    payment_date >= data_after
  )
return(df)
}
