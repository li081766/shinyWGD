#' Obtain coordinates for anchorpoints from GFF files
#'
#' This function takes a file containing anchorpoints, GFF files for two species, and species names,
#' and retrieves the coordinates of anchorpoints and associated genes from the GFF files.
#'
#' @param anchorpoints A file containing anchorpoints information with columns like gene_x, gene_y, and other relevant data.
#' @param species1 The name of the first species.
#' @param gff_file1 The path to the GFF file for the first species.
#' @param out_file The output file where the results will be saved.
#' @param species2 (Optional) The name of the second species. Specify this parameter and gff_file2 if working with two species.
#' @param gff_file2 (Optional) The path to the GFF file for the second species.
#'
#' @importFrom vroom vroom
#' @importFrom dplyr filter
#' @importFrom dplyr select
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#'
#'
#' @return None. The function saves the results to the specified out_file.
#'
obtain_coordiantes_for_anchorpoints <- function(anchorpoints, species1, gff_file1, out_file, species2=NULL, gff_file2=NULL){
    gff_df <- suppressMessages(
        vroom(
            gff_file1,
            delim="\t",
            comment="#",
            col_names=FALSE
        )
    )
    # library(vroom)
    # library(dplyr)

    X1 <- X4 <- X5 <- X7 <- X9 <- NULL
    position_df <- gff_df %>%
        filter(gff_df$X3=="mRNA") %>%
        select(X1, X9, X4, X5, X7) %>%
        mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))

    colnames(position_df) <- c("list", "gene", "start", "end", "strand")

    position_df$sp <- species1
    if( !is.null(gff_file2) ){
        gff_df2 <- suppressMessages(
            vroom(
                gff_file2,
                delim="\t",
                comment="#",
                col_names=FALSE
            )
        )
        position_df2 <- gff_df2 %>%
            filter(gff_df2$X3=="mRNA") %>%
            select(X1, X9, X4, X5, X7) %>%
            mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))

        colnames(position_df2) <- c("list", "gene", "start", "end", "strand")
        position_df2$sp <- species2

        position_df <- rbind(position_df, position_df2)
    }
    anchors_df <- suppressMessages(
        vroom(
            anchorpoints,
            delim="\t",
            col_names=TRUE
        )
    )

    final_df <- data.frame()
    merged_x <- left_join(anchors_df, position_df, by=c("gene_x"="gene"))
    merged_y <- left_join(merged_x, position_df, by=c("gene_y"="gene"))
    colnames(merged_y) <- c("id", "multiplicon", "basecluster",
                            "geneX", "geneY", "coordX", "coordY",
                            "is_real_anchorpoint",
                            "listX", "startX", "endX", "strandX", "speciesX",
                            "listY", "startY", "endY", "strandY", "speciesY")
    final_df <- merged_y

    speciesX <- speciesY <- NULL
    # if( !is.null(gff_file2) ){
    #     final_df <- final_df %>% filter(speciesX != speciesY)
    #     final_table <- data.frame(matrix(ncol=ncol(final_df), nrow=nrow(final_df)))
    #     for( i in 1:nrow(final_df) ){
    #         each_row <- final_df[i, ]
    #         if( each_row$speciesX != species1 ){
    #             tmp <- each_row[9:13]
    #             each_row[9:13] <- each_row[14:18]
    #             each_row[14:18] <- tmp
    #
    #             tmp2 <- each_row$geneX
    #             each_row$geneX <- each_row$geneY
    #             each_row$geneY <- tmp2
    #
    #             tmp3 <- each_row$coordX
    #             each_row$coordX <- each_row$coordY
    #             each_row$coordY <- tmp3
    #         }
    #         final_table[i,] <- each_row
    #     }
    #     colnames(final_table) <- c("id", "multiplicon", "basecluster",
    #                                "geneX",  "geneY",  "coordX", "coordY",
    #                                "is_real_anchorpoint",
    #                                "listX", "startX", "endX", "strandX", "speciesX",
    #                                "listY", "startY", "endY", "strandY", "speciesY")
    #     write.table(final_table,
    #                 file=out_file,
    #                 sep="\t",
    #                 row.names=FALSE,
    #                 quote=FALSE)
    # }else{
    #     write.table(
    #         final_df,
    #         file=out_file,
    #         sep="\t",
    #         row.names=FALSE,
    #         quote=FALSE
    #     )
    # }
    write.table(
        final_df,
        file=out_file,
        sep="\t",
        row.names=FALSE,
        quote=FALSE
    )
}
