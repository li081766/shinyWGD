#' Check if an Object is Not NULL
#'
#' This function checks if an object is not NULL.
#'
#' @param x An R object to check.
#'
#' @return A logical value indicating whether the object is not NULL.
#'
is.not.null <- function(x) {
    !is.null(x)
}

#' Creating a Custom Download Button
#'
#' Use this function to create a custom download button or link. When clicked, it will initiate a browser download. The filename and contents are specified by the corresponding downloadHandler() defined in the server function.
#'
#' @param outputId The name of the output slot that the downloadHandler is assigned to.
#' @param label The label that should appear on the button.
#' @param class Additional CSS classes to apply to the tag, if any. Default NULL.
#' @param status The status of the button; default is "primary."
#' @param ... Other arguments to pass to the container tag function.
#' @param icon An icon() to appear on the button; default is icon("download").
#'
#' @importFrom htmltools tags
#'
#' @return An HTML tag to allow users to download the object.
#'
downloadButton_custom <- function(
        outputId,
        label="Download",
        class=NULL,
        status="primary",
        ...,
        icon=shiny::icon("download")
        ){
    aTag <- tags$a(
        id=outputId,
        class=paste(paste0("btn btn-", status, " shiny-download-link"), class),
        href="",
        target="_blank",
        download=NA,
        icon,
        label,
        ...
    )
}

#' Read Data from Uploaded File
#'
#' This function reads data from an uploaded file in a Shiny application and returns it as a data frame.
#'
#' @param uploadfile The object representing the uploaded file obtained through the Shiny upload function.
#'
#' @importFrom utils read.delim
#'
#' @return A data frame containing the data from the uploaded file.
#'
read_data_file <- function(uploadfile) {
    dataframe <- read.delim(
        uploadfile$datapath,
        sep="\t",
        header=FALSE,
        fill=TRUE,
        na.strings=""
    )
    return(dataframe)
}

#' Check and Prepare GFF/GTF Input File
#'
#' This function checks the file format of a GFF/GTF input file and prepares it for analysis. It can handle both uncompressed and compressed formats.
#'
#' @param gff_input_name A descriptive name for the GFF/GTF file.
#' @param gff_input_path The file path to the GFF/GTF file.
#' @param working_wd A character string specifying the working directory to be used.
#'
#' @importFrom stringr str_detect
#' @importFrom stringr regex
#' @importFrom fs file_temp
#' @importFrom shinyalert shinyalert
#'
#' @return The path to the prepared GFF file for analysis.
#'
check_gff_input <- function(gff_input_name, gff_input_path, working_wd){
    checked_gff <- paste0(working_wd, "/", gff_input_name, ".gff")
    if( str_detect(gff_input_path$name, ".(gff|gff3)$") ){
        link_gff_cmd <- paste0("cat ", gff_input_path$datapath, " | grep -v '#' > ", checked_gff)
        system(link_gff_cmd)
    }
    else if( str_detect(gff_input_path$name, regex(".(gff.gz|gff3.gz|gz)$")) ){
        gzip_gff_cmd <- paste0("gunzip -c ", gff_input_path$datapath, " | grep -v '#' > ", checked_gff)
        system(gzip_gff_cmd)
    }
    else{
        shinyalert(
            "Oops!",
            paste0("Please upload the correct annotatoin file for ", gff_input_name, " then switch this on"),
            type="error"
        )
    }
    return(checked_gff)
}

#' Check and Process GFF Input File from a Specific Path
#'
#' This function checks the type of GFF input file specified by its path and processes it accordingly.
#'
#' @param gff_input_name The informal name of the GFF input file.
#' @param gff_input_path The path to the GFF input file.
#' @param working_wd A character string specifying the working directory to be used.
#'
#' @importFrom stringr str_detect
#' @importFrom stringr regex
#' @importFrom fs file_temp
#' @importFrom shinyalert shinyalert
#'
#' @return A string containing the processed GFF file's path.
#'
check_gff_from_file <- function(gff_input_name, gff_input_path, working_wd){
    checked_gff <- paste0(working_wd, "/", gff_input_name, ".gff")
    if( str_detect(gff_input_path, ".(gff|gff3)$") ){
        link_gff_cmd <- paste0("cat ", gff_input_path, " | grep -v '#' > ", checked_gff)
        system(link_gff_cmd)
    }
    else if( str_detect(gff_input_path, regex(".(gff.gz|gff3.gz|gz)$")) ){
        gzip_gff_cmd <- paste0("gunzip -c ", gff_input_path, " | grep -v '#' > ", checked_gff)
        system(gzip_gff_cmd)
    }
    else{
        shinyalert(
            "Oops!",
            paste0("Please upload the correct annotatoin file for ", gff_input_name, " then switch this on"),
            type="error"
        )
    }
    return(checked_gff)
}


