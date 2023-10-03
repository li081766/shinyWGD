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

output$WgdKsratesSettingDisplay <- renderUI({
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
                       padding-right: 20px;
                       padding-top: 10px; ",
                fluidRow(
                    column(
                        6,
                        h6(
                            HTML(
                                "Species number is set to <b><font color='#9F5000'>",
                                num,
                                "</b></font>, larger than <b><font color='red'>ONE</font></b>.",
                                " Following <b><font color='green'>Ksrates</font></b> pipeline..."
                            )
                        )
                    ),
                    column(
                        6,
                        uiOutput("multipleSpeciesPanel")
                    ),
                    column(
                        6,
                        pickerInput(
                            inputId="select_focal_species",
                            label=HTML("<b>Focal Species</b> for Ksrates:"),
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
                            HTML("Upload <b>a Newick Tree</b> File for Ksrates:"),
                            multiple=FALSE,
                            width="100%"
                        )
                    )
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        6,
                        actionButton(
                            inputId="ksrates_go",
                            HTML("Create <b><i>Ksrates</b></i> Codes"),
                            #"Create Codes",
                            width="230px",
                            icon=icon("code"),
                            status="secondary",
                            style="color: #fff;
                                   background-color: #27ae60;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;
                                   animation: glowing 5300ms infinite; "
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
                                        " Go to <i><b>Ksrates</b></i> Codes</font>"
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
                                    HTML("Create <i><b>Orthofinder</b></i> Codes"),
                                    width="265px",
                                    icon=icon("code"),
                                    status="secondary",
                                    style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowing 5300ms infinite; "
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
                                            " Go to <i><b>Orthofinder</b></i> Codes</font>"
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
            style="margin-top: 40px; display: inline-flex;",
            materialSwitch(
                "multiple_iadhore",
                HTML("<b><i><font color='green'>i-ADHoRe</b></i></font> Mode"),
                value=FALSE,
                status="success",
            ),
            span(
                `data-toggle`="tooltip",
                `data-placement`="auto",
                `data-trigger`="click hover",
                title="If switching on this mode, i-ADHoRe will study all the species within one run. The code will be appended to the main script of run_diamond_iadhore.sh. See more details in i-ADHoRe manul",
                #title=HTML("<div>If switching on this mode, <b><font color='green'>i-ADHoRe</font></b> uses the multiple-species mode to study all the species within one run.<br>The code will be appended to the main script <b><font color='steelblue' face='Courier New' bgcolor='grey'>run_diamond_iadhore.sh</font></b></div>"),
                icon("info-circle", style="font-size: 120%; margin-left: -100px;")
            ),
            tags$script(HTML('
               $( document ).on("shiny:sessioninitialized", function(event) {
                    $(\'span[data-toggle="tooltip"]\').tooltip({
                        html: true
                    });
               });'
            ))
        )
    }
})

