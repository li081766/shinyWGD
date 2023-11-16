output$UploadDisplay <- renderUI({
    sp_range <- 1:input$number_of_study_species
    ui_parts <- c()
    scientific_names <- readLines("www/content/scientific_names.xls")
    scientific_names_selected <- rep(scientific_names, length.out=input$number_of_study_species)
    for( i in sp_range ){
        ui_parts[[i]] <- fluidRow(
            tags$style(
                HTML(
                    "input::placeholder {
                      font-style: italic;
                    }"
                )
            ),
            column(
                4,
                textInput(
                    paste0("latin_name_", i),
                    paste("Species ", i, " Latin Name:"),
                    value="",
                    width="100%",
                    placeholder=scientific_names_selected[[i]]
                )
            ),
            column(
                4,
                fileInput(
                    paste0("proteome_", i),
                    HTML("Upload CDS <b>Fasta</b> File:"),
                    multiple=FALSE,
                    width="100%",
                    accept=c(
                        ".fasta",
                        ".fa",
                        ".fasta.gz",
                        ".fa.gz",
                        ".gz"
                    )
                )
            ),
            column(
                4,
                fileInput(
                    paste0("gff_", i),
                    HTML("Upload <b>GFF</b>/<b>GTF</b> File:"),
                    multiple=FALSE,
                    width="100%",
                    accept=c(
                        ".gff",
                        ".gff.gz",
                        ".gff3",
                        ".gff3.gz",
                        ".gtf",
                        ".gtf.gz",
                        ".gz"
                    )
                )
            )
        )
    }
    ui_parts
})

