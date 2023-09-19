library(data.table)
library(argparse)
library(dplyr)
library(vroom)
library(tools)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_dir", help="Path to the output directory", required=TRUE)
parser$add_argument("-c", "--command_file", help="Path to the command file for i-ADHoRe", required=TRUE)
parser$add_argument("-d", "--diamond_path", help="Path to the Diamond executable", required=TRUE)
parser$add_argument("-s", "--shinywgd_path", help="Path to the ShinyWGD directory", required=TRUE)
parser$add_argument("-p", "--num_cores", help="Number of CPU cores to use", type="integer", default=1)

args <- parser$parse_args()

input_data <- fread(args$input_file, header=FALSE, col.names=c("species", "fasta_file", "gff_file"), fill=T, sep="\t", na.strings=c("", "NA"))
input_data$species <- gsub(" ", "_", input_data$species)
run_diamond_2sp <- function(species1, fasta_file1, species2, fasta_file2, diamond_path, output_dir){
	if( !file.exists(output_dir) ){
		dir.create(output_dir)
	}

    seqs1 <- readLines(fasta_file1)
    seqs1 <- gsub(">(.*)", sprintf(">%s|\\1", species1), seqs1, perl=TRUE)
    temp_file1 <- tempfile()
    writeLines(seqs1, temp_file1)
    
    seqs2 <- readLines(fasta_file2)
    seqs2 <- gsub(">(.*)", sprintf(">%s|\\1", species2), seqs2, perl=TRUE)
    temp_file2 <- tempfile()
    writeLines(seqs2, temp_file2)
    
    merged_file <- file.path(output_dir, sprintf("%s_vs_%s.cds.fasta", species1, species2))
    system(paste("cat", temp_file1, temp_file2, ">", merged_file))
    
    merged_pep_file <- file.path(output_dir, sprintf("%s_vs_%s.pep.fasta", species1, species2))
    system(paste("Rscript tools/cds2aa.R -i",
                 merged_file,
                 "-o",
                 merged_pep_file))
    
    out_file <- file.path(output_dir, sprintf("%s_vs_%s.blastp.tsv", species1, species2))
    system(paste(diamond_path, "blastp",
                 "-d", merged_pep_file,
                 "-q", merged_pep_file,
                 "--outfmt", "6",
                 "-p", args$num_cores,
                 "--out", out_file,
                 "-e 1E-05",
                 "--quiet"))
    
    file.remove(temp_file1, temp_file2)
}

run_diamond <- function(species, fasta_file, diamond_path, output_dir){
	if( !file.exists(output_dir) ){
		dir.create(output_dir)
	}

    seqs <- readLines(fasta_file)
    seqs <- gsub(">(.*)", sprintf(">%s|\\1", species), seqs, perl=TRUE)
    cds_file <- file.path(output_dir, sprintf("%s.cds.fasta", species))
    writeLines(seqs, cds_file)
    
    pep_file <- file.path(output_dir, sprintf("%s.pep.fasta", species))
    system(paste("Rscript tools/cds2aa.R -i",
                 cds_file,
                 "-o",
                 pep_file))
    
    out_file <- file.path(output_dir, sprintf("%s_vs_%s.blastp.tsv", species, species))
    system(paste(diamond_path, "blastp",
                 "-d", pep_file,
                 "-q", pep_file,
                 "--outfmt", "6",
                 "-p", args$num_cores,
                 "--out", out_file,
                 "-e 1E-05",
                 "--quiet")
           )
}

