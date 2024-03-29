% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/from_features.R
\name{symconv2D.ks}
\alias{symconv2D.ks}
\title{symconv2D.ks}
\usage{
symconv2D.ks(rr, ss, skewflag = rep(1, 2))
}
\arguments{
\item{rr}{The first input matrix.}

\item{ss}{The second input matrix.}

\item{skewflag}{A vector of two scalar values for skew correction along each dimension.}
}
\value{
A matrix representing the result of the symmetric 2D convolution.
}
\description{
Perform symmetric 2D convolution using FFT.
}
