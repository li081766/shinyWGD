library(vroom)
library(dplyr)

obtain_coordiantes_for_anchorpoints <- function(anchorpoints, species1, gff_file1, out_file, species2=NULL, gff_file2=NULL){
    gff_df <- suppressMessages(
        vroom(
            gff_file1,
            delim="\t",
            comment="#",
            col_names=FALSE
        )
    )

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

    if( !is.null(gff_file2) ){
        final_df <- final_df %>% filter(speciesX != speciesY)
        final_table <- data.frame(matrix(ncol=ncol(final_df), nrow=nrow(final_df)))
        for( i in 1:nrow(final_df) ){
            each_row <- final_df[i, ]
            if( each_row$speciesX != species1 ){
                tmp <- each_row[9:13]
                each_row[9:13] <- each_row[14:18]
                each_row[14:18] <- tmp

                tmp2 <- each_row$geneX
                each_row$geneX <- each_row$geneY
                each_row$geneY <- tmp2

                tmp3 <- each_row$coordX
                each_row$coordX <- each_row$coordY
                each_row$coordY <- tmp3
            }
            final_table[i,] <- each_row
        }
        colnames(final_table) <- c("id", "multiplicon", "basecluster",
                                   "geneX",  "geneY",  "coordX", "coordY",
                                   "is_real_anchorpoint",
                                   "listX", "startX", "endX", "strandX", "speciesX",
                                   "listY", "startY", "endY", "strandY", "speciesY")
        write.table(final_table,
                    file=out_file,
                    sep="\t",
                    row.names=FALSE,
                    quote=FALSE)
    }else{
        write.table(final_df,
                    file=out_file,
                    sep="\t",
                    row.names=FALSE,
                    quote=FALSE)
    }
}

# obtain_coordiantes_for_anchorpoints(
#     anchorpoints="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Oryza_sativa_vs_Asparagus_officinalis/anchorpoints.txt",
#     species1="Oryza sativa",
#     gff_file1="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/sp_2.gff",
#     species2="Asparagus officinalis",
#     gff_file2="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/sp_3.gff",
#     out_file="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Oryza_sativa_vs_Asparagus_officinalis/anchorpoints.merged_position.txt"
# )
#
# obtain_coordiantes_for_anchorpoints(
#     anchorpoints="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Asparagus_officinalis_vs_Asparagus_officinalis/anchorpoints.txt",
#     species1="Asparagus officinalis",
#     gff_file1="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/sp_3.gff",
#     out_file="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Asparagus_officinalis_vs_Asparagus_officinalis/anchorpoints.merged_position.txt"
# )

# obtain_coordiantes_for_anchorpoints(
#     anchorpoints="~/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Elaeis_guineensis_vs_Elaeis_guineensis/anchorpoints.txt",
#     species1="Elaeis guineensis",
#     gff_file1="/Users/jiali/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Elaeis1.gff",
#     out_file="~/Desktop/Projects/ShinyWGD/ksrates/example/data/Analysis_2023-04-19/Syn/i-adhore.Elaeis_guineensis_vs_Elaeis_guineensis/anchorpoints.merged_pos.txt"
# )
