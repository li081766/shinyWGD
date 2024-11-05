#' Compute the Mean of Ks values for Each Multiplicon
#'
#' This function takes as input a multiplicon file, an anchorpoint file, Ks values, and other relevant information.
#' It calculates the mean of Ks values for each multiplicon and associates them with the corresponding data.
#'
#' @param multiplicon_file A file containing multiplicon information.
#' @param anchorpoint_file A file containing anchorpoints information with columns like geneX, geneY, and other relevant data.
#' @param species1 The name of the first species.
#' @param ks_file A file containing Ks values.
#' @param outfile The output file where the results will be saved.
#' @param anchorpointout_file The output file for anchorpoint data with Ks values.
#' @param species2 (Optional) The name of the second species. Specify this parameter and ks_file if working with two species.
#'
#' @importFrom vroom vroom
#' @importFrom stats median
#' @importFrom tidyr fill
#' @importFrom data.table copy
#'
#' @return None. The function saves the results to the specified outfile and anchorpointout_file.
#'
obtain_mean_ks_for_each_multiplicon <- function(multiplicon_file, anchorpoint_file, species1, ks_file, outfile, anchorpointout_file, species2=NULL){
    multiplicons <- suppressMessages(
        vroom(
            multiplicon_file,
            col_names=TRUE,
            delim="\t"
        )
    )
    anchorpoints <- suppressMessages(
        vroom(
            anchorpoint_file,
            col_names=TRUE,
            delim="\t"
        )
    )

    Ks <- genome_x <- list_x <- genome_y <- geneX <- geneY <- NULL
	tmp_pair1 <- tmp_pair2 <- geneA <- geneB <- pair1 <- pair2 <- NULL

    if( !is.null(species2) ){
        ks_value_df <- suppressMessages(
            vroom(
                ks_file,
                col_names=TRUE,
                delim="\t"
            ) %>%
                mutate(
                    pair1=paste(geneX, "VS", geneY, sep="_"),
                    pair2=paste(geneY, "VS", geneX, sep="_")
                )
        )

        colnames(ks_value_df) <- c("geneA", "geneB", "Omega", "Ka", "Ks", "pair1", "pair2")

        # ks_updateX_df <- left_join(
        #     ks_value_df,
        #     genes_df,
        #     by=c("geneX"="id")
        # ) %>%
        #     select(geneX, geneY, Omega, Ka, Ks, genome)
        # colnames(ks_updateX_df) <- c("geneX", "geneY", "Omega", "Ka", "Ks", "genomeX")
        #
        # ks_updateXY_df <- left_join(
        #     ks_updateX_df,
        #     genes_df,
        #     by=c("geneY"="id")
        # ) %>%
        #     select(geneX, geneY, Omega, Ka, Ks, genomeX, genome)
        # colnames(ks_updateXY_df) <- c("geneX", "geneY", "Omega", "Ka", "Ks", "genomeX", "genomeY")
        #
        # print(ks_updateXY_df)
        #
        # ks_updateXY_df <- ks_updateXY_df %>%
        #     rowwise() %>%
        #     filter(genomeX != genomeY)
        #
        # t1_df <- ks_updateXY_df$genomeX != species1
        # ks_updateXY_df[t1_df, c("geneX", "geneY")] <- ks_updateXY_df[t1_df, c("geneY", "geneX")]
        # ks_updateXY_df[t1_df, c("genomeX", "genomeY")] <- ks_updateXY_df[t1_df, c("genomeY", "genomeX")]
        #
        # ks_updateXY_df <- select(ks_updateXY_df, geneX, geneY, Omega, Ka, Ks)
        #
        # merged_ks <- left_join(
        #     anchorpoints,
        #     ks_updateXY_df,
        #     by=c("geneX"="geneX", "geneY"="geneY"),
        #     multiple="all") %>%
        #     filter(!is.na(Ks))
        #
        # if( nrow(merged_ks) == 0 ){
        #     merged_ks <- left_join(
        #         anchorpoints,
        #         ks_updateXY_df,
        #         by=c("geneY"="geneX",
        #              "geneX"="geneY"),
        #         multiple="all") %>%
        #         filter(!is.na(Ks))
        # }

        # colnames(ks_value_df) <- c("geneA", "geneB", "Omega", "Ka", "Ks")

        # merged_ks <- merge(
        #     anchorpoints,
        #     ks_value_df,
        #     by.x=c("geneX", "geneY"),
        #     by.y=c("geneA", "geneB")
        # )

        # merged_ks <- data.frame()
        # for( i in 1:nrow(anchorpoints) ){
        #     each_row <- anchorpoints[i, ]
        #     tmp_geneX <- each_row$geneX
        #     tmp_geneY <- each_row$geneY
        #     tmp_pair1 <- paste0(tmp_geneX, "_VS_", tmp_geneY)
        #     tmp_pair2 <- paste0(tmp_geneY, "_VS_", tmp_geneX)
        #     pair_list <- c(tmp_pair1, tmp_pair2)
        #
        #     tmp_ks_df <- ks_value_df %>%
        #         filter(pair1 %in% pair_list | pair2 %in% pair_list)
        #     if( nrow(tmp_ks_df) > 0 ){
        #         tmp_df <- bind_rows(each_row, tmp_ks_df) %>%
        #             select(-pair1, -pair2)
        #         merged_ks <- bind_rows(merged_ks, tmp_df)
        #     }
        # }
        anchorpoints <- anchorpoints %>%
            mutate(
                tmp_pair1=paste0(geneX, "_VS_", geneY),
                tmp_pair2=paste0(geneY, "_VS_", geneX)
            )

        # Merge data frames
        merged_ks <- bind_rows(
            anchorpoints %>%
                left_join(
                    ks_value_df,
                    by=c("tmp_pair1"="pair1"),
                    multiple="all"
                ),

            anchorpoints %>%
                left_join(
                    ks_value_df,
                    by=c("tmp_pair2"="pair1"),
                    multiple="all"
                ),

            anchorpoints %>%
                left_join(
                    ks_value_df,
                    by=c("tmp_pair1"="pair2"),
                    multiple="all"
                ),

            anchorpoints %>%
                left_join(
                    ks_value_df,
                    by=c("tmp_pair2"="pair2"),
                    multiple="all"
                )
        ) %>%
            filter(!is.na(Ks)) %>%
            select(-tmp_pair1, -tmp_pair2, -geneA, -geneB, -pair1, -pair2) %>%
            distinct()

        merged_ks <- subset(merged_ks, Ks<=5)
        merged_ks <- merged_ks[merged_ks$speciesX != merged_ks$speciesY, ]

        final_merged_ks <- data.frame(matrix(ncol=ncol(merged_ks), nrow=nrow(merged_ks)))
        for( i in 1:nrow(merged_ks) ){
            each_row <- merged_ks[i, ]
            if( each_row$speciesX != species1 ){
                x_columns <- grep("X", names(each_row))
                y_columns <- gsub("X", "Y", names(each_row[x_columns]))

                temp_values <- each_row[x_columns]
                each_row[x_columns] <- each_row[y_columns]
                each_row[y_columns] <- temp_values
            }
            final_merged_ks[i,] <- each_row
        }
        names(final_merged_ks) <- names(merged_ks)

        mean_ks_for_each_multiplicon <- aggregate(
            Ks ~ multiplicon,
            data=merged_ks,
            FUN=function(x) median(x, na.rm=TRUE)
        )

        multiplicons_filled <- fill(multiplicons, genome_x, list_x, .direction="down") # %>%
            # filter(genome_x != genome_y)

        # final_multiplicons <- data.frame(matrix(ncol=ncol(multiplicons_filled), nrow=nrow(multiplicons_filled)))
        # for( i in 1:nrow(multiplicons_filled) ){
        #     each_row <- multiplicons_filled[i, ]
        #     each_row$genome_x <- gsub("_", " ", each_row$genome_x)
        #     if( each_row$genome_x != species1 ){
        #         tmp1 <- each_row[2:3]
        #         each_row[2:3] <- each_row[5:6]
        #         each_row[5:6] <- tmp1
        #
        #         tmp2 <- each_row[10:11]
        #         each_row[10:11] <- each_row[12:13]
        #         each_row[12:13] <- tmp2
        #     }
        #
        #     final_multiplicons[i,] <- each_row
        # }
        colnames(multiplicons_filled) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                          "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")

        merged_ks_multiplicons <- left_join(
            multiplicons_filled,
            mean_ks_for_each_multiplicon,
            by="multiplicon"
        )
        merged_ks_multiplicons$Ks[is.na(merged_ks_multiplicons$Ks)] <- 0
    }
    else{
        ks_value_df <- suppressMessages(
            vroom(ks_file,
                  col_names=TRUE,
                  delim="\t")
        )

        # merge ks value for each anchor pair
        merged_ks <- left_join(
            anchorpoints,
            ks_value_df,
            by=c("geneX"="geneX",
                 "geneY"="geneY"),
            multiple="all") %>%
            filter(!is.na(Ks))
        if( nrow(merged_ks) == 0 ){
            merged_ks <- left_join(
                anchorpoints,
                ks_value_df,
                by=c("geneY"="geneX",
                     "geneX"="geneY"),
                multiple="all") %>%
                filter(!is.na(Ks))
        }
        merged_ks <- subset(merged_ks, Ks<=5)

        mean_ks_for_each_multiplicon <- aggregate(
            Ks ~ multiplicon,
            data=merged_ks,
            FUN=function(x) median(x, na.rm=TRUE)
        )

        multiplicons_filled <- fill(multiplicons, genome_x, list_x, .direction="down")

        final_multiplicons <- multiplicons_filled
        # for (i in 1:nrow(multiplicons_filled)) {
        #     each_row <- multiplicons_filled[i, ]
        #     tmp1 <- each_row[2:3]
        #     each_row[2:3] <- each_row[5:6]
        #     each_row[5:6] <- tmp1
        #
        #     tmp2 <- each_row[10:11]
        #     each_row[10:11] <- each_row[12:13]
        #     each_row[12:13] <- tmp2
        #     final_multiplicons <- rbind(final_multiplicons, each_row)
        # }
        colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                          "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")
        merged_ks_multiplicons <- left_join(
            final_multiplicons,
            mean_ks_for_each_multiplicon,
            by="multiplicon"
        )
        merged_ks_multiplicons$Ks[is.na(merged_ks_multiplicons$Ks)] <- 0
        final_merged_ks <- copy(merged_ks)
    }
    final_merged_ks <- final_merged_ks %>%
        distinct()
    write.table(final_merged_ks,
                file=anchorpointout_file,
                sep="\t",
                row.names=FALSE,
                quote=FALSE)
    write.table(merged_ks_multiplicons,
                file=outfile,
                sep="\t",
                row.names=FALSE,
                quote=FALSE)
}
