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


#' Title Draw KDE of a ksv object
#'
#' @param min.X default 0
#' @param max.X default 5
#' @param bin default 0.1
#' @param color "#66CC99"
#' @param draw.mode draw the mode of Ks distribution, default = F
#' @param x
#' @param draw.axis draw axis for the plot, default = F
#'
#' @return
#' @export
#'
#' @examples
plotKsDistDensity <- function(x, min.X = 0, max.X = 5, bin = 0.1, max.Y = 1,
                              color = "#66CC99", draw.mode = F,
                              draw.axis = TRUE) {
    
    color <- paste(color, "66", sep = "")
    
    x <- read.table(x, sep="\t", header=T)
    ks.max <- data.frame(Ks = x$Ks[x$Ks <= max.X])
    
    d <- density(ks.max$Ks, bw = bin, from = min.X, to = max.X)
    mode <- modeFinder(ks.max$Ks, bw = bin, from = min.X, to = max.X)
    
    if (draw.axis) {
        plot(NULL, xlim = c(min.X, max.X), ylim = c(0, max.Y), frame.plot = F,
             xlab = expression(italic(K)[S]), ylab = "Density")
        #plot(d, frame.plot = F, xlab = "Ks", ylab = "Density", xlim = c(0,max.X))
        lines(d$x, d$y, col = color)
        poly.y <- d$y
        poly.y[1] <- 0
        poly.y[length(poly.y)] <- 0
        polygon(d$x, poly.y, col=color, border = NA)
    } else {
        lines(d$x, d$y, col = color)
        poly.y <- d$y
        poly.y[1] <- 0
        poly.y[length(poly.y)] <- 0
        polygon(d$x, poly.y, col=color, border = NA)
    }
    
    if (draw.mode) {
        abline(v = mode, col = "red", lty = 2)
        mode.msg <- paste("Mode estimate: ", round(mode, 3))
        text(x = 2, y = 0.3, labels = mode.msg)
    }
}

#' Title Draw severl KDEs based a list ksv objects
#'
#' @param ksd.list a list of ksv
#' @param colors colors, default: automatically colors from autoColors()
#' @param ... parameters from plotKsDistDensity()
#'
#' @return
#' @export
#'
#' @examples
plotMultipleKsDensity <- function(ksd.list, colors = NA, ...) {
    if (length(ksd.list) != length(colors)) {
        simpleError("Different lengths of lists")
    }
    
    if (length(colors) != length(ksd.list)) {
        colors <- autoColors(length(ksd.list))
    }
    
    i <- 1
    plotKsDistDensity(ksd.list[[i]], color = colors[i], ...)
    for (i in 2:length(ksd.list)) {
        plotKsDistDensity(ksd.list[[i]], color = colors[i], draw.axis = FALSE, ...)
    }
    
}

#' Find the peak in a single mode distribution
#'
#' @param dist a ksv object or a vector of Ks values
#' @param bw binwidth in density(), default 0.1
#' @param from from in density(), default 0
#' @param to to in density(), default 5
#'
#' @return
#' @export
#'
#' @examples
modeFinder <- function(x, bw = 0.1, from = 0, to = 5) {
    if (is.ksv(x)) {
        k <- x$ks.value
    } else {
        k <- x
    }
    d <- density(k, bw = bw, from = from, to = to)
    peak <- d$x[which.max(d$y)]
    return(peak)
}