#' Check if a file is in FASTA format with cds sequences.
#'
#' This function checks whether a given file is in FASTA format with cds sequences.
#'
#' @param file_path The path to the input file.
#'
#' @return TRUE if the file is in FASTA format with cds sequences, FALSE otherwise.
#'
is_fasta_cds <- function(file_path) {
    if( endsWith(file_path, ".gz") ){
        con <- gzfile(file_path, "rt")
    } else {
        con <- file(file_path, "rt")
    }

    lines <- readLines(con, n=2, warn=FALSE)
    close(con)

    if( length(lines) < 2 ){
        return(FALSE)
    }

    if( !grepl("^>", lines[1]) ){
        return(FALSE)
    }

    sequence_lines <- lines[-1]
    nucleotide_chars <- c("A", "T", "C", "G", "N", "a", "t", "c", "g", "n")

    if( all(unlist(strsplit(sequence_lines, "")) %in% nucleotide_chars) ){
        return(TRUE)
    }else{
        return(FALSE)
    }
}

#' Extract the first part of a string by splitting it at tab characters.
#'
#' This function takes a string and splits it at tab characters. It then
#' returns the first part of the resulting character vector.
#'
#' @param name The input string to be split.
#'
#' @return Returns the first part of the input string.
#'
extract_first_part <- function(name) {
    parts <- unlist(strsplit(name, "\t"))
    return(parts[1])
}

#' Remove Genes Contain Stop Codons within the Sequence
#'
#' This function removes the gene contains stop codons (TAA, TAG, TGA, taa, tag, tga)
#' within its sequence.
#'
#' @param sequence A nucleotide sequence as a character string.
#'
#' @return A character string or NULL.
#'
remove_inner_stop_codon_sequence <- function(sequence) {
    is_stop_codon <- function(codon) {
        stop_codons <- c("TAA", "TAG", "TGA", "taa", "tag", "tga")
        return(codon %in% stop_codons)
    }

    codons <- strsplit(sequence, "")
    codons <- split(codons, rep(1:(length(codons) / 3), each=3))
    codons <- sapply(codons, paste, collapse="")
    codons <- codons[-length(codons)]

    if( any(is_stop_codon(codons)) ){
        return(NULL)
    }else{
        return(sequence)
    }
}

