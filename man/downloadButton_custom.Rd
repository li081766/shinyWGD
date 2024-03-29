% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{downloadButton_custom}
\alias{downloadButton_custom}
\title{Creating a Custom Download Button}
\usage{
downloadButton_custom(
  outputId,
  label = "Download",
  class = NULL,
  status = "primary",
  ...,
  icon = shiny::icon("download")
)
}
\arguments{
\item{outputId}{The name of the output slot that the downloadHandler is assigned to.}

\item{label}{The label that should appear on the button.}

\item{class}{Additional CSS classes to apply to the tag, if any. Default NULL.}

\item{status}{The status of the button; default is "primary."}

\item{...}{Other arguments to pass to the container tag function.}

\item{icon}{An icon() to appear on the button; default is icon("download").}
}
\value{
An HTML tag to allow users to download the object.
}
\description{
Use this function to create a custom download button or link. When clicked, it will initiate a browser download. The filename and contents are specified by the corresponding downloadHandler() defined in the server function.
}