run_filter_blast <- function(blastpoutput, filtered_out){
    blast_output <- fread(
        blastpoutput, sep="\t", header=FALSE,
        col.names=c(
            "query_id", "subject_id", "pident", "length",
            "mismatch", "gapopen", "qstart", "qend", "sstart",
            "send", "evalue", "bitscore"
        )
    ) %>% filter( query_id != subject_id)
    
    blast_output <- data.table(blast_output)
    blast_output[, c("species1", "gene_id1") := tstrsplit(query_id, "|", fixed=TRUE)]
    blast_output[, c("species2", "gene_id2") := tstrsplit(subject_id, "|", fixed=TRUE)]
    
    max_bitscores_1 <- blast_output[, .(max_bitscore_x1=max(bitscore)), by=c("gene_id1", "species2")]
    max_bitscores_4 <- blast_output[, .(max_bitscore_y2=max(bitscore)), by=c("gene_id2", "species1")]
    blast_output <- merge(blast_output, max_bitscores_1, by=c("gene_id1", "species2"))
    blast_output <- merge(blast_output, max_bitscores_4, by=c("gene_id2", "species1"))
    
    blast_output[, max_bitscore := max(max_bitscore_x1, max_bitscore_y2), by=c("gene_id1", "gene_id2")]
    blast_output[, c_value:= bitscore/max_bitscore]
    blast_output_filtered <- subset(blast_output, c_value > 0.5)
    
    blast_output_filtered <- blast_output_filtered %>%
        mutate(gene1=ifelse(gene_id1 < gene_id2, gene_id1, gene_id2),
               gene2=ifelse(gene_id1 < gene_id2, gene_id2, gene_id1)) %>%
        distinct(gene1, gene2, .keep_all=TRUE)
    
    blast_output_filtered <- data.table(
        blast_output_filtered[, c("gene1"="gene_id1", "gene2"="gene_id2")]
    )
    fwrite(blast_output_filtered, filtered_out, sep="\t", quote=FALSE, col.names=FALSE)
}

prepare_gene_list <- function(species, gff_file, outdir){
    output_dir <- paste0(outdir, "/gene_lists")
    if( !file.exists(output_dir) ){
        dir.create(output_dir)
    }
    sp_output_dir <- paste0(output_dir, "/", species)
    if( !file.exists(sp_output_dir) ){
        dir.create(sp_output_dir)
    }
    output_file <- paste0(output_dir, "/", species, ".geneLists")
    genelistconf <- file(output_file, open="w")
    
    gff <- read.table(gff_file, header=FALSE, stringsAsFactors=FALSE, quote="", sep="\t")
    colnames(gff) <- c("seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute")
    split_gff <- split(gff, gff$seqname)
    cat(paste0("genome=", species, "\n"), file=genelistconf, append=TRUE)
    for( i in names(split_gff) ){
        chromosome_gff <- split_gff[[i]]
        filename <- paste0(i, ".txt")
		output_file_path <- file.path(sp_output_dir, filename)
        filepath <- file.path("Syn", "gene_lists", species, filename)
        chromosome_genes <- subset(chromosome_gff, feature == "mRNA" & grepl("^ID=([^;]+);", attribute))
        gene_id <- gsub("^ID=([^;]+);.*", "\\1", chromosome_genes$attribute)
        output <- cbind(gene_id, chromosome_genes$strand)
        write.table(output, file=output_file_path, quote=FALSE, sep="", col.names=FALSE, row.names=FALSE)
        cat(paste0(i, " ", filepath, "\n"), file=genelistconf, append=TRUE)
        
    }
    close(genelistconf)
}

get_chr_length_for_species <- function(species, gff_file, outdir){
    output_dir <- paste0(outdir, "/gene_lists")
    
    gff_df <- suppressMessages(vroom(gff_file,
                                     delim="\t",
                                     comment="#",
                                     col_names=c("seqid", "source", "type",
                                                 "start", "end", "score", 
                                                 "strand", "phase", "attributes")))
        
    gff_grouped <- group_by(gff_df, seqid)
    max_pos <- summarise(gff_grouped, len=max(end))
    max_pos$sp <- species
    output_file <- paste0(output_dir, "/", species, ".Chr_len.list")
    write.table(max_pos, 
                file=output_file, 
                sep="\t",
                row.names=FALSE, 
                quote=FALSE)
}

get_chr_gene_num_for_species <- function(species, gff_file, outdir){
    output_dir <- paste0(outdir, "/gene_lists")
    
    gff_df <- suppressMessages(vroom(gff_file,
                                     delim="\t",
                                     comment="#",
                                     col_names=c("seqid", "source", "type",
                                                 "start", "end", "score", 
                                                 "strand", "phase", "attributes")))
        
    gff_grouped <- group_by(gff_df, seqid)
    gene_num <- summarise(gff_grouped, num=sum(type=="mRNA"))
    gene_num$sp <- species
    output_file <- paste0(output_dir, "/", species, ".Chr_gene_num.list")
    write.table(gene_num, 
                file=output_file, 
                sep="\t",
                row.names=FALSE, 
                quote=FALSE)
}