output$WgdksratesSettingDisplay <- renderUI({
    num <- toupper(as.english(input$number_of_study_species))
    if( input$number_of_study_species < 2 ){
        mode <- "Whole-Paranome"
        fluidRow(
            class="justify-content-end",
            style="padding-bottom: 5px;",
            column(
                12,
                div(HTML("Species number is set to <b><font color='#9F5000'>",
                        num,
                        "</b></font>, less than <b><font color='red'>TWO</font></b>.<br>",
                        "Following <b>WGD ",
                        "<font color='green'>",
                        mode,
                        "</font>",
                        "</b> pipeline ...<br></br>"),
                    div(class="d-flex justify-content-between",
                        div(class="float-left",
                            actionButton(
                                inputId="wgd_go",
                                HTML("Create <b><i>wgd</i></b> Codes"),
                                #width="200px",
                                icon=icon("code"),
                                status="secondary",
                                style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px; "
                            )
                        ),
                        div(class="float-middle text-center",
                            style="margin: 15px 5px 5px 5px; ",
                            actionLink(
                                "go_codes",
                                HTML(paste0("<font color='#5151A2'>",
                                            icon("share"),
                                            " Go to <i><b>wgd</b></i> Codes</font>")
                                )
                            )
                        ),
                        div(class="float-right",
                            downloadButton(
                                outputId="wgd_ksrates_data_download",
                                label="Download Analysis Data",
                                #width="215px",
                                icon=icon("download"),
                                status="secondary",
                                style="background-color: #5151A2;
                                       padding: 5px 10px 5px 10px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowingD 5000ms infinite; "
                            )
                        )
                    )
                )
            )
        )
    }
    else{
        fluidRow(
            div(
                style="padding-left: 20px;
                       padding-right: 20px;",
                fluidRow(
                    column(
                        12,
                        h6(
                            HTML(
                                "Species number is set to <b><font color='#9F5000'>",
                                num,
                                "</b></font>, larger than <b><font color='red'>ONE</font></b>.",
                                " Following <b><font color='green'>ksrates</font></b> pipeline...<br></br>"
                            )
                        )
                    ),
                    column(
                        6,
                        pickerInput(
                            inputId="select_focal_species",
                            label=HTML("<b>Focal Species</b> for <b><font color='green'>ksrates</font></b>:"),
                            options=list(
                                title='Please select focal species below'
                            ),
                            choices=NULL,
                            multiple=FALSE
                        )
                    ),
                    column(
                        6,
                        fileInput(
                            "newick_tree",
                            HTML("Upload <b>a Newick Tree</b> File for <b><font color='green'>ksrates</font></b>:"),
                            multiple=FALSE,
                            width="100%"
                        )
                    ),
                    column(
                        12,
                        uiOutput("multipleSpeciesPanel")
                    ),
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        6,
                        actionButton(
                            inputId="ksrates_go",
                            HTML("Create <b><i>ksrates</b></i> Codes"),
                            width="230px",
                            icon=icon("code"),
                            status="secondary",
                            style="color: #fff;
                                   background-color: #27ae60;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;
                                   animation: glowing 5300ms infinite; "
                        ),
                        div(
                            id="ksrates_progress_container_js"
                        )
                    ),
                    column(
                        6,
                        div(class="float-right",
                            style="padding-top: 10px; ",
                            actionLink(
                                "go_codes_ksrates",
                                HTML(
                                    paste0(
                                        "<font color='#5151A2'>",
                                        icon("share"),
                                        #" Go to Codes"
                                        " Go to <i><b>ksrates</b></i> Codes</font>"
                                    )
                                )
                            )
                        )
                    )
                ),
                fluidRow(
                    column(
                        6,
                        div(class="float-left",
                            actionButton(
                                inputId="iadhore_go",
                                HTML("Create <b><i>i-ADHoRe</b></i> Codes"),
                                width="245px",
                                icon=icon("code"),
                                status="secondary",
                                style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowing 5300ms infinite; "
                            ),
                            div(
                                id="iadhore_progress_container_js"
                            )
                        )
                    ),
                    column(
                        6,
                        div(class="float-right",
                            style="padding-top: 10px;",
                            actionLink(
                                "go_codes_iadhore",
                                HTML(paste0("<font color='#5151A2'>",
                                            icon("share"),
                                            " Go to <i><b>i-ADHoRe</b></i> Codes</font>")
                                )
                            )
                        )
                    )
                ),
                if( input$number_of_study_species > 2 ){
                    fluidRow(
                        column(
                            6,
                            div(#class="float-left",
                                style="padding-bottom: 15px;",
                                actionButton(
                                    inputId="orthofinder_go",
                                    HTML("Create <i><b>OrthoFinder</b></i> Codes"),
                                    width="265px",
                                    icon=icon("code"),
                                    status="secondary",
                                    style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowing 5300ms infinite; "
                                ),
                                div(
                                    id="orthofinder_progress_container_js"
                                )
                            )
                        ),
                        column(
                            6,
                            div(class="float-right",
                                style="padding-top: 10px;",
                                actionLink(
                                    "go_codes_orthofinder",
                                    HTML(
                                        paste0(
                                            "<font color='#5151A2'>",
                                            icon("share"),
                                            " Go to <i><b>OrthoFinder</b></i> Codes</font>"
                                        )
                                    )
                                )
                            )
                        )
                    )
                },
                fluidRow(
                    hr(class="setting"),
                    column(
                        12,
                        align="left",
                        div(
                            HTML("<b>Download Analysis Data:</b><br>"),
                            style="padding-bottom: 15px;",
                            downloadButton(
                                outputId="wgd_ksrates_data_download",
                                label="Download",
                                width="250px",
                                icon=icon("download"),
                                status="secondary",
                                style="background-color: #5151A2;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowingD 5000ms infinite; "
                            )
                        )
                    )
                )
            )
        )
    }
})

output$multipleSpeciesPanel <- renderUI({
    if( input$number_of_study_species > 2 ){
        div(
            style="display: inline-flex;",
            column(
                8,
                HTML(
                    "If switching on the right mode, <font color='green'><b>i-ADHoRe</b></font> will study all the species within one run. The code will be appended to the main script of <font color='green'><b>run_diamond_iadhore.sh</b></font>. See more details in <font color='green'><b>i-ADHoRe</b></font> manual"
                ),
            ),
            column(
                4,
                style="margin-top: 20px;",
                switchInput(
                    inputId="multiple_iadhore",
                    onStatus="success",
                    offStatus="danger"
                )
            )
        )
    }
})

observeEvent(input$switchTab, {
    if (input$switchTab=="help") {
        updateTabsetPanel(session, "shinywgd", selected="help")
    }
})

