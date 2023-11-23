observeEvent(input$ks_data_example, {
    showModal(
        modalDialog(
            title=HTML("The description of the demo data used in the <b><i>K</i><sub>s</sub> Age Distribution Analysis</b>"),
            size="xl",
            uiOutput("ks_data_example_panel")
        )
    )

    output$ks_data_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    HTML(
                        paste0(
                            "<p>In the demo data, we selected four species: <i>Elaeis guineensis</i>, <i>Oryza sativa</i>, <i>Asparagus officinalis</i>, and <i>Vitis vinifera</i>, to generate the data.</p>",
                            "<p>First, we followed the preparation steps in the Data Preparation Page of the <b>shinyWGD</b> server to create the script for the corresponding package, <b>ksrates</b>. ",
                            "We then submitted the job to the PSB computing server to obtain the output.</p>",
                            "<p>After obtaining the output, the <b><i>K</i><sub>s</sub>Dist</b> module reads the data and continues the analysis. ",
                            "Users can choose the type and combinations of the data to study the <b>intra-</b> and <b>inter-species</b> <i>K</i><sub>s</sub> age distribution. ",
                            "Additionally, users have the option to use the <b>rate correction</b> module to adjust the substitution rate among species.</p>",
                            "<p>To download the demo data, <a href='https://github.com/li081766/shinyWGD_Demo_Data/blob/main/4sp_Ks_Data_for_Visualization.tar.gz' target='_blank'>click here</a>.</p>",
                            "<p><br></br></p>"
                        )
                    ),
                    h5(
                        HTML(
                            "<hr><p><b><font color='#BDB76B'>For true data</font></b>"
                        )
                    ),
                    HTML(
                        "<p>Users should upload the zipped-file, named as <b><i>Ks_Data_for_Visualization.tar.gz</i></b> in the <b>Analysis-*</b> folder created by <b>shinyWGD</b>, to start the <b><i>K</i><sub>s</sub>Dist Analysis</b>.</p>"
                    )
                )
            )
        )
    })
})

example_data_dir <- file.path(getwd(), "demo_data")
ks_example_dir <- file.path(example_data_dir, "Example_Ks_Visualization")

if( !dir.exists(ks_example_dir) ){
    if( !dir.exists(example_data_dir) ){
        dir.create(example_data_dir)
    }
    dir.create(ks_example_dir)
    downloadAndExtractData <- function() {
        download.file(
            "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_Ks_Data_for_Visualization.tar.gz",
            destfile=file.path(getwd(), "data.zip"),
            mode="wb"
        )

        system(
            paste(
                "tar xzf",
                shQuote(file.path(getwd(), "data.zip")),
                "-C",
                shQuote(ks_example_dir)
            )
        )

        file.remove(file.path(getwd(), "data.zip"))
    }

    downloadAndExtractData()
}

buttonClicked <- reactiveVal(NULL)
ks_analysis_dir_Val <- reactiveVal(ks_example_dir)

observeEvent(input$Ks_data_zip_file, {
    buttonClicked("fileInput")

    base_dir <- tempdir()
    timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
    ksAnalysisDir <- file.path(base_dir, paste0("Ks_data_", gsub("[ :\\-]", "_", timestamp)))
    dir.create(ksAnalysisDir)
    system(
        paste(
            "tar xzf",
            input$Ks_data_zip_file$datapath,
            "-C",
            ksAnalysisDir
        )
    )
    ks_analysis_dir_Val(ksAnalysisDir)
})

observeEvent(input$ks_data_example, {
    buttonClicked("actionButton")
    ks_analysis_dir_Val(ks_example_dir)
})

observe({
    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
        if( length(ksAnalysisDir) > 0 ){
            dirName <- basename(ksAnalysisDir)
            output$selectedKsDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'><i>K</i><sub>s</sub> Age Distribution Analysis</font></b>"))
                    )
                )
            })
        }
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
        if( length(ksAnalysisDir) > 0 ){
            dirName <- basename(ksAnalysisDir)
            output$selectedKsDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("Selected Directory:<br><b><font color='#EE82EE'>", dirName, "</font></b>"))
                    )
                )
            })
        }
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
        if( length(ksAnalysisDir) > 0 ){
            dirName <- basename(ksAnalysisDir)
            output$selectedKsDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("Selected Directory:<br><b><font color='#EE82EE'><i>K</i><sub>s</sub> Age Distribution Analysis</font></b>"))
                    )
                )
            })
        }
    }
})

