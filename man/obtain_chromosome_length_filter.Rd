% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/obtain_chromosome_length.R
\name{obtain_chromosome_length_filter}
\alias{obtain_chromosome_length_filter}
\title{obtain_chromosome_length_filter}
\usage{
obtain_chromosome_length_filter(species_info_df)
}
\arguments{
\item{species_info_df}{A data frame containing species information with columns "sp," "cds," and "gff."}
}
\value{
A list containing two data frames: len_df for chromosome lengths and num_df for mRNA counts.
}
\description{
Process a data frame containing species information and extract chromosome lengths and mRNA counts from GFF files.
}