output$ObtainTreeFromTimeTreeSettingDisplay <- renderUI({
    num <- toupper(as.english(input$number_of_study_species))
    if( input$number_of_study_species > 2 ){
        fluidRow(
            div(
                style="background-color: #F5FFE8; padding-left: 20px;",
                fluidRow(
                    column(
                        12,
                        h4(
                            icon("tree", style="color: #64A600;"),
                            HTML("<font color='#64A600'>Extracting Tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a></font>")
                        )
                    )
                ),
                hr(class="setting"),
                fluidRow(
                    div(
                        style="padding-left: 20px;",
                        column(
                            12,
                            h6(
                                HTML(
                                    "If you don’t ensure the evolutionary relationships among the studied species,
                <br>click the button below to obtain a tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a>."
                                )
                            )
                        ),
                        # div(class="float-left, padding-right: 20px; padding-left: 20px;",
                            tags$head(
                                tags$style(HTML(
                                    "@keyframes glowing {
                                     0% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
                                     50% { background-color: #73BF00; box-shadow: 0 0 20px #43b0d1; }
                                     100% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
                                     }
                                @keyframes glowingD {
                                     0% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
                                     50% { background-color: #8C8C00; box-shadow: 0 0 20px #43b0d1; }
                                     100% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
                                     }"
                                ))
                            ),
                            actionButton(
                                inputId="extract_tree_go",
                                "Extract Tree",
                                width="200px",
                                icon=icon("tree"),
                                status="secondary",
                                style="color: #fff;
                                      background-color: #019858;
                                      border-color: #fff;
                                      padding: 5px 14px 5px 14px;
                                      margin: 5px 5px 5px 5px;
                                      animation: glowing 5300ms infinite;"
                            # )
                        ),
                        fluidRow(
                            column(
                                12,
                                HTML(paste0("The Newick Tree Extracted from TimeTree.org:")),
                                div(
                                    style="width: 500px;",
                                    verbatimTextOutput(
                                        "TimetreeNewick",
                                        placeholder=TRUE
                                    )
                                )
                            )
                        ),
                        h6(
                            HTML("<font color='red'><b>Note</b></font> TimeTree database does not include all the species.
                     <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the species are not included in the TimeTree database,
                     <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;you should ensure the relationship in other ways.")
                        )
                    )
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
                HTML(paste0("<div style='color: #FA9D88; font-style: italic;'>", choice, "</div>"))
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
                HTML(paste0("<div style='color: #FA9D88; font-style: italic;'>", choice, "</div>"))
            })
        )
    )
})

observeEvent(input$extract_tree_go, {
    analysis_dir <- paste0(tempdir(), "/Analysis_", Sys.Date())
    if( !file.exists(analysis_dir) ){
        dir.create(paste0(tempdir(), "/Analysis_", Sys.Date()))
    }
    species_names_file <- paste0(analysis_dir, "/species_names_list.xls")
    from_file <- get_species_from_file()
    from_input <- get_species_from_input()

    if( length(from_file) > 0 | length(from_input[nzchar(from_input)]) > 0 ){
        if( length(from_file) > 0 ){
            writeLines(get_species_from_file(), species_names_file)
        }else{
            writeLines(get_species_from_input(), species_names_file)
        }
        species_name_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/species_names_list.xls")
        timetree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/timetree.newick")
        newick_tree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/species_tree.newick")
        withProgress(message='Extracting in progress', value=0, {
            system(
                paste(
                    "Rscript tools/obtain_newick_tree_from_timetree.R ",
                    species_name_file,
                    timetree_file,
                    newick_tree_file
                )
            )
            if( file.exists(newick_tree_file) ){
                output$TimetreeNewick <- renderText({
                    CommandText <- readChar(newick_tree_file, file.info(newick_tree_file)$size)
                })
            }else{
                shinyalert(
                    "Oops",
                    "Fail to extract tree from Timetree.org. Please try other ways!",
                    type="error"
                )
            }
            incProgress(amount=1)
        })
    }
    else{
        shinyalert(
            "Oops",
            "Please upload data first, then switch on this",
            type="error"
        )
    }
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

observeEvent(input$ksrates_go, {
    if( is.null(input$upload_data_file) ){
        if( is.null(input[[paste0("proteome_", 2)]]) ){
            shinyalert(
                "Oops!",
                "Please upload the data from at least two species to trigger the Ksrates pipeline, then switch this on",
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
                incProgress(amount=.1, message="Preparing Ksrates configure file...")
                Sys.sleep(.1)
                ksratesDir <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd")
                if( !file.exists(ksratesDir) ){
                    dir.create(ksratesDir)
                }
                ksratesconf <- paste0(ksratesDir, "/ksrates_conf.txt")
                speciesinfoconf <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls")
                create_ksrates_configure_file_v2(input, ksratesconf, speciesinfoconf)

                incProgress(amount=.1, message="Preparing Ksrates expert parameters...")
                Sys.sleep(.1)
                # create Ksrate expert parameters file
                ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                create_ksrates_expert_parameter_file(ksratesexpert)

                incProgress(amount=.8, message="Creating Ksrates Runing Script ...")
                Sys.sleep(.1)
                ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                ksrates_cmd <- create_ksrates_cmd(input, "ksrates_conf.txt", ksrates_cmd_sh_file)
                incProgress(amount=1)
                Sys.sleep(.1)
            })
        }
    }
    else{
        data_table <- read_data_file(input$upload_data_file)
        ncols <- ncol(data_table)
        nrows <- nrow(data_table)
        if( nrows > 1 ){
            if( is.null(input$select_focal_species) ){
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
                    incProgress(amount=.1, message="Preparing Ksrates Configure File ...")
                    Sys.sleep(.1)
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

                    incProgress(amount=.1, message="Preparing Ksrates Expert Parameters ...")
                    Sys.sleep(.1)
                    ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                    create_ksrates_expert_parameter_file(ksratesexpert)

                    incProgress(amount=.8, message="Create Ksrates Running Script ...")
                    Sys.sleep(.1)
                    ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                    wgd_cmd_sh_file <- paste0(ksratesDir, "/run_wgd_rest_species.sh")
                    ksrates_cmd <- create_ksrates_cmd_from_table(data_table, "ksrates_conf.txt", ksrates_cmd_sh_file, wgd_cmd_sh_file, input$select_focal_species)

                    incProgress(amount=1)
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
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.1, message="Preparing i-ADHoRe configure file...")
            Sys.sleep(.1)
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
                    paste0(getwd()[1], "/tools/computing_anchorpoint_ks.MultiThreads.sh"),
                    syn_dir
                )
            )
            incProgress(amount=.3, message="Dealing with gff files...")
            system(
                paste(
                    "sh tools/preparing_iadhore_inputs.shell",
                    species_info,
                    syn_dir
                )
            )
            incProgress(amount=.5, message="Generating the codes for diamond and i-ADHoRe")
            if( input$multiple_iadhore ){
                system(
                    paste(
                        "sh tools/generating_iadhore_codes.local.shell",
                        species_info,
                        syn_dir,
                        cmd_file,
                        getwd()[1],
                        "running_diamond.shell",
                        "diamond_path",
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
                        "diamond_path",
                        4
                    )
                )
            }
            incProgress(amount=.8, message="Done")
            Sys.sleep(.1)
            incProgress(amount=1)
            Sys.sleep(.1)
        })
    }
})