output$ksanalysisPanel <- renderUI({
    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }
    ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        names_df <- map_informal_name_to_latin_name(species_info_file[1])
        newick_tree_file <- paste0(dirname(species_info_file), "/tree.newick")
        newick_tree <- readLines(newick_tree_file)
        session$sendCustomMessage("findOutgroup", newick_tree)
        if( !is.null(input$treeOrderList) ){
            num_rows <- length(input$treeOrderList) / 3
            num_cols <- 3
            species_tree_df <- matrix(
                input$treeOrderList,
                nrow=num_rows,
                ncol=num_cols,
                byrow=TRUE
            )
            species_tree_df <- as.data.frame(species_tree_df)
            colnames(species_tree_df) <- c("Species", "id", "pId")
            species_tree_df <- species_tree_df[-nrow(species_tree_df), ]
        }else{
            species_tree_df <- data.frame(
                Species=character(),
                id=integer(),
                pId=integer(),
                stringsAsFactors=FALSE
            )
        }
    }
    if( any(grepl("ortholog_distributions", ksfiles)) | any(grepl("paralog_distributions", ksfiles)) ){
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })

        div(class="boxLike",
            style="background-color: #FBFEEC;",
            fluidRow(
                div(
                    style="padding-bottom: 5px;
                           padding-top: 5px;
                           padding-left: 10px;",
                    h5(icon("cog"), HTML("Select <font color='#bb5e00'><b><i>K</i><sub>s</sub></b></font> to analyze")),
                    column(
                        12,
                        hr(class="setting")
                    ),
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="paralogous_ks_button",
                                label=HTML("<font color='white'><b>&nbsp;Paralog <i>K</i><sub>s</sub>&nbsp;&#x25BC;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font>"),
                                icon=icon("list"),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to choose species",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("paralog_ks_files_collapse"),
                            bs_collapse(
                                id="paralog_ks_files_collapse",
                                content=tags$div(
                                    class="well",
                                    pickerInput(
                                        inputId="paralog_ks_files_list",
                                        label=HTML("<b><font color='#38B0E4'>Species</font></b>"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: steelblue; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=FALSE
                                    ),
                                    div(
                                        class="d-flex justify-content-end",
                                        actionButton(
                                            inputId="confirm_paralog_ks_go",
                                            "Confirm analysis",
                                            title="Confirm the selection",
                                            class="my-confirm-button-class",
                                            status="secondary",
                                            style="color: #fff;
                                                   background-color: #C0C0C0;
                                                   border-color: #fff;
                                                   margin: 22px 0px 0px 0px; ",
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="orthologous_ks_button",
                                label=HTML("<font color='white'><b>&nbsp;Ortholog <i>K</i><sub>s</sub>&nbsp;&#x25BC;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font>"),
                                icon=icon("list"),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to choose species",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("ortholog_ks_files_collapse"),
                            bs_collapse(
                                id="ortholog_ks_files_collapse",
                                content=tags$div(
                                    class="well",
                                    pickerInput(
                                        inputId="ortholog_ks_files_list_A",
                                        label=HTML("<b><font color='#38B0E4'>Reference Species</font></b>"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: steelblue; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=FALSE
                                    ),
                                    pickerInput(
                                        inputId="ortholog_ks_files_list_B",
                                        label=HTML("<b><font color='#B97D4B'>Species to Compare</font></b>"),
                                        options=list(
                                            title='Please select species below',
                                            `selected-text-format`="count > 1",
                                            `actions-box`=TRUE
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #B97D4B; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=TRUE
                                    ),
                                    div(
                                        class="d-flex justify-content-end",
                                        actionButton(
                                            inputId="confirm_ortholog_ks_go",
                                            "Confirm analysis",
                                            title="Confirm the selection",
                                            class="my-confirm-button-class",
                                            status="secondary",
                                            style="color: #fff;
                                                   background-color: #C0C0C0;
                                                   border-color: #fff;
                                                   margin: 22px 0px 0px 0px; ",
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="rate_correct_button",
                                label=HTML("<font color='white'><b>&nbsp;Rate Correction&nbsp;&#x25BC;</b></font>"),
                                icon=icon("list"),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to set",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("rate_correction_collapse"),
                            bs_collapse(
                                id="rate_correction_collapse",
                                content=tags$div(
                                    class="well",
                                    pickerInput(
                                        inputId="select_ref_species",
                                        label=HTML("Choose <b><font color='#54B4D3'>Reference</font></b> species:"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=character(0)
                                    ),
                                    pickerInput(
                                        inputId="select_outgroup_species",
                                        label=HTML("Choose <b><font color='#fc8d59'>Outgroup</font></b> species:"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=species_tree_df$Species,
                                        choicesOpt=list(
                                            content=lapply(species_tree_df$Species, function(choice) {
                                                choice <- gsub("_", " ", choice)
                                                paste0("<div style='color: #fc8d59; font-style: italic;'>", choice, "</div>")
                                            })
                                        )
                                    ),
                                    pickerInput(
                                        inputId="select_study_species",
                                        label=HTML("Choose <b><font color='#C699FF'>Other</font></b> species to analyze:"),
                                        options=list(
                                            title='Please select one or multiple species below',
                                            `selected-text-format`="count > 1",
                                            `actions-box`=TRUE
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #C699FF; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=TRUE
                                    ),
                                    hr(class="setting"),
                                    pickerInput(
                                        inputId="select_focal_species",
                                        label=HTML("Choose <b><font color='#54B4D3'>Focal</font></b> species to draw paralog <b><i>K</i><sub>s</sub></b> distribution (optional):"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #54B4D3; font-style: italic;'>", choice, "</div>")
                                            })
                                        )
                                    ),
                                    div(
                                        class="d-flex justify-content-end",
                                        actionButton(
                                            inputId="confirm_rate_correction_go",
                                            "Confirm analysis",
                                            title="Confirm the selection",
                                            class="my-confirm-button-class",
                                            status="secondary",
                                            style="color: #fff;
                                                   background-color: #C0C0C0;
                                                   border-color: #fff;
                                                   margin: 22px 0px 0px 0px; ",
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    }
})

observeEvent(input$ortholog_ks_files_list_A, {
    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }

    ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    names_df <- map_informal_name_to_latin_name(species_info_file[1])
    paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]
    species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
        replace_informal_name_to_latin_name(names_df, x)
    })
    selected_species <- input$ortholog_ks_files_list_A
    remaining_species <- setdiff(unlist(species_list), selected_species)
    updatePickerInput(
        session,
        "ortholog_ks_files_list_B",
        choices=remaining_species,
        choicesOpt=list(
            content=lapply(remaining_species, function(choice) {
                paste0("<div style='color: #B97D4B; font-style: italic;'>", choice, "</div>")
            })
        )
    )
})

observeEvent(input$rate_correct_button, {
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="none";')
})

observeEvent(input$paralogous_ks_button, {
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="none";')
})

observeEvent(input$orthologous_ks_button, {
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="block";')
    #shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.transition="height 0.5s ease-in-out";')
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="none";')
})

observe({
    observeEvent(input$treeOrderList, {
        num_rows <- length(input$treeOrderList) / 3
        num_cols <- 3
        species_tree_df <- matrix(
            input$treeOrderList,
            nrow=num_rows,
            ncol=num_cols,
            byrow=TRUE
        )

        species_tree_df <- species_tree_df[-nrow(species_tree_df), ]
        species_remaining <- sort(species_tree_df[, 1])

        updatePickerInput(
            session,
            "select_ref_species",
            choices=species_remaining,
            choicesOpt=list(
                content=lapply(species_remaining, function(choice) {
                    choice <- gsub("_", " ", choice)
                    paste0("<div style='color: #54B4D3; font-style: italic;'>", choice, "</div>")
                })
            )
        )
    })
})

observe({
    if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
        observeEvent(input$treeOrderList, {
            num_rows <- length(input$treeOrderList) / 3
            num_cols <- 3
            species_tree_df <- matrix(
                input$treeOrderList,
                nrow=num_rows,
                ncol=num_cols,
                byrow=TRUE
            )

            species_tree_df <- as.data.frame(species_tree_df)
            colnames(species_tree_df) <- c("Species", "id", "pId")
            species_tree_df$id <- as.numeric(species_tree_df$id)
            species_tree_df$pId <- as.numeric(species_tree_df$pId)

            under_score <- grepl("_", species_tree_df[1, 1])

            if( under_score ){
                bait_id <- species_tree_df[species_tree_df$Species == gsub(" ", "_", input$select_ref_species), "id"]
                bait_pId <- species_tree_df[species_tree_df$Species == gsub(" ", "_", input$select_ref_species), "pId"]
            }else{
                bait_id <- species_tree_df[species_tree_df$Species == gsub("_", " ", input$select_ref_species), "id"]
                bait_pId <- species_tree_df[species_tree_df$Species == gsub("_", " ", input$select_ref_species), "pId"]
            }

            filtered_df <- species_tree_df[species_tree_df$id > bait_id, ]
            if( filtered_df[1, "pId"] == bait_pId ){
                filtered_df <- filtered_df[-1, ]
            }
            updatePickerInput(
                session,
                "select_outgroup_species",
                choices=filtered_df$Species,
                choicesOpt=list(
                    content=lapply(filtered_df$Species, function(choice) {
                        choice <- gsub("_", " ", choice)
                        paste0("<div style='color: #fc8d59; font-style: italic;'>", choice, "</div>")
                    })
                )
            )

            observeEvent(input$select_outgroup_species, {
                outgroup_id <- species_tree_df[species_tree_df$Species == input$select_outgroup_species, "id"]
                outgroup_pId <- species_tree_df[species_tree_df$Species == input$select_outgroup_species, "pId"]
                filtered_study_df <- species_tree_df[(species_tree_df$id < outgroup_id) & (species_tree_df$Species != input$select_ref_species), ]
                if( nrow(filtered_study_df) > 0 && filtered_study_df[nrow(filtered_study_df), "pId"] == outgroup_pId ){
                    filtered_study_df <- filtered_study_df[-nrow(filtered_study_df), ]
                }
                updatePickerInput(
                    session,
                    "select_study_species",
                    choices=sort(filtered_study_df$Species),
                    choicesOpt=list(
                        content=lapply(sort(filtered_study_df$Species), function(choice) {
                            choice <- gsub("_", " ", choice)
                            paste0("<div style='color: #998ec3; font-style: italic;'>", choice, "</div>")
                        })
                    )
                )
            })
        })
    }
})

observeEvent(input$confirm_paralog_ks_go, {
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
    shinyjs::runjs("$('#confirm_paralog_ks_go').css('background-color', 'green');")
    updateActionButton(
        session,
        "confirm_paralog_ks_go",
        icon=icon("check")
    )

    setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_paralog_ks_go').css('background-color', '#C0C0C0');
              //$('#confirm_paralog_ks_go').empty();
        }, 12000);"

    shinyjs::runjs(setTimeoutFunction)

    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }

    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        paralog_species <- input$paralog_ks_files_list
        ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        # infer the peaks of paralog ks
        ksPeaksFile <- paste0(ksAnalysisDir, "/ksrates_wd/ksPeaks.xls")
        names_df <- map_informal_name_to_latin_name(species_info_file[1])

        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })

        paralog_ksfile_df <- data.frame(
            species=unlist(species_list),
            path=paralog_ksfiles
        )

        selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
        ks_file <- selected_paralog_ksfile_df$path
        ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

        if( file.exists(ks_anchor_file) ){
            output$data_choosing <- renderUI({
                fluidRow(
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="peaks_choice",
                                label=HTML("<font color='orange'>Peaks in</font>:"),
                                choices=c("Paranome", "Anchored pairs"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        ),
                    ),
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="gmm_choice",
                                label=HTML("<font color='orange'>GMM modelling</font>:"),
                                choices=c("Paranome", "Anchored pairs"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        ),
                    ),
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="sizer_choice",
                                label=HTML("<font color='orange'>Sizer modelling</font>:"),
                                choices=c("Paranome", "Anchored pairs"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        )
                    )
                )
            })
        }else{
            output$data_choosing <- renderUI({
                fluidRow(
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="peaks_choice",
                                label=HTML("<font color='orange'>Peaks in</font>:"),
                                choices=c("Paranome"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        ),
                    ),
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="gmm_choice",
                                label=HTML("<font color='orange'>GMM modelling</font>:"),
                                choices=c("Paranome"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        ),
                    ),
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="sizer_choice",
                                label=HTML("<font color='orange'>Sizer modelling</font>:"),
                                choices=c("Paranome"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        )
                    )
                )
            })
        }

        withProgress(message='Configure in progress', value=0, {
            output$ks_analysis_output <- renderUI({
                div(
                    class="boxLike",
                    style="background-color: #FDFFFF;
                           padding-bottom: 10px;
                           padding-top: 10px;",
                    column(
                        12,
                        h4(HTML("<b><font color='#9B3A4D'>Paralog <i>K</i><sub>s</sub></font> Age Distribution</b>"))
                    ),
                    div(
                        style="padding: 10px 10px 10px 10px;",
                        hr(class="setting"),
                        fluidRow(
                            column(
                                2,
                                h5(HTML("Select <b><font color='orange'>Data</b></font> for:"))
                            ),
                            column(
                                6,
                                uiOutput("data_choosing")
                            ),
                            column(
                                2,
                                actionButton(
                                    inputId="paralog_ks_plot_go",
                                    HTML("Start<br><b>paralog <i>K</i><sub>s</sub></b></br>analysis"),
                                    icon=icon("play"),
                                    status="secondary",
                                    title="Click to start",
                                    class="my-start-button-class",
                                    style="color: #fff;
                                           background-color: #27ae60;
                                           border-color: #fff;
                                           padding: 5px 14px 5px 14px;
                                           margin: 5px 5px 5px 5px;"
                                )
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                2,
                                h5(HTML("<b><font color='orange'><i>K</i><sub>s</sub> </font></b> setting:")),
                            ),
                            column(
                                10,
                                fluidRow(
                                    column(
                                        2,
                                        div(
                                            style="padding: 12px 10px 5px 10px;
                                                   border-radius: 10px;
                                                   background-color: #FFF5EE;",
                                            pickerInput(
                                                inputId="plot_mode_option_paralog",
                                                label=HTML("<font color='orange'><i>K</i><sub>s</sub> Mode</font>:"),
                                                choices=c("weighted", "average", "min", "pairwise"),
                                                multiple=FALSE,
                                                selected="weighted",
                                                inline=TRUE
                                            )
                                        )
                                    ),
                                    column(
                                        4,
                                        div(
                                            style="/*display: flex; align-items: center;*/
                                                   margin-bottom: -10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                            sliderInput(
                                                inputId="ks_binWidth_paralog",
                                                label=HTML("<font color='orange'>BinWidth</font>:&nbsp;"),
                                                min=0,
                                                max=0.2,
                                                step=0.01,
                                                value=0.1
                                            )
                                        )
                                    ),
                                    column(
                                        4,
                                        div(
                                            style="/*display: flex; align-items: center; */
                                                   margin-bottom: -10px;                                                   border-radius: 10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                            sliderInput(
                                                inputId="ks_maxK_paralog",
                                                label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
                                                min=0,
                                                step=1,
                                                max=10,
                                                value=5
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                9,
                                fluidRow(
                                    column(
                                        6,
                                        tags$style(
                                            HTML(".rotate-135 {
                                                transform: rotate(135deg);
                                            }"),
                                            HTML(".rotate-45{
                                                transform: rotate(45deg);
                                            }")
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_add",
                                            "",
                                            icon("arrows-alt-v"),
                                            title="Expand vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-135"
                                            ),
                                            title="Compress vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_add",
                                            "",
                                            icon("arrows-alt-h"),
                                            title="Expand horizontal spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-45"
                                            ),
                                            title="Compress horizontal spacing"
                                        ),
                                        downloadButton_custom(
                                            "ksPlotParalogousDownload",
                                            title="Download the Plot",
                                            status="secondary",
                                            icon=icon("download"),
                                            label=".svg",
                                            class="my-download-button-class",
                                            style="color: #fff;
                                                  background-color: #6B8E23;
                                                  border-color: #fff;
                                                  padding: 5px 5px 5px 5px;"
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    fluidRow(
                        column(
                            12,
                            div(
                                id="Wgd_plot_paralog"
                            )
                        )
                    ),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            2,
                            h5(HTML("<b><font color='orange'>Figure</b></font> setting:")),
                        ),
                        column(
                            10,
                            fluidRow(
                                column(
                                    4,
                                    div(
                                        style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                        sliderInput(
                                            inputId="y_limit_paralog",
                                            label=HTML("Set the <font color='orange'>Y axis limit</font>:"),
                                            min=0,
                                            max=10000,
                                            step=500,
                                            value=2000
                                        ),
                                    )
                                ),
                                column(
                                    4,
                                    div(
                                        style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                        pickerInput(
                                            inputId="gmm_comp_paralog",
                                            label=HTML("<font color='orange'>Choose GMM component</font>:&nbsp;"),
                                            options=list(
                                                title='Please select component below'
                                            ),
                                            choices=list(),
                                            selected=NULL,
                                            multiple=FALSE
                                        ),
                                    )
                                )
                                # column(
                                #     4,
                                #     div(
                                #         style="padding: 12px 10px 5px 10px;
                                #                border-radius: 10px;
                                #                background-color: #F0FFFF",
                                #         sliderInput(
                                #             inputId="gmm_comp_paralog",
                                #             label=HTML("<font color='orange'>Choose GMM component</font>:&nbsp;"),
                                #             min=0,
                                #             step=1,
                                #             max=10,
                                #             value=3
                                #         )
                                #     )
                                # ),
                                # column(
                                #     2,
                                #     div(
                                #         style="padding: 12px 10px 5px 10px;
                                #                border-radius: 10px;
                                #                background-color: #F0FFFF",
                                #         HTML("Add the <font color='orange'>GMM modelling lines</font>:"),
                                #         prettyToggle(
                                #             inputId="add_gmm_mode_lines",
                                #             label_on="Yes!",
                                #             icon_on=icon("check"),
                                #             status_on="info",
                                #             status_off="warning",
                                #             label_off="No..",
                                #             icon_off=icon("remove", verify_fa=FALSE)
                                #         )
                                #     )
                                # )
                            )
                        ),
                    ),
                    fluidRow(
                        column(
                            12,
                            uiOutput("ks_peak_table_output")
                        )
                    )
                )
            })

            Sys.sleep(.2)
            incProgress(amount=.5, message="Configure done ...")
            incProgress(amount=1)
            Sys.sleep(.1)
        })
    }
    else{
        shinyalert(
            "Oops!",
            "Fail to access the output of shinyWGD. Please ensure that all the results of shinyWGD were generated successfully!",
            type="error"
        )
    }
})

observeEvent(input$paralog_ks_plot_go, {
    #shinyjs::runjs('document.getElementById("Wgd_plot_paralog").innerHTML="";')
    withProgress(message='Analyzing in progress', value=0, {
        if( is.null(buttonClicked()) ){
            ksAnalysisDir <- ks_example_dir
        }
        else if( buttonClicked() == "fileInput" ){
            ksAnalysisDir <- ks_analysis_dir_Val()
        }
        else if( buttonClicked() == "actionButton" ){
            ksAnalysisDir <- ks_example_dir
        }

        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        if( file.exists(species_info_file[1]) ){
            paralog_species <- input$paralog_ks_files_list
            ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
            species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
            ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
            paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

            names_df <- map_informal_name_to_latin_name(species_info_file[1])

            species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
                replace_informal_name_to_latin_name(names_df, x)
            })

            paralog_ksfile_df <- data.frame(
                species=unlist(species_list),
                path=paralog_ksfiles)

            # infer the peaks of paralog ks
            ksPeaksFile <- paste0(ksAnalysisDir, "/ksrates_wd/ksPeaks.xls")
            if( !(file.exists(ksPeaksFile)) ){
                selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
                withProgress(message='Inference the Peaks of the paralog Ks in progress', value=0, {
                    maxK <- input[["ks_maxK_paralog"]]
                    peaks_df <- data.frame()
                    selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
                    ks_file <- selected_paralog_ksfile_df$path
                    ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

                    incProgress(
                        amount=0.4,
                        message=paste0("Find peaks for ", selected_paralog_ksfile_df$species, " ...")
                    )

                    if( input$peaks_choice == "Paranome" ){
                        raw_df <- read.table(
                            ks_file,
                            header=TRUE,
                            sep="\t"
                        )
                        raw_ks <- raw_df[raw_df$Ks>=0 & raw_df$Ks<=maxK, ]$Ks
                        all_peaks <- PeaksInKsDistributionValues(raw_ks, peak.maxK=3)
                        bs_CI_list <- c()
                        for( i in 1:length(all_peaks) ){
                            bootPeak <- bootStrapPeaks(raw_ks, peak.index=i, rep=500, peak.maxK=3)
                            bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                            bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                            bs_CI_list <- c(bs_CI_list, bs_CI)
                        }
                        peaks_df <- data.frame(
                            species=rep(selected_paralog_ksfile_df$species, length(all_peaks)),
                            peak_in="Paranome",
                            peak=format(all_peaks, nsmall=2),
                            CI=bs_CI_list
                        )
                    }
                    else{
                        anchors_df <- read.table(
                            ks_anchor_file,
                            header=TRUE,
                            sep="\t"
                        )
                        anchors_ks <- anchors_df[anchors_df$Ks>=0 & anchors_df$Ks<=maxK, ]$Ks
                        anchors_peaks <- PeaksInKsDistributionValues(anchors_ks, peak.maxK=3)
                        bs_CI_list <- c()
                        for( i in 1:length(anchors_peaks) ){
                            bootPeak <- bootStrapPeaks(anchors_ks, peak.index=i, rep=500, peak.maxK=3)
                            bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                            bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                            bs_CI_list <- c(bs_CI_list, bs_CI)
                        }
                        peaks_df <- data.frame(
                            species=rep(selected_paralog_ksfile_df$species, length(anchors_peaks)),
                            peak_in="Anchor pairs",
                            peak=anchors_peaks,
                            CI=bs_CI_list
                        )
                    }

                    col_names <- c("Species",  "Peak in", "Peak", "95% Confidence Interval")
                    colnames(peaks_df) <- col_names
                    write.table(
                        peaks_df,
                        file=ksPeaksFile,
                        row.names=FALSE,
                        sep="\t",
                        quote=FALSE
                    )
                    Sys.sleep(.2)
                    incProgress(amount=.2, message="Find peaks done")
                })
            }
            else{
                peaksInfo <- read.table(
                    ksPeaksFile,
                    header=TRUE,
                    sep="\t"
                )
                tested_species <- unique(peaksInfo$Species)

                if( !(all(input$paralog_ks_files_list %in% tested_species)) ){
                    need_to_test_speices <- setdiff(input$paralog_ks_files_list, tested_species)
                    selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% need_to_test_speices, ]
                    withProgress(message='Inference the Peaks of the paralog Ks in progress', value=0, {
                        maxK <- input[["ks_maxK_paralog"]]
                        peaks_df <- data.frame()
                        selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
                        ks_file <- selected_paralog_ksfile_df$path
                        ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

                        incProgress(
                            amount=0.4,
                            message=paste0("Find peaks for ", selected_paralog_ksfile_df$species, " ...")
                        )

                        if( input$peaks_choice == "Paranome" ){
                            raw_df <- read.table(
                                ks_file,
                                header=TRUE,
                                sep="\t"
                            )
                            raw_ks <- raw_df[raw_df$Ks>=0 & raw_df$Ks<=maxK, ]$Ks
                            all_peaks <- PeaksInKsDistributionValues(raw_ks, peak.maxK=3)
                            bs_CI_list <- c()
                            for( i in 1:length(all_peaks) ){
                                bootPeak <- bootStrapPeaks(raw_ks, peak.index=i, rep=500, peak.maxK=3)
                                bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                                bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                                bs_CI_list <- c(bs_CI_list, bs_CI)
                            }
                            peaks_df <- data.frame(
                                species=rep(selected_paralog_ksfile_df$species, length(all_peaks)),
                                peak_in="Paranome",
                                peak=format(all_peaks, nsmall=2),
                                CI=bs_CI_list
                            )
                        }
                        else{
                            anchors_df <- read.table(
                                ks_anchor_file,
                                header=TRUE,
                                sep="\t"
                            )
                            anchors_ks <- anchors_df[anchors_df$Ks>=0 & anchors_df$Ks<=maxK, ]$Ks
                            anchors_peaks <- PeaksInKsDistributionValues(anchors_ks, peak.maxK=3)
                            bs_CI_list <- c()
                            for( i in 1:length(anchors_peaks) ){
                                bootPeak <- bootStrapPeaks(anchors_ks, peak.index=i, rep=500, peak.maxK=3)
                                bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                                bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                                bs_CI_list <- c(bs_CI_list, bs_CI)
                            }
                            peaks_df <- data.frame(
                                species=rep(selected_paralog_ksfile_df$species, length(anchors_peaks)),
                                peak_in="Anchor pairs",
                                peak=anchors_peaks,
                                CI=bs_CI_list
                            )
                        }

                        col_names <- c("Species",  "Peak in", "Peak", "95% Confidence Interval")
                        colnames(peaks_df) <- col_names
                        write.table(
                            peaks_df,
                            file=ksPeaksFile,
                            row.names=FALSE,
                            col.names=FALSE,
                            sep="\t",
                            quote=FALSE,
                            append=TRUE
                        )
                        Sys.sleep(.2)
                        incProgress(amount=.2, message="Find peaks done")
                    })
                }

                peaksInfo <- read.table(
                    ksPeaksFile,
                    header=TRUE,
                    sep="\t"
                )

                output$ks_peak_table_output <- renderUI({
                    selected_peaks_info <- peaksInfo[peaksInfo$Species %in% input$paralog_ks_files_list, ]
                    output$ks_peak_table_output <- renderUI({
                        fluidRow(
                            column(
                                12,
                                hr(class="splitting")
                            ),
                            column(
                                8,
                                fluidRow(
                                    column(
                                        6,
                                        h4(HTML("<b><font color='#9B3A4D'>Paralog <i>K</i><sub>s</sub></font></b> Peaks"))
                                    ),
                                    column(
                                        12,
                                        selected_peaks_info %>%
                                            setNames(., colnames(.) %>% gsub("X95\\.\\.Confidence\\.Interval", "95% Confidence Interval", .)) %>%
                                            setNames(., colnames(.) %>% gsub("Peak\\.In", "Peak In", .)) %>%
                                            datatable(
                                                options=list(
                                                    searching=TRUE
                                                ),
                                                rownames=FALSE
                                            ) %>%
                                            formatStyle(
                                                "Species",
                                                fontWeight='bold',
                                                fontStyle="italic"
                                            )
                                    ),
                                    column(
                                        12,
                                        div(class="float-right",
                                            downloadButton_custom(
                                                "ksPeakCsvDownload",
                                                title="Download the Peaks info Table",
                                                status="secondary",
                                                icon=icon("download"),
                                                label=".csv",
                                                class="my-download-button-class",
                                                style="color: #fff;
                                                      background-color: #6B8E23;
                                                      border-color: #fff;
                                                      padding: 5px 14px 5px 14px;
                                                      margin: 5px 5px 5px 5px;"
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    })
                })

                output$ksPeakCsvDownload <- downloadHandler(
                    filename=function() {
                        "peaksInfo.csv"
                    },
                    content=function(file) {
                        write.csv(peaksInfo, file)
                    }
                )
            }

            selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
            files_list <- selected_paralog_ksfile_df$path
            ks_file <- selected_paralog_ksfile_df$path
            ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

            if( file.exists(ks_anchor_file) ){
                files_list_new <- c(ks_file, ks_anchor_file)
            }else{
                files_list_new <- c(ks_file)
            }
            full_data <- calculateKsDistribution4wgd_multiple(
                files_list_new,
                plot.mode=input[["plot_mode_option_paralog"]],
                maxK=input[["ks_maxK_paralog"]],
                binWidth=input[["ks_binWidth_paralog"]],
            )
            barData <- full_data$bar
            ksDist <- full_data$density

            paralogSpecies <- files_list[grep("paralog_distributions", files_list)]
            paralog_id <- gsub(".ks.tsv$", "", basename(paralogSpecies))

            Sys.sleep(.2)
            incProgress(amount=.2, message="GMM modelling ...")

            ks.mclust <- data.frame()
            ks.sizer <- list()
            if( input$gmm_choice == "Paranome" ){
                ks_title <- gsub(".tsv$", "", basename(ks_file))
            }else{
                ks_title <- gsub(".tsv$", "", basename(ks_anchor_file))
            }
            ks_data <- ksDist[ksDist$title == ks_title, ]
            ks_value <- ks_data$ks

            Sys.sleep(.2)
            incProgress(
                amount=0.2,
                message=paste0("GMM modelling for ", ks_title, " ...")
            )

            # GMM modelling
            gmm_pre_outfile <- paste0(dirname(ks_file), "/", ks_title, ".gmm.Rdata")
            if( file.exists(gmm_pre_outfile) ){
                load(gmm_pre_outfile)
            }else{
                df <- ks_mclust_v2(ks_value)
                save(df, file=gmm_pre_outfile)
            }
            df$title <- ks_title
            ks.mclust <- rbind(ks.mclust, df)
            ks.bic <- unique(ks.mclust[, c("title", "comp", "BIC")])
            emmix_outfile <- paste0(dirname(ks_file), "/", ks_title, ".emmix.output.xls")
            if( !file.exists(emmix_outfile) ){
                write.table(
                    ks.mclust,
                    file=emmix_outfile,
                    row.names=FALSE,
                    sep="\t",
                    quote=FALSE
                )
            }

            gmm_BIC_df <- unique(ks.mclust[, c("comp", "BIC")])
            gmm_BIC_list <- sapply(1:nrow(gmm_BIC_df), function(i) {
                paste0(
                    "comp: <b>",
                    gmm_BIC_df[i, "comp"],
                    "</b>, BIC: <b>",
                    round(gmm_BIC_df[i, "BIC"], 3),
                    "</b>"
                )
            }, simplify="list")

            updatePickerInput(
                session,
                "gmm_comp_paralog",
                choices=gmm_BIC_list,
                choicesOpt=list(
                    content=lapply(gmm_BIC_list, function(choice) {
                        HTML(choice)
                    })
                )
            )

            incProgress(
                amount=0.3,
                message=paste0("SiZer modelling for ", ks_title, " ...")
            )

            #Sizer modelling
            sizer_pre_outfile <- paste0(dirname(ks_file), "/", ks_title, ".sizer.Rdata")
            if( file.exists(sizer_pre_outfile) ){
                load(sizer_pre_outfile)
            }
            else{
                if( input$gmm_choice == "Paranome" ){
                    ks_file_tmp <- ks_file
                }else{
                    ks_file_tmp <- ks_anchor_file
                }
                ksd_tmp <- read.wgd_ksd(ks_file_tmp)
                ks_value_tmp <- ksd_tmp$ks_dist$Ks[ksd_tmp$ks_dist$Ks <= input[["ks_maxK_paralog"]]]
                df_sizer <- SiZer(
                    ks_value_tmp,
                    gridsize=c(500, 50),
                    bw=c(0.01, 5)
                )
                save(df_sizer, file=sizer_pre_outfile)
            }

            ks.sizer[[ks_title]] <- list(
                species=ks_title,
                sizer=df_sizer$sizer,
                map=df_sizer$map,
                bw=df_sizer$bw
            )

            Sys.sleep(.2)
            incProgress(amount=.5, message="Calculating done...")

            widthSpacing <- reactiveValues(
                value=1000
            )
            heightSpacing <- reactiveValues(
                value=500
            )

            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightSpacing$value <- heightSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightSpacing$value <- heightSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthSpacing$value <- widthSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthSpacing$value <- widthSpacing$value - 50
            })

            observe({
                selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[["ks_maxK_paralog"]], ]
                names_df <- map_informal_name_to_latin_name(species_info_file[1])

                if( isTruthy(input$gmm_comp_paralog) && input$gmm_comp_paralog != "" ){
                    selected_comp <- as.numeric(
                        regmatches(input$gmm_comp_paralog, regexpr("\\d+", input$gmm_comp_paralog))
                    )

                    ksMclust <- ks.mclust %>%
                        filter(comp == selected_comp) %>%
                        ungroup()

                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_paralog",
                        "species_list"=names_df,
                        "ks_title"=ks_title,
                        "ks_bar_df"=selectedBarData,
                        "paralog_id"=paralog_id,
                        "mclust_df"=ksMclust,
                        "sizer_list"=ks.sizer,
                        "xlim"=input[["ks_maxK_paralog"]],
                        "ylim"=input[["y_limit_paralog"]],
                        "color"="",
                        "opacity"=input[["ks_transparency_paralog"]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                }else{
                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_paralog",
                        "species_list"=names_df,
                        "ks_title"=ks_title,
                        "ks_bar_df"=selectedBarData,
                        "paralog_id"=paralog_id,
                        #"mclust_df"=ksMclust,
                        "sizer_list"=ks.sizer,
                        "xlim"=input[["ks_maxK_paralog"]],
                        "ylim"=input[["y_limit_paralog"]],
                        "color"="",
                        "opacity"=input[["ks_transparency_paralog"]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                }
                session$sendCustomMessage("Paralog_Bar_Plotting", plot_wgd_data)
            })
        }
        Sys.sleep(.2)
        incProgress(amount=.4, message="Ploting done...")
    })
})

observeEvent(input$confirm_ortholog_ks_go, {
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
    shinyjs::runjs("$('#confirm_ortholog_ks_go').css('background-color', 'green');")
    updateActionButton(
        session,
        "confirm_ortholog_ks_go",
        icon=icon("check")
    )

    setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_ortholog_ks_go').css('background-color', '#C0C0C0');
              //$('#confirm_ortholog_ks_go').empty();
        }, 6000);"

    shinyjs::runjs(setTimeoutFunction)

    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }

    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        paralog_species <- input$paralog_ks_files_list
        ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        # infer the peaks of paralog ks
        ksPeaksFile <- paste0(ksAnalysisDir, "/ksrates_wd/ksPeaks.xls")
        names_df <- map_informal_name_to_latin_name(species_info_file[1])

        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })

        paralog_ksfile_df <- data.frame(
            species=unlist(species_list),
            path=paralog_ksfiles
        )
        selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
        ks_file <- selected_paralog_ksfile_df$path
        ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

        withProgress(message='Configure in progress', value=0, {
            output$ks_analysis_output <- renderUI({
                div(
                    class="boxLike",
                    style="background-color: #FDFFFF;
                           padding-bottom: 10px;
                           padding-top: 10px;",
                    column(
                        12,
                        h4(HTML("<b><font color='#9B3A4D'>Ortholog <i>K</i><sub>s</sub></font> Age Distribution</b>"))
                    ),
                    div(
                        style="padding: 10px 10px 10px 10px;",
                        hr(class="setting"),
                        fluidRow(
                            column(
                                2,
                                h5(HTML("<b><font color='orange'><i>K</i><sub>s</sub> </font></b> setting:")),
                            ),
                            column(
                                10,
                                fluidRow(
                                    column(
                                        4,
                                        div(
                                            style="/*display: flex; align-items: center; */
                                                   margin-bottom: -10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                            sliderInput(
                                                inputId="ks_maxK_ortholog",
                                                label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
                                                min=0,
                                                step=1,
                                                max=10,
                                                value=5
                                            )
                                        )
                                    ),
                                    column(
                                        3,
                                        actionButton(
                                            inputId="ortholog_ks_plot_go",
                                            HTML("Start<br><b>ortholog <i>K</i><sub>s</sub></b></br>analysis"),
                                            icon=icon("play"),
                                            status="secondary",
                                            class="my-start-button-class",
                                            title="Click to start",
                                            style="color: #fff;
                                                   background-color: #27ae60;
                                                   border-color: #fff;
                                                   padding: 5px 14px 5px 14px;
                                                   margin: 5px 5px 5px 5px;"
                                        )
                                    )
                                )
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                9,
                                fluidRow(
                                    column(
                                        6,
                                        tags$style(
                                            HTML(".rotate-135 {
                                                transform: rotate(135deg);
                                            }"),
                                            HTML(".rotate-45{
                                                transform: rotate(45deg);
                                            }")
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_add",
                                            "",
                                            icon("arrows-alt-v"),
                                            title="Expand vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-135"
                                            ),
                                            title="Compress vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_add",
                                            "",
                                            icon("arrows-alt-h"),
                                            title="Expand horizontal spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-45"
                                            ),
                                            title="Compress horizontal spacing"
                                        ),
                                        downloadButton_custom(
                                            "ksPlotOrthologousDownload",
                                            title="Download the Plot",
                                            status="secondary",
                                            icon=icon("download"),
                                            class="my-download-button-class",
                                            label=".svg",
                                            style="color: #fff;
                                                  background-color: #6B8E23;
                                                  border-color: #fff;
                                                  padding: 5px 5px 5px 5px;"
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    fluidRow(
                        column(
                            12,
                            div(
                                id="Wgd_plot_ortholog"
                            )
                        )
                    ),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            2,
                            h5(HTML("<b><font color='orange'>Figure</b></font> setting:")),
                        ),
                        column(
                            10,
                            fluidRow(
                                column(
                                    4,
                                    div(
                                        style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                        sliderInput(
                                            inputId="y_limit_ortholog",
                                            label=HTML("Set the <font color='orange'>Y axis limit</font>:"),
                                            min=0,
                                            step=0.2,
                                            max=5,
                                            value=2
                                        ),
                                    )
                                ),
                                column(
                                    4,
                                    div(
                                        style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                        sliderInput(
                                            inputId="opacity_paralog",
                                            label=HTML("Set the <font color='orange'>Transparency</font>:"),
                                            min=0,
                                            max=1,
                                            step=0.1,
                                            value=0.5
                                        )
                                    )
                                )
                            )
                        ),
                    )
                )
            })

            Sys.sleep(.2)
            incProgress(amount=.5, message="Configure done ...")
            incProgress(amount=1)
            Sys.sleep(.1)
        })
    }
    else{
        shinyalert(
            "Oops!",
            "Fail to access the output of shinyWGD. Please ensure that all the results of shinyWGD were generated successfully!",
            type="error"
        )
    }
})

observeEvent(input$ortholog_ks_plot_go, {
    #shinyjs::runjs('document.getElementById("Wgd_plot_ortholog").innerHTML="";')
    withProgress(message='Analyzing in progress', value=0, {
        # session$sendCustomMessage("Progress_Bar_Update", "")
        if( is.null(buttonClicked()) ){
            ksAnalysisDir <- ks_example_dir
        }
        else if( buttonClicked() == "fileInput" ){
            ksAnalysisDir <- ks_analysis_dir_Val()
        }
        else if( buttonClicked() == "actionButton" ){
            ksAnalysisDir <- ks_example_dir
        }

        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        if( file.exists(species_info_file[1]) ){
            paralog_species <- input$paralog_ks_files_list
            ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
            species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
            ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
            paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

            names_df <- map_informal_name_to_latin_name(species_info_file[1])

            widthSpacing <- reactiveValues(
                value=600
            )
            heightSpacing <- reactiveValues(
                value=350
            )
            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightSpacing$value <- heightSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightSpacing$value <- heightSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthSpacing$value <- widthSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthSpacing$value <- widthSpacing$value - 50
            })

            speciesA <- input$ortholog_ks_files_list_A
            speciesB <- input$ortholog_ks_files_list_B

            matching_A <- which(names_df$latin_name == gsub("_", " ", speciesA))
            speciesA_informal_name <- names_df$informal_name[matching_A]
            speciesA_files <- ortholog_ksfiles[grepl(speciesA_informal_name, ortholog_ksfiles)]

            files_list <- c()

            for( i in 1:length(speciesB) ){
                pattenEach <- which(names_df$latin_name == gsub("_", " ", speciesB[[i]]))
                each_informal_name <- names_df$informal_name[pattenEach]
                species_A_B_file <- speciesA_files[grepl(each_informal_name, speciesA_files)]
                files_list <- c(files_list, species_A_B_file)
            }

            full_data <- calculateKsDistribution4wgd_multiple(
                files_list,
                maxK=input[["ks_maxK_ortholog"]],
            )
            denData <- full_data$density

            Sys.sleep(.2)
            incProgress(amount=.4, message="Calculating done...")

            observe({
                selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[["ks_maxK_ortholog"]], ]
                plot_wgd_data <- list(
                    "plot_id"="Wgd_plot_ortholog",
                    "ks_density_df"=selectedDenData,
                    "xlim"=input[["ks_maxK_ortholog"]],
                    "ylim"=input[["y_limit_ortholog"]],
                    "names_df"=names_df,
                    "color"="",
                    "opacity"=input[["opacity_paralog"]],
                    "width"=widthSpacing$value,
                    "height"=heightSpacing$value
                )
                session$sendCustomMessage("Otholog_Density_Plotting", plot_wgd_data)
            })
            Sys.sleep(.2)
            incProgress(amount=.4, message="Ploting done...")
        }
    })
})

