% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/from_features.R
\name{dfltBWrange}
\alias{dfltBWrange}
\title{dfltBWrange}
\usage{
dfltBWrange(x, tau)
}
\arguments{
\item{x}{The input data, which can be a numeric vector or matrix.}

\item{tau}{A parameter used in bandwidth calculation.}
}
\value{
A list of bandwidth ranges for each dimension of the input data.
}
\description{
This function computes the default bandwidth range for kernel density estimation.
}
