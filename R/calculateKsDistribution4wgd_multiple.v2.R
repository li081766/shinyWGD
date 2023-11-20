#' Calculate the Ks Distribution for Multiple Speices
#'
#' This function takes a list of data files, calculates the Ks distribution, and returns the results.
#'
#' @param files_list A list of file paths containing Ks data.
#' @param binWidth The width of Ks bins for the distribution.
#' @param maxK The maximum Ks value to consider.
#' @param plot.mode The mode for plotting ("weighted", "average", "min", or "pairwise").
#' @param include.outliers Whether to include outliers in the calculation.
#' @param minK The minimum Ks value to include in the distribution.
#' @param minAlnLen The minimum alignment length to include in the distribution.
#' @param minIdn The minimum alignment identity to include in the distribution.
#' @param minCov The minimum alignment coverage to include in the distribution.
#'
#' @importFrom stats aggregate
#' @importFrom stats complete.cases
#' @importFrom dplyr bind_rows
#'
#' @return A list containing two data frames: "bar" for Ks distribution and "density" for density data.
#'
calculateKsDistribution4wgd_multiple <- function(
        files_list, binWidth=0.1, maxK=5,
        plot.mode="weighted",
        include.outliers=F, minK=0, minAlnLen=0, minIdn=0, minCov=0){
    # library(dplyr)

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
