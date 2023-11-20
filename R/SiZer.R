#' SiZer (Significant Zero Crossings)
#'
#' The SiZer (Significant Zero Crossings) method is a technique used for assessing the statistical significance of zero crossings in data density estimation.
#'
#' @param x A numeric vector containing the data for which you want to calculate SiZer.
#' @param bw Bandwidth parameter for kernel density estimation. If not provided, default values are used.
#' @param gridsize A vector specifying the grid size for SiZer. Default is c(401, 151).
#' @param signifLevel The significance level for SiZer. Default is 0.05.
#'
#' @importFrom stats na.omit
#'
#' @return A list containing SiZer results, including the SiZer curve, the SiZer map, and the bandwidth.
#'
#' @examples
#' ks_value_tmp <- c(81.3724, 77.5539, 76.6121, 3.5945, 3.3308, -1, 15.4158, 2.7786, 1.8054)
#' df_sizer <- SiZer(
#'     ks_value_tmp,
#'     gridsize=c(500, 50),
#'     bw=c(0.01, 5)
#' )
SiZer <- function(x, bw, gridsize, signifLevel=0.05) {

	if (!is.vector(x)){
		stop("SiZer is currently only available for 1-dimensional data")
	}

	x <- na.omit(x)

	x <- as.matrix(x)
	tau <- 5

	d <- 1
	n <- length(x)

	if (missing(gridsize)) gridsize <- c(401,151)
	if (length(gridsize)==1) gridsize <- rep(gridsize, 2)

	gs <- gridsize[1]

	## Set some defaults
	if (missing(bw)){
		bw.range  <- dfltBWrange(x,tau)
		bw <- matrix(unlist(bw.range), nrow=2, byrow=FALSE)
	}
	else{
		bw <- matrix(bw, ncol=1, nrow=2)
	}

	range.x <- list(c(min(x), c(max(x))))

	dfltCounts.out  <- dfltCounts(x, gridsize=gs, apply(bw, 2, max), range.x=range.x)
	range.x <-dfltCounts.out$range.x
	gcounts <- dfltCounts.out$counts

	x.SiZer <- seq(range.x[[1]][1], range.x[[1]][2], length=gs)
	bw <- seq(log10(bw[1,1]), log10(bw[2,1]), length=gridsize[2])
	SiZer.map <- matrix(0, ncol=length(bw), nrow=length(x.SiZer))

	i <- 0
	for (logh in bw){
		h <- 10^logh
		i <- i + 1
		est.dens <- drvkde(gcounts,drv=0,bandwidth=h, binned=TRUE, range.x=range.x, se=FALSE)
		est.dens$est[est.dens$est<0] <- 0
		ESS <- n*est.dens$est*prod(h)*(sqrt(2*pi)^d)
		sig.ESS <- ESS >= 5

	  	SiZer.col <- rep(0, length(ESS))
	  	SiZer.col[sig.ESS] <- 1

	  	sig.deriv <- SignifFeatureRegion(n, d, gcounts, gridsize = gs,
										   est.dens, h, signifLevel,
			   							   range.x, grad=TRUE, curv=FALSE)
	  	sig.grad <- sig.deriv$grad
	  	est.grad <- drvkde(gcounts, drv = 1,
	  	                   bandwidth = h, binned = TRUE,
						   range.x = range.x, se = FALSE)$est
	  	SiZer.col[sig.ESS & sig.grad & est.grad >0] <- 2
	 	SiZer.col[sig.ESS & sig.grad & est.grad <0] <- 3
	  	SiZer.map[,i] <- SiZer.col
	}
	return(
	    list(
	        sizer=x.SiZer,
	        map=SiZer.map,
	        bw=bw
	    )
	)
}
