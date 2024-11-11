#' ksv class
#'
is.ksv <- function(x) {
    # if (class(x) == "ksv") {
    if (inherits(x, "ksv")) {
        TRUE
    } else {
        FALSE
    }
}

#' modeFinder
#'
#' Find the mode (peak) of a univariate distribution.
#'
#' @param x A numeric vector or a kernel density estimate (KDE).
#' @param bw Bandwidth for the KDE. Default is 0.1.
#' @param from Starting point for mode search. Default is 0.
#' @param to Ending point for mode search. Default is 5.
#'
#' @return The mode (peak) of the distribution.
#'
modeFinder <- function(x, bw = 0.1, from = 0, to = 5) {
    if (is.ksv(x)) {
        k <- x$ks.value
    } else {
        k <- x
    }
    d <- stats::density(k, bw = bw, from = from, to = to)
    peak <- d$x[which.max(d$y)]
    return(peak)
}

#' relativeRate
#'
#' Compute relative rates using input data files and statistical computations.
#'
#' @param ksv2out_1_file A character string specifying the path to the first input data file.
#' @param ksv2out_2_file A character string specifying the path to the second input data file.
#' @param ksv_between_file A character string specifying the path to the third input data file.
#' @param KsMax A numeric value representing a maximum threshold for Ks values.
#' @param low A numeric value specifying the lower quantile for bootstrapping. Default is 0.025.
#' @param up A numeric value specifying the upper quantile for bootstrapping. Default is 0.975.
#' @param bs An integer specifying the number of bootstrap iterations. Default is 1000.
#'
#' @importFrom stats quantile
#'
#' @return A list containing computed relative rates and their confidence intervals.
#'
relativeRate <- function(ksv2out_1_file, ksv2out_2_file, ksv_between_file, KsMax, low = 0.025, up = 0.975, bs = 1000) {
    ksv2out_1 <- read.table(ksv2out_1_file, sep="\t", header=TRUE)
    ksv2out_1 <- ksv2out_1[ksv2out_1$Ks <= KsMax, ]
    ksv2out_2 <- read.table(ksv2out_2_file, sep="\t", header=TRUE)
    ksv2out_2 <- ksv2out_2[ksv2out_2$Ks <= KsMax, ]
    ksv_between <- read.table(ksv_between_file, sep="\t", header=TRUE)
    ksv_between <- ksv_between[ksv_between$Ks <= KsMax, ]

    outgroup.d1 <- ksv2out_1$Ks
    outgroup.d2 <- ksv2out_2$Ks
    ingroup.d <- ksv_between$Ks
    moderel <- list()
    a.dist <- vector()
    b.dist <- vector()
    c.dist <- vector()
    for (i in seq(1:bs)) {
        a <- sample(outgroup.d1, size = length(outgroup.d1), replace = TRUE)
        b <- sample(outgroup.d2, size = length(outgroup.d2), replace = TRUE)
        c <- sample(ingroup.d, size = length(ingroup.d), replace = TRUE)
        a_mode <- .5 * (modeFinder(c) + modeFinder(a) - modeFinder(b))
        b_mode <- .5 * (modeFinder(c) + modeFinder(b) - modeFinder(a))
        c_mode <- .5 * (modeFinder(a) + modeFinder(b) - modeFinder(c))
        a.dist <- c(a.dist, a_mode)
        b.dist <- c(b.dist, b_mode)
        c.dist <- c(c.dist, c_mode)
    }

    moderel$a_mode <- modeFinder(a.dist)
    moderel$b_mode <- modeFinder(b.dist)
    moderel$c_mode <- modeFinder(c.dist)
    moderel$a_low_bound <- as.vector(quantile(a.dist, low))
    moderel$a_up_bound <- as.vector(quantile(a.dist, up))
    moderel$b_low_bound <- as.vector(quantile(b.dist, low))
    moderel$b_up_bound <- as.vector(quantile(b.dist, up))
    moderel$c_low_bound <- as.vector(quantile(c.dist, low))
    moderel$c_up_bound <- as.vector(quantile(c.dist, up))

    return(moderel)
}
