#' Calculate the Ks distributions of multiple species
#'
#' @param files_list a list includes the *.ks.csv files created by ksrates or wgd
#' @param binWidth bin width, default 0.1
#' @param maxK maximum Ks value, default 5
#' @param plot.mode plot mode, default weighted
#' @param include.outliers outliers, default FALSE
#' @param minK minimum Ks value, default 0
#' @param minAlnLen minimum aligning length, default 0
#' @param minIdn minimum identity, default 0
#' @param minCov minimum coverage, default 0
#'
#' @return A list includes two data frames, one is the KDE distribution, the other is the original Ks values
#'
#' @export
#'
#' @examples
#' full_data <- calculateKsDistribution4wgd_multiple(
#'     files_list_new,
#'     plot.mode=input[[paste0("plot_mode_option_", combined_i)]],
#'     maxK=input[[paste0("ks_maxK_", combined_i)]],
#'     binWidth=input[[paste0("ks_binWidth_", combined_i)]],
#' )
calculateKsDistribution4wgd_multiple <- function(
        files_list, binWidth=0.1, maxK=5,
        plot.mode="weighted",
        include.outliers=F, minK=0, minAlnLen=0, minIdn=0, minCov=0){
    library(dplyr)

    full.data <- data.frame()
    full.data.density <- data.frame()
    full_df <- data.frame()
    cols_to_select <- c("Ks", "title")

    for( i in files_list ){
        title <- basename(i)
        title <- gsub(".tsv", "", title)
        plottitle <- gsub("wgd_", "", title)
        df <- read.table(i, sep="\t", header=T)
        df <- df[df$Ks>=minK
                 & df$AlignmentCoverage>=minCov
                 & df$AlignmentLength>=minAlnLen
                 & df$AlignmentIdentity>=minIdn, ]

        if (include.outliers == F) {
            df <- df[df$WeightOutliersExcluded>0,]
        }

        if (plot.mode == "weighted") {
            if (include.outliers == T) {
                df$Weight <- df$WeightOutliersIncluded
            } else {
                df$Weight <- df$WeightOutliersExcluded
            }
        }
        else if (plot.mode == "average") {
            temp.df <- aggregate(df$Ks, by=list(df$Family, df$Node), FUN=mean)
            colnames(temp.df) <- c("Family", "Node", "Ks")
            temp.df$Weight <- 1
            df <- temp.df
        }
        else if (plot.mode == "min") {
            temp.df <- aggregate(df$Ks, by=list(df$Family, df$Node), FUN=min)
            colnames(temp.df) <- c("Family", "Node", "Ks")
            temp.df$Weight <- 1
            df <- temp.df
        }
        else if (plot.mode == "pairwise") {
            df$Weight <- 1
        } else {
            stop("plot.mode should be \"weighted\", \"average\", \"min\", or \"pairwise\"")
        }
        df <- df[complete.cases(df$Ks), ]

        valuesPerBin <- binWidth / 0.01
        df$Ks.bin <- cut(df$Ks, seq(0, maxK, binWidth), right=F, include.lowest=T)
        maxBin <- length(levels(df$Ks.bin))

        df$title <- plottitle
        selected_cols <- df[cols_to_select]
        full_df <- bind_rows(full_df, selected_cols)

        ks.aggregate <- aggregate(df$Weight, by=list(ks.bin=df$Ks.bin), FUN=sum)
        ks.bin.df <- data.frame(ks.bin=cut(seq(minK, maxK, binWidth)[1:maxBin] + binWidth / 2,
                                           seq(minK, maxK, binWidth),
                                           right=F, include.lowest=T),
                                ks=seq(minK, maxK, binWidth)[1:maxBin] + binWidth / 2)
        ks.dist <- merge(ks.aggregate, ks.bin.df, by="ks.bin")

        ks.dist$title <- plottitle
        full.data <- bind_rows(full.data, ks.dist)

        density_df <- data.frame(
            ks=df$Ks,
            title=plottitle,
            binWidth=binWidth
        )
        full.data.density <- rbind(full.data.density, density_df)

    }
    return(list(bar=full.data,
                density=full.data.density))
}
