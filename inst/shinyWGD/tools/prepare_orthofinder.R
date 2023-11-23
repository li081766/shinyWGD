library(data.table)
library(argparse)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_dir", help="Path to the output directory", required=TRUE)
parser$add_argument("-c", "--command_file", help="Path to the command file for i-ADHoRe", required=TRUE)

args <- parser$parse_args()

input_data <- fread(args$input_file,
                    header=FALSE,
                    col.names=c("species", "fasta_file", "gff_file"),
                    fill=T,
                    sep="\t",
                    na.strings=c("", "NA"))
for( i in seq_len(nrow(input_data)) ){
    species <- input_data$species[i]
    fasta_file <- file.path(input_data$fasta_file[i])
    pep_dir <- paste0(args$output_dir, "/pepDir")
    if( !file.exists(pep_dir) ){
        dir.create(pep_dir)
    }
    pep_file <- paste0(pep_dir, "/", gsub(" ", "_", species), ".pep")
    system(
        paste(
            "Rscript tools/cds2aa.R",
            "-i", fasta_file,
            "-o", pep_file
        )
    )
}

cmd_file <- args$command_file
if( file.exists(cmd_file) ){
    file.remove(cmd_file)
}

cmd_con <- file(cmd_file, open="w")

#outDir <- paste0(args$output_dir, "/orthofinderOutputDir")
writeLines(
    c(
        "#!/bin/bash",
        "",
        "#SBATCH -p all",
        "#SBATCH -c 4",
        "#SBATCH --mem 8G",
        paste0("#SBATCH -o ", basename(cmd_file), ".o%j"),
        paste0("#SBATCH -e ", basename(cmd_file), ".e%j"),
        ""
    ),
    cmd_con
)

writeLines(
    "module load OrthoFinder",
    cmd_con
)
writeLines(
    paste("orthofinder",
          "-f pepDir",
          "-S diamond -t 4 -a 4 -I 3 -M msa -ot",
          "-o orthofinderOutputDir"
    ),
    cmd_con
)
writeLines("folder=$(find ./orthofinderOutputDir -maxdepth 1 -type d -name \"Results_*\" -printf '%f')", cmd_con)
writeLines("cd ds_tree_wd", cmd_con)
writeLines(
    paste0(
        "sh ",
        "./computing_Ks_tree_of_SingleCopyOrthologues.shell \\\n",
        "\t-i ../orthofinderOutputDir/$folder/Orthogroups/Orthogroups_SingleCopyOrthologues.txt \\\n",
        "\t-o ../orthofinderOutputDir/$folder/Orthogroups/Orthogroups.tsv \\\n",
        "\t-d ../orthofinderOutputDir/$folder/Orthogroup_Sequences/ \\\n",
        "\t-s SingleCopyOrthologues.tsv \\\n",
        "\t-c ../../Species.info.xls \\\n",
        "\t-p singleCopyAlign.phylip \\\n",
        "\t-t ../../tree.newick \\\n",
        "\t-n 4"
    ),
    cmd_con
)
writeLines("cd ..", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Comparative_Genomics_Statistics/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Gene_Duplication_Events/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Gene_Trees/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Orthologues/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Phylogenetically_Misplaced_Genes/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Phylogenetic_Hierarchical_Orthogroups/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Putative_Xenologs/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Resolved_Gene_Trees/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/Species_Tree/", cmd_con)
writeLines("rm -r orthofinderOutputDir/$folder/WorkingDirectory/", cmd_con)
writeLines("tar czf orthofinderOutputDir/$folder/Orthogroup_Sequences.tar.gz orthofinderOutputDir/$folder/Orthogroup_Sequences/ && rm -r orthofinderOutputDir/$folder/Orthogroup_Sequences", cmd_con)
close(cmd_con)
