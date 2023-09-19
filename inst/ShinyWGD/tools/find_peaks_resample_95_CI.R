#' Find the peaks of a given distribution
#'
#' @param x the given distribution
#' @param m maximum peaks can be found, default 3
#'
#' @return
#' @export
#'
#' @examples
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

#' Find peaks in the Ks distribution
#'
#' @param ks a list of Ks value
#' @param binWidth width bin, default 0.1
#' @param maxK maximum Ks value, default 5
#' @param m maximum peaks, default 3
#' @param peak.maxK maximum Ks value to narrow the identification of peaks, default 2
#' @param spar smoothing parameter, default 0.25
#'
#' @return
#' @export
#'
#' @examples
PeaksInKsDistributionValues <- function(ks, binWidth=0.1, maxK=5,
                                        m=3, peak.maxK=2, spar=0.25) {
    
    ksDist <- hist(ks, seq(0, maxK, 0.01), plot=F)$counts
    
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

#' Generate the Ks distribution
#'
#' @param ksraw a list of Ks values
#' @param speciesName the name of a species, default NULL
#' @param maxK maximum Ks value, default 5
#'
#' @return
#' @export
#'
#' @examples
generateKsDistribution <- function(ksraw, speciesName=NULL, maxK=5) {
    ksDist <- hist(ksraw, seq(0, maxK, 0.01), plot=F)$counts
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

#' Re-sample the Ks distribution
#'
#' @param ks a list of Ks value
#' @param maxK maximum Ks value, default 5
#'
#' @return
#' @export
#'
#' @examples
resampleKsDistribution <- function(ks, maxK=5) {
    ksDist <- generateKsDistribution(ks, maxK=maxK)
    return(sample(x=ksDist, size=length(ksDist), replace=T))
}

#' Bootstrap the peaks of the Ks distribution
#'
#' @param ksRaw a list of Ks values
#' @param binWidth width bin, default 0.1
#' @param maxK maximum Ks value 5
#' @param m maximum number of peaks, default 3
#' @param peak.index index of peaks, default 1
#' @param peak.maxK the maximum Ks value of the peak, default 2
#' @param spar smoothing parameter, default 0.25
#' @param rep the replicates for bootstrap, default 10000
#' @param from minimum Ks value, default 0
#' @param to maximum Ks value, default maxK
#'
#' @return
#' @export
#'
#' @examples
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
