
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pligFx

<!-- badges: start -->
<!-- badges: end -->

The goal of pligFx is to …

## Installation

You can install the development version of pligFx from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kennedynyavor/PligFx",force = TRUE)
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(pligFx)
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.4     ✔ readr     2.1.5
#> ✔ forcats   1.0.0     ✔ stringr   1.5.1
#> ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
#> ✔ purrr     1.0.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
## basic example code
```

The `read_pmt` function imports the all payment data seemlessly and
performs all neccesary joins internally. It takes the production month
and a `data_after` parameter. Data_after is used to filter the all
payment data (payment_date \>= data_after).

``` r
setwd("~/z_data/data_prep/")
df <- read_pmt(as.Date("2024-11-01"))
#> Rows: 10276883 Columns: 14
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ";"
#> chr (13): policy_number, prp_other_names, prp_surname, status_reason, transa...
#> dbl  (1): amount
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Check the import

    #> `summarise()` has grouped output by 'allocation_month'. You can override using
    #> the `.groups` argument.
    #> # A tibble: 24 × 3
    #> # Groups:   allocation_month [12]
    #>    allocation_month product_type     GwP
    #>    <date>           <chr>          <dbl>
    #>  1 2016-01-01       Risk         405489.
    #>  2 2016-01-01       Savings      639033.
    #>  3 2016-02-01       Risk         447771.
    #>  4 2016-02-01       Savings      802122.
    #>  5 2016-03-01       Risk         426875.
    #>  6 2016-03-01       Savings      727915.
    #>  7 2016-04-01       Risk         442639.
    #>  8 2016-04-01       Savings      780812.
    #>  9 2016-05-01       Risk         521731.
    #> 10 2016-05-01       Savings      942688.
    #> # ℹ 14 more rows

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
