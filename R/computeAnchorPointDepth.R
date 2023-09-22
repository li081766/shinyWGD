#' Compute the Depth of Anchored Points
#'
#' This function calculates the depth of anchored points based on the provided parameters.
#'
#' @param anchorpoint_ks_file The file containing anchorpoint and Ks data.
#' @param multiplicon_id The ID of the multiplicon to consider.
#' @param selected_query_chr A list of selected query chromosomes.
#' @param selected_subject_chr A list of selected subject chromosomes (optional).
#'
#' @return A list containing depth data frames, including "query_depth" and "subject_depth" if subject chromosomes are specified, or "depth" if not.
#'
#' @export
#'
#' @examples
#' # Example usage:
#' depth_list <- computing_depth(
#'     anchorpoint_ks_file = anchorpointout_file,
#'     multiplicon_id = selected_multiplicons_Id,
#'     selected_query_chr = query_selected_chr_list,
#'     selected_subject_chr = subject_selected_chr_list
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

#' Compute the Depth of Anchored Points in a Paranome Comparison
#'
#' This function computes the depth of anchored points in a paranome comparison based on the provided parameters.
#'
#' @param anchorpoint_ks_file The file containing anchor point and Ks value data.
#' @param multiplicon_id The IDs of the multiplicons to consider.
#' @param selected_query_chr The list of selected query chromosomes.
#'
#' @return A list containing the depth dataframe.
#' @export
#'
#' @examples
#' # Example usage:
#' depth_list <- computing_depth_paranome(
#'     anchorpoint_ks_file = anchorpointout_file,
#'     multiplicon_id = selected_multiplicons_Id,
#'     selected_query_chr = query_selected_chr_list
#' )
#'
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
