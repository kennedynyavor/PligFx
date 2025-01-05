library(lubridate)
library(dplyr)
library(stringr)
library(janitor)
library(readr)
library(magrittr)
library(readxl)

utils::globalVariables(c("agent_branch", "agent_team", "policy_number", "payment_date","scb","agency","allocation_month","date_key"))

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
#' @importFrom dplyr mutate mutate_at vars matches filter group_by ungroup case_when if_else left_join select
#'
#' @importFrom janitor make_clean_names
#'
#' @importFrom stringr str_detect str_sub
#'
#' @importFrom readr read_delim
#'
#' @importFrom magrittr %>%
#'
#' @importFrom readxl read_excel
#'
#' @examples
#' read_pmt(as.Date('2024-11-01'))
read_pmt <- function(prod_month, data_after = as.Date('2013-01-01')) {

month_year <- paste0(toupper(month(prod_month, label = TRUE)), year(prod_month))
root_folder <- paste0(getwd(),"/raw_data/",
                      month_year,
                      "/")
check_file <- str_detect(dir(root_folder), paste0("PAYMENT", ".*", month_year, ".txt$"))

if(sum(check_file*1) == 1){

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
        .default = "Agency"),
    product_code = str_sub(policy_number,1,4)
  ) %>%
  filter(
    payment_date >= data_after
  ) %>%
  left_join(
    read_excel(
      paste0(getwd(),"/dim_files/product_details.xlsx"),
      trim_ws = TRUE,
      .name_repair = make_clean_names
    ),
    by = 'product_code',
    keep = FALSE
  ) %>%
  left_join(
    read_excel(
      paste0(getwd(),"/dim_files/datetable.xlsx"),
      trim_ws = TRUE,
      .name_repair = make_clean_names,
      sheet = "dateTable"
    ) %>% mutate(
      date_key = ymd(date_key),
      agency = ymd(agency),
      scb = ymd(scb)
    ),
    by = c('transaction_date'='date_key'),
    keep = FALSE
  ) %>%
  mutate(
    allocation_month = if_else(str_detect(agent_branch,"SC BANCAS"),scb,agency)
  ) %>%
  select(
    -c(scb,agency)
  ) %>%
  filter(
    allocation_month <= prod_month
  )

  return(df)
} else {
  print("Data not Found")
  return("No Data Found")
}

}