unlink(paste0(tempdir(), "/Analysis_", Sys.Date()), recursive=T)
dir.create(paste0(tempdir(), "/Analysis_", Sys.Date()))

# update the focal species panel
get_species_from_input <- reactive({
    sp_range <- 1:input$number_of_study_species
    latin_names_list <- c()
    for( i in sp_range ){
        latin_name <- paste0("latin_name_", i)
        if( !is.null(input[[latin_name]]) ){
            latin_names_list <- c(latin_names_list, trimws(input[[latin_name]]))
        }
    }
    return(latin_names_list)
})
observeEvent(get_species_from_input(), {
    updatePickerInput(
        session,
        "select_focal_species",
        choices=get_species_from_input(),
        choicesOpt=list(
            content=lapply(get_species_from_input(), function(choice) {
                choice <- gsub("_", " ", choice)
                HTML(paste0("<div style='color: #5667E5; font-style: italic;'>", choice, "</div>"))
            })
        )
    )
})

get_species_from_file <- reactive({
    if( !is.null(input$upload_data_file)) {
        read_data_file(input$upload_data_file)[["V1"]]
    }
})
observeEvent(get_species_from_file(), {
    updatePickerInput(
        session,
        "select_focal_species",
        choices=get_species_from_file(),
        choicesOpt=list(
            content=lapply(get_species_from_file(), function(choice) {
                choice <- gsub("_", " ", choice)
                HTML(paste0("<div style='color: #5667E5; font-style: italic;'>", choice, "</div>"))
            })
        )
    )
})

observeEvent(input$upload_data_file, {
    unlink(paste0(tempdir(), "/Analysis_", Sys.Date()), recursive=T)
    dir.create(paste0(tempdir(), "/Analysis_", Sys.Date()))
    shinyalert(
        "Success",
        "You use a file file to upload the data. See more details in Help page",
        type="success"
    )
    data_table <- read_data_file(input$upload_data_file)
    ncols <- ncol(data_table)
    nrows <- nrow(data_table)

    if( input$number_of_study_species != nrows ){
        shinyalert(
            "Oops!",
            paste0("The species number in the file (", nrows, " species) is not equal to the number you chose (", input$number_of_study_species, " species). Please set the right species number to analyze!"),
            type="error",
        )
    }
})

