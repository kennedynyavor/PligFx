% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/main.R
\name{read_pmt}
\alias{read_pmt}
\title{A function that imports all payment}
\usage{
read_pmt(prod_month, data_after = as.Date("2013-01-01"))
}
\arguments{
\item{prod_month}{The production month}

\item{data_after}{A cut off data to filter the data by}
}
\value{
A data frame of all payment data
}
\description{
A function that imports all payment
}
\examples{
read_pmt(as.Date('2024-11-01'))
}
