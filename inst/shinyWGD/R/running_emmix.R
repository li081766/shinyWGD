#' ks_mclust_v2
#'
#' A wrapper to run emmix modeling using the mclust package.
#'
#' @param input_data The input data for clustering and modeling.
#'
#' @return A data frame containing clustering and modeling results.
#'
ks_mclust_v2 <- function(input_data) {
    # suppressMessages(
    #     library(mclust)
    # )
    ks.mclust <- data.frame()

    for (i in 1:10) {
        ks_dist <- list(Ks=input_data, maxK=max(input_data))
        ksv <- list(ks_dist=ks_dist)

        ks_g <- mix_logNormal_Ks(ksv, G=i, k.nstart=10)

        if (nrow(ks_g) > 0) {
            df <- data.frame(comp=ks_g$comp,
                             mean=ks_g$mean,
                             sigmasq=ks_g$sigmasq,
                             prop=ks_g$prop,
                             logLik=ks_g$logLik,
                             BIC=ks_g$BIC,
                             entities=ks_g$entities,
                             mode=ks_g$mode)
        } else {
            df <- data.frame(comp=NA,
                             mean=NA,
                             sigmasq=NA,
                             prop=NA,
                             logLik=NA,
                             BIC=NA,
                             entities=NA,
                             mode=NA)
        }

        ks.mclust <- rbind(ks.mclust, df)
    }

    return(ks.mclust)
}
