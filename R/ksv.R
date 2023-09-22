#' Read the output of Ks values for anchor pairs from the dating pipeline
#'
#' @param file Output file of Ks values for anchor pairs from the dating
#'   pipeline. If it a tabular file with Ks values not from the dating pipeline,
#'   please denote the column of Ks values using `ks_col`
#' @param ks_col Index of column for Ks values, default 9.
#' @param header Wheather the file has a header or not, default TRUE.
#'
#' @return A `ksv` object, which is a list including:
#'   * `ks_df`: the data frame that used for following analysis
#'   * `ks_dist`: a list including a vector of Ks values in the distribution
#'   * `raw_df`: raw data
#'   * `filters`: filters that applied to the raw data
#'
#' @seealso `generate_ksd`
#' @export
#'
#' @examples ksv <- read.dating_anchors(file)
read.dating_anchors <- function(file, ks_col = 9, header = TRUE) {

  df <- read.table(file, header = header)

  ks_value <- df[,ks_col]

  ks_df <- data.frame(Ks = ks_value, Weights = rep(1, length(ks_value)))
  ksv_list <- list(ks_df = ks_df,
                   ks_dist = generate_ksd(ks_df),
                   raw_df = df,
                   filters = list(include_outliers = NA,
                                  min_ks = NA,
                                  min_aln_len = NA,
                                  min_idn = NA,
                                  min_cov = NA,
                                  redundant = FALSE))

  class(ksv_list) <- "ksv"

  ksv_list
}

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
#' @export
#'
#' @examples ksv <- read.wgd_ksd(file)
read.wgd_ksd <- function(file, include_outliers = FALSE,
                         min_ks = 0, min_aln_len = 0,
                         min_idn = 0, min_cov = 0) {

  df <- read.table(file, sep = "\t", header = TRUE)

  filtered_df <- df %>%
    dplyr::filter(Ks >= min_ks &
                    AlignmentCoverage >= min_cov &
                    AlignmentLength >= min_aln_len &
                    AlignmentIdentity >= min_idn)

  if (include_outliers == TRUE) {
    filtered_df <- filtered_df %>%
      dplyr::mutate(Weight = WeightOutliersIncluded)
  } else {
    filtered_df <- filtered_df %>%
      dplyr::mutate(Weight = WeightOutliersExcluded)
  }

  ksv_list <- list(ks_df = filtered_df,
                   ks_dist = generate_ksd(filtered_df),
                   raw_df = df,
                   filters = list(include_outliers = include_outliers,
                                  min_ks = min_ks,
                                  min_aln_len = min_aln_len,
                                  min_idn = min_idn,
                                  min_cov = min_cov,
                                  redundant = TRUE))

  class(ksv_list) <- "ksv"

  ksv_list
}

#' Read file from KT pipeline
#'
#' @param file Output from KT pipeline
#'
#' @export
#'
#' @examples read_KTpipeline(file)
read_KTpipeline <- function(file) {
  ks_counts <- scan(file, skip = 1)

  ks <- seq(0.01, 5, 0.01)

  ks_df <- data.frame(Ks = ks, Ks_counts = ks_counts)
  ksValues <- NULL
  for (i in seq(1, length(ks))) {
    ksValues <- c(ksValues, rep(ks[i], ks_counts[i]))
  }

  ksd_list <- list(Ks = ksValues,
                   bin_width = 0.01,
                   maxK = 5)


  ksv_list <- list(ks_df = ks_df,
                   ks_dist = ksd_list,
                   raw_df = ks_df,
                   filters = list(include_outliers = FALSE,
                                  min_ks = 0,
                                  min_aln_len = 0,
                                  min_idn = 0,
                                  min_cov = 0,
                                  redundant = TRUE))

  class(ksv_list) <- "ksv"

  ksv_list
}

#' ksv class
#'
#' @export
#'
#' @examples is.ksv(x)
is.ksv <- function(x) {
  if (class(x) == "ksv") {
    TRUE
  } else {
    FALSE
  }
}

#' Convert
#'
#' @param ks_df A data frame including Ks and Weights.
#' @param bin_width Bin width for generating the distribution, default 0.01.
#' @param maxK Maximum Ks value for generating the distribution, default 5.
#'
#' @return A list including:
#'   *`Ks`: the Ks distribution;
#'   *`bin_width`: bin width;
#'   *`maxK`: maximum Ks.
#'
#' @examples generate_ksd(ks_df, bin_width=0.01)
generate_ksd <- function(ks_df, bin_width = 0.01, maxK = 5) {

  full_df <- ks_df

  valuesPerBin <- bin_width / 0.01
  full_df$Ks.bin <- cut(full_df$Ks, seq(0, maxK, bin_width),
                        right = F, include.lowest = T)
  maxBin <- length(levels(full_df$Ks.bin))

  ks.aggregate <- stats::aggregate(full_df$Weight,
                                   by = list(ks.bin=full_df$Ks.bin),
                                   FUN = sum)

  ks.bin.df <- data.frame(
    ks.bin = cut(seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2,
                 seq(0, 5, bin_width),right = F, include.lowest = T),
    ks = seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2)

  ks.dist <- merge(ks.aggregate, ks.bin.df, by = "ks.bin", all = TRUE)

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

  ksd_list <- list(Ks = ksValues,
                   bin_width = bin_width,
                   maxK = maxK)
  ksd_list
}