#' Check and Process Proteome Input File
#'
#' This function checks the type of proteome input file and processes it accordingly.
#'
#' @param proteome_name The informal name of the proteome input file.
#' @param proteome_input The proteome input data.
#' @param working_wd A character string specifying the working directory to be used.
#'
#' @importFrom stringr str_detect
#' @importFrom stringr regex
#' @importFrom shinyalert shinyalert
#' @importFrom seqinr read.fasta
#' @importFrom seqinr getLength
#' @importFrom seqinr write.fasta
#'
#' @return A string containing the processed proteome file's path.
#'
check_proteome_input <- function(proteome_name, proteome_input, working_wd){
    proteome_file <- paste0(working_wd, "/", proteome_name, ext=".fa")
    if( !is_fasta_cds(proteome_input$datapath) ){
        proteome_name <- gsub("[0-9]", "", proteome_name)
        proteome_name <- gsub("_", " ", proteome_name)
        shinyalert(
            "Oops!",
            paste0("Please upload the correct proteome file for ", proteome_name, " then switch this on"),
            type="error"
        )
        return(NULL)
    }

    sequences <- read.fasta(proteome_input$datapath)

    if( any(grepl("\\|", names(sequences))) ){
        proteome_name <- gsub("[0-9]", "", proteome_name)
        proteome_name <- gsub("_", " ", proteome_name)
        shinyalert(
            "Oops!",
            paste0(
                "Please upload the correct proteome file for ",
                proteome_name,
                ". Do not keep \"|\" in the identifier of each sequences.",
                "Then switch this on"
            ),
            type="error"
        )
        return(NULL)
    }

    lengths <- getLength(sequences)
    filtered_sequences <- sequences[lengths %% 3 == 0]

    filtered_sequences_2 <- sapply(filtered_sequences, remove_inner_stop_codon_sequence, simplify=FALSE)
    filtered_sequences_2 <- filtered_sequences_2[sapply(filtered_sequences_2, function(x) !is.null(x))]

    write.fasta(
        sequences=filtered_sequences_2,
        names=sapply(names(filtered_sequences_2), extract_first_part),
        file.out=proteome_file,
        nbchar=100000000
    )

    # Get the Log Info
    log_file <- paste0(working_wd, "/Sequence_processing.log")
    if( file.exists(log_file) ){
        logInfo <- file(log_file, open="a")
    }else{
        logInfo <- file(log_file, open="w")
        cat(paste("Species", "Tot_gene", "genes_not_triple_codon", "genes_within_stop_codons", "refined_gene", collapse="\t"), file=logInfo, sep="\n")
    }
    original_num <- length(sequences)
    filter_num1 <- length(filtered_sequences)
    filter_num2 <- length(filtered_sequences_2)

    if( original_num == filter_num1 && filter_num1 == filter_num2 ){
        cat(paste(proteome_name, original_num, 0, 0, original_num, collapse="\t"), file=logInfo, append=TRUE, sep="\n")
    }else{
        tmp1_num <- original_num - filter_num1
        tmp2_num <- filter_num1 - filter_num2
        cat(paste(proteome_name, original_num, tmp1_num, tmp2_num, filter_num2, collapse="\t"), file=logInfo, append=TRUE, sep="\n")
    }
    close(logInfo)

    return(proteome_file)
}

#' Check and Process Proteome Input File From a Special Path
#'
#' This function checks the type of proteome input file and processes it accordingly.
#'
#' @param proteome_name The informal name of the proteome input file.
#' @param proteome_input The proteome input data.
#' @param working_wd A character string specifying the working directory to be used.
#'
#' @importFrom stringr str_detect
#' @importFrom stringr regex
#' @importFrom shinyalert shinyalert
#' @importFrom seqinr read.fasta
#' @importFrom seqinr getLength
#' @importFrom seqinr write.fasta
#'
#' @return A string containing the processed proteome file's path.
#'
check_proteome_from_file <- function(proteome_name, proteome_input, working_wd){
    tmp_file <- paste0(working_wd, "/", proteome_name, ext=".tmp.fa")
    proteome_file <- paste0(working_wd, "/", proteome_name, ext=".fa")

    if( !is_fasta_cds(proteome_input) ){
        proteome_name <- gsub("[0-9]", "", proteome_name)
        proteome_name <- gsub("_", " ", proteome_name)
        shinyalert(
            "Oops!",
            paste0("Please upload the correct proteome file for ", proteome_name, " then switch this on"),
            type="error"
        )
        return(NULL)
    }

    sequences <- read.fasta(proteome_input)

    if( any(grepl("\\|", names(sequences))) ){
        proteome_name <- gsub("[0-9_]", " ", proteome_name)
        shinyalert(
            "Oops!",
            paste0(
                "Please upload the correct proteome file for ",
                proteome_name,
                ". Do not keep \"|\" in the identifier of each sequences.",
                "Then switch this on"
            ),
            type="error"
        )
        return(NULL)
    }

    lengths <- getLength(sequences)
    filtered_sequences <- sequences[lengths %% 3 == 0]
    filtered_sequences_2 <- sapply(filtered_sequences, remove_inner_stop_codon_sequence, simplify=FALSE)
    filtered_sequences_2 <- filtered_sequences_2[sapply(filtered_sequences_2, function(x) !is.null(x))]
    write.fasta(
        sequences=filtered_sequences_2,
        names=sapply(names(filtered_sequences_2), extract_first_part),
        file.out=proteome_file,
        nbchar=100000000
    )

    # Get the Log Info
    log_file <- paste0(working_wd, "/Sequence_processing.log")
    if( file.exists(log_file) ){
        logInfo <- file(log_file, open="a")
    }else{
        logInfo <- file(log_file, open="w")
        cat(paste("Species", "Tot_gene", "genes_not_triple_codon", "genes_within_stop_codons", "refined_gene", collapse="\t"), file=logInfo, sep="\n")
    }
    original_num <- length(sequences)
    filter_num1 <- length(filtered_sequences)
    filter_num2 <- length(filtered_sequences_2)

    if( original_num == filter_num1 && filter_num1 == filter_num2 ){
        cat(paste(proteome_name, original_num, 0, 0, original_num, collapse="\t"), file=logInfo, append=TRUE, sep="\n")
    }else{
        tmp1_num <- original_num - filter_num1
        tmp2_num <- filter_num1 - filter_num2
        cat(paste(proteome_name, original_num, tmp1_num, tmp2_num, filter_num2, collapse="\t"), file=logInfo, append=TRUE, sep="\n")
    }
    close(logInfo)

    return(proteome_file)
}

