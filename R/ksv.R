#' Read the output file of wgd ksd
#'
#' @param file The output file of `wgd ksd`
#' @param include_outliers Include outliers or not, default FALSE.
#' @param min_ks Minimum Ks value, default 0.
#' @param min_aln_len Minimum alignment length, default 0.
#' @param min_idn Minimum alignment identity, default 0.
#' @param min_cov Minimum alignment coverage, default 0.
#'
#' @return A `ksv` object, which is a list including:
#'   * `ks_df`: the data frame that used for following analysis
#'   * `ks_dist`: a list including a vector of Ks values in the distribution
#'   * `raw_df`: raw data
#'   * `filters`: filters that applied to the raw data
#'
#'
read.wgd_ksd <- function(file, include_outliers=FALSE,
                         min_ks=0, min_aln_len=0,
                         min_idn=0, min_cov=0) {

  df <- read.table(file, sep="\t", header=TRUE)

  Ks <- AlignmentCoverage <- AlignmentLength <- AlignmentIdentity <- NULL
  WeightOutliersIncluded <- WeightOutliersExcluded <- NULL

  filtered_df <- df %>%
    dplyr::filter(Ks >= min_ks &
                    AlignmentCoverage >= min_cov &
                    AlignmentLength >= min_aln_len &
                    AlignmentIdentity >= min_idn)

  if (include_outliers == TRUE) {
    filtered_df <- filtered_df %>%
      dplyr::mutate(Weight=WeightOutliersIncluded)
  } else {
    filtered_df <- filtered_df %>%
      dplyr::mutate(Weight=WeightOutliersExcluded)
  }

  ksv_list <- list(ks_df=filtered_df,
                   ks_dist=generate_ksd(filtered_df),
                   raw_df=df,
                   filters=list(include_outliers=include_outliers,
                                  min_ks=min_ks,
                                  min_aln_len=min_aln_len,
                                  min_idn=min_idn,
                                  min_cov=min_cov,
                                  redundant=TRUE))

  class(ksv_list) <- "ksv"

  ksv_list
}

#' Check if an object is of class "ksv"
#'
#' This function checks if the provided object is of class "ksv."
#'
#' @param x The object to be checked.
#'
#' @return
#' Returns TRUE if the object is of class "ksv"; otherwise, returns FALSE.
#'
is.ksv <- function(x) {
  # if (class(x) == "ksv") {
  if (inherits(x, "ksv")) {
    TRUE
  } else {
    FALSE
  }
}

#' Generate Kernel Density Estimates (KDE) for Ks Distribution
#'
#' This function generates Kernel Density Estimates (KDE) for the Ks (synonymous substitution rates) distribution.
#'
#' @param ks_df A data frame containing Ks values.
#' @param bin_width The width of each bin for KDE calculation.
#' @param maxK The maximum Ks value for the distribution.
#'
#' @return A list containing the following components:
#'   - `Ks`: A numeric vector representing the KDE values.
#'   - `bin_width`: The width of each bin used for KDE calculation.
#'   - `maxK`: The maximum Ks value for the distribution.
#'
generate_ksd <- function(ks_df, bin_width=0.01, maxK=5) {

    full_df <- ks_df

    valuesPerBin <- bin_width / 0.01
    full_df$Ks.bin <- cut(full_df$Ks, seq(0, maxK, bin_width),
                          right=FALSE, include.lowest=TRUE)
    maxBin <- length(levels(full_df$Ks.bin))

    ks.aggregate <- stats::aggregate(full_df$Weight,
                                     by=list(ks.bin=full_df$Ks.bin),
                                     FUN=sum)

    ks.bin.df <- data.frame(
        ks.bin=cut(seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2,
                     seq(0, 5, bin_width),right=FALSE, include.lowest=TRUE),
        ks=seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2)

    ks.dist <- merge(ks.aggregate, ks.bin.df, by="ks.bin", all=TRUE)

    ksDist <- ks.dist$x
    ksValues <- NULL
    maxCount <- maxK * 100
    for (i in seq(1, maxCount)) {
        ks <- seq(bin_width, maxK, bin_width)
        if (is.na(ksDist[i])) {
            next
        } else {
            ksValues <- c(ksValues, rep(ks[i], ksDist[i]))
        }
    }

    ksd_list <- list(Ks=ksValues,
                     bin_width=bin_width,
                     maxK=maxK)
    ksd_list
}
