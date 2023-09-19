#' Title Compute the mean of Ks for each multiplicon
#'
#' @param multiplicon_file multiplicons.txt created by i-ADHoRe
#' @param anchorpoint_file anchorpoints.merged_pos.txt reformed anchorpoints.txt
#' @param species1 the name of query species
#' @param ks_file anchorpoints.ks.txt the file includes the Ks value of anchored points
#' @param outfile a file to save the mean of Ks for each multiplicon
#' @param anchorpointout_file a file to save the corresponding Ks for anchored points 
#' @param species2 the name of subject species, default: NULL
#'
#' @export 
#'
#' @examples
#' obtain_mean_ks_for_each_multiplicon(
#'     multiplicon_file=multiplicon_file,
#'     anchorpoint_file=anchorpoint_merged_file,
#'     ks_file=ks_file,
#'     species1=querySpecies,
#'     species2=subjectSpecies,
#'     anchorpointout_file=anchorpointout_file,
#'     outfile=multiplicon_ks_file
#' )
obtain_mean_ks_for_each_multiplicon <- function(multiplicon_file, anchorpoint_file, species1, ks_file, outfile, anchorpointout_file, species2=NULL){
    library(vroom)
    library(dplyr)
    multiplicons <- suppressMessages(
        vroom(multiplicon_file,
              col_names=TRUE,
              delim="\t"
        )
    )
    anchorpoints <- suppressMessages(
        vroom(anchorpoint_file,
              col_names=TRUE,
              delim="\t")
    )
    
    if( !is.null(species2) ){
        ks_value_df <- suppressMessages(
            vroom(ks_file,
                  col_names=TRUE,
                  delim="\t")
        )
        
        merged_ks <- left_join(anchorpoints, 
                               ks_value_df, 
                               by=c("geneX"="geneX", "geneY"="geneY"),
                               multiple="all") %>%
            filter(!is.na(Ks))
        if( nrow(merged_ks) == 0 ){
            merged_ks <- left_join(anchorpoints, 
                                   ks_value_df, 
                                   by=c("geneY"="geneX", 
                                        "geneX"="geneY"),
                                   multiple="all") %>%
                filter(!is.na(Ks))
        }
        merged_ks <- unique(merged_ks)
        merged_ks <- subset(merged_ks, Ks<=5)

        mean_ks_for_each_multiplicon <- aggregate(Ks ~ multiplicon, 
                                                  data=merged_ks,
                                                  FUN=function(x) median(x, na.rm=TRUE)
                                                  #FUN=function(x) mean(x, na.rm = TRUE)
        )
        
        multiplicons_filled <- fill(multiplicons, genome_x, list_x, .direction = "down") %>%
            filter(genome_x != genome_y)
        
        final_multiplicons <- data.frame(matrix(ncol = ncol(multiplicons_filled), nrow = nrow(multiplicons_filled)))
        for (i in 1:nrow(multiplicons_filled)) {
            each_row <- multiplicons_filled[i, ]
            each_row$genome_x <- gsub("_", " ", each_row$genome_x)
            if (each_row$genome_x != species1) {
                tmp1 <- each_row[2:3]
                each_row[2:3] <- each_row[5:6]
                each_row[5:6] <- tmp1
                
                tmp2 <- each_row[10:11]
                each_row[10:11] <- each_row[12:13]
                each_row[12:13] <- tmp2
            }
            
            final_multiplicons[i,] <- each_row
        }
        colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                          "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")
        
        merged_ks_multiplicons <- left_join(final_multiplicons, 
                                            mean_ks_for_each_multiplicon,
                                            by="multiplicon")
        merged_ks_multiplicons$Ks[is.na(merged_ks_multiplicons$Ks)] <- 0
    }
    else{
        ks_value_df <- suppressMessages(
            vroom(ks_file,
                  col_names=TRUE,
                  delim="\t")
        ) 
        # %>% select(Family, Ka, Ks, Paralog1, Paralog2)
        
        # merge ks value for each anchor pair
        merged_ks <- left_join(anchorpoints, 
                               ks_value_df, 
                               by=c("geneX"="geneX", 
                                    "geneY"="geneY"),
                               multiple="all") %>%
            filter(!is.na(Ks))
        if( nrow(merged_ks) == 0 ){
            merged_ks <- left_join(anchorpoints, 
                                   ks_value_df, 
                                   by=c("geneY"="geneX", 
                                        "geneX"="geneY"),
                                   multiple="all") %>%
                filter(!is.na(Ks))
        }
        merged_ks <- subset(merged_ks, Ks<=5)
        
        mean_ks_for_each_multiplicon <- aggregate(Ks ~ multiplicon, 
                                                  data=merged_ks,
                                                  FUN=function(x) median(x, na.rm=TRUE)
                                                  #FUN=function(x) mean(x, na.rm = TRUE)
        )
        
        multiplicons_filled <- fill(multiplicons, genome_x, list_x, .direction = "down") 
        
        final_multiplicons <- multiplicons_filled
        for (i in 1:nrow(multiplicons_filled)) {
            each_row <- multiplicons_filled[i, ]
            # each_row$genome_x <- gsub("_", " ", each_row$genome_x)
            tmp1 <- each_row[2:3]
            each_row[2:3] <- each_row[5:6]
            each_row[5:6] <- tmp1
            
            tmp2 <- each_row[10:11]
            each_row[10:11] <- each_row[12:13]
            each_row[12:13] <- tmp2
            final_multiplicons <- rbind(final_multiplicons, each_row)
        }
        colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                          "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")
        merged_ks_multiplicons <- left_join(final_multiplicons, 
                                            mean_ks_for_each_multiplicon,
                                            by="multiplicon")
        merged_ks_multiplicons$Ks[is.na(merged_ks_multiplicons$Ks)] <- 0
    }
    write.table(merged_ks, 
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