#' Check File Existence in a Data Table
#'
#' This function checks the existence of files specified in a data table.
#'
#' @param data_table A data table with file paths in columns V2 and V3.
#' @param working_wd A path of the working directory
#'
#' @return This function has no return value. It prints messages to the console.
#'
checkFileExistence <- function(data_table, working_wd){
    for( i in 1:nrow(data_table) ){
        file1 <- as.character(data_table[i, "V2"])

        if( !file.exists(paste0(working_wd, "/", file1)) ){
            shinyalert(
                "Oops!",
                paste0(
                    "Fail to open ",
                    file1, ".",
                    " Please set the correct proteome file for ",
                    as.character(data_table[i, "V1"]), ". ",
                    "Then continue ..."
                ),
                type="error"
            )
        }

        if( !is.na(data_table[i, "V3"]) ){
            file2 <- as.character(data_table[i, "V3"])
            if( !file.exists(paste0(working_wd, "/", file2)) ){
                shinyalert(
                    "Oops!",
                    paste0(
                        "Fail to open ",
                        file2, ".",
                        " Please set the correct annotation file for ",
                        as.character(data_table[i, "V1"]),". ",
                        "Then continue ..."
                    ),
                    type="error"
                )
            }
        }
    }
}

#' Create Ksrates Configuration File
#'
#' This function generates a configuration file for the Ksrates pipeline based on Shiny input.
#'
#' @param input The Input object of Shiny.
#' @param ksrates_conf_file The path to the Ksrates configuration file.
#' @param species_info_file The path to the species information file.
#'
create_ksrates_configure_file_v2 <- function(input, ksrates_conf_file, species_info_file){
    latin_names_temp <- c()
    fasta_filenames_temp <- c()

    collinearity <- "yes"
    workdirname <- dirname(dirname(ksrates_conf_file))
    newick_tree <- readLines(input$newick_tree$datapath)
    newick_tree <- gsub("_", " ", newick_tree)
    system(paste("cp", input$newick_tree$datapath, paste0(workdirname, "/tree.newick")))

    SpeciesInfoConf <- file(species_info_file, open="w")
    shiny::withProgress(message='Processing fasta files in progress', value=0, {
        for( i in 1:input$number_of_study_species ){
            latin_name <- paste0("latin_name_", i)
            shiny::incProgress(
                amount=0.8/input$number_of_study_species,
                message=paste0(i, "/", input$number_of_study_species, ". Dealing with ", input[[latin_name]], " ...")
            )
            Sys.sleep(.1)

            latin_name_temp <- trimws(input[[latin_name]])
            latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
            informal_name_temp <- paste0(latin_name_list[1], i)

            newick_tree <- gsub(latin_name_temp, informal_name_temp, newick_tree)

            proteome_temp <- check_proteome_input(
                informal_name_temp,
                input[["proteome"]],
                workdirname
            )
            if( is.null(proteome_temp) ){
                close(SpeciesInfoConf)
                return(NULL)
            }
            latin_names_temp <- c(latin_names_temp, paste0(informal_name_temp, ": ", latin_name_temp))
            fasta_filenames_temp <- c(fasta_filenames_temp, paste0(informal_name_temp, ": ../", informal_name_temp, ".fa"))

            gff <- paste0("gff_", i)
            if( input$select_focal_species == latin_name_temp ){
                if( is.null(input[[gff]]) ){
                    collinearity <- "no"
                    shinyalert(
                        "Note!",
                        "No Annotation file for the focal species is detected. Do not run the collinearity analysis for the focal species",
                        type="info"
                    )
                }else{
                    focal_species_gff_filenames_temp <- paste0("../", informal_name_temp, ".gff")
                }
            }
            if( input$select_focal_species == latin_name_temp ){
                focal_species_informal <- informal_name_temp
            }
            if( is.not.null(input[[gff]]) ){
                gff_temp <- check_gff_input(
                    informal_name_temp,
                    input[[gff]],
                    workdirname
                )
                cat(paste0(latin_name_temp, "\t", proteome_temp, "\t", gff_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
            }
            else{
                cat(paste0(latin_name_temp, "\t", proteome_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
            }
        }
        shiny::incProgress(amount=1)
        Sys.sleep(.1)
    })

    close(SpeciesInfoConf)

    ksratesconf <- file(ksrates_conf_file, open="w")
    cat(paste0("[SPECIES]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("focal_species=", focal_species_informal), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("newick_tree=", newick_tree), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("latin_names=", paste(latin_names_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("fasta_filenames=", paste(fasta_filenames_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    if( collinearity == "yes" ){
        cat(paste0("gff_filename=", focal_species_gff_filenames_temp), file=ksratesconf, append=TRUE, sep="\n")
    }
    cat(paste0("peak_database_path=ortholog_peak_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("ks_list_database_path=ortholog_ks_list_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[ANALYSIS SETTING]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("paranome=yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("collinearity=", collinearity), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_feature=mrna"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_attribute=id"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_number_outgroups=4"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("consensus_mode_for_multiple_outgroups=mean among outgroups"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[PARAMETERS]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_paralogs_plot=5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_paralogs=0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("y_axis_max_limit_paralogs_plot=None"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("num_bootstrap_iterations=200"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("divergence_colors= Red, MediumBlue, Goldenrod, Crimson, ForestGreen, Gray, SaddleBrown, Black"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_orthologs_plots=5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_orthologs=0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_ks_paralogs=5"), append=TRUE, file=ksratesconf, sep="\n")
    cat(paste0("max_ks_orthologs=10"), append=TRUE, file=ksratesconf)
    close(ksratesconf)
}

#' Create Ksrates Configuration File Based on Data Table
#'
#' This function generates a Ksrates configuration file based on a data table and other parameters.
#'
#' @param data_table The data table containing information about species, proteomes, and GFF files.
#' @param focal_species The name of the focal species.
#' @param newick_tree_file The path to the Newick tree file.
#' @param ksrates_conf_file The path to the Ksrates configuration file to be generated.
#' @param species_info_file The path to the species information file.
#' @param working_wd A character string specifying the working directory to be used.
#'
create_ksrates_configure_file_based_on_table <- function(
        data_table,
        focal_species,
        newick_tree_file,
        ksrates_conf_file,
        species_info_file,
        working_wd
    ){
    if( ncol(data_table) < 2 ){
        shinyalert(
            "Oops!",
            "You trigger Ksrates pipeline. Please upload the Annotation file for at lease species",
            type="error"
        )
    }

    workdirname <- dirname(dirname(ksrates_conf_file))
    system(paste("cp", newick_tree_file$datapath, paste0(workdirname, "/tree.newick")))

    newick_tree <- readLines(newick_tree_file$datapath)
    newick_tree <- gsub("_", " ", newick_tree)
    latin_names_temp <- c()
    fasta_filenames_temp <- c()
    gff_species <- c()

    collinearity <- "yes"

    SpeciesInfoConf <- file(species_info_file, open="w")

    shiny::withProgress(message='Processing fasta files in progress', value=0, {
        for( i in 1:nrow(data_table) ){
            latin_name <- data_table[i, 1]
            latin_name <- gsub("_", " ", latin_name)

            shiny::incProgress(
                amount=0.8/nrow(data_table),
                message=paste0(i, "/", nrow(data_table), ". Dealing with ", data_table[i, 1], " ...")
            )
            Sys.sleep(.1)

            proteome <- paste0(working_wd, "/original_data/", data_table[i, 2])
            latin_name_temp <- trimws(latin_name)
            latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
            informal_name_temp <- paste0(latin_name_list[1], i)
            if( focal_species == latin_name ){
                focal_species_informal=informal_name_temp
            }

            newick_tree <- gsub(latin_name, informal_name_temp, newick_tree)
            proteome_temp <- check_proteome_from_file(
                informal_name_temp,
                proteome,
                workdirname
            )
            if( is.null(proteome_temp) ){
                close(SpeciesInfoConf)
                return(NULL)
            }
            latin_names_temp <- c(latin_names_temp, paste0(informal_name_temp, ": ", latin_name_temp))
            fasta_filenames_temp <- c(fasta_filenames_temp, paste0(informal_name_temp, ": ../", informal_name_temp, ".fa"))
            if( !is.na(data_table[i, 3]) ){
                gff_temp <- check_gff_from_file(
                    informal_name_temp,
                    paste0(working_wd, "/original_data/", data_table[i, 3]),
                    workdirname
                )
                gff_species <- c(gff_species, informal_name_temp)
                cat(paste0(latin_name_temp, "\t", proteome_temp, "\t", gff_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
            }else{
                cat(paste0(latin_name_temp, "\t", proteome_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
            }
        }
        shiny::incProgress(amount=1)
        Sys.sleep(.1)
    })

    if( !focal_species_informal %in% gff_species ){
        collinearity <- "no"
        shinyalert(
            "Note!",
            "No Annotation file for the focal species is detected. Do not run the collinearity analysis for the focal species",
            type="info"
        )
    }else{
        focal_species_gff_filenames_temp <- paste0("../", focal_species_informal, ".gff")
    }
    close(SpeciesInfoConf)
    ksratesconf <- file(ksrates_conf_file, open="w")
    cat(paste0("[SPECIES]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("focal_species=", focal_species_informal), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("newick_tree=", newick_tree), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("latin_names=", paste(latin_names_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("fasta_filenames=", paste(fasta_filenames_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    if( collinearity == "yes" ){
        cat(paste0("gff_filename=", focal_species_gff_filenames_temp), file=ksratesconf, append=TRUE, sep="\n")
    }
    cat(paste0("peak_database_path=ortholog_peak_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("ks_list_database_path=ortholog_ks_list_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[ANALYSIS SETTING]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("paranome=yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("collinearity=", collinearity), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_feature=mrna"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_attribute=id"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_number_outgroups=4"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("consensus_mode_for_multiple_outgroups=mean among outgroups"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[PARAMETERS]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_paralogs_plot=5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_paralogs=0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("y_axis_max_limit_paralogs_plot=None"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("num_bootstrap_iterations=200"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("divergence_colors= Red, MediumBlue, Goldenrod, Crimson, ForestGreen, Gray, SaddleBrown, Black"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_orthologs_plots=5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_orthologs=0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_ks_paralogs=5"), append=TRUE, file=ksratesconf, sep="\n")
    cat(paste0("max_ks_orthologs=10"), append=TRUE, file=ksratesconf)
    close(ksratesconf)
}

#' Create ksrates Expert Parameter File
#'
#' @param ksrates_expert_parameter_file The file is used to store the ksrates expert parameter
#'
create_ksrates_expert_parameter_file <- function(ksrates_expert_parameter_file){
    expert_parameter <- file(ksrates_expert_parameter_file, open="w")
    cat(paste0("logging_level=info"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_gene_family_size=200"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("distribution_peak_estimate=mode"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("kde_bandwidth_modifier=0.4"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("plot_adjustment_arrows=no"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("num_mixture_model_initializations=10"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_iterations=300"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_components=5"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_ks=5"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("extra_paralogs_analyses_methods=no"), append=TRUE, file=expert_parameter, sep="\n")
    close(expert_parameter)
}

#' Create Ksrates Command Files from Data Table
#'
#' This function generates command files for running Ksrates and related analyses based on a data table and configuration file.
#'
#' @param data_table The data table containing information about species.
#' @param ksratesconf The path to the Ksrates configuration file.
#' @param cmd_file The path to the main Ksrates command file to be generated.
#' @param focal_species The name of the focal species.
#'
create_ksrates_cmd_from_table <- function(data_table, ksratesconf, cmd_file, focal_species){
    cmd <- file(cmd_file, open="w")
    # wgd_cmd <- file(wgd_cmd_file, open="w")
    # cat("module load wgd blast mcl paml fasttree mafft i-adhore diamond; export OMP_NUM_THREADS=1", file=wgd_cmd, append=TRUE, sep="\n")
    # Add Sbatch commond line
    cat("#!/bin/bash", file=cmd, append=TRUE, sep="\n")
    cat("", file=cmd, append=TRUE, sep="\n")
    cat("#SBATCH -p all", file=cmd, append=TRUE, sep="\n")
    cat("#SBATCH -c 1", file=cmd, append=TRUE, sep="\n")
    cat("#SBATCH --mem 4G", file=cmd, append=TRUE, sep="\n")
    cat(paste0("#SBATCH -o ", basename(cmd_file), ".o%j"), file=cmd, append=TRUE, sep="\n")
    cat(paste0("#SBATCH -e ", basename(cmd_file), ".e%j"), file=cmd, append=TRUE, sep="\n")
    cat("", file=cmd, append=TRUE, sep="\n")

    cat("module load ksrates/x86_64/1.1.3", file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates init ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-ks ", ksratesconf, " --n-threads 1"), file=cmd, append=TRUE, sep="\n")
    for( i in 1:nrow(data_table) ){
        latin_name <- data_table[i, 1]
        latin_name <- gsub("_", " ", latin_name)
        latin_name_temp <- trimws(latin_name)
        latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
        informal_name_i <- paste0(latin_name_list[1], i)
        for( j in 1:nrow(data_table) ){
            latin_name <- data_table[j, 1]
            latin_name <- gsub("_", " ", latin_name)
            latin_name_temp <- trimws(latin_name)
            latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
            informal_name_j <- paste0(latin_name_list[1], j)
            if( j > i ){
                cat(
                    paste0(
                        "ksrates orthologs-ks ",
                        ksratesconf, " ",
                        informal_name_i, " ",
                        informal_name_j, " ",
                        "--n-threads 1; ",
                        "gzip ",
                        "ortholog_distributions/wgd_",
                        informal_name_i, "_", informal_name_j, "/",
                        informal_name_i, "_", informal_name_j, ".blast.tsv"
                    ),
                    file=cmd, append=TRUE, sep="\n"
                )
            }
        }
    }
    cat(paste0("ksrates orthologs-analysis ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-orthologs ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates orthologs-adjustment ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-paralogs ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-tree ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-analyses ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    close(cmd)
}

#' Create Ksrates Command Files from Shiny Input
#'
#' @param input The Input object of Shiny.
#' @param ksratesconf The path to the Ksrates configuration file.
#' @param cmd_file The path to the main Ksrates command file to be generated.
#'
create_ksrates_cmd <- function(input, ksratesconf, cmd_file){
    cmd <- file(cmd_file, open="w")
    # Add Sbatch commond line
    cat("#!/bin/bash", file=cmd, append=TRUE, sep="\n\n")
    cat("#SBATCH -p all", file=cmd, append=TRUE, sep="\n")
    cat("#SBATCH -c 1", file=cmd, append=TRUE, sep="\n")
    cat("#SBATCH --mem 4G", file=cmd, append=TRUE, sep="\n")
    cat(paste0("#SBATCH -o ", basename(cmd_file), ".o%j"), file=cmd, append=TRUE, sep="\n")
    cat(paste0("#SBATCH -e ", basename(cmd_file), ".e%j"), file=cmd, append=TRUE, sep="\n\n")
    cat("", file=cmd, append=TRUE, sep="\n")

    cat("module load ksrates/x86_64/1.1.3", file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates init ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-ks ", ksratesconf, " --n-threads 1"), file=cmd, append=TRUE, sep="\n")
    informal_name_list <- paste0("seq_", 1:input$number_of_study_species)
    for( i in 1:length(informal_name_list) ){
        latin_name <- paste0("latin_name_", i)
        latin_name_temp <- trimws(input[[latin_name]])
        latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
        informal_name_i <- paste0(latin_name_list[1], i)
        for( j in 1:length(informal_name_list) ){
            latin_name <- paste0("latin_name_", j)
            latin_name_temp <- trimws(input[[latin_name]])
            latin_name_list <- strsplit(latin_name_temp, split=' ')
            informal_name_j <- paste0(latin_name_list[[1]], j)
            if( j > i ){
                cat(
                    paste0(
                        "ksrates orthologs-ks ",
                        ksratesconf, " ",
                        informal_name_i, " ",
                        informal_name_j, " ",
                        "--n-threads 1; ",
                        "gzip ",
                        "ortholog_distributions/wgd_",
                        informal_name_i, "_", informal_name_j, "/",
                        informal_name_i, "_", informal_name_j, ".blast.tsv"
                    ),
                    file=cmd, append=TRUE, sep="\n"
                )
            }
        }
    }
    cat(paste0("ksrates orthologs-analysis ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-orthologs ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates orthologs-adjustment ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-paralogs ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates plot-tree ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-analyses ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    close(cmd)
}

#' Map Informal Names to Latin Names
#'
#' This function reads information from an Excel file (XLS) containing columns "latin_name," "informal_name," and "gff." It extracts the "latin_name" and "informal_name" columns, performs some data manipulation, and returns a data frame with these two columns.
#'
#' @param sp_gff_info_xls The path to the Excel file containing species information.
#'
#' @return A data frame with "latin_name" and "informal_name" columns.
#'
map_informal_name_to_latin_name <- function(sp_gff_info_xls){
    df <- read.table(
        sp_gff_info_xls,
        sep="\t",
        header=FALSE,
        fill=TRUE,
        na.strings="",
        col.names=c("latin_name", "informal_name", "gff")
    )

    informal_files <- gsub(".*/", "", df$informal_name)
    informal_files <- gsub(".fa", "", informal_files)
    gff_files <- gsub(".*/", "", df$gff)
    df$informal_name <- informal_files
    df$gff <- gff_files
    return(df[, 1:2])
}

#' Replace Informal Names with Latin Names
#'
#' This function takes a data frame `names_df` containing "latin_name" and "informal_name" columns and an `input` string as input. It replaces informal species names in the `input` string with their corresponding Latin names based on the information in `names_df`. If the `input` string contains underscores ("_"), it assumes a comparison between two species and replaces both informal names. Otherwise, it replaces the informal name in the `input` string.
#'
#' @param names_df A data frame with "latin_name" and "informal_name" columns.
#' @param input The input string that may contain informal species names.
#'
#' @return A modified input string with informal names replaced by Latin names.
#'
replace_informal_name_to_latin_name <- function(names_df, input){
    if( grepl("_", input) ){
        species_list <- strsplit(input, "_")
        latin_name1 <- species_list[[1]][1]
        for( i in 1:nrow(names_df) ){
            latin_name1 <- gsub(names_df$informal_name[i],
                                names_df$latin_name[i],
                                latin_name1)
        }
        latin_name2 <- species_list[[1]][2]
        for( i in 1:nrow(names_df) ){
            latin_name2 <- gsub(names_df$informal_name[i],
                                names_df$latin_name[i],
                                latin_name2)
        }
        return(paste(latin_name1, "vs", latin_name2))
    }
    else{
        for( i in 1:nrow(names_df) ){
            input <- gsub(names_df$informal_name[i],
                               names_df$latin_name[i],
                               input)
        }
        return(input)
    }
}