observeEvent(input$wgd_go, {
    unlink(paste0(tempdir(), "/Analysis_", Sys.Date()), recursive=T)
    dir.create(paste0(tempdir(), "/Analysis_", Sys.Date()))
    if( is.null(input$upload_data_file) ){
        if( is.null(input[[paste0("proteome_", 1)]]) ){
            shinyalert(
                "Oops!",
                "Please upload the data from at least one species, then switch this on",
                type="error"
            )
        }
        else{
            withProgress(message='Creating in progress', value=0, {
                incProgress(amount=.2, message="Preparing files ...")
                Sys.sleep(1)
                latin_name <- gsub(" $", "", input[[paste0("latin_name_", 1)]])
                informal_name <- gsub(" ", "_", latin_name)
                query_proteome_t <- check_proteome_input(
                    informal_name,
                    input[[paste0("proteome_", 1)]]
                )
                incProgress(amount=.3, message="Creating WGD Runing Script ...")
                Sys.sleep(.5)
                wgd_cmd_sh_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
                wgd_cmd <- file(wgd_cmd_sh_file, open="w")
                # create wgd runing script
                cat(
                    paste0("wgd dmd -I 3 ", informal_name, ".fa -o 01.wgd_dmd --nostrictcds"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                cat(
                    paste0("wgd ksd 01.wgd_dmd/", informal_name, ".fa.mcl ", informal_name, ".fa -o 02.wgd_ksd"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                if( is.null(input[[paste0("gff_", 1)]]) ){
                    shinyalert(
                        "Warning",
                        "No annotation file uploaded. Skip the synteny analysis in WGD pipeline",
                        type="warning",
                    )
                }
                else{
                    query_gff_t <- check_gff_input(
                        informal_name,
                        input[[paste0("gff_", 1)]]
                    )
                    cat(
                        paste0("wgd syn -f mRNA -a ID -ks 02.wgd_ksd/", informal_name, ".fa.ks.tsv ", informal_name, ".gff 01.wgd_dmd/", informal_name, ".fa.mcl -o 03.wgd_syn"),
                        file=wgd_cmd,
                        append=TRUE,
                        sep="\n"
                    )
                }
                cat(
                    paste0("wgd mix -ni 100 --method bgmm 02.wgd_ksd/", informal_name, ".fa.ks.tsv", " -o 04.wgd_mix"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                close(wgd_cmd)
                incProgress(amount=1)
                Sys.sleep(2)
            })
        }
    }
    else{
        data_table <- read_data_file(input$upload_data_file)
        ncols <- ncol(data_table)
        nrows <- nrow(data_table)
        if( nrows == 1 ){
            withProgress(message='Creating in progress', value=0, {
                # wgd pipeline needs user to upload valid files
                incProgress(amount=.2, message="Preparing Files ...")
                Sys.sleep(.2)
                latin_name <- gsub(" ", "_", data_table[1, "V1"])
                proteome <- data_table[1, "V2"]
                proteome_checked <- check_proteome_from_file(
                    latin_name,
                    proteome
                )
                incProgress(amount=.3, message="Creating WGD Runing Script ...")
                Sys.sleep(.5)
                wgd_cmd_sh_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
                wgd_cmd <- file(wgd_cmd_sh_file, open="w")
                # create wgd runing script
                cat(
                    paste0("wgd dmd -I 3 ", latin_name, ".fa -o 01.wgd_dmd"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                cat(
                    paste0("wgd ksd 01.wgd_dmd/", latin_name, ".fa.mcl ", latin_name, ".fa -o 02.wgd_ksd"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                if( ncols > 2 ){
                    gff <- data_table[1, "V3"]
                    gff_checked <- check_gff_from_file(
                        latin_name,
                        gff
                    )
                    cat(
                        paste0("wgd syn -f mRNA -a ID -ks 02.wgd_ksd/", latin_name, ".fa.ks.tsv ", latin_name, ".gff 01.wgd_dmd/", latin_name, ".fa.mcl -o 03.wgd_syn"),
                        file=wgd_cmd,
                        append=TRUE,
                        sep="\n"
                    )
                }
                else if( ncols == 2 ){
                    shinyalert(
                        "Warning",
                        "No annotation file found. Skip the synteny analysis in WGD pipeline",
                        type="warning",
                    )
                }
                cat(
                    paste0("wgd mix -ni 100 --method bgmm 02.wgd_ksd/", latin_name, ".fa.ks.tsv", " -o 04.wgd_mix"),
                    file=wgd_cmd,
                    append=TRUE,
                    sep="\n"
                )
                close(wgd_cmd)
                incProgress(amount=1)
                Sys.sleep(2)
            })
        }
    }
})

updateProgress <- function(container, width, type) {
    session$sendCustomMessage(
        "UpdateProgressBar",
        list(container=container, width=width, type=type)
    )
}

observeEvent(input$upload_data_file,{
    withProgress(message='Checking the path of input files', value=0, {
        data_table <- read_data_file(input$upload_data_file)
        checkFileExistence(data_table)
        incProgress(amount=1)
    })
})

observeEvent(input$ksrates_go, {
    if( is.null(input$upload_data_file) ){
        progress_data <- list("actionbutton"="ksrates_go",
                              "container"="ksrates_progress_container_js")
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )
        if( is.null(input[[paste0("proteome_", 2)]]) ){
            shinyalert(
                "Oops!",
                "Please upload the data from at least two species to trigger the ksrates pipeline, then switch this on",
                type="error"
            )
        }
        else if( is.null(input$select_focal_species) ){
            shinyalert(
                "Oops!",
                "Please define focal species first, then switch this on",
                type="error"
            )
        }
        else if( is.null(input$newick_tree) ){
            shinyalert(
                "Oops!",
                "Please upload the newick tree first, then switch this on",
                type="error"
            )
        }
        else{
            withProgress(message='Creating in progress', value=0, {
                incProgress(amount=.15, message="Preparing ksrates configure file...")
                updateProgress(
                    container="ksrates_progress_container_js",
                    width=15,
                    type="Create ksrates code"
                )
                Sys.sleep(1)

                ksratesDir <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd")
                if( !file.exists(ksratesDir) ){
                    dir.create(ksratesDir)
                }
                ksratesconf <- paste0(ksratesDir, "/ksrates_conf.txt")
                speciesinfoconf <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls")

                create_ksrates_configure_file_v2(input, ksratesconf, speciesinfoconf)

                incProgress(amount=.6, message="Preparing ksrates expert parameters...")
                updateProgress(
                    container="ksrates_progress_container_js",
                    width=60,
                    type="Create ksrates code"
                )
                Sys.sleep(1)
                # create Ksrate expert parameters file
                ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                create_ksrates_expert_parameter_file(ksratesexpert)

                updateProgress("ksrates_progress_container_js", 80, "Create ksrates code")
                incProgress(amount=.8, message="Creating ksrates Runing Script ...")
                Sys.sleep(1)
                ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                ksrates_cmd <- create_ksrates_cmd(input, "ksrates_conf.txt", ksrates_cmd_sh_file)

                system(
                    paste(
                        "cp",
                        paste0(getwd()[1], "/tools/run_paralog_ks_rest_species.sh"),
                        ksratesDir
                    )
                )

                updateProgress("ksrates_progress_container_js", 100, "Create ksrates code")
                incProgress(amount=1)
                Sys.sleep(1)
            })
        }
    }
    else{
        progress_data <- list("actionbutton"="ksrates_go",
                              "container"="ksrates_progress_container_js")
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )

        data_table <- read_data_file(input$upload_data_file)
        ncols <- ncol(data_table)
        nrows <- nrow(data_table)
        if( nrows > 1 ){
            if( is.null(input$select_focal_species) || input$select_focal_species == ""){
                shinyalert(
                    "Oops!",
                    "Please define focal species first, then switch this on",
                    type="error"
                )
            }
            else if( is.null(input$newick_tree) ){
                shinyalert(
                    "Oops!",
                    "Please upload the newick tree first, then switch this on",
                    type="error"
                )
            }
            else{
                withProgress(message='Creating in progress', value=0, {
                    incProgress(amount=.15, message="Preparing ksrates Configure File ...")
                    updateProgress("ksrates_progress_container_js", 15, "Create ksrates code")
                    Sys.sleep(1)
                    ksratesDir <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd")
                    if( !file.exists(ksratesDir) ){
                        dir.create(ksratesDir)
                    }
                    ksratesconf <- paste0(ksratesDir, "/ksrates_conf.txt")
                    speciesinfoconf <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls")
                    create_ksrates_configure_file_based_on_table(
                        data_table,
                        input$select_focal_species,
                        input$newick_tree,
                        ksratesconf,
                        speciesinfoconf
                    )

                    incProgress(amount=.6, message="Preparing ksrates Expert Parameters ...")
                    updateProgress("ksrates_progress_container_js", 60, "Create ksrates code")
                    Sys.sleep(1)

                    ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                    create_ksrates_expert_parameter_file(ksratesexpert)

                    incProgress(amount=.8, message="Create ksrates Running Script ...")
                    updateProgress("ksrates_progress_container_js", 80, "Create ksrates code")
                    Sys.sleep(1)
                    ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                    ksrates_cmd <- create_ksrates_cmd_from_table(data_table, "ksrates_conf.txt", ksrates_cmd_sh_file, input$select_focal_species)

                    system(
                        paste(
                            "cp",
                            paste0(getwd()[1], "/tools/run_paralog_ks_rest_species.sh"),
                            ksratesDir
                        )
                    )

                    incProgress(amount=1)
                    updateProgress("ksrates_progress_container_js", 100, "Create ksrates code")
                    Sys.sleep(.1)
                })
            }
        }
    }
})

observeEvent(input$iadhore_go, {
    species_info <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls"))
    if( is.null(input$upload_data_file) & is.null(input[[paste0("gff_", 1)]]) ){
        shinyalert(
            "Oops!",
            "Please upload the annotation file (gff) for at least one species to trigger the i-ADHoRe pipeline, then switch this on",
            type="error"
        )
    }
    else if ( !file.exists(species_info) ){
        shinyalert(
            "Oops",
            "Please click the Create-Ksrate-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        progress_data <- list("actionbutton"="iadhore_go",
                              "container"="iadhore_progress_container_js")
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.2, message="Preparing i-ADHoRe configure file...")
            updateProgress("iadhore_progress_container_js", 20, "Creat i-ADHoRe code")
            Sys.sleep(1)

            syn_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/i-ADHoRe_wd"))
            if( !file.exists(syn_dir) ){
                dir.create(syn_dir)
            }
            cmd_file <- paste0(syn_dir, "/run_diamond_iadhore.sh")
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/running_diamond.shell"),
                    syn_dir
                )
            )
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/computing_anchorpoint_ks.MultiThreads.shell"),
                    syn_dir
                )
            )

            incProgress(amount=.1, message="Dealing with gff files...")
            updateProgress("iadhore_progress_container_js", 30, "Creat i-ADHoRe code")
            Sys.sleep(1)

            system(
                paste(
                    "sh tools/preparing_iadhore_inputs.shell",
                    species_info,
                    syn_dir
                )
            )
            incProgress(amount=.4, message="Generating the codes for diamond and i-ADHoRe")
            updateProgress("iadhore_progress_container_js", 70, "Creat i-ADHoRe code")
            Sys.sleep(1)

            if( input$multiple_iadhore ){
                system(
                    paste(
                        "sh tools/generating_iadhore_codes.local.shell",
                        species_info,
                        syn_dir,
                        cmd_file,
                        getwd()[1],
                        "running_diamond.shell",
                        4,
                        "mode"
                    )
                )
            }else{
                system(
                    paste(
                        "sh tools/generating_iadhore_codes.local.shell",
                        species_info,
                        syn_dir,
                        cmd_file,
                        getwd()[1],
                        "running_diamond.shell",
                        4
                    )
                )
            }
            incProgress(amount=1, message="Done")
            updateProgress("iadhore_progress_container_js", 100, "Creat i-ADHoRe code")
            Sys.sleep(1)
        })
    }
})

observeEvent(input$orthofinder_go, {
    progress_data <- list("actionbutton"="orthofinder_go",
                          "container"="orthofinder_progress_container_js")
    session$sendCustomMessage(
        "Progress_Bar_Complete",
        progress_data
    )

    species_info <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls"))
    if( file.exists(species_info) ){
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.1, message="Preparing OrthoFinder input file...")
            updateProgress("orthofinder_progress_container_js", 10, "Create OrthoFinder code")
            Sys.sleep(1)

            orthofinder_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/OrthoFinder_wd"))
            if( !dir.exists(orthofinder_dir) ){
                dir.create(orthofinder_dir)
            }
            ds_tree_dir <- paste0(orthofinder_dir, "/ds_tree_wd")
            if( !dir.exists(ds_tree_dir) ){
                dir.create(ds_tree_dir)
            }
            cmd_file <- paste0(orthofinder_dir, "/run_orthofinder.sh")
            incProgress(amount=.1, message="Create inputs file for OrthoFinder ...")
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/computing_Ks_tree_of_SingleCopyOrthologues.shell"),
                    ds_tree_dir
                )
            )
            incProgress(amount=.1, message="Translate CDS into proteins ...")
            updateProgress("orthofinder_progress_container_js", 30, "Create OrthoFinder code")
            Sys.sleep(1)

            system(
                paste(
                    "Rscript tools/prepare_orthofinder.R",
                    "-i", species_info,
                    "-o", orthofinder_dir,
                    "-c", cmd_file
                )
            )

            incProgress(amount=1, message="Done")
            updateProgress("orthofinder_progress_container_js", 100, "Create OrthoFinder code")
            Sys.sleep(1)
        })
    }
    else{
        shinyalert(
            "Oops",
            "Please click the Create-Ksrate-Codes button first, then switch this on",
            type="error"
        )
    }
})