#' Draw Ks distribution using output from `wgd`
#'
#' @param file `ksd` output file from `wgd`, usually with a name `*.ks.tsv`
#' @param bin_width bin width of the histgram, default 0.1, minimum 0.01
#' @param maxK maximum Ks value, default 5
#' @param maxY maximum value for y-axis, default 1000
#' @param plot_mode modes to account for redundant duplicate, including `weighted` (default), `average`, `min`, and `pairwise`
#' @param color color of the histgram, default "darkgray"
#' @param pdf_file plot the figure in a pdf file with a specific name or not `NULL` (default)
#' @param include.outliers wheter to include outliers in the `wgd ksd` outpuf, default `FALSE`
#' @param minK minimum Ks value, default 0
#' @param minAlnLen minimum alignment length, default 0
#' @param minIdn minimum alignment identity, default 0
#' @param minCov minimum alignment coverage, default 0
#'
#' @export
#'
#' @examples
#' ksv <- read.wgd_ksd(file)
#' plot.ksv(ksv)
plot.ksv <- function(ksv, bin_width = 0.1, maxK = 5, maxY = 1000,
                     plot_mode = "weighted", color = "gray",
                     pdf_file = NULL, ...) {

  full_df <- ksv$ks_df

  # prepare Ks and weights
  if (plot_mode == "redundant" || ksv$filters$redundant == FALSE) {
    full_df$Weight <- 1

  } else if (plot_mode == "weighted") {
    full_df <- ksv$ks_df

  } else if (plot_mode == "average") {
    temp_df <- stats::aggregate(full_df$Ks,
                                by = list(full_df$Family, full_df$Node),
                                FUN = mean)
    colnames(temp_df) <- c("Family", "Node", "Ks")
    temp_df$Weight <- 1
    full_df <- temp_df

  } else if (plot_mode == "min") {
    temp_df <- stats::aggregate(full_df$Ks,
                                by = list(full_df$Family, full_df$Node),
                                FUN = min)
    colnames(temp_df) <- c("Family", "Node", "Ks")
    temp_df$Weight <- 1
    full_df <- temp_df

  } else if (plot_mode == "pairwise") {
    full_df$Weight <- 1

  } else {
    stop("plot_mode should be \"weighted\", \"average\",
         \"min\", or \"pairwise\"")
  }

  valuesPerBin <- bin_width / 0.01
  full_df$Ks.bin <- cut(full_df$Ks, seq(0, maxK, bin_width),
                        right = F, include.lowest = T)
  maxBin <- length(levels(full_df$Ks.bin))

  ks.aggregate <- stats::aggregate(full_df$Weight,
                                   by = list(ks.bin=full_df$Ks.bin),
                                   FUN = sum)

  ks.bin.df <- data.frame(
    ks.bin = cut(seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2,
                 seq(0, 5, bin_width),right = F, include.lowest = T),
    ks = seq(0, maxK, bin_width)[1:maxBin] + bin_width / 2)

  ks.dist <- merge(ks.aggregate, ks.bin.df, by = "ks.bin")

  if (is.null(pdf_file)) {
    par(mar = c(4, 5, 2, 1) + 0.2, cex.lab = 1.4, cex.axis = 1.2)
    plot(as.numeric(ks.dist$ks[1:maxBin]), ks.dist$x[1:maxBin], type="h",
         lwd = valuesPerBin * 0.9 * (5 / maxK),
         lend = 1, col = color,
         xlim = c(0, maxK), ylim = c(0, maxY),
         xlab = expression(italic(K)[S]),
         ylab = "Number of retained duplicates", bty = "n")
  } else {
    pdf(pdf_file, width = 7, height = 5)
    par(mar = c(4, 5, 2, 1) + 0.2, cex.lab = 1.4, cex.axis = 1.2)
    plot(as.numeric(ks.dist$ks[1:maxBin]), ks.dist$x[1:maxBin], type="h",
         lwd = valuesPerBin * 0.9 * (5 / maxK),
         lend = 1, col = color,
         xlim = c(0, maxK), ylim = c(0, maxY),
         xlab = expression(italic(K)[S]),
         ylab = "Number of retained duplicates", bty = "n")
    dev.off()
  }
}

#' Draw a density plot of ksv
#'
#' @param mids the data of ksv
#' @param counts counts
#' @param maxK maximum Ks
#' @param spar the smooth level
#' @param color color
#'
#' @export
#'
#' @examples plot_ksv_density(mids, count, 5)
plot_ksv_density <- function(mids, counts, maxK,
                             spar = 0.2, color = "#424242") {
  xx <- seq(0, maxK, 0.01)
  s02 <- stats::smooth.spline(mids, counts, spar = spar)
  graphics::lines(stats::predict(s02, xx), col = color, lwd = 1.6)
}

#' Convert
#'
#' @param file input file
#' @param species_name species name
#'
#' @export
#'
#' @examples convert_wgd2kevins(file, "rice")
convert_wgd2kevins <- function(file, species_name) {
  ks <- read.wgd_ksd(file)
  values <- generate_ksd(ks$ks_df)$Ks
  df <- as.data.frame(table(cut(values, seq(0, 5, 0.01), right = T)))
  df[,1] <- seq(0.01,5,0.01)
  outfile <- paste(species_name, "KsDistributionNew.txt", sep = "")
  write.table(df[,2], outfile, quote = F, row.names = FALSE)
}
