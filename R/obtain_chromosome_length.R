#' obtain_chromosome_length
#'
#' Process species information file and extract chromosome lengths and mRNA counts from GFF files.
#'
#' @param species_info_file A character string specifying the path to the species information file.
#'
#' @importFrom vroom vroom
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr filter
#'
#' @return A list containing two data frames: len_df for chromosome lengths and num_df for mRNA counts.
#'
obtain_chromosome_length <- function(species_info_file){
    actual_path <- dirname(species_info_file)

    df <- read.table(
        species_info_file,
        sep="\t",
        header=FALSE,
        fill=T,
        na.strings="",
		col.names=c("sp", "cds", "gff")
    )

    cds_files <- gsub(".*/", "", df$cds)
    gff_files <- gsub(".*/", "", df$gff)

    new_cds_files <- paste0(actual_path, "/", cds_files)
    new_gff_files <- paste0(actual_path, "/", gff_files)

    df$cds <- new_cds_files
    df$gff <- new_gff_files

    len_df <- data.frame(sp=character(),
                         chr=character(),
                         len=integer())
    # num_df <- data.frame(sp=character(),
    #                      chr=character(),
    #                      num=integer())

    for( i in 1:nrow(df) ){
        each_row <- df[i, ]
        gff_df <- suppressMessages(vroom(each_row$gff,
                        delim="\t",
                        comment="#",
                        col_names=c("seqchr", "source", "type",
                                    "start", "end", "score",
                                    "strand", "phase", "attributes")))

        seqchr <- end <- type <- NULL

        gff_grouped <- group_by(gff_df, seqchr)
        max_pos <- summarise(gff_grouped, len=max(end))
        max_pos$sp <- gsub(" ", "_", each_row$sp)
        len_df <- rbind(len_df, max_pos)
        # mRNA_counts <- gff_grouped %>%
        #     filter(type=="mRNA") %>%
        #     group_by(seqchr) %>%
        #     summarise(count=dplyr::n())
        # mRNA_counts$sp <- gsub(" ", "_", each_row$sp)
        # num_df <- rbind(num_df, mRNA_counts)
    }
    #colnames(num_df) <- c("seqchr", "num", "sp")
    #return(list(len_df=len_df, num_df=num_df))
    return(len_df)
}

#' obtain_chromosome_length_filter
#'
#' Process a data frame containing species information and extract chromosome lengths and mRNA counts from GFF files.
#'
#' @param species_info_df A data frame containing species information with columns "sp," "cds," and "gff."
#'
#' @importFrom vroom vroom
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr filter
#'
#' @return A list containing two data frames: len_df for chromosome lengths and num_df for mRNA counts.
#'
obtain_chromosome_length_filter <- function(species_info_df){

    df <- species_info_df
    colnames(df) <- c("sp", "cds", "gff")

    len_df <- data.frame(sp=character(),
                         chr=character(),
                         len=integer())
    num_df <- data.frame(sp=character(),
                         chr=character(),
                         num=integer())

    seqchr <- end <- type <- NULL
    for( i in 1:nrow(df) ){
        each_row <- df[i, ]
        gff_df <- suppressMessages(
            vroom(
                each_row$gff,
                delim="\t",
                comment="#",
                col_names=c("seqchr", "source", "type",
                            "start", "end", "score",
                            "strand", "phase", "attributes")
            )
        )

        gff_grouped <- group_by(gff_df, seqchr)
        max_pos <- summarise(gff_grouped, len=max(end))
        max_pos$sp <- gsub(" ", "_", each_row$sp)
        len_df <- rbind(len_df, max_pos)
        mRNA_counts <- gff_grouped %>%
            filter(type=="mRNA") %>%
            group_by(seqchr) %>%
            summarise(count=dplyr::n())
        mRNA_counts$sp <- gsub(" ", "_", each_row$sp)
        num_df <- rbind(num_df, mRNA_counts)
    }
    colnames(num_df) <- c("seqchr", "num", "sp")
    return(list(len_df=len_df, num_df=num_df))
}
