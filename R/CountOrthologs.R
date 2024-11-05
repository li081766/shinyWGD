#' Count Ortholog Genes in a Species
#'
#' This function counts ortholog genes in a given species based on input data.
#'
#' @param atomic.df A data frame containing information about ortholog genes.
#'        It should have the following columns:
#'        - multiplicon: The multiplicon identifier.
#'        - geneX: The gene identifier in speciesX.
#'        - speciesX: The species name for geneX.
#'        - listX: The chromosome or list identifier for geneX.
#'        - coordX: The coordinate information for geneX.
#'        - geneY: The gene identifier in speciesY.
#'        - speciesY: The species name for geneY.
#'        - listY: The chromosome or list identifier for geneY.
#'        - coordY: The coordinate information for geneY.
#'        - level: The orthology level.
#'        - num_anchors: The number of anchors.
#'        - is_real: A flag indicating if the data is real.
#'        - Ks: The Ks value.
#' @param species The species for which ortholog gene counts should be computed.
#'
#' @return A data frame summarizing the counts of ortholog genes for each chromosome.
#'
CountOrthologs <- function(atomic.df, species) {
  if (length(unique(atomic.df$speciesX)) > 1) {
    stop ("atomatic.df is not ordered")
  }

  if (length(unique(atomic.df$speciesY)) > 1) {
    stop ("atomatic.df is not ordered")
  }

  if(atomic.df$speciesX[1] == species){
    to.count.df <-atomic.df[,c("geneX", "listX", "listY")]  # here I added the chr of corresponding anchorpoints to further remove tandem duplicates
  } else if (atomic.df$speciesY[1] == species) {
    to.count.df <- atomic.df[,c("geneY", "listY", "listX")] # here I added the chr of corresponding anchorpoints to further remove tandem duplicates
  } else {
    stop ("atomatic.df do not have the speices")
  }

  names(to.count.df) <- c("gene", "chr", "anchor_chr")
  chrs <- unique(to.count.df$chr)
  summary <- list()
  for (ch in chrs) {
    genes <- to.count.df[to.count.df$chr == ch, c("gene", "anchor_chr")]
    summary[[ch]] <- table(table(genes$gene))
  }
  #return(summary)

  max.num <- max(unlist(lapply(summary, function(x) max(as.numeric(names(x))))))
  row.num <- length(chrs)
  summary.df <- as.data.frame(matrix(NA, nrow=row.num, ncol=max.num + 1))
  names(summary.df) <- c("chr_segs", as.character(rep(1:max.num)))

  for (i in 1:row.num) {
    summary.df[i,1] <- names(summary)[i]
    for (j in 1:max.num) {
      n <- summary[[i]][which(names(summary[[i]]) == j)]
      if (length(n) == 1) {
        summary.df[i,(j+1)] <- n
      } else if (length(n) == 0) {
        summary.df[i,(j+1)] <- 0
      } else {
        stop ("some counts are wrong!!!")
      }
    }
  }
  return(summary.df)
}
