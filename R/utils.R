is.not.null <- function(x) ! is.null(x)

#' Creating a custom download button
#'
#' Use these functions to create a custom download button or link;
#' when clicked, it will initiate a browser download.
#' The filename and contents are specified by the corresponding downloadHandler() defined in the server function.
#'
#' @param outputId The name of the output slot that the downloadHandler is assigned to.
#' @param label The label that should appear on the button.
#' @param class Additional CSS classes to apply to the tag, if any. Default NULL.
#' @param status The status of the button, default primary
#' @param ... Other arguments to pass to the container tag function.
#' @param icon An icon() to appear on the button. Default is icon("download").
#'
#' @return A HTML tag to allow users to download the object.
#' @export
#'
#' @examples downloadButton(
#'     outputId="wgd_ksrates_data_download",
#'     label="Download Analysis Data",
#'     width="215px",
#'     icon=icon("download"),
#'     status="secondary",
#'     style="background-color: #5151A2;
#'            padding: 5px 10px 5px 10px;
#'            margin: 5px 5px 5px 5px;
#'            animation: glowingD 5000ms infinite; "
#' )
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

#' Read a upload table file
#'
#' @param uploadfile The object of the file through uploading function of Shiny.
#'
#' @return A data frame includes the data from the file.
#' @export
#'
#' @examples read_data_file(input$upload_data_file)[["V1"]]
read_data_file <- function(uploadfile){
    dataframe <- read.table(
        uploadfile$datapath,
        sep="\t",
        header=FALSE,
        fill=T,
        na.strings=""
    )
    return(dataframe)
}

