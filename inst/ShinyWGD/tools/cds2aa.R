library(seqinr)
library(argparse)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_file", help="Path to the output file", required=TRUE)

args <- parser$parse_args()

cds_sequences <- read.fasta(args$input_file)
proteins <- lapply(cds_sequences, translate)

#' Remove the last "*" from the protein sequence
#'
#' @param seq protein sequence
#'
#' @return modified sequence
#' @export
#'
#' @noRd
remove_last_asterisk <- function(seq){
    if( seq[length(seq)] == "*" ){
        seq <- seq[seq != "*"]
    }
    return(seq)
}

proteins <- lapply(proteins, remove_last_asterisk)
write.fasta(
    sequences=proteins,
    names=names(proteins),
    file.out=args$output_file
)
