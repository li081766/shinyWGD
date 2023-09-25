# library(seqinr)
library(argparse)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_file", help="Path to the output file", required=TRUE)

args <- parser$parse_args()

read.cds <- function(file, format, delete_corrupt_cds=TRUE, ...) {
    if (!is.element(format, c("fasta", "fastq")))
        stop("Please choose a file format that is supported by this function.")
    
    if (!file.exists(file))
        stop("The file path you specified does not seem to exist: '", file,"'.", call.=FALSE)
    
    geneids <- seqs <- NULL
    
    tryCatch({
        cds_file <- Biostrings::readDNAStringSet(filepath=file, format=format, ...)
        
        if (length(cds_file) == 0)
            stop("The file '", file,"' seems to be empty and does not contain any sequences.", call.=FALSE)
        
        cds_names <- as.vector(
            unlist(sapply(cds_file@ranges@NAMES, function(x) {
                return(strsplit(x, " ")[[1]][1])
            }))
        )
        
        cds.dt <- data.table::data.table(geneids=cds_names,
                                         seqs=tolower(as.character(cds_file)))
        
        
        data.table::setkey(cds.dt, geneids)
        
        mod3 <- function(x) {
            return((nchar(x) %% 3) == 0)
        }
        
        all_triplets <- as.logical(cds.dt[ , mod3(seqs)])
        
        n_seqs <- nrow(cds.dt)
        
    }, error=function(e) {
        stop(
            "File ",
            file,
            " could not be read properly.",
            "\n",
            "Please make sure that ",
            file,
            " contains only CDS sequences and is in ",
            format,
            " format."
        )
    })
    
    if (!all(all_triplets)) {
        message(
            "There seem to be ",
            length(which(!all_triplets)),
            " coding sequences in your input dataset which cannot be properly divided in base triplets, because their sequence length cannot be divided by 3."
        )
        corrupted_file <-
            paste0(basename(file), "_corrupted_cds_seqs.fasta")
        
        message(
            "A fasta file storing all corrupted coding sequences for inspection was generated and stored at '",
            file.path(getwd(), corrupted_file),
            "'."
        )
        message("\n")
        corrupted_seqs <- as.data.frame(cds.dt[which(!all_triplets)])
        seq_vector <- corrupted_seqs$seqs
        names(seq_vector) <- corrupted_seqs$geneids
        corrupted_seqs_biostrings <- Biostrings::DNAStringSet(seq_vector, use.names=TRUE)                                       
        Biostrings::writeXStringSet(corrupted_seqs_biostrings, filepath=corrupted_file)
        
        if (delete_corrupt_cds) {
            message(
                "You chose option 'delete_corrupt_cds=TRUE', thus corrupted coding sequences were removed.",
                "If after consulting the file '",
                corrupted_file,
                "' you still wish to retain all coding sequences please specify the argument 'delete_corrupt_cds=FALSE'."
            )
            message("\n")
            return(cds.dt[-which(!all_triplets) , list(geneids, seqs)])
        }
        
        if (!delete_corrupt_cds) {
            message(
                "You chose option 'delete_corrupt_cds=FALSE', thus corrupted coding sequences were retained for subsequent analyses.")
            message(
                "The following modifications were made to the CDS sequences that were not divisible by 3:")
            message(
                "- If the sequence had 1 residue nucleotide then the last nucleotide of the sequence was removed.")
            message(
                "- If the sequence had 2 residue nucleotides then the last two nucleotides of the sequence were removed.")
            message(
                "If after consulting the file '",
                corrupted_file,
                "' you wish to remove all corrupted coding sequences please specify the argument 'delete_corrupt_cds=TRUE'."
            )
            
            mod3_residue_1 <-
                function(x) {
                    return((nchar(x) %% 3) == 1)
                }
            
            mod3_residue_2 <-
                function(x) {
                    return((nchar(x) %% 3) == 2)
                }
            
            residue_1 <- cds.dt[ , mod3_residue_1(seqs)]
            residue_2 <- cds.dt[ , mod3_residue_2(seqs)]
            
            residue_1_seqs <- as.character(cds.dt[which(residue_1) , seqs])
            residue_2_seqs <- as.character(cds.dt[which(residue_2) , seqs])
            
            residue_1_seqs_vec <- as.character(sapply(residue_1_seqs, function(x) {
                stringr::str_sub(x, 1, nchar(x) - 1)
            }))
            
            residue_2_seqs_vec <- as.character(sapply(residue_2_seqs, function(x) {
                stringr::str_sub(x, 1, nchar(x) - 2)
            }))
            
            cds.dt[which(residue_1) , seqs := residue_1_seqs_vec]
            cds.dt[which(residue_2) , seqs := residue_2_seqs_vec]
            
            all_triplets_new <- cds.dt[ , mod3(seqs)]
            
            if (any(!all_triplets_new)) {
                stop("Something went wring during the trimming process. Not all sequences were trimmed properly.", call.=FALSE)
            } else {
                message("All corrupted CDS were trimmed.")
            }
            
            n_seqs_new <- nrow(cds.dt)
            
            if(!(n_seqs == n_seqs_new))
                stop("After trimming corrupted CDS some sequences seem to be lost. Please check what might have gone wrong with the sequence trimming.", call.=FALSE)
            
            return(cds.dt)
        }
        
    } else {
        return(cds.dt)
    }
}

# dna_seqs <- read.fasta(args$input_file)
# aa_seqs <- lapply(dna_seqs, function(x) translate(x, ambiguous=TRUE))
# write.fasta(aa_seqs, names=names(dna_seqs), file.out=args$output_file)


if ( !file.exists(args$input_file) ){
    stop(
        "The file '",
        args$input_file,
        "' seems not to exist. Please check your file path.",
        call.=FALSE
    )
}


cds_file <- read.cds(
    file=args$input_file,
    format="fasta",
    delete_corrupt_cds=TRUE
)
cds_seqs <- as.data.frame(cds_file)
seq_vector <- cds_seqs$seqs
names(seq_vector) <- cds_seqs$geneids
seqs_biostrings <- Biostrings::DNAStringSet(seq_vector, use.names=TRUE)   
protein_file <- Biostrings::translate(seqs_biostrings, if.fuzzy.codon="solve")
Biostrings::writeXStringSet(protein_file, args$output_file)


