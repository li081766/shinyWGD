library(data.table)
library(argparse)

parser <- argparse::ArgumentParser()
parser$add_argument("-i", "--input_file", help="Path to the input file", required=TRUE)
parser$add_argument("-o", "--output_dir", help="Path to the output directory", required=TRUE)
parser$add_argument("-s", "--select_clade", help="Species to select gene families for Whale", required=TRUE)
parser$add_argument("-c", "--command_file", help="Path to the command file for i-ADHoRe", required=TRUE)

args <- parser$parse_args()

input_data <- fread(args$input_file,
                    header=FALSE,
                    col.names=c("species", "fasta_file", "gff_file"),
                    fill=TRUE,
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

#outDir <- paste0(args$output_dir, "/OrthoFinderOutputDir")
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
          "-o OrthoFinderOutputDir"
    ),
    cmd_con
)
writeLines("folder=$(find ./OrthoFinderOutputDir -maxdepth 1 -type d -name \"Results_*\" -printf '%f')", cmd_con)
writeLines("cd ds_tree_wd", cmd_con)
writeLines(
    paste0(
        "sh ",
        "./computing_Ks_tree_of_SingleCopyOrthologues.shell \\\n",
        "\t-i ../OrthoFinderOutputDir/$folder/Orthogroups/Orthogroups_SingleCopyOrthologues.txt \\\n",
        "\t-o ../OrthoFinderOutputDir/$folder/Orthogroups/Orthogroups.tsv \\\n",
        "\t-d ../OrthoFinderOutputDir/$folder/Orthogroup_Sequences/ \\\n",
        "\t-s SingleCopyOrthologues.tsv \\\n",
        "\t-c ../../Species.info.xls \\\n",
        "\t-p singleCopyAlign.phylip \\\n",
        "\t-t ../../tree.newick \\\n",
        "\t-n 4"
    ),
    cmd_con
)
writeLines("cd ..", cmd_con)
writeLines("# Prepare data for Whale", cmd_con)
filter_script <- paste0(getwd()[1], "/tools/Whale.jl/scripts/orthofilter.py")
system(
    paste(
        "cp",
        filter_script,
        dirname(cmd_file)
    )
)
writeLines(
    paste(
        "python",
        "./orthofilter.py",
        "OrthoFinderOutputDir/$folder/Orthogroups/Orthogroups.tsv",
        args$select_clade,
        "orthogroups.filtered.tsv",
        "1"
    ),
    cmd_con
)
writeLines(
    paste0(
        "tar -czf OrthoFinderOutput_for_Whale.tar.gz orthogroups.filtered.tsv ",
        "--files-from=<(awk -F'\\t' -v folder=\"$folder\" ",
        "'$1 ~ /^OG/ {print \"OrthoFinderOutputDir/\" folder \"/MultipleSequenceAlignments/\"$1\".fa\"}' ",
        "orthogroups.filtered.tsv)"
    ),
    cmd_con
)
writeLines("tar czf OrthoFinderOutputDir/$folder/MultipleSequenceAlignments.tar.gz OrthoFinderOutputDir/$folder/MultipleSequenceAlignments/ && rm -r OrthoFinderOutputDir/$folder/MultipleSequenceAlignments/", cmd_con)
writeLines("tar czf OrthoFinderOutputDir/$folder/Orthogroup_Sequences.tar.gz OrthoFinderOutputDir/$folder/Orthogroup_Sequences/ && rm -r OrthoFinderOutputDir/$folder/Orthogroup_Sequences/", cmd_con)
writeLines("tar czf OrthoFinderOutputDir/$folder/Single_Copy_Orthologue_Sequences.tar.gz OrthoFinderOutputDir/$folder/Single_Copy_Orthologue_Sequences/ && rm -r OrthoFinderOutputDir/$folder/Single_Copy_Orthologue_Sequences/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Comparative_Genomics_Statistics/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Gene_Duplication_Events/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Gene_Trees/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Orthologues/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Phylogenetically_Misplaced_Genes/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Phylogenetic_Hierarchical_Orthogroups/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Putative_Xenologs/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Resolved_Gene_Trees/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/Species_Tree/", cmd_con)
writeLines("rm -r OrthoFinderOutputDir/$folder/WorkingDirectory/", cmd_con)
close(cmd_con)
