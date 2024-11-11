#' Find Peaks in a Numeric Vector
#'
#' This function identifies peaks in a numeric vector by analyzing the shape of the curve.
#'
#' @param x A numeric vector in which peaks will be identified.
#' @param m An integer indicating the half-width of the neighborhood to consider when identifying peaks. A larger value of `m` makes peak detection less sensitive.
#'
#' @return A numeric vector containing the indices of the identified peaks in the input vector `x`.
#'
#'
find_peaks <- function (x, m=3){
    shape <- diff(sign(diff(x, na.pad=FALSE)))
    pks <- sapply(which(shape < 0), FUN=function(i){
        z <- i - m + 1
        z <- ifelse(z > 0, z, 1)
        w <- i + m + 1
        w <- ifelse(w < length(x), w, length(x))
        if(all(x[c(z : i, (i + 2) : w)] <= x[i + 1])) return(i + 1) else return(numeric(0))
    })
    pks <- unlist(pks)

    return(pks)
}

#' Find Peaks in the Ks Distribution
#'
#' This function identifies peaks in a distribution of Ks (synonymous substitution rates) values.
# It performs a histogram analysis on the Ks values and detects peaks based on the smoothed curve.
# The function is useful for identifying modes or clusters in Ks distributions.
#
#' @param ks A numeric vector containing Ks values for which peaks will be identified.
#' @param binWidth A numeric value specifying the bin width for creating the histogram.
#' @param maxK A numeric value indicating the maximum Ks value to consider.
#' @param m An integer indicating the half-width of the neighborhood to consider when identifying peaks. A larger value of `m` makes peak detection less sensitive.
#' @param peak.maxK A numeric value specifying the maximum Ks value to consider when identifying peaks.
#' @param spar A numeric value controlling the smoothness of the spline fit. Higher values make the fit smoother.
#'
#' @importFrom graphics hist
#' @importFrom stats smooth.spline
#' @importFrom stats predict
#'
#' @return A numeric vector containing the identified peaks in the Ks distribution.
#'
PeaksInKsDistributionValues <- function(ks, binWidth=0.1, maxK=5,
                                        m=3, peak.maxK=2, spar=0.25) {

    ksDist <- hist(ks, seq(0, maxK, 0.01), plot=FALSE)$counts

    ksDistBinned <- NULL
    valuesPerBin <- binWidth / 0.01
    for (i in seq(1, 500, valuesPerBin)) {
        ks <- seq(0.01 * valuesPerBin / 2, 5, 0.01 * valuesPerBin)
        ksDistBinned=c(ksDistBinned, sum(ksDist[i:(i + valuesPerBin - 1)]))
    }
    maxBin=length(ks[ks <= maxK])
    s02 <- smooth.spline(ks[1:maxBin], ksDistBinned[1:maxBin], spar=spar)
    xx <- seq(0, maxK, 0.01)
    peaks <- xx[find_peaks(predict(s02, xx)$y, m=m)]
    peaks.max <- peaks[peaks <= peak.maxK]

    return(peaks.max)
}

#' Generate the Ks Distribution
#'
#' This function generates a Ks (synonymous substitution rates) distribution from raw Ks values.
# It calculates the histogram of Ks values and returns the binned Ks distribution.
#
#' @param ksraw A numeric vector containing raw Ks values.
#' @param speciesName (Optional) A character string specifying the species name associated with the Ks values.
#' @param maxK A numeric value indicating the maximum Ks value to consider in the distribution.
#'
#' @return A numeric vector containing the binned Ks distribution.
#'
generateKsDistribution <- function(ksraw, speciesName=NULL, maxK=5) {
    ksDist <- hist(ksraw, seq(0, maxK, 0.01), plot=FALSE)$counts
    ksDistBinned <- NULL
    valuesPerBin <- 1
    maxCount <- maxK * 100
    for (i in seq(1, maxCount, valuesPerBin)) {
        ks <- seq(0.01, maxK, 0.01 * valuesPerBin)
        if( !is.na(ksDist[i:(i + valuesPerBin - 1)]) ){
            ksDistBinned=c(ksDistBinned, rep(ks[i], sum(ksDist[i:(i + valuesPerBin - 1)])))
        }
    }
    return(ksDistBinned)
}

#' Resample a Ks Distribution
#'
#' This function resamples a given Ks (synonymous substitution rates) distribution.
# It generates a new sample of the Ks values based on the provided distribution.
#
#' @param ks A numeric vector representing the Ks distribution to be resampled.
#' @param maxK A numeric value indicating the maximum Ks value to consider in the distribution.
#'
#' @return A numeric vector containing a resampled Ks distribution.
#'
resampleKsDistribution <- function(ks, maxK=5) {
    ksDist <- generateKsDistribution(ks, maxK=maxK)
    return(sample(x=ksDist, size=length(ksDist), replace=TRUE))
}

#' Bootstrap Peaks in the Ks Distribution
#'
#' This function performs bootstrapping on a given Ks (synonymous substitution rates) distribution
#' to estimate peaks within the distribution.
#
#' @param ksRaw A numeric vector representing the raw Ks distribution to be bootstrapped.
#' @param binWidth A numeric value indicating the bin width for histogram calculation.
#' @param maxK A numeric value indicating the maximum Ks value to consider in the distribution.
#' @param m An integer specifying the parameter for peak detection.
#' @param peak.index An integer indicating the index of the peak to be estimated.
#' @param peak.maxK A numeric value indicating the maximum Ks value for peak estimation.
#' @param spar A numeric value controlling the smoothness of spline fitting.
#' @param rep An integer specifying the number of bootstrap repetitions.
#' @param from A numeric value indicating the lower bound for peak estimation.
#' @param to A numeric value indicating the upper bound for peak estimation.
#'
#' @return A numeric vector containing bootstrapped peak estimates.
#'
bootStrapPeaks <- function(ksRaw, binWidth=0.1, maxK=5, m=3, peak.index=1,
                           peak.maxK=2, spar=0.25, rep=1000, from=0, to=maxK) {
    peaks <- c()
    r=0
    while (r < rep) {
        s <- resampleKsDistribution(ksRaw, maxK=maxK)
        p <- PeaksInKsDistributionValues(ks=s, binWidth=binWidth, maxK=maxK, m=m,
                                         peak.maxK=peak.maxK, spar=spar)
        if (is.na(p[peak.index])) {
            next
        } else if (p[peak.index] < from || p[peak.index] > to) {
            next
        } else {
            peaks <- c(peaks, p[peak.index])
            r <- r + 1
        }
    }

    return(peaks)
}
