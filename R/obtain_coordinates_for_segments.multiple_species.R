#' Obtain Coordinates for Segments in Multiple Synteny Blocks
#'
#' This function extracts coordinates for segments within multiple synteny blocks based on input dataframes.
# It merges information from GFF and segment dataframes to generate a final output.
#
#' @param seg_df A dataframe containing information about synteny segments.
#' @param gff_df A dataframe containing GFF (General Feature Format) information.
#' @param input A list containing input data, typically multiple synteny query chromosomes.
#' @param out_file A character string specifying the output file path.
#'
#' @return A dataframe with coordinates for segments within multiple synteny blocks.
#'
#' @export
#'
#' @examples
#' # Example usage:
#' # Define dataframes for segments and GFF information
#' seg_df <- read.table("segments.csv", header=TRUE, sep=",")
#' gff_df <- read.table("genomic_data.gff", header=TRUE, sep="\t")
#'
#' # Define input data
#' input_data <- list(
#'     multiple_synteny_query_chr_SpeciesA=c("Chr1", "Chr2"),
#'     multiple_synteny_query_chr_SpeciesB=c("ChrX", "ChrY")
#' )
#'
#' # Obtain coordinates for segments within multiple synteny blocks
#' obtain_coordinates_for_segments_multiple(seg_df, gff_df, input_data, "output_coordinates.txt")
#'
obtain_coordinates_for_segments_multiple <- function(
        seg_df,
        gff_df,
        input,
        out_file
    ){
    library(vroom)
    library(dplyr)

    position_df <- data.frame()
    for( x in 1:nrow(gff_df) ){
        each_row <- gff_df[x, ]
        selected_chrs <- input[[paste0("multiple_synteny_query_chr_", gsub(" ", "_", each_row$species))]]
        gff_df_tmp <- suppressMessages(
            vroom(
                each_row$gffPath,
                delim="\t",
                comment="#",
                col_names=FALSE
            )
        ) %>%
            filter(X1 %in% selected_chrs)
        gff_df_tmp <- gff_df_tmp %>%
            filter(gff_df_tmp$X3 == "mRNA") %>%
            select(X1, X9, X4, X5, X7) %>%
            mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))
        colnames(gff_df_tmp) <- c("list", "gene", "start", "end", "strand")
        gff_df_tmp$sp <- each_row$species
        position_df <- rbind(position_df, gff_df_tmp)
    }

    segs <- seg_df
    start_subset <- select(position_df, gene, start)
    merged_data <- left_join(segs, start_subset, by=c("first"="gene"))
    end_subset <- select(position_df, gene, end)
    merged_data <- left_join(merged_data, end_subset, by=c("last"="gene"))

    multiplicon_list <- unique(merged_data$multiplicon)
    final_df <- data.frame()
    for( i in multiplicon_list ){
        df_subset <- merged_data[merged_data$multiplicon==i, ]
        df_row1 <- df_subset[1, ]
        for( y in 2:nrow(df_subset) ){
            df_row2 <- df_subset[y, ]
            new_row <- c(df_row1, df_row2)
            final_df <- rbind(final_df, new_row)
        }
    }
    final_output <- select(final_df, multiplicon, genome, list, first, last, start, end, order,
                           genome.1, list.1, first.1, last.1, start.1, end.1, order.1)
    colnames(final_output) <- c("multiplicon", "genomeX", "listX", "firstX", "lastX", "startX", "endX", "orderX",
                                "genomeY", "listY", "firstY", "lastY", "startY", "endY", "orderY")
    rownames(final_output) <- NULL
    final_output1 <- subset(final_output, genomeX != genomeY)
    write.table(
        final_output1,
        file=out_file,
        sep="\t",
        row.names=FALSE,
        quote=FALSE
    )
}