# Link to Codes page
observeEvent(input$go_codes, {
    ksratescommadFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd/run_ksrates.sh")
    wgdcommmandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
    if( !file.exists(wgdcommmandFile) & !file.exists(ksratescommadFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-wgd-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        updateNavbarPage(inputId="shinywgd", selected="codes_page")
        shinyjs::runjs(
            'setTimeout(function () {
                document.querySelector("#ksratesParameterPanel").scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }, 100);
            '
        )
    }
})


observeEvent(input$go_codes_ksrates, {
    ksratescommadFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd/run_ksrates.sh")
    wgdcommmandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
    if( !file.exists(wgdcommmandFile) & !file.exists(ksratescommadFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-ksrates-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        updateNavbarPage(inputId="shinywgd", selected="codes_page")
        shinyjs::runjs(
            'setTimeout(function () {
                document.querySelector("#ksratesParameterPanel").scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }, 100);
        ')
    }
})

observeEvent(input$go_codes_iadhore, {
    iadhorecommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/i-ADHoRe_wd/run_diamond_iadhore.sh")
    if( !file.exists(iadhorecommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-i-ADHoRe-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        updateNavbarPage(inputId="shinywgd", selected="codes_page")
        shinyjs::runjs(
            'setTimeout(function () {
                document.querySelector("#iadhoreParameterPanel").scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }, 100);
        ')
    }
})

