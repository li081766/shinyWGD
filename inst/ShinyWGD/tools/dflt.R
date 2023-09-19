# These are from package feature. They not exprted in the package.
######### R-function dfltBWrange  #########

# Obtain default set of grid counts from a
# multivariate point cloud 'x'.

# Last changed: 22 JUL 2005

dfltBWrange <- function(x,tau) {
  d <- ncol(x)
  if (d==1) x <- as.matrix(x)

  r <- 2
  cmb.fac.upp <- (4/((d+2*r+2)*nrow(x)))^(1/(d+2*r+4))
  r <- 0
  cmb.fac.low <- (4/((d+2*r+2)*nrow(x)))^(1/(d+2*r+4))

  ## Compute the scale in each direction

  st.devs <- apply(x,2,sd)
  IQR.vals <- apply(x, 2, IQR)/(qnorm(3/4) - qnorm(1/4))
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
######### R-function dfltLabs  #########

# Obtain default axis labels.

# Last changed: 03 AUG 2005

dfltLabs <- function(d,names.x,xlab,ylab,zlab)
{
   if (d==1)
   {
      if (is.null(xlab))
      {
         if (is.null(names.x)) xlab <- ""
         if (!is.null(names.x)) xlab <- names.x
      }
   }

   if (d==2)
   {
      if ((is.null(xlab))|(is.null(ylab)))
      {
         if (is.null(names.x))
         {
            if (is.null(xlab)) xlab <- ""
            if (is.null(ylab)) ylab <- ""
         }
         if (!is.null(names.x))
         {
            if (is.null(xlab)) xlab <- names.x[1]
            if (is.null(ylab)) ylab <- names.x[2]
         }
      }
   }

   if (d>=3)
   {
      if ((is.null(xlab))|(is.null(ylab))|(is.null(zlab)))
      {
         if (is.null(names.x))
         {
            if (is.null(xlab)) xlab <- ""
            if (is.null(ylab)) ylab <- ""
            if (is.null(zlab)) zlab <- ""
         }
         if (!is.null(names.x))
         {
            if (is.null(xlab)) xlab <- names.x[1]
            if (is.null(ylab)) ylab <- names.x[2]
            if (is.null(zlab)) zlab <- names.x[3]
         }
      }
   }

   return(list(xlab=xlab,ylab=ylab,zlab=zlab))
}

######## End of dfltLabs ########
