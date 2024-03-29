% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ksv.R
\name{read.wgd_ksd}
\alias{read.wgd_ksd}
\title{Read the output file of wgd ksd}
\usage{
read.wgd_ksd(
  file,
  include_outliers = FALSE,
  min_ks = 0,
  min_aln_len = 0,
  min_idn = 0,
  min_cov = 0
)
}
\arguments{
\item{file}{The output file of \verb{wgd ksd}}

\item{include_outliers}{Include outliers or not, default FALSE.}

\item{min_ks}{Minimum Ks value, default 0.}

\item{min_aln_len}{Minimum alignment length, default 0.}

\item{min_idn}{Minimum alignment identity, default 0.}

\item{min_cov}{Minimum alignment coverage, default 0.}
}
\value{
A \code{ksv} object, which is a list including:
\itemize{
\item \code{ks_df}: the data frame that used for following analysis
\item \code{ks_dist}: a list including a vector of Ks values in the distribution
\item \code{raw_df}: raw data
\item \code{filters}: filters that applied to the raw data
}
}
\description{
Read the output file of wgd ksd
}