#' Check the uploading annotation file
#'
#' @param gff_input_name The prefix of the annotation file
#' @param gff_input_path The annotation file created by Shiny uploading function
#'
#' @return A gff file path includes standardized annotation info.
#' @export
#'
#' @examples check_gff_input(informal_name, input[[paste0("gff_", 1)]])
check_gff_input <- function(gff_input_name, gff_input_path){
    checked_gff <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", gff_input_name, ".gff")
    if( str_detect(gff_input_path$name, ".(gff|gff3)$") ){
        link_gff_cmd <- paste0("ln -sf ", gff_input_path$datapath, " ", checked_gff)
        system(link_gff_cmd)
    }
    else if( str_detect(gff_input_path$name, regex(".(gff.gz|gff3.gz|gz)$")) ){
        gzip_gff_cmd <- paste0("gunzip -c ", gff_input_path$datapath, " > ", checked_gff)
        system(gzip_gff_cmd)
    }
    else if( str_detect(gff_input_path$name, ".gtf$") ){
        convertGTF_cmd <- paste0("gffread --keep-genes ", gff_input_path$datapath, " > ", checked_gff)
        system(convertGTF_cmd)
    }
    else if( str_detect(gff_input_path$name, regex(".gtf.gz$")) ){
        gunzipped_gtf <- file_temp(ext = ".gtf")
        gunzip_gtf_cmd <- paste0("gunzip -c ", gff_input_path$datapath, " > ", gunzipped_gtf)
        system(gunzip_gtf_cmd)
        convertGTF_cmd <- paste0("gffread --keep-genes ", gunzipped_gtf, " > ", checked_gff)
        system(convertGTF_cmd)
        system(paste0("rm ", gunzipped_gtf))
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

#' Check the annotation file from a file location
#'
#' @param gff_input_name The prefix of the annotation file
#' @param gff_input_path The path of the annotation file
#'
#' @return A gff file path includes standardized annotation info.
#' @export
#'
#' @examples gff_temp <- check_gff_from_file(informal_name_temp, data_table[i, 3])
check_gff_from_file <- function(gff_input_name, gff_input_path){
    checked_gff <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", gff_input_name, ".gff")
    if( str_detect(gff_input_path, ".(gff|gff3)$") ){
        link_gff_cmd <- paste0("ln -sf ", gff_input_path, " ", checked_gff)
        system(link_gff_cmd)
    }
    else if( str_detect(gff_input_path, regex(".(gff.gz|gff3.gz|gz)$")) ){
        gzip_gff_cmd <- paste0("gunzip -c ", gff_input_path, " > ", checked_gff)
        system(gzip_gff_cmd)
    }
    else if( str_detect(gff_input_path, ".gtf$") ){
        convertGTF_cmd <- paste0("gffread --keep-genes ", gff_input_path, " > ", checked_gff)
        system(convertGTF_cmd)
    }
    else if( str_detect(gff_input_path, regex(".gtf.gz$")) ){
        gunzipped_gtf <- file_temp(ext = ".gtf")
        gunzip_gtf_cmd <- paste0("gunzip -c ", gff_input_path, " > ", gunzipped_gtf)
        system(gunzip_gtf_cmd)
        convertGTF_cmd <- paste0("gffread --keep-genes ", gunzipped_gtf, " > ", checked_gff)
        system(convertGTF_cmd)
        system(paste0("rm ", gunzipped_gtf))
    }
    else{
        shinyalert(
            paste0("Oops!", "Please upload the correct annotatoin file for ", gff_input_name, " then switch this on"),
            type="error"
        )
    }
    return(checked_gff)
}

#' Check the uploading proteome file
#'
#' @param proteome_name The prefix of the proteome file
#' @param proteome_input The proteome file created by Shiny uploading function
#'
#' @return A proteome fasta file path includes standardized protein info.
#' @export
#'
#' @examples proteome_temp <- check_proteome_input(informal_name_temp, input[[proteome]])
check_proteome_input <- function(proteome_name, proteome_input){
    tmp_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", proteome_name, ext=".tmp.fa")
    proteome_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", proteome_name, ext=".fa")
    if( str_detect(proteome_input$name, regex(".gz$")) ){
        system(paste0("gunzip -c ", proteome_input$datapath, " > ", tmp_file))
        library(Biostrings)
        fasta <- readDNAStringSet(tmp_file)
        sequences <- as.character(fasta)
        filtered_sequences <- sequences[nchar(sequences) %% 3==0]
        headers <- paste0(">", names(filtered_sequences))
        fasta_modified <- paste(headers, filtered_sequences, sep="\n")
        writeLines(fasta_modified, con=proteome_file)
        if( file.exists(tmp_file) ){
            system(paste("rm", tmp_file))
        }
    }
    else if( str_detect(proteome_input$name, regex(".(fa|fasta|fna|fas)$")) ){
        library(Biostrings)
        fasta <- readDNAStringSet(proteome_input$datapath)
        sequences <- as.character(fasta)
        filtered_sequences <- sequences[nchar(sequences) %% 3==0]
        headers <- paste0(">", names(filtered_sequences))
        fasta_modified <- paste(headers, filtered_sequences, sep="\n")
        writeLines(fasta_modified, con=proteome_file)
    }
    else{
        shinyalert(
            paste0("Oops!", "Please upload the correct proteome file for ", proteome_name, " then switch this on"),
            type="error"
        )
    }
    return(proteome_file)
}

#' Check the proteom file from the file location
#'
#' @param proteome_name The prefix of the proteome file
#' @param proteome_input The path of the proteome file
#'
#' @return A proteome fasta file path includes standardized protein info.
#' @export
#'
#' @examples proteome_temp <- check_proteome_from_file(informal_name_temp, proteome)
check_proteome_from_file <- function(proteome_name, proteome_input){
    tmp_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", proteome_name, ext=".tmp.fa")
    proteome_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/", proteome_name, ext=".fa")
    if( str_detect(proteome_input, regex(".gz$")) ){
        #print(proteome_input)
        system(paste0("gunzip -c ", proteome_input, " > ", tmp_file))
        suppressMessages(library(Biostrings))
        fasta <- readDNAStringSet(tmp_file)
        sequences <- as.character(fasta)
        filtered_sequences <- sequences[nchar(sequences) %% 3==0]
        headers <- paste0(">", names(filtered_sequences))
        fasta_modified <- paste(headers, filtered_sequences, sep="\n")
        writeLines(fasta_modified, con=proteome_file)
        if( file.exists(tmp_file) ){
            system(paste("rm", tmp_file))
        }
    }
    else if( str_detect(proteome_input, regex(".(fa|fasta|fna|fas)$")) ){
        suppressMessages(library(Biostrings))
        fasta <- readDNAStringSet(proteome_input)
        sequences <- as.character(fasta)
        filtered_sequences <- sequences[nchar(sequences) %% 3==0]
        headers <- paste0(">", names(filtered_sequences))
        fasta_modified <- paste(headers, filtered_sequences, sep="\n")
        writeLines(fasta_modified, con=proteome_file)
    }
    else{
        shinyalert(
            paste0("Oops!", "Please upload the correct proteome file for ", proteome_name, " then switch this on"),
            type="error"
        )
    }
    return(proteome_file)
}

#' Creating ksrates configure file
#'
#' @param input The Input object of Shiny.
#' @param ksrates_conf_file The file is used to store the configure of ksrates.
#' @param species_info_file The file is used to store the updated info.
#'
#' @export
#'
#' @examples create_ksrates_configure_file_v2(input, ksratesconf, speciesinfoconf)
create_ksrates_configure_file_v2 <- function(input, ksrates_conf_file, species_info_file){
    latin_names_temp <- c()
    fasta_filenames_temp <- c()
    # gff_filenames_temp <- c()

    workdirname <- dirname(dirname(ksrates_conf_file))
    newick_tree <- readLines(input$newick_tree$datapath)
    system(paste("cp", input$newick_tree$datapath, paste0(workdirname, "/tree.newick")))

    SpeciesInfoConf <- file(species_info_file, open="w")
    for( i in 1:input$number_of_study_species ){
        latin_name <- paste0("latin_name_", i)
        proteome <- paste0("proteome_", i)
        latin_name_temp <- trimws(input[[latin_name]])
        latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
        informal_name_temp <- paste0(latin_name_list[1], i)

        newick_tree <- gsub(latin_name_temp, informal_name_temp, newick_tree)

        proteome_temp <- check_proteome_input(
            informal_name_temp,
            input[[proteome]]
        )
        latin_names_temp <- c(latin_names_temp, paste0(informal_name_temp, ": ", latin_name_temp))
        fasta_filenames_temp <- c(fasta_filenames_temp, paste0(informal_name_temp, ": ", informal_name_temp, ".fa"))

        gff <- paste0("gff_", i)
        if( input$select_focal_species == latin_name_temp ){
            if( is.null(input[[gff]]) ){
                shinyalert(
                    "Oops!",
                    "You trigger Ksrates pipeline. Please upload the Annotation file for at lease the focal species",
                    type="error"
                )
            }else{
                focal_species_gff_filenames_temp <- paste0(informal_name_temp, ".gff")
            }
        }
        if( input$select_focal_species == latin_name_temp ){
            focal_species_informal <- informal_name_temp
        }
        if( is.not.null(input[[gff]]) ){
            gff_temp <- check_gff_input(
                informal_name_temp,
                input[[gff]]
            )
            cat(paste0(latin_name_temp, "\t", proteome_temp, "\t", gff_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
        }
        else{
            cat(paste0(latin_name_temp, "\t", proteome_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
        }
    }
    close(SpeciesInfoConf)

    ksratesconf <- file(ksrates_conf_file, open="w")
    cat(paste0("[SPECIES]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("focal_species = ", focal_species_informal), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("newick_tree = ", newick_tree), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("latin_names = ", paste(latin_names_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("fasta_filenames = ", paste(fasta_filenames_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_filename = ", focal_species_gff_filenames_temp), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("peak_database_path = ortholog_peak_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("ks_list_database_path = ortholog_ks_list_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[ANALYSIS SETTING]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("paranome = yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("collinearity = yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_feature = mrna"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_attribute = id"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_number_outgroups = 4"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("consensus_mode_for_multiple_outgroups = mean among outgroups"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[PARAMETERS]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_paralogs_plot = 5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_paralogs = 0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("y_axis_max_limit_paralogs_plot = None"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("num_bootstrap_iterations = 200"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("divergence_colors =  Red, MediumBlue, Goldenrod, Crimson, ForestGreen, Gray, SaddleBrown, Black"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_orthologs_plots = 5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_orthologs = 0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_ks_paralogs = 5"), append=TRUE, file=ksratesconf, sep="\n")
    cat(paste0("max_ks_orthologs = 10"), append=TRUE, file=ksratesconf)
    close(ksratesconf)
}

#' Create ksrates configure file based on the data table
#'
#' @param data_table A data frame includes three columns: species name, proteome file, annotation file.
#' @param focal_species The name of the focal species used in ksrates
#' @param newick_tree_file The path of newick tree file
#' @param ksrates_conf_file The file is used to store the configure of ksrates.
#' @param species_info_file The file is used to store the updated info.
#'
#' @export
#'
#' @examples create_ksrates_configure_file_based_on_table(
#'  data_table,
#'  input$select_focal_species,
#'  input$newick_tree,
#'  ksratesconf,
#'  speciesinfoconf
#' )
create_ksrates_configure_file_based_on_table <- function(data_table, focal_species, newick_tree_file, ksrates_conf_file, species_info_file){
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
    latin_names_temp <- c()
    fasta_filenames_temp <- c()
    #gff_filenames_temp <- c()
    gff_species <- c()

    SpeciesInfoConf <- file(species_info_file, open="w")
    for( i in 1:nrow(data_table) ){
        latin_name <- data_table[i, 1]
        proteome <- data_table[i, 2]
        latin_name_temp <- trimws(latin_name)
        latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
        informal_name_temp <- paste0(latin_name_list[1], i)
        if( focal_species == latin_name ){
            focal_species_informal = informal_name_temp
        }
        newick_tree <- gsub(latin_name, informal_name_temp, newick_tree)
        proteome_temp <- check_proteome_from_file(
            informal_name_temp,
            proteome
        )
        latin_names_temp <- c(latin_names_temp, paste0(informal_name_temp, ": ", latin_name_temp))
        fasta_filenames_temp <- c(fasta_filenames_temp, paste0(informal_name_temp, ": ../", informal_name_temp, ".fa"))
        if( !is.na(data_table[i, 3]) ){
            gff_temp <- check_gff_from_file(
                informal_name_temp,
                data_table[i, 3]
            )
            # gff_filenames_temp <- c(gff_filenames_temp, paste0(informal_name_temp, ": ", informal_name_temp, ".gff"))
            gff_species <- c(gff_species, informal_name_temp)
            cat(paste0(latin_name_temp, "\t", proteome_temp, "\t", gff_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
        }else{
            cat(paste0(latin_name_temp, "\t", proteome_temp), file=SpeciesInfoConf, append=TRUE, sep="\n")
        }
    }
    if( !focal_species_informal %in% gff_species ){
        shinyalert(
            "Oops",
            paste0("Please set the annotation gff file for the focal species: ", focal_species),
            type="error",
        )
    }else{
        focal_species_gff_filenames_temp <- paste0("../", focal_species_informal, ".gff")
    }
    close(SpeciesInfoConf)
    ksratesconf <- file(ksrates_conf_file, open="w")
    cat(paste0("[SPECIES]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("focal_species = ", focal_species_informal), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("newick_tree = ", newick_tree), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("latin_names = ", paste(latin_names_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("fasta_filenames = ", paste(fasta_filenames_temp, collapse=", ")), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_filename = ", focal_species_gff_filenames_temp), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("peak_database_path = ortholog_peak_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("ks_list_database_path = ortholog_ks_list_db.tsv"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[ANALYSIS SETTING]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("paranome = yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("collinearity = yes"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_feature = mrna"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("gff_attribute = id"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_number_outgroups = 4"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("consensus_mode_for_multiple_outgroups = mean among outgroups"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("[PARAMETERS]"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_paralogs_plot = 5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_paralogs = 0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("y_axis_max_limit_paralogs_plot = None"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("num_bootstrap_iterations = 200"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("divergence_colors =  Red, MediumBlue, Goldenrod, Crimson, ForestGreen, Gray, SaddleBrown, Black"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("x_axis_max_limit_orthologs_plots = 5"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("bin_width_orthologs = 0.1"), file=ksratesconf, append=TRUE, sep="\n")
    cat(paste0("max_ks_paralogs = 5"), append=TRUE, file=ksratesconf, sep="\n")
    cat(paste0("max_ks_orthologs = 10"), append=TRUE, file=ksratesconf)
    close(ksratesconf)
}

#' Create ksrates expert parameter file
#'
#' @param ksrates_expert_parameter_file The file is used to store the ksrates expert parameter
#'
#' @export
#'
#' @examples ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
#' create_ksrates_expert_parameter_file(ksratesexpert)
create_ksrates_expert_parameter_file <- function(ksrates_expert_parameter_file){
    expert_parameter <- file(ksrates_expert_parameter_file, open="w")
    cat(paste0("logging_level = info"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_gene_family_size = 200"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("distribution_peak_estimate = mode"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("kde_bandwidth_modifier = 0.4"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("plot_adjustment_arrows = no"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("num_mixture_model_initializations = 10"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_iterations = 300"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_components = 5"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("max_mixture_model_ks = 5"), append=TRUE, file=expert_parameter, sep="\n")
    cat(paste0("extra_paralogs_analyses_methods = no"), append=TRUE, file=expert_parameter, sep="\n")
    close(expert_parameter)
}

#' Create ksrates command Shell file
#'
#' @param data_table A data frame includes three columns: species name, proteome file, annotation file.
#' @param ksratesconf The file of ksrates configure infomation.
#' @param cmd_file The shell file is used to save the commmand line of ksrates.
#' @param wgd_cmd_file The shell file is used to save the command line of wgd.
#' @param focal_species  The name of the focal species used in ksrates.
#'
#' @export
#'
#' @examples  create_ksrates_cmd_from_table(data_table, "ksrates_conf.txt", ksrates_cmd_sh_file, wgd_cmd_sh_file, input$select_focal_species)
create_ksrates_cmd_from_table <- function(data_table, ksratesconf, cmd_file, wgd_cmd_file, focal_species){
    cmd <- file(cmd_file, open="w")
    wgd_cmd <- file(wgd_cmd_file, open="w")
    cat("module load wgd blast mcl paml fasttree mafft i-adhore diamond; export OMP_NUM_THREADS=1", file=wgd_cmd, append=TRUE, sep="\n")
    cat("module load ksrate", file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates init ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-ks ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    for( i in 1:nrow(data_table) ){
        latin_name <- data_table[i, 1]
        latin_name_temp <- trimws(latin_name)
        latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
        informal_name_i <- paste0(latin_name_list[1], i)
        if( latin_name_temp != focal_species ){
            cat(paste0("# Dealing with ", latin_name_temp), file=wgd_cmd, append=TRUE, seq="\n")
            cat(paste0("mkdir paralog_distributions/wgd_", informal_name_i), file=wgd_cmd, append=TRUE, seq="\n")
            cat(paste0("wgd dmd -I 3 ../", informal_name_i, ".fa -o paralog_distributions/wgd_", informal_name_i, "/01.wgd_dmd"), file=wgd_cmd, append=TRUE, sep="\n")
            cat(paste0("wgd ksd paralog_distributions/wgd_", informal_name_i, "/01.wgd_dmd/", informal_name_i, ".fa.mcl ../", informal_name_i, ".fa -o paralog_distributions/wgd_", informal_name_i, "/02.wgd_ksd"), file=wgd_cmd, append=TRUE, sep="\n")
            if( !is.na(data_table[i, 3]) ){
                cat(
                    paste0(
                        "wgd syn -f mRNA -a ID -ks paralog_distributions/wgd_",
                        informal_name_i, "/02.wgd_ksd/", informal_name_i, ".fa.ks.tsv ../",
                        informal_name_i, ".gff paralog_distributions/wgd_",
                        informal_name_i, "/01.wgd_dmd", informal_name_i, ".fa.mcl -o paralog_distributions/wgd_",
                        informal_name_i, "/03.wgd_syn"),
                    file=wgd_cmd, append=TRUE, sep="\n"
                )
                cat("", file=wgd_cmd, append=TRUE, sep="\n")
            }
        }
        for( j in 1:nrow(data_table) ){
            latin_name <- data_table[j, 1]
            latin_name_temp <- trimws(latin_name)
            latin_name_list <- strsplit(latin_name_temp, split=' ')[[1]]
            informal_name_j <- paste0(latin_name_list[1], j)
            if( j > i ){
                cat(paste("ksrates orthologs-ks",
                           ksratesconf,
                           informal_name_i,
                           informal_name_j
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
    close(wgd_cmd)
}

#' Create ksrates command Shell file
#'
#' @param input The Input object of Shiny.
#' @param ksratesconf The file of ksrates configure infomation.
#' @param cmd_file The shell file is used to save the commmand line of ksrates.
#'
#' @export
#'
#' @examples create_ksrates_cmd(input, "ksrates_conf.txt", ksrates_cmd_sh_file)
create_ksrates_cmd <- function(input, ksratesconf, cmd_file){
    cmd <- file(cmd_file, open="w")
    cat(paste0("ksrates init ", ksratesconf), file=cmd, append=TRUE, sep="\n")
    cat(paste0("ksrates paralogs-ks ", ksratesconf), file=cmd, append=TRUE, sep="\n")
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
                        ksratesconf,
                        " ",
                        informal_name_i,
                        " ",
                        informal_name_j
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

#' Remapping the temporary informal name to the Latin name
#'
#' @param sp_gff_info_xls A file includes the Latin name, informal name, and gff file
#'
#' @return A data frame includes the corresponding pair of Latin and informal name
#' @export
#'
#' @examples names_df <- map_informal_name_to_latin_name(species_info_file[1])
map_informal_name_to_latin_name <- function(sp_gff_info_xls){
    df <- read.table(
        sp_gff_info_xls,
        sep="\t",
        header=FALSE,
        fill=T,
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

#' Replace the infomal name to Latin name
#'
#' @param names_df The data frame includes the corresponding pair of Latin and informal name
#' @param input The informal name
#'
#' @return A string includes the Latin name
#' @export
#'
#' @examples replace_informal_name_to_latin_name(names_df, x)
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