#' Title Calculate branch lengths in a three-way comparisons using the approach in the relative rate test
#'
#' @param ksv2out_1 a ksv object to outgroup
#' @param ksv2out_2 the other ksv object to to outgroup
#' @param ksv_between a ksv object between ingroup
#' @param low lower quantile for confidence interval (95% default), 0.025
#' @param up upper quantile for confidence interval (95% default), 0.975
#' @param bs bootstrap number, default 1000
#'
#' @return
#' @export
#'
#' @examples
relativeRate <- function(ksv2out_1_file, ksv2out_2_file, ksv_between_file, KsMax, low = 0.025, up = 0.975, bs = 1000) {
    ksv2out_1 <- read.table(ksv2out_1_file, sep="\t", header=T)
    ksv2out_1 <- ksv2out_1[ksv2out_1$Ks <= KsMax, ]
    ksv2out_2 <- read.table(ksv2out_2_file, sep="\t", header=T)
    ksv2out_2 <- ksv2out_2[ksv2out_2$Ks <= KsMax, ]
    ksv_between <- read.table(ksv_between_file, sep="\t", header=T)
    ksv_between <- ksv_between[ksv_between$Ks <= KsMax, ]
    
    outgroup.d1 <- ksv2out_1$Ks
    outgroup.d2 <- ksv2out_2$Ks
    ingroup.d <- ksv_between$Ks
    moderel <- list()
    a.dist <- vector()
    b.dist <- vector()
    c.dist <- vector()
    for (i in seq(1:bs)) {
        a <- sample(outgroup.d1, size = length(outgroup.d1), replace = T)
        b <- sample(outgroup.d2, size = length(outgroup.d2), replace = T)
        c <- sample(ingroup.d, size = length(ingroup.d), replace = T)
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

#' Title
#'
#' @param ksv2out_1 a ksv object to outgroup
#' @param ksv2out_2 the other ksv object to to outgroup
#' @param ksv_between a ksv object between ingroup
#' @param colors colors for ksv2out_1 and ksv2out_2, default autoColors(2)
#' @param maxX default 3
#' @param ... for relativeRate()
#'
#' @return
#' @export
#'
#' @examples
plotReleativRateKsBars <- function(ksv2out_1, ksv2out_2, ksv_between, maxX = 5, colors = NA, ...) {
    if (length(colors) != 2) {
        colors <- autoColors(2)
    }
    
    mode.3 <- relativeRate(ksv2out_1, ksv2out_2, ksv_between, KsMax=maxX, ...)
    ref_full <- mode.3$a_mode + mode.3$c_mode
    cal_full <- mode.3$b_mode + mode.3$c_mode
    
    par(mar = c(0.5, 4.1, 1, 1.1), cex.lab = 1.4, cex.axis = 1.2)
    plot(NULL, xlim = c(0, maxX), ylim = c(0,3.5),
         frame.plot = F, xlab = NA, ylab = NA, axes = F)
    
    shape::Arrows(mode.3$c_mode, 1, 0, 1, col = "grey", arr.type = "triangle", arr.adj = 1, arr.length = 0.2)
    segments(mode.3$c_mode, 1, mode.3$c_mode, 3, col=colors[2])
    shape::Arrows(mode.3$c_mode, 1, ref_full, 1, col=colors[1], arr.type = "triangle", arr.adj = 1, arr.length = 0.2)
    shape::Arrows(mode.3$c_mode, 3, cal_full, 3, col=colors[2], arr.type = "triangle", arr.adj = 1, arr.length = 0.2)
    points(mode.3$c_mode, 1, pch = 20, cex = 0.6)
    
    rect(mode.3$c_low_bound, 1-0.25, mode.3$c_up_bound, 1+0.25, col = "#8080804D", border = NA)
    
    title1 <- gsub(".ks.tsv", "", basename(ksv2out_1))
    title2 <- gsub(".ks.tsv", "", basename(ksv2out_2))
    titleB <- gsub(".ks.tsv", "", basename(ksv_between))
    
    
    # numbers
    text(0.6, 1.6, round(mode.3$c_mode, 3), col = "grey")
    text(0.6, 0.6, titleB)
    text(1.4, 1.6, round(mode.3$a_mode, 3), col = colors[1])
    text(3.1, 1.6, title1, col=colors[1])
    text(1.4, 3.6, round(mode.3$b_mode, 3), col = colors[2])
    text(3.1, 3.6, title2, col=colors[2])
}

#' Title Draw results for relative rate test
#'
#' @param ksv2out_1 a ksv object to outgroup
#' @param ksv2out_2 the other ksv object to to outgroup
#' @param ksv_between a ksv object between ingroup
#' @param colors colors for ksv2out_1 and ksv2out_2, default autoColors(2)
#' @param ... for relativeRate()
#'
#' @return
#' @export
#'
#' @examples
plotReleativRateKsDensity <- function(ksv2out_1, ksv2out_2, ksv_between, maxX = 5, colors = NA, ...) {
    if (is.na(colors)) {
        colors <- autoColors(3)
    }
    
    par(xpd = NA) 
    layout(matrix(c(rep(1,1),rep(2,5))))
    
    plotReleativRateKsBars(ksv2out_1, ksv2out_2, ksv_between, maxX = maxX, colors = colors)
    
    par(mar = c(5.1, 4.1, 0.5, 1.1), cex.lab = 1.4, cex.axis = 1.2)
    plotMultipleKsDensity(list(ksv2out_1, ksv2out_2), color = colors, max.X = maxX)
    
}

#' Color palette
#'
#' @param num number of colors
#' @param spectrum a vector of some colors to form a scale
#'
#' @return
#' @export
#'
#' @examples
autoColors <- function(num = 5, spectrum = c("#F15A5A",
                                             "#F0C419",
                                             "#4EBA6F",
                                             "#2D95BF",
                                             "#955BA5")) {
    colfunc <- colorRampPalette(spectrum)
    return(colfunc(num))
    
}