make_configure_iadhore_2sp <- function(species1, species1_list_file, species2, species2_list_file, config_file, output_dir){
    if( file.exists(config_file) ){
        file.remove(config_file)
    }
    
    config_file_con <- file(config_file, open="a")
    
    sp1_gene_list <- file(species1_list_file, open="r")
    sp1_input <- readLines(sp1_gene_list)
    close(sp1_gene_list)
    sp2_gene_list <- file(species2_list_file, open="r")
    sp2_input <- readLines(sp2_gene_list)
    close(sp2_gene_list)
    
    writeLines(sp1_input, config_file_con)
    writeLines(sp2_input, config_file_con)
    writeLines(paste0("blast_table=", output_dir, "/", species1, "_vs_", species2, ".blastp.pairs"), config_file_con)
    writeLines("table_type=pairs", config_file_con)
    writeLines(paste0("output_path=", output_dir), config_file_con)
    writeLines("cluster_type=collinear", config_file_con)
    writeLines("prob_cutoff=0.01", config_file_con)
    writeLines("write_stats=true", config_file_con)
    writeLines("level_2_only=false", config_file_con)
    writeLines("multiple_hypothesis_correction=FDR", config_file_con)
    writeLines("gap_size=35", config_file_con)
    writeLines("cluster_gap=40", config_file_con)
    writeLines("q_value=0.75", config_file_con)
    writeLines("anchor_points=3", config_file_con)
    writeLines("alignment_method=gg2", config_file_con)
    writeLines("max_gaps_in_alignment=40", config_file_con)
    writeLines("visualizeGHM=false", config_file_con)
    writeLines("visualizeAlignment=false", config_file_con)
    writeLines("verbose_output=true", config_file_con)
    writeLines("", config_file_con)
    close(config_file_con)
}

make_configure_iadhore <- function(species, species_list_file,config_file, output_dir){
    if( file.exists(config_file) ){
        file.remove(config_file)
    }
    
    config_file_con <- file(config_file, open="a")
    
    sp_gene_list <- file(species_list_file, open="r")
    sp_input <- readLines(sp_gene_list)
    close(sp_gene_list)
    
    writeLines(sp_input, config_file_con)
    writeLines(paste0("blast_table=", output_dir, "/", species, "_vs_", species, ".blastp.pairs"), config_file_con)
    writeLines("table_type=pairs", config_file_con)
    writeLines(paste0("output_path=", output_dir), config_file_con)
    writeLines("cluster_type=collinear", config_file_con)
    writeLines("prob_cutoff=0.01", config_file_con)
    writeLines("write_stats=true", config_file_con)
    writeLines("level_2_only=false", config_file_con)
    writeLines("multiple_hypothesis_correction=FDR", config_file_con)
    writeLines("gap_size=35", config_file_con)
    writeLines("cluster_gap=40", config_file_con)
    writeLines("q_value=0.75", config_file_con)
    writeLines("anchor_points=3", config_file_con)
    writeLines("alignment_method=gg2", config_file_con)
    writeLines("max_gaps_in_alignment=40", config_file_con)
    writeLines("visualizeGHM=false", config_file_con)
    writeLines("visualizeAlignment=false", config_file_con)
    writeLines("verbose_output=true", config_file_con)
    writeLines("", config_file_con)
    close(config_file_con)
}


complete_info <- complete.cases(input_data)
input_data <- input_data[complete_info, ]

