#' Obtain coordinates for segments in a comparison
#'
#' This function retrieves the coordinates for segments in a comparison based on the provided parameters.
#'
#' @param seg_file The file containing segment data.
#' @param sp1 The species name for the first genome.
#' @param gff_file1 The GFF file for the first genome.
#' @param out_file The output file to store the merged position data.
#' @param sp2 The species name for the second genome (optional).
#' @param gff_file2 The GFF file for the second genome (optional).
#'
#' @importFrom vroom vroom
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#'
#' @return NULL (the results are saved in the output file).
#'
obtain_coordiantes_for_segments <- function(seg_file, sp1, gff_file1, out_file, sp2=NULL, gff_file2=NULL){
    # library(vroom)
    # library(dplyr)

    gff_df <- suppressMessages(
        vroom(gff_file1,
              delim="\t",
              comment="#",
              col_names=FALSE)
    )
    X1 <- X4 <- X5 <- X7 <- X9 <- NULL
    position_df <- gff_df %>%
        filter(gff_df$X3=="mRNA") %>%
        select(X1, X9, X4, X5, X7) %>%
        mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))

    colnames(position_df) <- c("list", "gene", "start", "end", "strand")

    if( !is.null(gff_file2) ){
        gff_df2 <- suppressMessages(
            vroom(gff_file2,
                  delim="\t",
                  comment="#",
                  col_names=FALSE)
        )
        position_df2 <- gff_df2 %>%
            filter(gff_df2$X3=="mRNA") %>%
            select(X1, X9, X4, X5, X7) %>%
            mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))

        colnames(position_df2) <- c("list", "gene", "start", "end", "strand")
        position_df <- rbind(position_df, position_df2)
    }
    segs <- suppressMessages(
        vroom(seg_file,
              delim="\t",
              col_names=TRUE)
    )

    gene <- start <- end <- multiplicon <- genome <- list <- first <- last <- NULL
    genome.1 <- list.1 <- first.1 <- last.1 <- start.1 <- end.1 <- order.1 <- NULL
    genomeX <- genomeY <- NULL

    start_subset <- select(position_df, gene, start)
    merged_data <- left_join(segs, start_subset, by = c("first"="gene"))
    end_subset <- select(position_df, gene, end)
    merged_data <- left_join(merged_data, end_subset, by=c("last"="gene"))

    multiplicon_list <- unique(merged_data$multiplicon)
    final_df <- data.frame()
    for (i in multiplicon_list) {
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
    sp_list <- unique(c(final_output1$genomeX, final_output1$genomeY))

    if( length(sp_list) > 1 ){
        final_table <- data.frame(matrix(ncol = ncol(final_output1), nrow = nrow(final_output1)))
        for( i in 1:nrow(final_output1) ){
            each_row <- final_output1[i, ]
            if( each_row$genomeX != sp1 ){
                tmp <- each_row[2:8]
                each_row[2:8] <- each_row[9:15]
                each_row[9:15] <- tmp
            }
            final_table[i,] <- each_row
        }
        colnames(final_table) <- c("multiplicon", "genomeX", "listX", "firstX", "lastX", "startX", "endX", "orderX",
                                    "genomeY", "listY", "firstY", "lastY", "startY", "endY", "orderY")
        write.table(final_table,
                    file=out_file,
                    sep="\t",
                    row.names=FALSE,
                    quote=FALSE)
    }
    else{
        final_table <- final_output
        for (i in 1:nrow(final_output)) {
            each_row <- final_output[i, ]
            tmp <- each_row[2:8]
            each_row[2:8] <- each_row[9:15]
            each_row[9:15] <- tmp
            final_table <- rbind(final_table, each_row)
        }
        colnames(final_table) <- c("multiplicon", "genomeX", "listX", "firstX", "lastX", "startX", "endX", "orderX",
                                   "genomeY", "listY", "firstY", "lastY", "startY", "endY", "orderY")
        write.table(final_table,
                    file=out_file,
                    sep="\t",
                    row.names=FALSE,
                    quote=FALSE)
    }
}
