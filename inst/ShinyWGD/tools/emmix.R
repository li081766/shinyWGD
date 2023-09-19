#' A wrapper to run EM analysis of \(ln\) Ks values with k-means
#'
#' @param v A list include a vector of Ks values namely `ks_value`,
#'   and a bolean variable namely `log`
#'
#' @param k.centers Number of k-means centers, default 2.
#'
#' @param k.nstart Number of random start of k-means clustering, default 10.
#'   For a formal analysis, it is recommended to use 500.
#'
#' @return A list, i.e., the original output of mclust::emV
#'
run_emmix_kmeas <- function(v, k.centers = 2, k.nstart = 500) {
  if (v$log == FALSE) {
    warning("Better to use the log-normal distribution")
  }
  n <- length(v$ks_value)
  suppressMessages(
      k_fit <- kmeans(v$ks_value, centers = k.centers, nstart = k.nstart,
                      algorithm = "Lloyd", iter.max=1000)
  )
  # prepare data as a data frame for mclust::em
  k_data <- data.frame(v = v$ks_value, cluster = k_fit$cluster)

  # prepare parameters as a list for mclust::em
  df <- k_data %>%
    dplyr::group_by(cluster) %>%
    dplyr::summarise_at(dplyr::vars(v), list(sigmasq = var))

  var.list <- list(modelName = "V",
                   d = 1, # dimension
                   G = k.centers,
                   sigmasq = df$sigmasq)

  par.list <- list(pro = k_fit$size / n,
                   mean = t(k_fit$centers),
                   variance = var.list)


  kk <- mclust::emV(data = v$ks_value, parameters = par.list)

  kk$BIC <- mclust::bic("V", kk$loglik, n = n, d = 1, G = k.centers)

  kk
}


#' Log-Normal mixturing analyses of a Ks distributions for the whole paranome
#'
#' @param G An integer vector specifying the range of the mixtured components.
#'   A BIC is calculated for each component. The default is G = 1:5.
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
#' @export
#'
#' @examples
#' mix_logNormal_Ks <- function(ksv)
#'
mix_logNormal_Ks <- function(ksv, G = 1:5, k.nstart = 500, maxK = 5,
                             plot = FALSE,...) {

  if (maxK <= ksv$ks_dist$maxK) {
    ksv$ks_dist$Ks <- ksv$ks_dist$Ks[ksv$ks_dist$Ks <= maxK]
    ksv$ks_dist$maxK <- maxK
  } else {
    warning("The max Ks is smaller than maxK, please read the Ks file again.")
  }

  Ks <- ksv$ks_dist$Ks
  v <- list(ks_value = log(Ks, exp(1)),
            log = TRUE)

  ks.mix <- data.frame()
  for (i in G) {
    ks_g <- run_emmix_kmeas(v, k.centers = i, k.nstart = k.nstart)
    df <- data.frame(comp = i,
                     mean = ks_g$parameters$mean,
                     sigmasq = ks_g$parameters$variance$sigmasq,
                     prop = ks_g$parameters$pro,
                     logLik = ks_g$loglik,
                     BIC = ks_g$BIC,
                     entities = length(v$ks_value))

    df <- df %>% dplyr::arrange(mean)
    ks.mix <- rbind(ks.mix, df)
  }

  #> plot BIC as a figure output
  if (plot == TRUE) {
    bic_df <- dplyr::select(ks.mix, comp, BIC) %>%
      dplyr::distinct() %>%
      dplyr::rename(value = BIC) %>%
      dplyr::mutate(para = "BIC")

    loglik_df <- dplyr::select(ks.mix, comp, logLik) %>%
      dplyr::distinct() %>%
      dplyr::rename(value = logLik) %>%
      dplyr::mutate(para = "Log-likelyhood")

    sum_df <- dplyr::bind_rows(bic_df, loglik_df)
    p <- ggplot2::ggplot(sum_df, mapping = ggplot2::aes(x = comp, y = value)) +
      ggplot2::geom_point() +
      ggplot2::geom_line() +
      ggplot2::scale_x_continuous(breaks = seq(1, max(G), 1)) +
      ggplot2::theme_bw() +
      ggplot2::facet_wrap(~ para, ncol = 2, scales = "free")
    print(p)
  }

  ks.mix$mode <- exp(ks.mix$mean - ks.mix$sigmasq)

  ks.mix
}

