#' Title Compute the depth of anchored points in inter-comparasion
#'
#' @param anchorpoint_ks_file the anchored points file with the Ks values
#' @param multiplicon_id the multiplicon id used to reduce the complixity of computing
#' @param selected_query_chr the selected chromosomes of the query species
#' @param selected_subject_chr the selected chromosomes of the subject species
#'
#' @return a list including the depth of query species and the subject species
#'
#' @examples depth_list <- computing_depth(
#' anchorpoint_ks_file=anchorpointout_file,
#' multiplicon_id=selected_multiplicons_Id,
#' selected_query_chr=query_selected_chr_list,
#' selected_subject_chr=subject_selected_chr_list
#' )
computing_depth <- function(anchorpoint_ks_file, 
                            multiplicon_id,
                            selected_query_chr,
                            selected_subject_chr=NULL){
    if( !is.null(selected_subject_chr) ){
        anchorpoint_df <- read.table(
            anchorpoint_ks_file,
            sep="\t", 
            header=TRUE,
            fill=T,
            na.strings=""
        ) %>%
            filter(multiplicon %in% multiplicon_id) %>%
            filter(listX %in% selected_query_chr) %>%
            filter(listY %in% selected_subject_chr)
        
        suppressMessages(
            query_depth <- anchorpoint_df %>%
                group_by(listX, coordX) %>%
                summarise(count=n())
        )
        
        suppressMessages(
            subject_depth <- anchorpoint_df %>%
                group_by(listY, coordY) %>%
                summarise(count=n())
        )
        
        return(list(query_depth=query_depth,
                    subject_depth=subject_depth))
    }else{
        anchorpoint_df <- read.table(
            anchorpoint_ks_file,
            sep="\t", 
            header=TRUE,
            fill=T,
            na.strings=""
        ) %>%
            filter(listX %in% selected_query_chr)

        suppressMessages(
            query_depth <- anchorpoint_df %>%
                group_by(listX, coordX) %>%
                summarise(count=n())
        )
        
        return(list(depth=query_depth))
    }
}

#' Title compute the depth of anchored points in intra-comparison 
#'
#' @param anchorpoint_ks_file 
#' @param multiplicon_id 
#' @param selected_query_chr 
#'
#' @return a list of the depth dataframe
#'
#' @examples depth_list <- computing_depth_paranome(
#' anchorpoint_ks_file=anchorpointout_file,
#' multiplicon_id=selected_multiplicons_Id,
#' selected_query_chr=query_selected_chr_list
#' )
computing_depth_paranome <- function(
        anchorpoint_ks_file,
        multiplicon_id,
        selected_query_chr
    ){
    anchorpoint_df <- read.table(
        anchorpoint_ks_file,
        sep="\t", 
        header=TRUE,
        fill=T,
        na.strings=""
    ) 

    tmp_df <- anchorpoint_df
    
    data_names <- names(tmp_df)
    data_names_swapped <- gsub("X$", "TEMP", data_names)
    data_names_swapped <- gsub("Y$", "X", data_names_swapped)
    data_names_swapped <- gsub("TEMP$", "Y", data_names_swapped)
    
    colnames(tmp_df) <- data_names_swapped
    
    anchorpoint_df <- rbind(anchorpoint_df, tmp_df) %>%
        filter(multiplicon %in% multiplicon_id) %>%
        filter(listX %in% selected_query_chr)

    suppressMessages(
        query_depth <- anchorpoint_df %>%
            group_by(listX, coordX) %>%
            summarise(count=n())
    )
    return(list(depth=query_depth))
}