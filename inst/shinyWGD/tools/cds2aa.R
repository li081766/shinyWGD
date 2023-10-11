library(seqinr)
library(argparse)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_file", help="Path to the output file", required=TRUE)

args <- parser$parse_args()

cds_sequences <- read.fasta(args$input_file)
proteins <- sapply(cds_sequences, function(seq) {
    translated_seq <- translate(seq)
    if (tail(translated_seq, 1) == "*") {
        translated_seq <- head(translated_seq, -1)
    }
    return(translated_seq)
})

write.fasta(
    sequences=proteins,
    names=names(proteins),
    file.out=args$output_file
)

