#' obtain_chromosome_length
#'
#' Process species information file and extract chromosome lengths and mRNA counts from GFF files.
#'
#' @param species_info_file A character string specifying the path to the species information file.
#'
#' @return A list containing two data frames: len_df for chromosome lengths and num_df for mRNA counts.
#'
#' @export
#'
#' @examples
#' # Load the species information into a data frame (replace 'species_info_df' with your actual data frame)
#' species_info_df <- read.table("path/to/your/species_info_file.txt", sep="\t", header=TRUE)
#'
#' # Call the obtain_chromosome_length_filter function
#' result <- obtain_chromosome_length_filter(species_info_df)
#'
#' # Access the chromosome length and mRNA count data frames from the result
#' len_df <- result$len_df
#' num_df <- result$num_df
#'
#' # Print the first few rows of the data frames
#' head(len_df)
#' head(num_df)
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
    num_df <- data.frame(sp=character(),
                         chr=character(),
                         num=integer())

    for( i in 1:nrow(df) ){
        each_row <- df[i, ]
        gff_df <- suppressMessages(vroom(each_row$gff,
                        delim="\t",
                        comment="#",
                        col_names=c("seqchr", "source", "type",
                                    "start", "end", "score",
                                    "strand", "phase", "attributes")))

        gff_grouped <- group_by(gff_df, seqchr)
        max_pos <- summarise(gff_grouped, len=max(end))
        max_pos$sp <- each_row$sp
        len_df <- rbind(len_df, max_pos)
        mRNA_counts <- gff_grouped %>%
            filter(type=="mRNA") %>%
            group_by(seqchr) %>%
            summarize(count=n())
        mRNA_counts$sp <- each_row$sp
        num_df <- rbind(num_df, mRNA_counts)
    }
    colnames(num_df) <- c("seqchr", "num", "sp")
    return(list(len_df=len_df, num_df=num_df))
}

#' obtain_chromosome_length_filter
#'
#' Process a data frame containing species information and extract chromosome lengths and mRNA counts from GFF files.
#'
#' @param species_info_df A data frame containing species information with columns "sp," "cds," and "gff."
#'
#' @return A list containing two data frames: len_df for chromosome lengths and num_df for mRNA counts.
#'
#' @export
#'
#' @examples
#' Create a sample data frame
#' species_info_df <- data.frame(
#'   sp=c("SpeciesA", "SpeciesB"),
#'   cds=c("cds_file_A.gff", "cds_file_B.gff"),
#'   gff=c("gff_file_A.gff", "gff_file_B.gff")
#' )
#'
#' # Obtain chromosome lengths and mRNA counts
#' result <- obtain_chromosome_length_filter(species_info_df)
obtain_chromosome_length_filter <- function(species_info_df){

    df <- species_info_df
    colnames(df) <- c("sp", "cds", "gff")

    len_df <- data.frame(sp=character(),
                         chr=character(),
                         len=integer())
    num_df <- data.frame(sp=character(),
                         chr=character(),
                         num=integer())

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
        max_pos$sp <- each_row$sp
        len_df <- rbind(len_df, max_pos)
        mRNA_counts <- gff_grouped %>%
            filter(type=="mRNA") %>%
            group_by(seqchr) %>%
            summarize(count=n())
        mRNA_counts$sp <- each_row$sp
        num_df <- rbind(num_df, mRNA_counts)
    }
    colnames(num_df) <- c("seqchr", "num", "sp")
    return(list(len_df=len_df, num_df=num_df))
}