#' Draw a Ks distribution with fitted Gaussian
#'
#' @param ncomponent Number of components, default 3.
#' @param bin_width Bin width for the Ks distribution, default 0.1
#' @param maxK Maximum Ks value, default 5.
#' @param maxY Maximum number of y-axis, default 1000.
#' @param ... other parameters in plot.ksd or plot.ksv and mix_logNormal_Ks
#' @param ksv A `ksv` object
#' @param EMMIX.file The output file of EMMIX software.
#'
#' @return
#' @export
#'
#' @examples
plot_Ks_mix <- function(ksv, ncomponent = 3, EMMIX.file = NULL,
                        bin_width = 0.1, maxK = 5, maxY = 1000, ...) {
  if (is.null(EMMIX.file)) { # No EMMIX.file provided
    emmix_df <- mix_logNormal_Ks(ksv, G = ncomponent, plot = FALSE, ...)
  } else {
    emmix_df <- parse_EMMIX(emmix, ncomponent)
  }

  plot.ksv(ksv, bin_width = bin_width, maxK = maxK, maxY = maxY)

  total <- emmix_df$entities[1]
  df <- subset(emmix_df, comp == ncomponent)
  df$mode <- exp(df$mean - df$sigmasq)
  df <- df %>% dplyr::arrange(mean)

  k <- seq(bin_width/2, maxK, bin_width)
  mixed_df <- data.frame(k = k)
  for (j in 1:nrow(df)) {
    lty <- ifelse(j > 6, 6, j)
    kn <- dlnorm(k, mean = df$mean[j], sd = sqrt(df$sigmasq[j]))
    #lines(k, kn * bin_width * total * df$prop[j], lty = lty)
    lines(k, kn / sum(kn) * total * df$prop[j],
          col = "red", lty = lty) # Rolf's code
    abline(v = df$mode[j], lty = lty, col = "darkgrey")
    mixed_df <- cbind(mixed_df,
                      as.data.frame(kn / sum(kn) * total * df$prop[j]))
    colnames(mixed_df)[j+1] <- j
  }

  #> combine all the mixture parts
  mixed_df <- mixed_df %>%
    dplyr::mutate(total = apply(mixed_df[,2:ncol(mixed_df)], 1, sum))
  lines(k, mixed_df$total)

}

#' Read the EMMIX output for a range of components
#'
#' @param emmix.out The output file from EMMIX software.
#'
#' @param G An integer vector specifying the range of the mixture components.
#'   The default is G = 1:3.
#'
#' @return A data frame with seven variables.
#' @export
#'
#' @examples
parse_EMMIX <- function(emmix.out, G = 1:3) {
  final_df <- parse_one_EMMIX(emmix.out, ncomponent = G[1])
  for (i in G[2:length(G)]) {
    df <- parse_one_EMMIX(emmix.out, ncomponent = i)
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
#' @examples
#' parseEMMIX("data/WelMiLog.out")
parse_one_EMMIX <- function(emmix.out, ncomponent = 3) {
  fh <- file(emmix.out, "r")
  comp <- 0
  m <- c()
  sigmasq <- c()
  tag <- ""
  while (TRUE) {
    line <- readLines(fh, n = 1)
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
  df <- data.frame(comp = rep(comp, comp), mean = m,
                   sigmasq = sigmasq, prop = prop,
                   logLik = logLik, BIC = BIC)
  df$entities <- entities

  df
}
