########## R function: SignifFeatureRegion ##########

# For determining the region of significant
# gradient for a particular bandwidth and
# significance level.

# Last changed: 18 JAN 2006

#' SignifFeatureRegion
#'
#' This function computes the significance of features based on gradient and curvature analysis.
#'
#' @param n The sample size.
#' @param d The dimensionality of the data.
#' @param gcounts A numeric vector representing data counts.
#' @param gridsize A numeric vector specifying the grid size.
#' @param dest A kernel density estimate.
#' @param bandwidth The bandwidth parameter.
#' @param signifLevel The significance level.
#' @param range.x The range of x values.
#' @param grad A logical value indicating whether to compute the gradient significance.
#' @param curv A logical value indicating whether to compute the curvature significance.
#' @param neg.curv.only A logical value indicating whether to consider negative curvature only.
#'
#' @importFrom stats pchisq
#'
#' @return A list containing the significance results for gradient and curvature.
#'
SignifFeatureRegion <- function(n, d, gcounts, gridsize, dest, bandwidth, signifLevel, range.x, grad=TRUE, curv=TRUE, neg.curv.only=TRUE)
{
  h <- bandwidth

  ESS <- n*dest$est*prod(h)*(sqrt(2*pi)^d)
  SigESS <- ESS >= 5

  Sig.scalar <- array(NA, dim=gridsize)
  Sig2.scalar <- array(NA, dim=gridsize)

  dest$est[dest$est<0] <- 0
  ## constant for variance of gradient estimate
  Sig.scalar <- 1/2*(2*sqrt(pi))^(-d)*n^(-1)*prod(h)^(-1)*dest$est

  ##  constants for variance of curvature estimate
  if (d==1)
    Sig2.scalar <- (8*sqrt(pi)*n*prod(h))^(-1)*dest$est
  else if (d==2)
    Sig2.scalar <- (16*pi*n*prod(h))^(-1)*dest$est
  else if (d==3)
    Sig2.scalar <- (32*pi^(3/2)*n*prod(h))^(-1)*dest$est
  else if (d==4)
    Sig2.scalar <- (64*pi^2*n*prod(h))^(-1)*dest$est

  ## Matrix square root - taken from Stephen Lake
  ## http://www5.biostat.wustl.edu/s-news/s-news-archive/200109/msg00067.html

  matrix.sqrt <- function(A)
  {
    sva <- svd(A)
    if (min(sva$d)>=0)
      Asqrt <- sva$u %*% diag(sqrt(sva$d)) %*% t(sva$v)
    else
      stop("Matrix square root is not defined")
    return(Asqrt)
  }


  if (d>1)
  {
    WaldGrad <- array(NA, dim=gridsize)
    WaldCurv <- array(NA, dim=gridsize)
    local.mode <- array(FALSE, dim=gridsize)
  }

  if (d==1)
  {
    if (grad)
    {
      obj1 <- drvkde(gcounts, drv=1, bandwidth=h, binned=TRUE, range.x=range.x, se=FALSE)
      fhat1 <- obj1$est

      Sig.inv12 <- 1/sqrt(Sig.scalar * h^(-2))
      WaldGrad <- (Sig.inv12 * fhat1)^2
    }

    if (curv)
    {
      obj2 <- drvkde(gcounts,drv=2,bandwidth=h,binned=TRUE,range.x=range.x, se=FALSE)
      fhat2 <- obj2$est

      Sig2.inv12 <- 1/sqrt(Sig2.scalar * 3*h^(-4))
      lambda1 <- Sig2.inv12 * fhat2
      WaldCurv <- lambda1^2
      local.mode <- (lambda1 < 0)
    }
  }

  if (d==2)
  {
    if (grad)
    {
      obj10 <- drvkde(gcounts,drv=c(1,0),bandwidth=h,binned=TRUE,
                      range.x=range.x,se=FALSE)
      obj01 <- drvkde(gcounts,drv=c(0,1),bandwidth=h,binned=TRUE,
                      range.x=range.x,se=FALSE)
      fhat10 <- obj10$est
      fhat01 <- obj01$est

      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          if (SigESS[i1,i2])
          {
            Sig.inv12 <- 1/sqrt(Sig.scalar[i1,i2] * h^(-2))
            WaldGrad[i1,i2] <- sum((Sig.inv12 * c(fhat10[i1,i2], fhat01[i1,i2]))^2)
          }
    }


    if (curv)
    {
      Sig2.mat <-
        matrix(c(3/h[1]^4, 0, 1/(h[1]^2*h[2]^2),
                 0, 1/(h[1]^2*h[2]^2), 0,
                 1/(h[1]^2*h[2]^2), 0, 3/h[2]^4),
               nrow=3, ncol=3)

      Sig2.mat.inv <- chol2inv(chol(Sig2.mat))

      obj20 <- drvkde(gcounts,drv=c(2,0),bandwidth=h,
                      binned=TRUE,range.x=range.x, se=FALSE)
      obj11 <- drvkde(gcounts,drv=c(1,1),bandwidth=h,
                      binned=TRUE,range.x=range.x, se=FALSE)
      obj02 <- drvkde(gcounts,drv=c(0,2),bandwidth=h,
                      binned=TRUE,range.x=range.x, se=FALSE)
      fhat20 <- obj20$est
      fhat11 <- obj11$est
      fhat02 <- obj02$est

      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          if (SigESS[i1,i2])
          {
            Sig2.inv12 <- sqrt(1/Sig2.scalar[i1,i2])*matrix.sqrt(Sig2.mat.inv)
            fhat.temp <- Sig2.inv12 %*%
              c(fhat20[i1,i2], fhat11[i1,i2], fhat02[i1,i2])

            WaldCurv[i1,i2] <- sum(fhat.temp^2)
          }

      lambda1 <- ((fhat20 + fhat02) - sqrt((fhat20-fhat02)^2 + 4*fhat11^2))/2
      lambda2 <- ((fhat20 + fhat02) + sqrt((fhat20-fhat02)^2 + 4*fhat11^2))/2
      local.mode <- (lambda1 < 0) & (lambda2 < 0)
    }
  }


  if (d==3)
  {
    if (grad)
    {
      obj100 <- drvkde(gcounts,drv=c(1,0,0),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj010 <- drvkde(gcounts,drv=c(0,1,0),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj001 <- drvkde(gcounts,drv=c(0,0,1),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)

      fhat100 <- obj100$est
      fhat010 <- obj010$est
      fhat001 <- obj001$est

      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          for (i3 in 1:gridsize[3])
            if (SigESS[i1,i2,i3])
            {
              Sig.inv12 <- 1/sqrt(Sig.scalar[i1,i2,i3] * h^(-2))
              WaldGrad[i1,i2,i3] <-
                sum((Sig.inv12 * c(fhat100[i1,i2,i3], fhat010[i1,i2,i3],
                                   fhat001[i1,i2,i3]))^2)
            }
    }


    if (curv)
    {
      obj200 <- drvkde(gcounts,drv=c(2,0,0),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj110 <- drvkde(gcounts,drv=c(1,1,0),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj101 <- drvkde(gcounts,drv=c(1,0,1),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj020 <- drvkde(gcounts,drv=c(0,2,0),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj011 <- drvkde(gcounts,drv=c(0,1,1),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      obj002 <- drvkde(gcounts,drv=c(0,0,2),bandwidth=h,
                       binned=TRUE,range.x=range.x, se=FALSE)
      fhat200 <- obj200$est
      fhat110 <- obj110$est
      fhat101 <- obj101$est
      fhat020 <- obj020$est
      fhat011 <- obj011$est
      fhat002 <- obj002$est

      Sig2.mat <-
        matrix(c(3/h[1]^4, 0, 0, 1/(h[1]*h[2])^2, 0, 1/(h[1]*h[3])^2,
                 0, 1/(h[1]*h[2])^2, 0, 0, 0, 0,
                 0, 0, 1/(h[1]*h[3])^2, 0, 0, 0,
                 1/(h[1]*h[2])^2, 0, 0, 3/h[2]^4, 0, 1/(h[2]*h[3])^2,
                 0, 0, 0, 0, 1/(h[2]*h[3])^2, 0,
                 1/(h[1]*h[3])^2, 0, 0, 1/(h[2]*h[3])^2, 0, 3/h[3]^4),
               nrow=6, ncol=6)

      Sig2.mat.inv <- chol2inv(chol(Sig2.mat))

      ## at each grid point, find eigenvalues of vech'ed curvature matrix
      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          for (i3 in 1:gridsize[3])
            if (SigESS[i1,i2,i3])
            {
              Sig2.inv12 <- sqrt(1/Sig2.scalar[i1,i2,i3]) *
                matrix.sqrt(Sig2.mat.inv)
              fhat.temp <- Sig2.inv12 %*%
                c(fhat200[i1,i2,i3], fhat110[i1,i2,i3], fhat101[i1,i2,i3],
                  fhat020[i1,i2,i3], fhat011[i1,i2,i3], fhat002[i1,i2,i3])

              D2.mat <-
                matrix(c(fhat200[i1,i2,i3], fhat110[i1,i2,i3], fhat101[i1,i2,i3],
                         fhat110[i1,i2,i3], fhat020[i1,i2,i3], fhat011[i1,i2,i3],
                         fhat101[i1,i2,i3], fhat011[i1,i2,i3], fhat002[i1,i2,i3]),
                       nrow=3)
              lambda <- eigen(D2.mat, symmetric=TRUE, only.values=TRUE)$values

              WaldCurv[i1,i2,i3] <- sum(fhat.temp^2)

              local.mode[i1,i2,i3] <- all(lambda < 0)
          }
    }

  }

  if (d==4)
  {
    if (grad)
    {
      obj1000 <- drvkde(gcounts,drv=c(1,0,0,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0100 <- drvkde(gcounts,drv=c(0,1,0,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0010 <- drvkde(gcounts,drv=c(0,0,1,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0001 <- drvkde(gcounts,drv=c(0,0,0,1),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)

      fhat1000 <- obj1000$est
      fhat0100 <- obj0100$est
      fhat0010 <- obj0010$est
      fhat0001 <- obj0001$est

      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          for (i3 in 1:gridsize[3])
            for (i4 in 1:gridsize[4])
              if (SigESS[i1,i2,i3,i4])
              {
                Sig.inv12 <- 1/sqrt(Sig.scalar[i1,i2,i3,i4] * h^(-2))
                WaldGrad[i1,i2,i3,i4] <-
                  sum((Sig.inv12*c(fhat1000[i1,i2,i3,i4],fhat0100[i1,i2,i3,i4],
                                   fhat0010[i1,i2,i3,i4],fhat0001[i1,i2,i3,i4]))^2)
              }
    }

    if (curv)
    {
      obj2000 <- drvkde(gcounts,drv=c(2,0,0,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj1100 <- drvkde(gcounts,drv=c(1,1,0,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj1010 <- drvkde(gcounts,drv=c(1,0,1,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj1001 <- drvkde(gcounts,drv=c(1,0,0,1),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0200 <- drvkde(gcounts,drv=c(0,2,0,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0110 <- drvkde(gcounts,drv=c(0,1,1,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0101 <- drvkde(gcounts,drv=c(0,1,0,1),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0020 <- drvkde(gcounts,drv=c(0,0,2,0),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0011 <- drvkde(gcounts,drv=c(0,0,1,1),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)
      obj0002 <- drvkde(gcounts,drv=c(0,0,0,2),bandwidth=h,
                        binned=TRUE,range.x=range.x, se=FALSE)

      fhat2000 <- obj2000$est
      fhat1100 <- obj1100$est
      fhat1010 <- obj1010$est
      fhat1001 <- obj1001$est
      fhat0200 <- obj0200$est
      fhat0110 <- obj0110$est
      fhat0101 <- obj0101$est
      fhat0020 <- obj0020$est
      fhat0011 <- obj0011$est
      fhat0002 <- obj0002$est

      Sig2.mat <-
        matrix(c(3/h[1]^4, 0, 0, 0, 1/(h[1]*h[2])^2, 0, 0, 1/(h[1]*h[3])^2, 0, 1/(h[1]*h[4])^2,
                 0, 1/(h[1]*h[2])^2, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 1/(h[1]*h[3])^2, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 1/(h[1]*h[4])^2, 0, 0, 0, 0, 0, 0,
                 1/(h[1]*h[2])^2, 0, 0, 0, 3/h[2]^4, 0, 0, 1/(h[2]*h[3])^2, 0, 1/(h[2]*h[4])^2,
                 0, 0, 0, 0, 0, 1/(h[2]*h[3])^2, 0, 0, 0, 0,
                 0, 0, 0, 0 ,0, 0, 1/(h[2]*h[4])^2, 0, 0, 0,
                 1/(h[1]*h[3])^2, 0, 0, 0, 1/(h[2]*h[3])^2, 0, 0, 3/h[3]^4, 0, 1/(h[3]*h[4])^2,
                 0, 0, 0, 0, 0, 0, 0, 0, 1/(h[3]*h[4])^2, 0,
                 1/(h[1]*h[4])^2, 0, 0, 0, 1/(h[2]*h[4])^2, 0, 0, 1/(h[3]*h[4])^2, 0, 3/h[4]^4),
               nrow=10, ncol=10)

      Sig2.mat.inv <- chol2inv(chol(Sig2.mat))

      for (i1 in 1:gridsize[1])
        for (i2 in 1:gridsize[2])
          for (i3 in 1:gridsize[3])
            for (i4 in 1:gridsize[4])
              if (SigESS[i1,i2,i3,i4])
              {
                Sig2.inv12 <- sqrt(1/Sig2.scalar[i1,i2,i3,i4]) *
                  matrix.sqrt(Sig2.mat.inv)
                fhat.temp <- Sig2.inv12 %*%
                  c(fhat2000[i1,i2,i3,i4], fhat1100[i1,i2,i3,i4],
                    fhat1010[i1,i2,i3,i4], fhat1001[i1,i2,i3,i4],
                    fhat0200[i1,i2,i3,i4], fhat0110[i1,i2,i3,i4],
                    fhat0101[i1,i2,i3,i4], fhat0020[i1,i2,i3,i4],
                    fhat0011[i1,i2,i3,i4], fhat0002[i1,i2,i3,i4])

                D2.mat <-
                  matrix(c(fhat2000[i1,i2,i3,i4], fhat1100[i1,i2,i3,i4], fhat1010[i1,i2,i3,i4], fhat1001[i1,i2,i3,i4],
                           fhat1100[i1,i2,i3,i4], fhat0200[i1,i2,i3,i4], fhat0110[i1,i2,i3,i4], fhat0101[i1,i2,i3,i4],
                           fhat1010[i1,i2,i3,i4], fhat0110[i1,i2,i3,i4], fhat0020[i1,i2,i3,i4], fhat0011[i1,i2,i3,i4],
                           fhat1001[i1,i2,i3,i4], fhat0101[i1,i2,i3,i4], fhat0011[i1,i2,i3,i4], fhat0002[i1,i2,i3,i4]),
                         nrow=4)
                WaldCurv[i1,i2,i3,i4] <- sum(fhat.temp^2)
                lambda <- eigen(D2.mat, symmetric=TRUE, only.values=TRUE)$values

                local.mode[i1,i2,i3,i4] <- all(lambda < 0)
              }
    }
  }


  ## multiple hypothesis testing - based on Hochberg's method
  ## - modified Bonferroni method using ordered p-values

  ## test statistic for gradient
  if (grad)
  {
    pval.Grad <- 1 - pchisq(WaldGrad, d)
    pval.Grad.ord <- pval.Grad[order(pval.Grad)]
    num.test <- sum(!is.na(pval.Grad.ord))

    if (num.test>=1)
      num.test.seq <- c(1:num.test, rep(NA, prod(gridsize) - num.test))
    else
      num.test.seq <- rep(NA, prod(gridsize))

    reject.nonzero <- ((pval.Grad.ord <= signifLevel/(num.test + 1 - num.test.seq)) &
                       (pval.Grad.ord > 0))
    reject.nonzero.ind <- which(reject.nonzero)

    ## p-value == 0 => reject null hypotheses automatically
    SignifGrad <- array(FALSE, dim=gridsize)
    SignifGrad[which(pval.Grad==0, arr.ind=TRUE)] <- TRUE

    ## p-value > 0 then reject null hypotheses indicated in reject.nonzero.ind
    for (i in reject.nonzero.ind)
      SignifGrad[which(pval.Grad==pval.Grad.ord[i], arr.ind=TRUE)] <- TRUE
  }

  ## test statistic for curvature
  if (curv)
  {
    pval.Curv <- 1 - pchisq(WaldCurv, d*(d+1)/2)
    pval.Curv.ord <- pval.Curv[order(pval.Curv)]
    num.test <- sum(!is.na(pval.Curv.ord))

    if (num.test>=1)
      num.test.seq <- c(1:num.test, rep(NA, prod(gridsize) - num.test))
    else
      num.test.seq <- rep(NA, prod(gridsize))
    reject.nonzero <- ((pval.Curv.ord <= signifLevel/(num.test + 1 - num.test.seq)) &(pval.Curv.ord > 0))
    reject.nonzero.ind <- which(reject.nonzero)

    SignifCurv <- array(FALSE, dim=gridsize)

    ## p-value == 0 => reject null hypotheses automatically
    SignifCurv[which(pval.Curv==0, arr.ind=TRUE)] <- TRUE

    ## p-value > 0 then reject null hypotheses indicated in reject.nonzero.ind
    for (i in reject.nonzero.ind)
      SignifCurv[which(pval.Curv==pval.Curv.ord[i], arr.ind=TRUE)] <- TRUE

    if (neg.curv.only) SignifCurv <- SignifCurv & local.mode
  }

  if (grad & !curv)
    return(list(grad=SignifGrad))
  else if (!grad & curv)
    return(list(curv=SignifCurv))
  else if (grad & curv)
    return(list(grad=SignifGrad, curv=SignifCurv))
}


########## End of SignifFeatureRegion ##########

# These are from package feature. They not exprted in the package.
######### R-function dfltBWrange  #########

# Obtain default set of grid counts from a
# multivariate point cloud 'x'.

# Last changed: 22 JUL 2005


#' dfltBWrange
#'
#' This function computes the default bandwidth range for kernel density estimation.
#'
#' @param x The input data, which can be a numeric vector or matrix.
#' @param tau A parameter used in bandwidth calculation.
#'
#' @return A list of bandwidth ranges for each dimension of the input data.
#'
dfltBWrange <- function(x,tau) {
  d <- ncol(x)
  if (d==1) x <- as.matrix(x)

  r <- 2
  cmb.fac.upp <- (4/((d+2*r+2)*nrow(x)))^(1/(d+2*r+4))
  r <- 0
  cmb.fac.low <- (4/((d+2*r+2)*nrow(x)))^(1/(d+2*r+4))

  sd <- IQR <- NULL
  ## Compute the scale in each direction
  st.devs <- apply(x,2,sd)
  IQR.vals <- apply(x, 2, IQR)/(stats::qnorm(3/4) - stats::qnorm(1/4))
  sig.hats <- apply(cbind(st.devs,IQR.vals),1,min)
  ##range.vals <- apply(x,2,max) - apply(x,2,min)

  range.h <- list()
  for (id in 1:d)
  {
    h.upp <- cmb.fac.upp*sig.hats[id]
    h.low <- 0.1*cmb.fac.low*sig.hats[id] ##3*(range.vals[id] + 2*tau*h.upp)/((gridsize[id]-1)*tau)
    range.h[[id]] <- c(h.low,h.upp)
  }

  return(range.h)
}

######## End of dfltBWrange ########
######### R-function:dfltCounts  #########
# Obtain default set of grid counts from a
# multivariate point cloud 'x'.
# Last changed: 18 JUL 2005

#' dfltCounts
#'
#' This function bins the input data into a regular grid.
#'
#' @param x The input data, which should be a numeric matrix.
#' @param gridsize A vector specifying the number of bins along each dimension.
#' @param h A vector specifying the bandwidth (smoothing parameter) along each dimension.
#' @param supp A parameter for determining the range of the bins.
#' @param range.x A list specifying the range of values for each dimension.
#' @param w A vector of weights for the data points.
#'
#' @return A list containing the binned counts and the range of values for each dimension.
#'
dfltCounts <- function(x,gridsize=rep(64,NCOL(x)),h=rep(0,NCOL(x)), supp=3.7, range.x, w)
{
  x <- as.matrix(x)
  d <- ncol(x)
  n <- nrow(x)
  if (missing(w)) w <- rep(1,n)

  if (missing(range.x))
  {
    range.x <- list()
    for (id in 1:d)
      range.x[[id]] <- c(min(x[,id])-supp*h[id],max(x[,id])+supp*h[id])
  }

  a <- unlist(lapply(range.x,min))
  b <- unlist(lapply(range.x,max))

  gpoints <- list()
  for (id in 1:d)
    gpoints[[id]] <- seq(a[id],b[id],length=gridsize[id])

  if ((d!=1)&(d!=2)&(d!=3)&(d!=4)) stop("binning implemented only for d=1,2,3,4")

  if (d==1) gcounts <- ks::binning(x=x, bgridsize=gridsize, h=h, xmin=a, xmax=b, w=w)$counts
  else if (d>1) gcounts <- ks::binning(x=x, bgridsize=gridsize, H=diag(h^2), xmin=a, xmax=b, w=w)$counts

  ##if (d==1) gcounts <- linbin.ks(x,gpoints[[1]], w=w)
  ##if (d==2) gcounts <- linbin2D.ks(x,gpoints[[1]],gpoints[[2]], w=w)
  ##if (d==3) gcounts <- linbin3D.ks(x,gpoints[[1]],gpoints[[2]],gpoints[[3]], w=w)
  ##if (d==4) gcounts <- linbin4D.ks(x,gpoints[[1]],gpoints[[2]],gpoints[[3]],gpoints[[4]], w=w)

  return(list(counts=gcounts,range.x=range.x))
}

######## End of dfltCounts ########

#####################################################################
## Matt Wand's version of binned kernel density derivative estimation
##
## Computes the mth derivative of a binned
## d-variate kernel density estimate based
## on grid counts.
#############################################################

#' drvkde
#'
#' Compute the mth derivative of a binned d-variate kernel density estimate based on grid counts.
#'
#' @param x The input data.
#' @param drv The order of the derivative to compute.
#' @param bandwidth The bandwidth (smoothing parameter) along each dimension.
#' @param gridsize The size of the grid.
#' @param range.x A list specifying the range of values for each dimension.
#' @param binned A logical indicating whether the input data is already binned.
#' @param se A logical indicating whether to compute standard errors.
#' @param w A vector of weights for the data points.
#'
#' @return A list containing the estimated density or derivative, and optionally, standard errors.
#'
drvkde <- function(x,drv,bandwidth,gridsize,range.x,binned=FALSE,se=TRUE, w)
{
  d <- length(drv)
  if (d==1) x <- as.matrix(x)

  ## Rename common variables
  h <- bandwidth
  tau <- 4 + max(drv)
  if (length(h)==1) h <- rep(h,d)

  if (missing(gridsize))
    if (!binned)   ## changes 16/02/2009
    {
      if (d==1) gridsize <- 401
      else if (d==2) gridsize <- rep(151,d)
      else if (d==3) gridsize <- rep(51, d)
      else if (d==4) gridsize <- rep(21, d)
    }
  else
  {
    if (d==1) gridsize <- dim(x)[1]
    else gridsize <- dim(x)
  }

  if(missing(w)) w <- rep(1,nrow(x))
  ## Bin the data if not already binned

  if (missing(range.x))
  {
    range.x <- list()
    for (id in 1:d)
      range.x[[id]] <- c(min(x[,id])-tau*h[id],max(x[,id])+tau*h[id])
  }

  a <- unlist(lapply(range.x,min))
  b <- unlist(lapply(range.x,max))

  M <- gridsize
  gpoints <- list()

  for (id in 1:d)
    gpoints[[id]] <- seq(a[id],b[id],length=M[id])

  if (binned==FALSE)
  {
    if (d==1) gcounts <- ks::binning(x=x, bgridsize=gridsize, h=h, xmin=a, xmax=b, w=w)$counts
    else if (d>1) gcounts <- ks::binning(x=x, bgridsize=gridsize, H=diag(h^2), xmin=a, xmax=b, w=w)$counts
  }
  else
    gcounts <- x

  n <- sum(gcounts)

  kapmid <- list()
  for (id in (1:d))
  {
    ## changes to Lid 13/02/2009
    Lid <- max(min(floor(tau*h[id]*(M[id]-1)/(b[id]-a[id])),M[id]),d)
    lvecid <- (0:Lid)
    facid  <- (b[id]-a[id])/(h[id]*(M[id]-1))
    argid <- lvecid*facid
    kapmid[[id]] <- stats::dnorm(argid)/(h[id]^(drv[id]+1))
    hmold0 <- 1
    hmold1 <- argid
    if (drv[id]==0) hmnew <- 1
    if (drv[id]==1) hmnew <- argid
    if (drv[id] >= 2)
      for (ihm in (2:drv[id]))
      {
        hmnew <- argid*hmold1 - (ihm-1)*hmold0
        hmold0 <- hmold1   # Compute drv[id] degree Hermite polynomial
        hmold1 <- hmnew    # by recurrence.
      }
    kapmid[[id]] <- hmnew*kapmid[[id]]*(-1)^drv[id]
  }

  if (d==1) kappam <- kapmid[[1]]/n
  if (d==2) kappam <- outer(kapmid[[1]],kapmid[[2]])/n
  if (d==3) kappam <- outer(kapmid[[1]],outer(kapmid[[2]],kapmid[[3]]))/n
  if (d==4) kappam <- outer(kapmid[[1]],outer(kapmid[[2]],outer(kapmid[[3]],kapmid[[4]])))/n

  if (!any(c(d==1,d==2,d==3,d==4))) stop("only for d=1,2,3,4")

  if (d==1)
  {
    est <- symconv.ks(kappam,gcounts,skewflag=(-1)^drv)
    if (se) est.var <- ((symconv.ks((n*kappam)^2,gcounts)/n) - est^2)/(n-1)
  }

  if (d==2)
  {
    ##est <- ks:::symconv.nd(kappam,gcounts,d=d)
    ##if (se) est.var <- ((ks:::symconv.nd((n*kappam)^2,gcounts,d=d)/n) - est^2)/(n-1)
    est <- symconv2D.ks(kappam,gcounts,skewflag=(-1)^drv)
    if (se) est.var <- ((symconv2D.ks((n*kappam)^2,gcounts)/n) - est^2)/(n-1)
  }

  if (d==3)
  {
    est <- symconv3D.ks(kappam,gcounts,skewflag=(-1)^drv)
    if (se) est.var <- ((symconv3D.ks((n*kappam)^2,gcounts)/n) - est^2)/(n-1)
  }

  if (d==4)
  {
    est <- symconv4D.ks(kappam,gcounts,skewflag=(-1)^drv)
    if (se) est.var <- ((symconv4D.ks((n*kappam)^2,gcounts)/n) - est^2)/(n-1)
  }

  if (se)
  {
    est.var[est.var<0] <- 0
    return(list(x.grid=gpoints,est=est,se=sqrt(est.var)))
  }
  else if (!se)
    return(list(x.grid=gpoints,est=est))
}


########################################################################
## Discrete convolution
########################################################################


## Computes the discrete convolution of
## a symmetric or skew-symmetric response
## vector r and a data vector s.
## If r is symmetric then "skewflag"=1.
## If r is skew-symmetric then "skewflag"=-1.


#' symconv.ks
#'
#' Perform symmetric convolution using FFT.
#'
#' @param rr The first input vector.
#' @param ss The second input vector.
#' @param skewflag A scalar value to apply skew correction.
#'
#' @importFrom stats fft
#'
#' @return A vector representing the result of the symmetric convolution.
#'
symconv.ks <- function (rr,ss,skewflag)
{
  L <- length(rr) - 1
  M <- length(ss)
  P <- 2^(ceiling(log(M + L)/log(2)))
  rp <- rep(0,P)
  rp[1:(L+1)] <- rr
  if (L>0) rp[(P-L+1):P] <- skewflag*rr[(L+1):2]
  sp <- rep(0,P)
  sp[1:M] <- ss
  R <- fft(rp)
  S <- fft(sp)
  t <- fft(R * S, TRUE)
  return((Re(t)/P)[1:M])
}


#' symconv2D.ks
#'
#' Perform symmetric 2D convolution using FFT.
#'
#' @param rr The first input matrix.
#' @param ss The second input matrix.
#' @param skewflag A vector of two scalar values for skew correction along each dimension.
#'
#' @importFrom stats fft
#'
#' @return A matrix representing the result of the symmetric 2D convolution.
#'
symconv2D.ks <- function(rr, ss, skewflag=rep(1,2))
{
  L <- dim(rr)-1
  M <- dim(ss)
  L1 <- L[1]
  L2 <- L[2]               # find dimensions of r,s
  M1 <- M[1]
  M2 <- M[2]
  P1 <- 2^(ceiling(log(M1+L1)/log(2))) # smallest power of 2 >= M1+L1
  P2 <- 2^(ceiling(log(M2+L2)/log(2))) # smallest power of 2 >= M2+L2

  rp <- matrix(0,P1,P2)
  rp[1:(L1+1),1:(L2+1)] <- rr
  if (L1>0)
    rp[(P1-L1+1):P1,1:(L2+1)] <- skewflag[1]*rr[(L1+1):2,]
  if (L2>0)
    rp[1:(L1+1),(P2-L2+1):P2] <- skewflag[2]*rr[,(L2+1):2]
  if (L1 > 0 & L2 > 0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2] <- prod(skewflag)*rr[(L1+1):2,(L2+1):2]
  # wrap around version of rr
  sp <- matrix(0,P1,P2)
  sp[1:M1,1:M2] <- ss                 # zero-padded version of ss

  RR <- fft(rp)        # Obtain FFT's of rr and ss
  SS <- fft(sp)
  tt <- fft(RR*SS,TRUE)               # invert element-wise product of FFT's
  return((Re(tt)/(P1*P2))[1:M1,1:M2]) # return normalized truncated tt
}

#' symconv3D.ks
#'
#' Perform symmetric 3D convolution using FFT.
#'
#' @param rr The first input 3D array.
#' @param ss The second input 3D array.
#' @param skewflag A vector of three scalar values for skew correction along each dimension.
#'
#' @importFrom stats fft
#'
#' @return A 3D array representing the result of the symmetric 3D convolution.
#'
symconv3D.ks <- function(rr, ss, skewflag=rep(1,3))
{
  L <- dim(rr) - 1
  M <- dim(ss)
  P <- 2^(ceiling(log(M+L)/log(2))) # smallest powers of 2 >= M+L
  L1 <- L[1] ; L2 <- L[2] ; L3 <- L[3]
  M1 <- M[1] ; M2 <- M[2] ; M3 <- M[3]
  P1 <- P[1] ; P2 <- P[2] ; P3 <- P[3]
  sf <- skewflag

  rp <- array(0,P)
  rp[1:(L1+1),1:(L2+1),1:(L3+1)] <- rr
  if (L1>0)
    rp[(P1-L1+1):P1,1:(L2+1),1:(L3+1)] <- sf[1]*rr[(L1+1):2,1:(L2+1),1:(L3+1)]
  if (L2>0)
    rp[1:(L1+1),(P2-L2+1):P2,1:(L3+1)] <- sf[2]*rr[1:(L1+1),(L2+1):2,1:(L3+1)]
  if (L3>0)
    rp[1:(L1+1),1:(L2+1),(P3-L3+1):P3] <- sf[3]*rr[1:(L1+1),1:(L2+1),(L3+1):2]
  if (L1>0 & L2>0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,1:(L3+1)] <- sf[1]*sf[2]*rr[(L1+1):2,(L2+1):2,1:(L3+1)]
  if (L2>0 & L3>0)
    rp[1:(L1+1),(P2-L2+1):P2,(P3-L3+1):P3] <- sf[2]*sf[3]*rr[1:(L1+1),(L2+1):2,(L3+1):2]
  if (L1>0 & L3>0)
    rp[(P1-L1+1):P1,1:(L2+1),(P3-L3+1):P3] <- sf[1]*sf[3]*rr[(L1+1):2,1:(L2+1),(L3+1):2]
  if (L1>0 & L2>0 & L3>0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,(P3-L3+1):P3] <- sf[1]*sf[2]*sf[3]*rr[(L1+1):2,(L2+1):2,(L3+1):2]

  sp <- array(0,P)
  sp[1:M1,1:M2,1:M3] <- ss            # zero-padded version of ss

  RR <- fft(rp)                       # Obtain FFT's of rr and ss
  SS <- fft(sp)
  tt <- fft(RR*SS,TRUE)               # invert element-wise product of FFT's
  return((Re(tt)/(P1*P2*P3))[1:M1,1:M2,1:M3]) # return normalized truncated tt
}

#' symconv4D.ks
#'
#' Perform symmetric 4D convolution using FFT.
#'
#' @param rr The first input 4D array.
#' @param ss The second input 4D array.
#' @param skewflag A vector of four scalar values for skew correction along each dimension.
#' @param fftflag A vector of two Boolean values for FFT flag.
#'
#' @importFrom stats fft
#'
#' @return A 4D array representing the result of the symmetric 4D convolution.
#'
symconv4D.ks <- function(rr, ss, skewflag=rep(1,4) , fftflag=rep(TRUE,2))
{
  L <- dim(rr) - 1
  M <- dim(ss)
  P <- 2^(ceiling(log(M+L)/log(2))) # smallest powers of 2 >= M+L
  L1 <- L[1] ; L2 <- L[2] ; L3 <- L[3] ; L4 <- L[4]
  M1 <- M[1] ; M2 <- M[2] ; M3 <- M[3] ; M4 <- M[4]
  P1 <- P[1] ; P2 <- P[2] ; P3 <- P[3] ; P4 <- P[4]
  sf <- skewflag

  rp <- array(0,P)
  rp[1:(L1+1),1:(L2+1),1:(L3+1),1:(L4+1)] <- rr

  if (L1>0)
    rp[(P1-L1+1):P1,1:(L2+1),1:(L3+1),1:(L4+1)] <- sf[1]*rr[(L1+1):2,1:(L2+1),1:(L3+1),1:(L4+1)]
  if (L2>0)
    rp[1:(L1+1),(P2-L2+1):P2,1:(L3+1),1:(L4+1)] <- sf[2]*rr[1:(L1+1),(L2+1):2,1:(L3+1),1:(L4+1)]
  if (L3>0)
    rp[1:(L1+1),1:(L2+1),(P3-L3+1):P3,1:(L4+1)] <- sf[3]*rr[1:(L1+1),1:(L2+1),(L3+1):2,1:(L4+1)]
  if (L4>0)
    rp[1:(L1+1),1:(L2+1),1:(L3+1),(P4-L4+1):P4] <- sf[4]*rr[1:(L1+1),1:(L2+1),1:(L3+1),(L4+1):2]

  if (L1>0 & L2 >0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,1:(L3+1),1:(L4+1)] <- sf[1]*sf[2]*rr[(L1+1):2,(L2+1):2,1:(L3+1),1:(L4+1)]
  if (L2>0 & L3>0)
    rp[1:(L1+1),(P2-L2+1):P2,(P3-L3+1):P3,1:(L4+1)] <- sf[2]*sf[3]*rr[1:(L1+1),(L2+1):2,(L3+1):2,1:(L4+1)]
  if (L3>0 & L4>0)
    rp[1:(L1+1),1:(L2+1),(P3-L3+1):P3,(P4-L4+1):P4] <- sf[3]*sf[4]*rr[1:(L1+1),1:(L2+1),(L3+1):2,(L4+1):2]
  if (L1>0 & L3>0)
    rp[(P1-L1+1):P1,1:(L2+1),(P3-L3+1):P3,1:(L4+1)] <- sf[1]*sf[3]*rr[(L1+1):2,1:(L2+1),(L3+1):2,1:(L4+1)]
  if (L2>0 & L4>0)
    rp[1:(L1+1),(P2-L2+1):P2,1:(L3+1),(P4-L4+1):P4] <- sf[2]*sf[4]*rr[1:(L1+1),(L2+1):2,1:(L3+1),(L4+1):2]
  if (L1>0 & L4>0)
    rp[(P1-L1+1):P1,1:(L2+1),1:(L3+1),(P4-L4+1):P4] <- sf[1]*sf[4]*rr[(L1+1):2,1:(L2+1),1:(L3+1),(L4+1):2]

  if (L1>0 & L2>0 & L3>0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,(P3-L3+1):P3,1:(L4+1)] <- sf[1]*sf[2]*sf[3]*rr[(L1+1):2,(L2+1):2,(L3+1):2,1:(L4+1)]
  if (L1>0 & L2>0 & L4>0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,1:(L3+1),(P4-L4+1):P4] <- sf[1]*sf[2]*sf[4]*rr[(L1+1):2,(L2+1):2,1:(L3+1),(L4+1):2]
  if (L2>0 & L3>0 & L4>0)
    rp[1:(L1+1),(P2-L2+1):P2,(P3-L3+1):P3,(P4-L4+1):P4] <- sf[2]*sf[3]*sf[4]*rr[1:(L1+1),(L2+1):2,(L3+1):2,(L4+1):2]

  if (L1>0 & L2>0 & L3>0 & L4>0)
    rp[(P1-L1+1):P1,(P2-L2+1):P2,(P3-L3+1):P3,(P4-L4+1):P4] <- sf[1]*sf[2]*sf[3]*sf[4]*rr[(L1+1):2,(L2+1):2,(L3+1):2,(L4+1):2]

  sp <- array(0,P)
  sp[1:M1,1:M2,1:M3,1:M4] <- ss            # zero-padded version of ss

  RR <- fft(rp)                       # Obtain FFT's of rr and ss
  SS <- fft(sp)
  tt <- fft(RR*SS,TRUE)               # invert element-wise product of FFT's
  return((Re(tt)/(P1*P2*P3*P4))[1:M1,1:M2,1:M3,1:M4]) # return normalized truncated tt
}