observeEvent(input$confirm_rate_correction_go, {
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
    shinyjs::runjs("$('#confirm_rate_correction_go').css('background-color', 'green');")
    updateActionButton(
        session,
        "confirm_rate_correction_go",
        icon=icon("check")
    )

    setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_rate_correction_go').css('background-color', '#C0C0C0');
              //$('#confirm_rate_correction_go').empty();
        }, 6000);"

    shinyjs::runjs(setTimeoutFunction)

    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }

    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        paralog_species <- input$paralog_ks_files_list
        ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        names_df <- map_informal_name_to_latin_name(species_info_file[1])

        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })

        paralog_ksfile_df <- data.frame(
            species=unlist(species_list),
            path=paralog_ksfiles
        )
        selected_paralog_ksfile_df <- paralog_ksfile_df[paralog_ksfile_df$species %in% input$paralog_ks_files_list, ]
        ks_file <- selected_paralog_ksfile_df$path
        ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

        withProgress(message='Configure in progress', value=0, {
            output$ks_analysis_output <- renderUI({
                div(
                    class="boxLike",
                    style="background-color: #FDFFFF;
                           padding-bottom: 10px;
                           padding-top: 10px;",
                    fluidRow(
                        column(
                            5,
                            h4(HTML("<b><font color='#91cf60'>Substitution Rate Correction</font></b>"))
                        ),
                        column(
                            6,
                            actionButton(
                                inputId="rate_plot_go",
                                HTML("Start <b>rate correction</b> analysis"),
                                icon=icon("play"),
                                status="secondary",
                                title="Click to start",
                                class="my-start-button-class",
                                style="color: #fff;
                                   background-color: #27ae60;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;"
                            )
                        )
                    ),
                    div(
                        style="padding: 10px 10px 10px 10px;",
                        hr(class="setting"),
                        fluidRow(
                            column(
                                2,
                                h5(HTML("<b><font color='orange'><i>K</i><sub>s</sub> </font></b> setting:")),
                            ),
                            column(
                                10,
                                uiOutput("rate_ks_setting")
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                9,
                                fluidRow(
                                    column(
                                        6,
                                        tags$style(
                                            HTML(".rotate-135 {
                                                transform: rotate(135deg);
                                            }"),
                                            HTML(".rotate-45{
                                                transform: rotate(45deg);
                                            }")
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_add",
                                            "",
                                            icon("arrows-alt-v"),
                                            title="Expand vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_vertical_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-135"
                                            ),
                                            title="Compress vertical spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_add",
                                            "",
                                            icon("arrows-alt-h"),
                                            title="Expand horizontal spacing"
                                        ),
                                        actionButton(
                                            "ks_svg_horizontal_spacing_sub",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-45"
                                            ),
                                            title="Compress horizontal spacing"
                                        ),
                                        downloadButton_custom(
                                            "ksPlotRateDownload",
                                            title="Download the Plot",
                                            status="secondary",
                                            icon=icon("download"),
                                            class="my-download-button-class",
                                            label=".svg",
                                            style="color: #fff;
                                                  background-color: #6B8E23;
                                                  border-color: #fff;
                                                  padding: 5px 5px 5px 5px;"
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    fluidRow(
                        column(
                            12,
                            div(
                                id="Wgd_plot_rate"
                            )
                        )
                    ),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            2,
                            h5(HTML("<b><font color='orange'>Figure</b></font> setting:")),
                        ),
                        column(
                            10,
                            uiOutput("rate_figure_setting")
                        )
                    )
                )
            })

            if( isTruthy(input$select_focal_species) & input$select_focal_species != ""  ){
                output$rate_ks_setting <- renderUI({
                    fluidRow(
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                                   border-radius: 10px;
                                                   background-color: #FFF5EE;",
                                pickerInput(
                                    inputId="plot_mode_option_rate",
                                    label=HTML("<font color='orange'><i>K</i><sub>s</sub> Mode</font>:"),
                                    choices=c("weighted", "average", "min", "pairwise"),
                                    multiple=FALSE,
                                    selected="weighted",
                                    inline=TRUE
                                )
                            )
                        ),
                        column(
                            4,
                            div(
                                style="/*display: flex; align-items: center;*/
                                                   margin-bottom: -10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                sliderInput(
                                    inputId="ks_binWidth_rate",
                                    label=HTML("<font color='orange'>BinWidth</font>:&nbsp;"),
                                    min=0,
                                    max=0.2,
                                    step=0.01,
                                    value=0.1
                                )
                            )
                        ),
                        column(
                            4,
                            div(
                                style="/*display: flex; align-items: center; */
                                                   margin-bottom: -10px;                                                   border-radius: 10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                sliderInput(
                                    inputId="ks_maxK_rate",
                                    label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
                                    min=0,
                                    step=1,
                                    max=10,
                                    value=5
                                )
                            )
                        )
                    )
                })

                output$rate_figure_setting <- renderUI({
                    fluidRow(
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                sliderInput(
                                    inputId="y1_limit_rate",
                                    label=HTML("Set the <font color='orange'>Y1 axis limit</font>:"),
                                    min=0,
                                    step=500,
                                    max=8000,
                                    value=1500
                                ),
                            )
                        ),
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                sliderInput(
                                    inputId="y2_limit_rate",
                                    label=HTML("Set the <font color='orange'>Y2 axis limit</font>:"),
                                    min=0,
                                    step=0.2,
                                    max=5,
                                    value=2
                                ),
                            )
                        ),
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                sliderInput(
                                    inputId="opacity_rate",
                                    label=HTML("Set the <font color='orange'>Transparency</font>:"),
                                    min=0,
                                    max=1,
                                    step=0.1,
                                    value=0.5
                                )
                            )
                        )
                    )
                })
            }
            else{
                output$rate_ks_setting <- renderUI({
                    fluidRow(
                        column(
                            4,
                            div(
                                style="/*display: flex; align-items: center; */
                                                   margin-bottom: -10px;                                                   border-radius: 10px;
                                                   border-radius: 10px;
                                                   padding: 10px 10px 0px 10px;
                                                   background-color: #FFF5EE;",
                                sliderInput(
                                    inputId="ks_maxK_rate",
                                    label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
                                    min=0,
                                    step=1,
                                    max=10,
                                    value=5
                                )
                            )
                        )
                    )
                })

                output$rate_figure_setting <- renderUI({
                    fluidRow(
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                sliderInput(
                                    inputId="y1_limit_rate",
                                    label=HTML("Set the <font color='orange'>Y axis limit</font>:"),
                                    min=0,
                                    step=0.2,
                                    max=5,
                                    value=2
                                ),
                            )
                        ),
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFFF",
                                sliderInput(
                                    inputId="opacity_rate",
                                    label=HTML("Set the <font color='orange'>Transparency</font>:"),
                                    min=0,
                                    max=1,
                                    step=0.1,
                                    value=0.5
                                )
                            )
                        )
                    )
                })
            }


            Sys.sleep(.2)
            incProgress(amount=.5, message="Configure done ...")
            incProgress(amount=1)
            Sys.sleep(.1)
        })
    }
    else{
        shinyalert(
            "Oops!",
            "Fail to access the output of shinyWGD. Please ensure that all the results of shinyWGD were generated successfully!",
            type="error"
        )
    }
})

