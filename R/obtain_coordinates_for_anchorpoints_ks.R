#' Obtain Coordinates and Ks Values for Anchorpoints
#'
#' This function extracts coordinates and Ks (synonymous substitution rate) values for anchorpoints
#' from input data and merges them into a single output file.
#
#' @param anchorpoints A character string specifying the file path for anchorpoints data.
#' @param anchorpoints_ks A character string specifying the file path for anchorpoints Ks values data.
#' @param genes_file A character string specifying the file path for genes information.
#' @param out_file A character string specifying the output file path for coordinates.
#' @param out_ks_file A character string specifying the output file path for Ks values.
#' @param species A character string specifying the species name.
#'
#' @return NULL (output files are generated with the specified information).
#'
#' @export
#'
#' @examples
#' # Example usage:
#' obtain_coordiantes_for_anchorpoints_ks(
#'     anchorpoints="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.txt",
#'     anchorpoints_ks="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.ks.txt",
#'     genes_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/genes.txt",
#'     out_file="output_coordinates.txt",
#'     out_ks_file="output_ks_values.txt",
#'     species="Vitis_vinifera"
#' )
obtain_coordiantes_for_anchorpoints_ks <- function(
        anchorpoints,
        anchorpoints_ks,
        genes_file,
        out_file,
        out_ks_file,
        species){
    library(vroom)
    library(dplyr)

    position_df <- suppressMessages(
        vroom(
            genes_file,
            delim="\t",
            comment="#",
            col_names=TRUE
        )
    ) %>%
        select(id, genome, list, orientation, remapped_coordinate)

    colnames(position_df) <- c("gene", "genome", "list", "strand", "coord")

    anchors_df <- suppressMessages(
        vroom(
            anchorpoints,
            delim="\t",
            col_names=TRUE
        )
    )

    merged_x <- left_join(anchors_df, position_df, by=c("gene_x"="gene"))
    final_df <- left_join(merged_x, position_df, by=c("gene_y"="gene")) %>%
        select(multiplicon,
               gene_x, genome.x, list.x, strand.x, coord.x,
               gene_y, genome.y, list.y, strand.y, coord.y)

    colnames(final_df) <- c("multiplicon",
                            "geneX", "speciesX", "listX", "strandX", "coordX",
                            "geneY", "speciesY", "listY", "strandY", "coordY")

    genome_list <- unique(position_df$genome)
    write.table(
        final_df,
        file=out_file,
        sep="\t",
        row.names=FALSE,
        quote=FALSE
    )
    if( length(genome_list) > 1 ){
        final_df <- final_df %>%
            filter(speciesX != speciesY)

        final_df_out <- data.frame(
            matrix(
                ncol=ncol(final_df),
                nrow=nrow(final_df)
            )
        )

        for( i in 1:nrow(final_df) ){
            each_row <- final_df[i, ]
            if( each_row$speciesX != species ){
                tmp1 <- each_row[2:6]
                each_row[2:6] <- each_row[7:11]
                each_row[7:11] <- tmp1
            }
            final_df_out[i, ] <- each_row
        }
        colnames(final_df_out) <- colnames(final_df)
        final_df <- final_df_out
    }

    anchors_ks_df <- suppressMessages(
        vroom(
            anchorpoints_ks,
            delim="\t",
            col_names=TRUE
        )
    ) %>%
        rowwise() %>%
        mutate(gene_pair=paste(sort(c(geneX, geneY)), collapse="_")) %>%
        distinct(gene_pair, .keep_all=TRUE) %>%
        select(-gene_pair)

    merged_x <- left_join(anchors_ks_df, position_df, by=c("geneX"="gene"))
    anchors_ks_df <- left_join(merged_x, position_df, by=c("geneY"="gene")) %>%
        select(geneX, genome.x, list.x, strand.x, coord.x,
               geneY, genome.y, list.y, strand.y, coord.y,
               Omega, Ka, Ks)

    if( length(genome_list) > 1 ){
        anchors_ks_df <- anchors_ks_df %>%
            filter(genome.x != genome.y)

        final_df_out <- data.frame(
            matrix(
                ncol=ncol(anchors_ks_df),
                nrow=nrow(anchors_ks_df)
            )
        )

        for( i in 1:nrow(anchors_ks_df) ){
            each_row <- anchors_ks_df[i, ]
            if( each_row$genome.x != species ){
                tmp1 <- each_row[1:5]
                each_row[1:5] <- each_row[6:10]
                each_row[6:10] <- tmp1
            }
            final_df_out[i, ] <- each_row
        }
        colnames(final_df_out) <- colnames(anchors_ks_df)
        final_anchors_ks_df <- final_df_out
    }else{
        final_anchors_ks_df <- anchors_ks_df
    }

    final_anchors_ks_df <- final_anchors_ks_df %>%
        select(geneX, geneY, Omega, Ka, Ks)

    final_table_ks_df <- merge(
        final_df,
        final_anchors_ks_df,
        by.x=c("geneX", "geneY"),
        by.y=c("geneX", "geneY"),
        all.x=TRUE
    ) %>%
        select(multiplicon,
               geneX, speciesX, listX, strandX, coordX,
               geneY, speciesY, listY, strandY, coordY,
               Omega, Ka, Ks) %>%
        arrange(multiplicon)

    final_table_ks_df[is.na(final_table_ks_df)] <- -1

    write.table(final_table_ks_df,
                file=out_ks_file,
                sep="\t",
                row.names=FALSE,
                quote=FALSE)
}