observeEvent(input$go_codes_orthofinder, {
    orthofinderCommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/OrthoFinder_wd/run_orthofinder.sh")
    if( !file.exists(orthofinderCommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-OrthoFinder-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        updateNavbarPage(inputId="shinywgd", selected="codes_page")
        shinyjs::runjs(
            'setTimeout(function () {
                document.querySelector("#orthofinderParameterPanel").scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }, 100);
        ')
    }
})

# Create analysis data to download
output$wgd_ksrates_data_download <- downloadHandler(
    filename=function(){
        paste0("Analysis_Data.", Sys.Date(), ".tgz")
    },
    content=function(file){
        # ksratescommadFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_ksrates.sh")
        # wgdcommmandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
        # if( !file.exists(wgdcommmandFile) & !file.exists(ksratescommadFile) ){
        #     shinyalert(
        #         "Oops",
        #         "Please click the TEST Create-WGD-Codes or Create-ksrates-Codes button first, then switch this on",
        #         type="error"
        #     )
        #     return(NULL)
        # }
        # else{
        withProgress(message='Downloading in progress', value=0, {
            # update the Species.info.xls
            species_info <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls"))
            species_data <- read.table(
                species_info,
                header=FALSE,
                sep="\t",
                stringsAsFactors=FALSE
            )

            species_data$V1 <- gsub("_", " ", species_data$V1)
            species_data$V2 <- gsub("^.*/", "../", species_data$V2)
            species_data$V3 <- gsub("^.*/", "../", species_data$V3)

            write.table(
                species_data,
                file=species_info,
                sep="\t",
                quote=FALSE,
                col.names=FALSE,
                row.names=FALSE
            )

            incProgress(amount=.1, message="Compressing files...")
            shinyalert(
                "Note",
                "Pleae wait for compressing the files. Do not close the window",
                type="info"
            )
            run_dir <- getwd()
            setwd(tempdir())
            # seq_files <- list.files(
            #     path=paste0("Analysis_", Sys.Date()),
            #     full.names=TRUE,
            #     pattern=".fa$"
            # )
            # lapply(seq_files, R.utils::gzip)
            # gff_files <- list.files(
            #     path=paste0("Analysis_", Sys.Date()),
            #     full.names=TRUE,
            #     pattern=".gff$"
            # )
            # lapply(gff_files, R.utils::gzip)
            #system(paste0("gzip Analysis_", Sys.Date(), "/*gff Analysis_",  Sys.Date(), "/*fa"))
            system(paste0("tar czf ", file,
                          " --dereference ",
                          "Analysis_",
                          Sys.Date()
            )
            )
            incProgress(amount=.9, message="Downloading file...")
            incProgress(amount=1)
            Sys.sleep(.1)
            setwd(run_dir)
        })
    }
    # },
    # contentType="application/zip"
)