observeEvent(input$orthofinder_go, {
    species_info <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Species.info.xls"))
    if( file.exists(species_info) ){
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.1, message="Preparing Orthofinder input file...")
            Sys.sleep(.1)
            orthofinder_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Orthofinder_wd"))
            if( !file.exists(orthofinder_dir) ){
                dir.create(orthofinder_dir)
            }
            cmd_file <- paste0(orthofinder_dir, "/run_orthofinder.sh")
            incProgress(amount=.3, message="Create inputs file for Orthofinder ...")
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/computing_Ks_tree_of_SingleCopyOrthologues.sh"),
                    orthofinder_dir
                )
            )
            system(
                paste(
                    "Rscript tools/prepare_orthofinder.R",
                    "-i", species_info,
                    "-o", orthofinder_dir,
                    "-c", cmd_file
                )
            )
            incProgress(amount=1)
            Sys.sleep(.1)
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
            "Please click the Create-Ksrates-Codes button first, then switch this on",
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
    orthofinderCommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/Orthofinder_wd/run_orthofinder.sh")
    if( !file.exists(orthofinderCommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-Orthofinder-Codes button first, then switch this on",
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
        #         "Please click the TEST Create-WGD-Codes or Create-Ksrates-Codes button first, then switch this on",
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

            species_data$V2 <- gsub("^.*/", "../", species_data$V2)
            species_data$V3 <- gsub("^.*/", "../", species_data$V3)

            file.edit(
                species_info,
                species_data,
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