iadhore_sp_list <- list()
for( i in seq_len(nrow(input_data)) ){
    species <- input_data$species[i]
    fasta_file <- file.path(input_data$fasta_file[i])
    outdir <- paste0(args$output_dir, "/", "i-adhore.", species, "_vs_", species)
    prepare_gene_list(species, input_data$gff_file[i], args$output_dir)
    get_chr_length_for_species(species, input_data$gff_file[i], args$output_dir)
    get_chr_gene_num_for_species(species, input_data$gff_file[i], args$output_dir)
    out_file <- file.path(outdir, "/", sprintf("%s_vs_%s.blastp.tsv", species, species))
    out_filter_file <- file.path(outdir, "/", sprintf("%s_vs_%s.blastp.pairs", species, species))
    if( !file.exists(out_file) ){
        run_diamond(species, fasta_file, args$diamond_path, outdir)
        run_filter_blast(out_file, out_filter_file)
    }
    
    iadhore_sp_list <- c(iadhore_sp_list, input_data$species[i])
    for( j in seq_len(nrow(input_data)) ){
        if( j > i ){
            species1 <- input_data$species[i]
            fasta_file1 <- file.path(input_data$fasta_file[i])
            
            species2 <- input_data$species[j]
            fasta_file2 <- file.path(input_data$fasta_file[j])
            
            outdir <- paste0(args$output_dir, "/", "i-adhore.", species1, "_vs_", species2)
            out_file <- file.path(outdir, "/", sprintf("%s_vs_%s.blastp.tsv", species1, species2))
            out_filter_file <- file.path(outdir, "/", sprintf("%s_vs_%s.blastp.pairs", species1, species2))
            if( !file.exists(out_file) ){
                run_diamond_2sp(species1, fasta_file1, species2, fasta_file2, args$diamond_path, outdir)
                run_filter_blast(out_file, out_filter_file)
            }
        }
    }
}

cmd_file <- paste0(args$output_dir, "/../", args$command_file)
if( file.exists(cmd_file) ){
    file.remove(cmd_file)
}

config_file_con <- file(cmd_file, open="w")
for( i in seq_len(length(iadhore_sp_list)) ){
    species <- iadhore_sp_list[[i]]
    species_gene_list <- paste0(args$output_dir, "/gene_lists/", species, ".geneLists")
    outdir <- paste0(args$output_dir, "/", "i-adhore.", species, "_vs_", species)
    if( !file.exists(outdir) ){
        dir.create(outdir)
    }
    iadhore_conf_file <- paste0(outdir, "/", species, "_vs_", species, ".i-adhore.ini")
    config_dir <- paste0("Syn/", "i-adhore.", species, "_vs_", species)
    make_configure_iadhore(species, species_gene_list, iadhore_conf_file, config_dir)
    writeLines(paste0("i-adhore ", "Syn/", "i-adhore.", species, "_vs_", species, "/", species, "_vs_", species, ".i-adhore.ini"), config_file_con)
    # add script to calculate the Ks of anchorpoints
    cdsFile <- paste0(species, ".cds.fasta")
    writeLines(paste0("cd Syn/", "i-adhore.", species, "_vs_", species, "/; ",
                      "sh ", args$shinywgd_path, "/tools/computing_anchorpoint_ks.MultiThreads.sh ",
                      "anchorpoints.txt ", cdsFile,
                      " 4; cd ../.."),
               config_file_con)
    for( j in seq_len(length(iadhore_sp_list)) ){
        if( j > i ){
            species1 <- iadhore_sp_list[[i]]
            species1_gene_list <- paste0(args$output_dir, "/gene_lists/", species1, ".geneLists")
            species2 <- iadhore_sp_list[[j]]
            species2_gene_list <- paste0(args$output_dir, "/gene_lists/", species2, ".geneLists")
            outdir <- paste0(args$output_dir, "/", "i-adhore.", species1, "_vs_", species2)
            if( !file.exists(outdir) ){
                dir.create(outdir)
            }
            iadhore_conf_file <- paste0(outdir, "/", species1, "_vs_", species2, ".i-adhore.ini")
            config_dir <- paste0("Syn/", "i-adhore.", species1, "_vs_", species2)
            make_configure_iadhore_2sp(species1, species1_gene_list, species2, species2_gene_list, iadhore_conf_file, config_dir)
            #writeLines(paste0("i-adhore ", outdir, "/", species1, "_vs_", species2, ".i-adhore.ini"), config_file_con)
            writeLines(paste0("i-adhore ", "Syn/", "i-adhore.", species1, "_vs_", species2, "/", 
                              species1, "_vs_", species2, ".i-adhore.ini"), config_file_con)
            # add script to calculate the Ks of anchorpoints
            cdsFile <- paste0(species1, "_vs_", species2, ".cds.fasta")
            writeLines(paste0("cd Syn/", "i-adhore.", species1, "_vs_", species2, "/; ",
                              "sh ", args$shinywgd_path, "/tools/computing_anchorpoint_ks.singlethread.sh ",
                              "anchorpoints.txt ", cdsFile,
                              "; cd ../.."),
                       config_file_con)
        }
    }
}
close(config_file_con)