observeEvent(input$rate_plot_go, {
    shinyjs::runjs("$('#confirm_rate_correction_go').css('background-color', 'green');")
    updateActionButton(
        session,
        "confirm_rate_correction_go",
        icon=icon("check")
    )

    if( is.null(buttonClicked()) ){
        ksAnalysisDir <- ks_example_dir
    }
    else if( buttonClicked() == "fileInput" ){
        ksAnalysisDir <- ks_analysis_dir_Val()
    }
    else if( buttonClicked() == "actionButton" ){
        ksAnalysisDir <- ks_example_dir
    }

    species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        paralog_species <- input$paralog_ks_files_list
        ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        names_df <- map_informal_name_to_latin_name(species_info_file[1])

        withProgress(message='Analyzing in progress', value=0, {
            widthSpacing <- reactiveValues(
                value=600
            )
            heightSpacing <- reactiveValues(
                value=350
            )
            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightSpacing$value <- heightSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightSpacing$value <- heightSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthSpacing$value <- widthSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthSpacing$value <- widthSpacing$value - 50
            })

            ks_selected_files <- c()

            refSpecies <- input$select_ref_species
            outgroupSpecies <- input$select_outgroup_species
            studySpecies <- input$select_study_species

            matching_ref <- which(names_df$latin_name == gsub("_", " ", refSpecies))
            ref_informal_name <- names_df$informal_name[matching_ref]

            matching_outgroup <- which(names_df$latin_name == gsub("_", " ", outgroupSpecies))
            outgroup_informal_name <- names_df$informal_name[matching_outgroup]

            ref2outgroupFile <- ortholog_ksfiles[grepl(ref_informal_name, ortholog_ksfiles) & grepl(outgroup_informal_name, ortholog_ksfiles)]
            ks_selected_files <- c(ks_selected_files, ref2outgroupFile)

            mode_df <- data.frame()
            for( i in 1:length(studySpecies) ){
                pattenEach <- which(names_df$latin_name == gsub("_", " ", studySpecies[[i]]))
                each_informal_name <- names_df$informal_name[pattenEach]
                ref2studyFile <- ortholog_ksfiles[grepl(ref_informal_name, ortholog_ksfiles) & grepl(each_informal_name, ortholog_ksfiles)]
                study2outgroupFile <- ortholog_ksfiles[grepl(each_informal_name, ortholog_ksfiles) & grepl(outgroup_informal_name, ortholog_ksfiles)]
                ks_selected_files <- c(ks_selected_files, study2outgroupFile)

                # relative rate test
                # source("tools/substitution_rate_correction.R", local=T, encoding="UTF-8")
                study.mode <- relativeRate(
                    ref2outgroupFile,
                    study2outgroupFile,
                    ref2studyFile,
                    KsMax=input[["ks_maxK_rate"]]
                )
                study.mode$ref <- refSpecies
                study.mode$outgroup <- outgroupSpecies
                study.mode$study <- studySpecies[[i]]
                df_each <- as.data.frame(t(unlist(study.mode)))
                mode_df <- rbind(mode_df, df_each)

                Sys.sleep(.2)
                incProgress(
                    amount=0.4/length(studySpecies),
                    message=paste0("Relative rate correction for ", studySpecies[[i]], " ...")
                )
            }

            Sys.sleep(.2)
            incProgress(amount=.4, message="Calculating done...")

            if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){
                pattenFocal <- which(names_df$latin_name == input$select_focal_species)
                each_focal_name <- names_df$informal_name[pattenFocal]

                ks_file <- paralog_ksfiles[grepl(each_focal_name, paralog_ksfiles)]
                paralog_id <- gsub(".ks.tsv$", "", basename(ks_file))

                ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

                if( file.exists(ks_anchor_file) ){
                    files_list_new <- c(ks_file, ks_anchor_file)
                }else{
                    files_list_new <- c(ks_file)
                }

                req(input[["ks_binWidth_rate"]])
                req(input[["plot_mode_option_rate"]])

                files_list_new <- c(files_list_new, ks_selected_files)

                full_data <- calculateKsDistribution4wgd_multiple(
                    files_list_new,
                    plot.mode=input[["plot_mode_option_rate"]],
                    maxK=input[["ks_maxK_rate"]],
                    binWidth=input[["ks_binWidth_rate"]]
                )
                barData <- full_data$bar
                denData <- full_data$density
                Sys.sleep(.2)
                incProgress(amount=.4, message="Calculating done...")

                observe({
                    selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[["ks_maxK_rate"]], ]
                    selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[["ks_maxK_rate"]], ]
                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_rate",
                        "ks_density_df"=selectedDenData,
                        "species_list"=names_df,
                        "ks_bar_df"=selectedBarData,
                        "rate_correction_df"=mode_df,
                        "paralog_id"=paralog_id,
                        "paralogSpecies"=input$select_focal_species,
                        "xlim"=input[["ks_maxK_rate"]],
                        "ylim"=input[["y1_limit_rate"]],
                        "y2lim"=input[["y2_limit_rate"]],
                        "color"="",
                        "opacity"=input[["opacity_rate"]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                    session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
                })
            }else{
                plot_wgd_data <- list(
                    "paralog_id"=""
                )
                files_list <- ks_selected_files

                full_data <- calculateKsDistribution4wgd_multiple(
                    files_list
                )
                denData <- full_data$density
                Sys.sleep(.2)
                incProgress(amount=.4, message="Calculating done...")

                observe({
                    selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[["ks_maxK_rate"]], ]
                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_rate",
                        "ks_density_df"=selectedDenData,
                        "rate_correction_df"=mode_df,
                        "species_list"=names_df,
                        "xlim"=input[["ks_maxK_rate"]],
                        "y2lim"=input[["y1_limit_rate"]],
                        "color"="",
                        "opacity"=input[["opacity_rate"]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                    session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
                })
            }
            Sys.sleep(.2)
            incProgress(amount=.4, message="Ploting done...")
        })
    }
})
