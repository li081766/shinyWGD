#' A wrapper to run EM analysis of \(ln\) Ks values with k-means
#'
#' @param v A list include a vector of Ks values namely `ks_value`,
#'   and a bolean variable namely `log`
#' @param k.centers Number of k-means centers, default 2.
#' @param k.nstart Number of random start of k-means clustering, default 10.
#'   For a formal analysis, it is recommended to use 500.
#'
#' @importFrom stats kmeans
#' @importFrom stats var
#'
#' @return A list, i.e., the original output of mclust::emV
#'
run_emmix_kmeas <- function(v, k.centers=2, k.nstart=500) {
  if (v$log == FALSE) {
    warning("Better to use the log-normal distribution")
  }
  n <- length(v$ks_value)
  suppressMessages(
      k_fit <- kmeans(v$ks_value, centers=k.centers, nstart=k.nstart,
                      algorithm="Lloyd", iter.max=1000)
  )
  # prepare data as a data frame for mclust::em
  k_data <- data.frame(v=v$ks_value, cluster=k_fit$cluster)

  cluster <- NULL
  # prepare parameters as a list for mclust::em
  df <- k_data %>%
    dplyr::group_by(cluster) %>%
    dplyr::summarise(sigmasq=var(v))

    #dplyr::summarise_at(dplyr::vars(v), list(sigmasq=var))

  var.list <- list(modelName="V",
                   d=1, # dimension
                   G=k.centers,
                   sigmasq=df$sigmasq)

  par.list <- list(pro=k_fit$size / n,
                   mean=t(k_fit$centers),
                   variance=var.list)


  kk <- mclust::emV(data=v$ks_value, parameters=par.list)

  kk$BIC <- mclust::bic("V", kk$loglik, n=n, d=1, G=k.centers)

  kk
}


#' Log-Normal mixturing analyses of a Ks distributions for the whole paranome
#'
#' @param G An integer vector specifying the range of the mixtured components.
#'   A BIC is calculated for each component. The default is G=1:5.
#'   For a formal analysis, it is recommended to use 1:10.
#'
#' @param k.nstart How many random sets should be chosen in the k-means
#'   clustering.
#'   For a formal analysis, it is recommended to use 500.
#'
#' @param maxK Maximum Ks values used in the mixture modeling analysis.
#'
#' @param ksv A `ksv` object.
#'
#' @return A data frame with seven variables.
#'
mix_logNormal_Ks <- function(ksv, G=1:5, k.nstart=500, maxK=5) {

  if (maxK <= ksv$ks_dist$maxK) {
    ksv$ks_dist$Ks <- ksv$ks_dist$Ks[ksv$ks_dist$Ks <= maxK]
    ksv$ks_dist$maxK <- maxK
  } else {
    warning("The max Ks is smaller than maxK, please read the Ks file again.")
  }

  Ks <- ksv$ks_dist$Ks
  v <- list(ks_value=log(Ks, exp(1)),
            log=TRUE)

  ks.mix <- data.frame()
  for (i in G) {
    ks_g <- run_emmix_kmeas(v, k.centers=i, k.nstart=k.nstart)
    df <- data.frame(comp=i,
                     mean=ks_g$parameters$mean,
                     sigmasq=ks_g$parameters$variance$sigmasq,
                     prop=ks_g$parameters$pro,
                     logLik=ks_g$loglik,
                     BIC=ks_g$BIC,
                     entities=length(v$ks_value))

    df <- df %>% dplyr::arrange(mean)
    ks.mix <- rbind(ks.mix, df)
  }

  ks.mix$mode <- exp(ks.mix$mean - ks.mix$sigmasq)

  ks.mix
}

#' Read the EMMIX output for a range of components
#'
#' @param emmix.out The output file from EMMIX software.
#'
#' @param G An integer vector specifying the range of the mixture components.
#'   The default is G=1:3.
#'
#' @return A data frame with seven variables.
#'
parse_EMMIX <- function(emmix.out, G=1:3) {
  final_df <- parse_one_EMMIX(emmix.out, ncomponent=G[1])
  for (i in G[2:length(G)]) {
    df <- parse_one_EMMIX(emmix.out, ncomponent=i)
    final_df <- rbind(final_df, df)
  }

  final_df
}

#' Read the EMMIX output for a specify number of components
#'
#' @param emmix.out The output file from EMMIX software.
#' @param ncomponent Number of components to read from the file.
#'
#' @return A data frame with seven variables.
#'
parse_one_EMMIX <- function(emmix.out, ncomponent=3) {
  fh <- file(emmix.out, "r")
  comp <- 0
  m <- c()
  sigmasq <- c()
  tag <- ""
  while (TRUE) {
    line <- readLines(fh, n=1)
    if (length(line) == 0) {
      break
    }

    if (grepl("entities", line)) {
      entities <- as.numeric(regmatches(line, regexpr("\\d+", line)))
    }

    # parse the output of EMMIX
    if (grepl("Results for", line)) {
      comp <- as.numeric(regmatches(line, regexpr("\\d+", line)))
      if (comp == ncomponent) {
        next
      }
      else {
        comp <- 0
        next
      }
    } else if (comp == 0) {
      next
    } else if (tag == ""){
      if (grepl("Final Log", line)) {
        logLik <- as.numeric(regmatches(line, regexpr("-\\d+.\\d+", line)))
      } else if (grepl("proportion", line)) {
        tag <- "proportion"
      } else if (grepl("Estimated mean", line)) {
        tag <- "mean"
      } else if (grepl("Estimated (common )?covariance", line)) {
        tag <- "covariance"
      } else if (grepl("BIC", line)) {
        tag <- "BIC"
      }
    } else if (tag == "proportion") {
      #print(tag)
      prop <- as.numeric(unlist(regmatches(line, gregexpr("\\d+.\\d+", line))))
      tag <- ""
    } else if (tag == "mean") {
      #print(tag)
      m <- c(m, as.numeric(regmatches(line, regexpr("-?\\d+.\\d+", line))))
      if (length(m) == comp) {
        tag <- ""
      }
    } else if (tag == "covariance") {
      #print(tag)
      sigmasq <- c(sigmasq, as.numeric(regmatches(line, regexpr("\\d+.\\d+(E-\\d+)?", line))))
      if (length(sigmasq) == comp) {
        tag <- ""
      }
    } else if (tag == "BIC") {
      #print(tag)
      BIC <- as.numeric(unlist(regmatches(line, gregexpr("\\d+.\\d+", line))[[1]][2]))
      break
    }
  }
  close(fh)

  if (length(m) == 0) {
    stop("The specified number of components does not exist.")

    return(NULL)
  }

  if (ncomponent == 1) {
    prop <- 1
  }
  df <- data.frame(comp=rep(comp, comp), mean=m,
                   sigmasq=sigmasq, prop=prop,
                   logLik=logLik, BIC=BIC)
  df$entities <- entities

  df
}
