observeEvent(input$collinear_data_example, {
    showModal(
        modalDialog(
            title=HTML("The description of the demo data used in the <b>Collinear Analysis</b>"),
            size="xl",
            uiOutput("collinear_data_example_panel")
        )
    )

    output$collinear_data_example_panel <- renderUI({
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
                            "<p>In the demo data, we selected four species: <i>Elaeis guineensis</i>, <i>Oryza sativa</i>, <i>Asparagus officinalis</i>, and <i>Vitis vinifera</i>, as also used in <b><i>K</i><sub>s</sub>Dist</b> module, to generate the data.</p>",
                            "<p>First, we followed the preparation steps in the Data Preparation Page of the <b>shinyWGD</b> server to create the script for the corresponding package, <b>i-ADHoRe</b>. ",
                            "We then submitted the job to the PSB computing server to obtain the output.</p>",
                            "<p>After obtaining the output, the <b>Collinear Analysis</b> module reads the data and continues the analysis. ",
                            "Users can choose the type and combinations of the data to study the <b>intra-</b> and <b>inter-species</b> collinear relationships. ",
                            "Additionally, users have the option to use the <b>multiple-spcies alignment</b> module to find the collinear blocks across several species.</p>",
                            "<p>To download the demo data, <a href='https://github.com/li081766/shinyWGD_Demo_Data/blob/main/4sp_Collinear_Data_for_Visualization.tar.gz' target='_blank'>click here</a>.</p>",
                            "<p><br></br></p>"
                        )
                    ),
                    h5(
                        HTML(
                            "<hr><p><b><font color='#BDB76B'>For true data</font></b>"
                        )
                    ),
                    HTML(
                        "<p>Users should upload the zipped-file, named as <b><i>Collinear_Data_for_Visualization.tar.gz</i></b> in the <b>Analysis-*</b> folder created by <b>shinyWGD</b>, to start the <b>Collinear Analysis</b>.</p>"
                    )
                )
            )
        )
    })
})

example_data_dir <- file.path(getwd(), "demo_data")
collinear_example_dir <- file.path(example_data_dir, "Example_Collinear_Visualization")

if( !dir.exists(collinear_example_dir) ){
    if( !dir.exists(example_data_dir) ){
        dir.create(example_data_dir)
    }
    dir.create(collinear_example_dir)
    downloadAndExtractData <- function() {
        download.file(
            "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_Collinear_Data_for_Visualization.tar.gz",
            destfile=file.path(getwd(), "collinear.data.zip"),
            mode="wb"
        )

        system(
            paste(
                "tar xzf",
                shQuote(file.path(getwd(), "collinear.data.zip")),
                "-C",
                shQuote(collinear_example_dir)
            )
        )

        file.remove(file.path(getwd(), "collinear.data.zip"))
    }

    downloadAndExtractData()
}

buttonCollinearClicked <- reactiveVal(NULL)
collinear_analysis_dir_Val <- reactiveVal(collinear_example_dir)

observeEvent(input$collinear_data_zip_file, {
    buttonCollinearClicked("fileInput")

    base_dir <- tempdir()
    timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
    collinearAnalysisDir <- file.path(base_dir, paste0("Collinear_data_", gsub("[ :\\-]", "_", timestamp)))
    dir.create(collinearAnalysisDir)
    system(
        paste(
            "tar xzf",
            input$collinear_data_zip_file$datapath,
            "-C",
            collinearAnalysisDir
        )
    )
    collinear_analysis_dir_Val(collinearAnalysisDir)
})

observeEvent(input$collinear_data_example, {
    buttonCollinearClicked("actionButton")
    collinear_analysis_dir_Val(collinear_example_dir)
})

observe({
    if( is.null(buttonCollinearClicked()) ){
        collinearAnalysisDir <- collinear_example_dir
        if( length(collinearAnalysisDir) > 0 ){
            dirName <- basename(collinearAnalysisDir)
            output$selectedSyntenyDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'>Collinear Analysis</font></b>"))
                    )
                )
            })
        }
    }
    else if( buttonCollinearClicked() == "fileInput" ){
        collinearAnalysisDir <- collinear_analysis_dir_Val()
        if( length(collinearAnalysisDir) > 0 ){
            dirName <- basename(collinearAnalysisDir)
            output$selectedSyntenyDirName <- renderUI({
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
    else if( buttonCollinearClicked() == "actionButton" ){
        collinearAnalysisDir <- collinear_example_dir
        if( length(collinearAnalysisDir) > 0 ){
            dirName <- basename(collinearAnalysisDir)
            output$selectedSyntenyDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("Selected Directory:<br><b><font color='#EE82EE'>Collinear Analysis</font></b>"))
                    )
                )
            })
        }
    }
})

observe({
    collinearAnalysisDir <- collinear_analysis_dir_Val()

    iadhorefiles <- list.files(path=collinearAnalysisDir, pattern="multiplicons.txt", full.names=TRUE, recursive=TRUE)
    multipleSpeciesIadhoreFile <- iadhorefiles[grepl("Multiple_Species", iadhorefiles)]
    iadhorefiles <- iadhorefiles[!(grepl("paralog_distributions", iadhorefiles))]
    iadhorefiles <- iadhorefiles[!(grepl("Multiple_Species", iadhorefiles))]

    if( length(iadhorefiles) > 0 ){
        split_paths <- strsplit(iadhorefiles, split="/")
        comparing_list <- lapply(split_paths, function(x){
            x[length(x)-1]
        })
        comparing_list <- gsub("i-adhore.", "", comparing_list)
        intra_list <- list()
        inter_list <- list()
        lapply(seq_along(comparing_list), function(i){
            sp_list_tmp <- unique(strsplit(comparing_list[i], split="_vs_")[[1]])
            if( length(sp_list_tmp) == 1 ){
                intra_list <<- append(intra_list, sp_list_tmp[1])
            }else{
                inter_list <<- append(inter_list, comparing_list[i])
            }
        })

        inter_list <- unlist(inter_list)
        intra_list <- unlist(intra_list)

        path_df <- data.frame(
            comparing_ID=character(),
            comparing_Type=character(),
            comparing_Path=character()
        )
        for( i in intra_list ){
            tmp_path_i <- iadhorefiles[grepl(paste0(i, "_vs_", i), iadhorefiles)]
            path_df <- rbind(
                path_df,
                data.frame(
                    comparing_ID=i,
                    comparing_Type="Intra",
                    comparing_Path=tmp_path_i
                )
            )
        }
        for( i in inter_list ){
            tmp_path_i <- iadhorefiles[grepl(i, iadhorefiles)]
            path_df <- rbind(
                path_df,
                data.frame(
                    comparing_ID=i,
                    comparing_Type="Inter",
                    comparing_Path=tmp_path_i
                )
            )
        }

        output$iadhoreAnalysisPanel <- renderUI({
            div(class="boxLike",
                style="background-color: #FBFEEC;
                           padding-bottom: 10px;
                           padding-top: 10px",
                fluidRow(
                    div(
                        style="padding-right: 5px;
                               padding-left: 5px;",
                        h5(icon("cog"), HTML("<font color='#bb5e00'>Synteny Analysis</font>")),
                        column(
                            12,
                            uiOutput("iadhoreSettingPanel")
                        ),
                        hr(class="setting"),
                        h5(icon("cog"), HTML("<font color='#bb5e00'>Clustering Analysis</font>")),
                        column(
                            12,
                            uiOutput("clusteringSettingPanel")
                        )
                    )
                )
            )
        })

        # Add multiple species to the path_df
        if( length(multipleSpeciesIadhoreFile) > 0 ){
            path_df <- rbind(
                path_df,
                data.frame(
                    comparing_ID="Multiple",
                    comparing_Type="Multiple",
                    comparing_Path=multipleSpeciesIadhoreFile[1]
                )
            )
        }

        if( is.not.null(intra_list) && is.not.null(inter_list) ){
            output$iadhoreSettingPanel <- renderUI({
                output <- tagList(
                    fluidRow(
                        column(
                            width=12,
                            div(
                                style="padding-bottom: 10px;",
                                bsButton(
                                    inputId="iadhore_intra_species_list_button",
                                    label=HTML("<font color='white'><b>&nbsp;Intra-species comparing: &nbsp;&#x25BC;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font>"),
                                    icon=icon("list"),
                                    style="success"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to choose species",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse("iadhore_intra_species_list_collapse"),
                                bs_collapse(
                                    id="iadhore_intra_species_list_collapse",
                                    content=tags$div(
                                        class="well",
                                        pickerInput(
                                            inputId="iadhore_intra_species_list",
                                            label=HTML("<b><font color='#38B0E4'>Species:</font></b>"),
                                            options=list(title='Please select species below'),
                                            choices=intra_list,
                                            choicesOpt=list(
                                                content=lapply(intra_list, function(choice) {
                                                    species <- gsub("_", " ", choice)
                                                    HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                                })
                                            ),
                                            multiple=FALSE
                                        ),
                                        div(
                                            class="d-flex justify-content-end",
                                            actionButton(
                                                inputId="confirm_intra_comparing_go",
                                                label="Confirm analysis",
                                                class="my-confirm-button-class",
                                                status="secondary",
                                                title="Click to confirm",
                                                style="color: #fff; background-color: #C0C0C0; border-color: #fff; margin: 22px 0px 0px 0px; "
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
                                    inputId="iadhore_inter_species_list_button",
                                    label=HTML("<font color='white'><b>&nbsp;Inter-species comparing:&nbsp;&#x25BC;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font>"),
                                    icon=icon("list"),
                                    style="success"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to choose species",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse("iadhore_inter_species_list_collapse"),
                                bs_collapse(
                                    id="iadhore_inter_species_list_collapse",
                                    content=tags$div(
                                        class="well",
                                        pickerInput(
                                            inputId="inter_list_A",
                                            label=HTML("<b><font color='#38B0E4'>Species A</font></b>"),
                                            options=list(
                                                title='Please select species below'
                                            ),
                                            choices=intra_list,
                                            choicesOpt=list(
                                                content=lapply(intra_list, function(choice) {
                                                    species <- gsub("_", " ", choice)
                                                    HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                                })
                                            ),
                                            multiple=FALSE
                                        ),
                                        pickerInput(
                                            inputId="inter_list_B",
                                            label=HTML("<b><font color='#B97D4B'>Species B</font></b>"),
                                            options=list(
                                                title='Please select species below',
                                                `selected-text-format`="count > 1",
                                                `actions-box`=TRUE
                                            ),
                                            choices=intra_list,
                                            choicesOpt=list(
                                                content=lapply(intra_list, function(choice) {
                                                    species <- gsub("_", " ", choice)
                                                    HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                                                })
                                            ),
                                            multiple=FALSE
                                        ),
                                        div(
                                            class="d-flex justify-content-end",
                                            actionButton(
                                                inputId="confirm_inter_comparing_go",
                                                "Confirm analysis",
                                                status="secondary",
                                                class="my-confirm-button-class",
                                                title="Click to confirm",
                                                style="color: #fff;
                                                       background-color: #C0C0C0;
                                                       border-color: #fff;
                                                       margin: 22px 0px 0px 0px; "
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        if( length(multipleSpeciesIadhoreFile) > 0 ){
                            column(
                                width=12,
                                div(
                                    style="padding-bottom: 10px;",
                                    bsButton(
                                        inputId="iadhore_multiple_species_list_button",
                                        label=HTML("<font color='white'><b>&nbsp;Multiple species comparing: &nbsp;&#x25BC;</b></font>"),
                                        icon=icon("list"),
                                        style="success",
                                    ) %>%
                                        bs_embed_tooltip(
                                            title="Click to choose species",
                                            placement="right",
                                            trigger="hover",
                                            options=list(container="body")
                                        ) %>%
                                        bs_attach_collapse("iadhore_multiple_species_list_collapse"),
                                    bs_collapse(
                                        id="iadhore_multiple_species_list_collapse",
                                        content=tags$div(
                                            class="well",
                                            style="background-color: #F5FFE8;",
                                            prettyCheckboxGroup(
                                                inputId="iadhore_multiple_species_list",
                                                label=HTML("Choose <b><i><font color='#E46A1B'>at least Three</font></b></i> Species:"),
                                                choiceValues=intra_list,
                                                choiceNames=lapply(intra_list, function(choice) {
                                                    HTML(paste0("<div style='color: #727EFA; font-style: italic;'>", gsub("_", " ", choice), "</div>"))
                                                }),
                                                icon=icon("check"),
                                                shape="round",
                                                status="success",
                                                fill=TRUE,
                                                animation="jelly"
                                            ),
                                            div(
                                                class="d-flex justify-content-end",
                                                actionButton(
                                                    inputId="confirm_multi_comparing_go",
                                                    "Confirm analysis",
                                                    status="secondary",
                                                    class="my-confirm-button-class",
                                                    title="Click to confirm",
                                                    style="color: #fff;
                                                           background-color: #C0C0C0;
                                                           border-color: #fff;
                                                           margin: 22px 0px 0px 0px; "
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
            })
            output$clusteringSettingPanel <- renderUI({
                fluidRow(
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="clustering_button",
                                label=HTML("<font color='white'><b>&nbsp;Clustering analysis setting:&nbsp;&#x25BC;&nbsp;&nbsp;</b></font>"),
                                icon=icon("list"),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to choose species",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("clustering_files_collapse"),
                            bs_collapse(
                                id="clustering_files_collapse",
                                content=tags$div(
                                    class="well",
                                    pickerInput(
                                        inputId="cluster_species_A",
                                        label=HTML("<b><font color='#38B0E4'>Species A</font></b>"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=intra_list,
                                        choicesOpt=list(
                                            content=lapply(intra_list, function(choice) {
                                                species <- gsub("_", " ", choice)
                                                HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                            })
                                        ),
                                        multiple=FALSE
                                    ),
                                    pickerInput(
                                        inputId="cluster_species_B",
                                        label=HTML("<b><font color='#B97D4B'>Species B</font></b>"),
                                        options=list(
                                            title='Please select species below',
                                            `selected-text-format`="count > 1",
                                            `actions-box`=TRUE
                                        ),
                                        choices=intra_list,
                                        choicesOpt=list(
                                            content=lapply(intra_list, function(choice) {
                                                species <- gsub("_", " ", choice)
                                                HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                                            })
                                        ),
                                        multiple=FALSE
                                    ),
                                    div(
                                        class="d-flex justify-content-end",
                                        actionButton(
                                            inputId="confirm_clustering_go",
                                            "Confirm analysis",
                                            status="secondary",
                                            class="my-confirm-button-class",
                                            title="Confirm to click",
                                            style="color: #fff;
                                                   background-color: #C0C0C0;
                                                   border-color: #fff;
                                                   margin: 22px 0px 0px 0px; "
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            })
        }
        rds_file <- paste0(collinearAnalysisDir, "/synteny.comparing.RData")
        if( !file.exists(rds_file) ){
            if( nrow(path_df) > 0 ){
                save(path_df, file=rds_file)
            }
        }
        # path_df <- path_df
        # path_df$comparing_Path <- gsub(
        #     "/Users/jiali/Desktop/Projects/ShinyWGD/packing/ShinyWGD/inst/shinyWGD/demo_data/Example_Collinear_Visualization/i-ADHoRe_wd/",
        #     "/www/bioinformatics01_rw/ShinyWGD/Example_4Sp/Example_Collinear_Visualization/i-ADHoRe_wd/",
        #     path_df$comparing_Path
        # )
        # save(path_df, file=paste0(collinearAnalysisDir, "/synteny.comparing.server.RData"))
    }
    else{
        shinyalert(
            "Oops!",
            "No i-ADHoRe output file found. Please provide the correct path...",
            type="error",
        )
    }

})

observe({
    collinearAnalysisDir <- collinear_analysis_dir_Val()

    rds_file <- paste0(collinearAnalysisDir, "/synteny.comparing.RData")
    if( file.exists(rds_file) ){
        load(rds_file)
        intra_list <- path_df[path_df$comparing_Type == "Intra", ]$comparing_ID
        if( isTruthy(input$inter_list_A) ){
            list_A_species <- input$inter_list_A
            remaining_species <- setdiff(intra_list, list_A_species)
            updatePickerInput(
                session,
                "inter_list_B",
                choices=remaining_species,
                choicesOpt=list(
                    content=lapply(remaining_species, function(choice) {
                        species <- gsub("_", " ", choice)
                        HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                    })
                )
            )
        }
        if( isTruthy(input$cluster_species_A) ){
            list_A_species <- input$cluster_species_A
            remaining_species <- setdiff(intra_list, list_A_species)
            updatePickerInput(
                session,
                "cluster_species_B",
                choices=remaining_species,
                choicesOpt=list(
                    content=lapply(remaining_species, function(choice) {
                        species <- gsub("_", " ", choice)
                        HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                    })
                )
            )
        }
    }
})

observeEvent(input$iadhore_intra_species_list_button, {
    shinyjs::runjs('document.getElementById("iadhore_intra_species_list_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("iadhore_inter_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_multiple_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("clustering_files_collapse").style.display="none";')
})

observeEvent(input$iadhore_inter_species_list_button, {
    shinyjs::runjs('document.getElementById("iadhore_intra_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_inter_species_list_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("iadhore_multiple_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("clustering_files_collapse").style.display="none";')
})

observeEvent(input$iadhore_multiple_species_list_button, {
    shinyjs::runjs('document.getElementById("iadhore_intra_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_inter_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_multiple_species_list_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("clustering_files_collapse").style.display="none";')
})

observeEvent(input$clustering_button, {
    shinyjs::runjs('document.getElementById("iadhore_intra_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_inter_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("iadhore_multiple_species_list_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("clustering_files_collapse").style.display="block";')
})

observeEvent(input$confirm_intra_comparing_go, {
    if( isTruthy(input$iadhore_intra_species_list) && input$iadhore_intra_species_list != "" ){
        shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
        shinyjs::runjs("$('#confirm_intra_comparing_go').css('background-color', 'green');")
        updateActionButton(
            session,
            "confirm_intra_comparing_go",
            icon=icon("check")
        )

        setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_intra_comparing_go').css('background-color', '#C0C0C0');
            }, 6000);"

        shinyjs::runjs(setTimeoutFunction)

        withProgress(message='Configuration in progress', value=0, {
            Sys.sleep(.2)
            incProgress(amount=.3, message="Configuring...")

            collinearAnalysisDir <- collinear_analysis_dir_Val()

            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

            color_list <- c("#F5FFE8", "#ECF5FF", "#FDFFFF", "#FBFFFD", "#F0FFF0",
                            "#FBFBFF", "#FFFFF4", "#FFFCEC", "#FFFAF4", "#FFF3EE")
            color_list_selected <- rep(color_list, length.out=nrow(path_df))

            intra_list <- input$iadhore_intra_species_list
            intra_species <- gsub("_", " ", input$iadhore_intra_species_list)

            panelTitle <- paste0("<font color='#DCFEE3'><b><i>", intra_species, "</i></b></font>")
            queryChrPanelTitle <- HTML(paste("Select <font color='#68AC57'><i><b>", intra_species, "</b></i></font> chromosomes:"))

            output$iadhore_output <- renderUI({
                div(
                    class="boxLike",
                    style="padding-right: 50px;
                           padding-left: 50px;
                           padding-top: 10px;
                           padding-bottom: 10px;
                           background-color: white",
                    fluidRow(
                        column(
                            width=12,
                            div(
                                style="padding-bottom: 10px;",
                                bsButton(
                                    inputId="plot_intra_button",
                                    label=HTML(panelTitle),
                                    style="info"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to see more details",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse("plot_panel_collapse_intra"),
                                bs_collapse(
                                    id="plot_panel_collapse_intra",
                                    show=TRUE,
                                    content=tags$div(
                                        class="well",
                                        fluidRow(
                                            div(
                                                style="padding-right: 30px;
                                                      padding-left: 30px;
                                                      padding-top: 10px;
                                                      padding-bottom: 10px;",
                                                fluidRow(
                                                    column(
                                                        2,
                                                        h5(HTML(paste0("<font color='orange'>", icon("dna"), "&nbsp;Chromosome</font> setting")))
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="padding: 12px 10px 5px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #F8F8FF",
                                                            sliderInput(
                                                                inputId="chr_num_cutoff",
                                                                label=HTML("Set the <font color='orange'>mininum gene number</font> in the chromosome:"),
                                                                min=0,
                                                                max=500,
                                                                step=50,
                                                                value=100
                                                            ),
                                                        )
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="padding: 12px 10px 20px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #F8F8FF",
                                                            pickerInput(
                                                                inputId="synteny_query_chr_intra",
                                                                label=queryChrPanelTitle,
                                                                options=list(
                                                                    title='Please select chromosomes below',
                                                                    `selected-text-format`="count > 1",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=TRUE
                                                            )
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        2,
                                                        h5(HTML("<font color='orange'>Anchor points</font> setting:"))
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="padding: 12px 10px 5px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #FFF5EE;",
                                                            sliderInput(
                                                                inputId="anchoredPointsCutoff_intra",
                                                                label=HTML("Set <font color='orange'>anchor points per multiplicon:</font>"),
                                                                min=3,
                                                                max=30,
                                                                step=1,
                                                                value=3
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        4,
                                                        tags$head(
                                                            tags$style(HTML(
                                                                "@keyframes glowing {
                                                                     0% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
                                                                     50% { background-color: #64A600; box-shadow: 0 0 20px #43b0d1; }
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
                                                            inputId="synplot_go_intra",
                                                            "Draw Syntenty Plot",
                                                            icon=icon("pencil-alt"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #009393;
                                                                   border-color: #fff;
                                                                   padding: 5px 10px 5px 10px;
                                                                   margin: 50px 5px 5px 35px;"
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h6(HTML("<b>The Dot Plot:</b>")),
                                                        tags$style(
                                                            HTML(".rotate-135 {
                                                                    transform: rotate(135deg);
                                                                }"),
                                                            HTML(".rotate-45{
                                                                    transform: rotate(45deg);
                                                                }")
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_add_dot_intra",
                                                            "",
                                                            icon("arrows-alt-v", class="rotate-45"),
                                                            title="Expand spacing"
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_sub_dot_intra",
                                                            "",
                                                            icon(
                                                                "down-left-and-up-right-to-center",
                                                                verify_fa=FALSE,
                                                            ),
                                                            title="Compress spacing"
                                                        ),
                                                        downloadButton_custom(
                                                            "download_dotView_intra",
                                                            title="Download the Plot",
                                                            status="secondary",
                                                            icon=icon("download"),
                                                            label=HTML(""),
                                                            class="my-download-button-class",
                                                            style="color: #fff;
                                                                   background-color: #6B8E23;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;"
                                                        )
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="dotView_intra"
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h6(HTML("<b>The Parallel Link Plot:</b>"))
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="/*display: flex; align-items: center;*/
                                                                   text-align: center;
                                                                   margin-bottom: 10px;                                                   border-radius: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 10px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            actionButton(
                                                                "svg_vertical_spacing_add_rainbow_intra",
                                                                "",
                                                                icon("arrows-alt-v"),
                                                                title="Expand vertical spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_vertical_spacing_sub_rainbow_intra",
                                                                "",
                                                                icon(
                                                                    "down-left-and-up-right-to-center",
                                                                    verify_fa=FALSE,
                                                                    class="rotate-135"
                                                                ),
                                                                title="Compress vertical spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_horizontal_spacing_add_rainbow_intra",
                                                                "",
                                                                icon("arrows-alt-h"),
                                                                title="Expand horizontal spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_horizontal_spacing_sub_rainbow_intra",
                                                                "",
                                                                icon(
                                                                    "down-left-and-up-right-to-center",
                                                                    verify_fa=FALSE,
                                                                    class="rotate-45"
                                                                ),
                                                                title="Compress horizontal spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                "download_SyntenicBlock_intra",
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                class="my-download-button-class",
                                                                style="color: #fff;
                                                                       background-color: #6B8E23;
                                                                       border-color: #fff;
                                                                       padding: 5px 14px 5px 14px;
                                                                       margin: 5px 5px 5px 5px;"
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="margin-bottom: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 5px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            prettyRadioButtons(
                                                                inputId="scale_link_intra",
                                                                label=HTML("<font color='orange'>Scale in</font>:"),
                                                                choices=c("Gene number", "True length"),
                                                                selected="Gene number",
                                                                icon=icon("check"),
                                                                inline=TRUE,
                                                                status="info",
                                                                animation="jelly"
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="SyntenicBlock_intra"
                                                    )
                                                ),
                                                hr(class="splitting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h5(HTML("<font color='#00DB00'><b>Multiplicon-level Synteny</b></font>"))
                                                    )
                                                ),
                                                fluidRow(
                                                    column(
                                                        4,
                                                        textInput(
                                                            inputId="gene_intra",
                                                            label="Seach the Gene:",
                                                            value="",
                                                            width="100%",
                                                            placeholder="Gene Id"
                                                        )
                                                    ),
                                                    column(
                                                        1,
                                                        actionButton(
                                                            inputId="searchButton_intra",
                                                            "",
                                                            width="40px",
                                                            icon=icon("search"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #8080C0;
                                                                   border-color: #fff;
                                                                   margin: 30px 0px 0px -15px; "
                                                        )
                                                    ),
                                                    column(
                                                        7,
                                                        uiOutput("foundItemsMessage_intra")
                                                    ),
                                                ),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        uiOutput("multiplicon_mirco_intra_plot")
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            })

            incProgress(amount=1, message="Configuration Done")
            Sys.sleep(.4)
        })

        observe({
            if( length(collinearAnalysisDir) > 0 && !is.null(input$chr_num_cutoff) ){
                intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
                intra_species_dir <- dirname(intra_selected_df$comparing_Path)
                genesFile <- paste0(intra_species_dir, "/genes.txt")
                chr_gene_num_file <- paste0(intra_species_dir, "/chr_gene_nums.txt")

                if( !file.exists(chr_gene_num_file) ){
                    if( file.exists(genesFile) ){
                        genes <- suppressMessages(
                            vroom(
                                genesFile,
                                delim="\t",
                                col_names=TRUE
                            )
                        )
                        gene_num_df <- aggregate(coordinate ~ genome + list, genes, max)
                        colnames(gene_num_df) <- c("sp", "seqchr", "gene_num")
                        gene_num_df$gene_num <- gene_num_df$gene_num + 1
                        write.table(
                            gene_num_df,
                            file=chr_gene_num_file,
                            sep="\t",
                            quote=F,
                            row.names=FALSE
                        )
                    }
                    else{
                        shinyalert(
                            "Oops",
                            "Fail to find correct ouputs of i-ADHoRe for ", intra_list,". Please ensure the output of i-ADHoRe, and then try again...",
                            type="error"
                        )
                    }
                }else{
                    gene_num_df <- read.table(
                        chr_gene_num_file,
                        sep="\t",
                        header=TRUE
                    )
                }

                if( is.null(gene_num_df) ){
                    querys <- NULL
                }else{
                    querys <- gene_num_df %>%
                        filter(gene_num >= input$chr_num_cutoff) %>%
                        arrange(seqchr) %>%
                        pull(seqchr)
                }
                if( length(querys) > 0 ){
                    updatePickerInput(
                        session,
                        "synteny_query_chr_intra",
                        choices=gtools::mixedsort(querys),
                        choicesOpt=list(
                            content=lapply(gtools::mixedsort(querys), function(choice) {
                                HTML(paste0("<div style='color: #68AC57;'>", choice, "</div>"))
                            })
                        )
                    )
                }else{
                    shinyalert(
                        "Oops",
                        "No chromosome found. Please lower the cutoff of gene number in the chromosome, and then try again...",
                        type="error"
                    )
                }
            }
        })
    }else{
        shinyalert(
            "Oops",
            "Please select the species first, and then click the confirm button...",
            type="error"
        )
    }
})

observe({
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$iadhore_intra_species_list) && input$iadhore_intra_species_list != "" ){
            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
            intra_list <- input$iadhore_intra_species_list
            intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
            intra_species_dir <- dirname(intra_selected_df$comparing_Path)

            syn_dir <- dirname(dirname(dirname(intra_selected_df$comparing_Path)))[1]
            sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")

            sp_chr_len_file <- paste0(dirname(sp_gff_info_xls), "/species_chr_len.RData")
            if( !file.exists(sp_chr_len_file) ){
                chr_len_df <- obtain_chromosome_length(sp_gff_info_xls)
                save(chr_len_df, file=sp_chr_len_file)
            }
        }
    }
})

observeEvent(input$synplot_go_intra, {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( !is.null(input$synteny_query_chr_intra) && input$iadhore_intra_species_list != "" ){
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

            output$foundItemsMessage_intra <- renderUI({
                HTML("")
            })

            output$multiplicon_mirco_intra_plot <- renderUI({
                HTML("")
            })

            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
            intra_list <- input$iadhore_intra_species_list
            intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
            intra_species_dir <- dirname(intra_selected_df$comparing_Path)

            syn_dir <- dirname(dirname(dirname(intra_selected_df$comparing_Path)))[1]
            sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")

            sp_chr_len_file <- paste0(dirname(sp_gff_info_xls), "/species_chr_len.RData")
            load(sp_chr_len_file)

            sp_gff_info_df <- suppressMessages(
                vroom(
                    sp_gff_info_xls,
                    col_names=c("species", "cdsPath", "gffPath"),
                    delim="\t"
                )
            )
            cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
            gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
            new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
            new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
            sp_gff_info_df$cdsPath <- new_cds_files
            sp_gff_info_df$gffPath <- new_gff_files

            querySpecies <- gsub("_", " ", intra_selected_df$comparing_ID)
            subjectSpecies <- querySpecies

            query_chr_Input <- "synteny_query_chr_intra"

            query_selected_chr_list <- input[[query_chr_Input]]
            query_chr_len_df <- chr_len_df[chr_len_df$sp==intra_selected_df$comparing_ID, ] %>%
                filter(seqchr %in% query_selected_chr_list)

            chr_gene_num_file <- paste0(intra_species_dir, "/chr_gene_nums.txt")

            gene_num_df <- read.table(
                chr_gene_num_file,
                sep="\t",
                header=TRUE
            )

            iadhoreDir <- dirname(intra_selected_df$comparing_Path)

            withProgress(message='Analyzing in progress', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.3, message="Preparing Data...")
                genesFile <- paste0(iadhoreDir, "/genes.txt")
                multiplicon_file <- paste0(iadhoreDir, "/multiplicons.txt")
                multiplicon_ks_file <- paste0(iadhoreDir, "/multiplicons.merged_ks.txt")
                anchorpointfile <- paste0(iadhoreDir, "/anchorpoints.txt")
                anchorpoint_merged_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos.txt")
                anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                ks_file <- paste0(iadhoreDir, "/anchorpoints.ks.txt")

                if( file.exists(ks_file) ){
                    if( !file.exists(anchorpointout_file) ){
                        obtain_coordiantes_for_anchorpoints(
                            anchorpoints=anchorpointfile,
                            species1=querySpecies,
                            gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                            out_file=anchorpoint_merged_file
                        )
                    }

                    if( !file.exists(multiplicon_ks_file) ){
                        obtain_mean_ks_for_each_multiplicon(
                            multiplicon_file=multiplicon_file,
                            anchorpoint_file=anchorpoint_merged_file,
                            ks_file=ks_file,
                            species1=querySpecies,
                            anchorpointout_file=anchorpointout_file,
                            outfile=multiplicon_ks_file
                        )
                    }
                }
                else{
                    shinyalert(
                        "Opps!",
                        paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of shinyWGD first ..."),
                        type="error",
                    )
                }

                Sys.sleep(.2)
                incProgress(amount=.3, message="Calculating Done")

                final_multiplicons <- suppressMessages(
                    vroom(
                        multiplicon_ks_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )

                final_anchorpoints <- suppressMessages(
                    vroom(
                        anchorpointout_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )

                query_chr_num_df <- gene_num_df %>%
                    filter(sp==gsub(" ", "_", querySpecies)) %>%
                    filter(seqchr %in% query_selected_chr_list)

                anchoredPointScutoff <- "anchoredPointsCutoff_intra"

                selected_multiplicons <- final_multiplicons %>%
                    filter(listX %in% query_selected_chr_list) %>%
                    filter(listY %in% query_selected_chr_list) %>%
                    filter(num_anchorpoints >= input[[anchoredPointScutoff]])
                selected_multiplicons_Id <- selected_multiplicons$multiplicon

                # source(file="tools/computeAnchorPointDepth.R", local=T, encoding="UTF-8")
                depth_list <- computing_depth_paranome(
                    anchorpoint_ks_file=anchorpointout_file,
                    multiplicon_id=selected_multiplicons_Id,
                    selected_query_chr=query_selected_chr_list
                )
                query_selected_depth_list <- depth_list$depth
                subject_selected_depth_list <- depth_list$depth

                selected_anchorpoints <- final_anchorpoints %>%
                    filter(listX %in% query_selected_chr_list) %>%
                    filter(listY %in% query_selected_chr_list) %>%
                    filter(multiplicon %in% selected_multiplicons_Id)

                plotSize <- reactiveValues(
                    value=400
                )
                observeEvent(input[["svg_spacing_add_dot_intra"]], {
                    plotSize$value <- plotSize$value + 50
                })
                observeEvent(input[["svg_spacing_sub_dot_intra"]], {
                    plotSize$value <- plotSize$value - 50
                })
                Sys.sleep(.2)
                incProgress(amount=.3, message="Drawing Dot Plot...")

                observe({
                    plot_dot_num_data <- list(
                        "plot_id"="dotView_intra",
                        "multiplicons"=selected_multiplicons,
                        "anchorpoints"=selected_anchorpoints,
                        "query_sp"=querySpecies,
                        "query_chr_gene_nums"=query_chr_num_df,
                        "query_depths"=query_selected_depth_list,
                        "subject_sp"=subjectSpecies,
                        "subject_chr_gene_nums"=query_chr_num_df,
                        "subject_depths"=subject_selected_depth_list,
                        "size"=plotSize$value
                    )
                    session$sendCustomMessage("Dot_Num_Plotting_paranome", plot_dot_num_data)
                })
                Sys.sleep(.2)
                incProgress(amount=1, message="Drawing Dot Plot Done")
            })

            # plot parallel figure
            withProgress(message='Parallel Syntenty Figure in progress', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.3, message="Drawing Parallel Syntenty Plot...")
                segmentsfile <- paste0(iadhoreDir, "/segments.txt")
                segs_pos_file <- paste0(iadhoreDir, "/segments.merged_pos.txt")
                subject_chr_len_df <- query_chr_len_df

                observe({
                    widthSpacingRainbow <- reactiveValues(
                        value=800
                    )
                    heightSpacingRainbow <- reactiveValues(
                        value=300
                    )
                    observeEvent(input[["svg_vertical_spacing_add_rainbow_intra"]], {
                        heightSpacingRainbow$value <- heightSpacingRainbow$value + 20
                    })
                    observeEvent(input[["svg_vertical_spacing_sub_rainbow_intra"]], {
                        heightSpacingRainbow$value <- heightSpacingRainbow$value - 20
                    })
                    observeEvent(input[["svg_horizontal_spacing_add_rainbow_intra"]], {
                        widthSpacingRainbow$value <- widthSpacingRainbow$value + 20
                    })
                    observeEvent(input[["svg_horizontal_spacing_sub_rainbow_intra"]], {
                        widthSpacingRainbow$value <- widthSpacingRainbow$value - 20
                    })
                    if( input$scale_link_intra == "True length" ){
                        plot_parallel_data <- list(
                            "plot_id"="SyntenicBlock_intra",
                            "segs"=selected_anchorpoints,
                            "query_sp"=querySpecies,
                            "query_chr_lens"=query_chr_len_df,
                            "subject_sp"=subjectSpecies,
                            "subject_chr_lens"=subject_chr_len_df,
                            "width"=widthSpacingRainbow$value,
                            "height"=heightSpacingRainbow$value,
                            "anchor_pair"="anchor_pair"
                        )
                        session$sendCustomMessage("Parallel_Plotting", plot_parallel_data)
                    }
                    else{
                        plot_parallel_data <- list(
                            "plot_id"="SyntenicBlock_intra",
                            "anchorpoints"=selected_anchorpoints,
                            "query_sp"=querySpecies,
                            "query_chr_nums"=query_chr_num_df,
                            "subject_sp"=subjectSpecies,
                            "subject_chr_nums"=query_chr_num_df,
                            "width"=widthSpacingRainbow$value,
                            "height"=heightSpacingRainbow$value
                        )
                        session$sendCustomMessage("Parallel_Number_Plotting", plot_parallel_data)
                    }
                })

                Sys.sleep(.3)
                incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
            })
        }
        else{
            shinyalert(
                "Oops",
                "Please select the chromosome first, and then click the button...",
                type="error"
            )
        }
    }
})

observeEvent(input[["searchButton_intra"]], {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$gene_intra) && input$gene_intra != "" ){
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
            withProgress(message='Searching Gene in progress', value=0, {
                Sys.sleep(.8)
                incProgress(amount=.2, message="Preparing Data...")

                load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
                intra_list <- input$iadhore_intra_species_list
                intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
                intra_species_dir <- dirname(intra_selected_df$comparing_Path)
                genesFile <- paste0(intra_species_dir, "/genes.txt")
                multiplicon_file <- paste0(intra_species_dir, "/multiplicons.txt")
                multiplicon_ks_file <- paste0(intra_species_dir, "/multiplicons.merged_ks.txt")
                anchorpointfile <- paste0(intra_species_dir, "/anchorpoints.txt")
                anchorpoint_merged_file <- paste0(intra_species_dir, "/anchorpoints.merged_pos.txt")
                anchorpointout_file <- paste0(intra_species_dir, "/anchorpoints.merged_pos_ks.txt")
                ks_file <- paste0(intra_species_dir, "/anchorpoints.ks.txt")

                syn_dir <- dirname(dirname(dirname(intra_selected_df$comparing_Path)))[1]
                sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")
                sp_gff_info_df <- suppressMessages(
                    vroom(
                        sp_gff_info_xls,
                        col_names=c("species", "cdsPath", "gffPath"),
                        delim="\t"
                    )
                )
                cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
                gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
                new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
                new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
                sp_gff_info_df$cdsPath <- new_cds_files
                sp_gff_info_df$gffPath <- new_gff_files

                querySpecies <- gsub("_", " ", intra_selected_df$comparing_ID)
                subjectSpecies <- querySpecies

                if( file.exists(ks_file) ){
                    if( !file.exists(anchorpointout_file) ){
                        obtain_coordiantes_for_anchorpoints(
                            anchorpoints=anchorpointfile,
                            species1=querySpecies,
                            gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                            out_file=anchorpoint_merged_file
                        )
                    }

                    if( !file.exists(multiplicon_ks_file) ){
                        obtain_mean_ks_for_each_multiplicon(
                            multiplicon_file=multiplicon_file,
                            anchorpoint_file=anchorpoint_merged_file,
                            ks_file=ks_file,
                            species1=querySpecies,
                            anchorpointout_file=anchorpointout_file,
                            outfile=multiplicon_ks_file
                        )
                    }
                }
                else{
                    shinyalert(
                        "Opps!",
                        paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of shinyWGD first ..."),
                        type="error",
                    )
                }

                Sys.sleep(.2)
                incProgress(amount=.3, message="Calculating Done")

                final_anchorpoints <- suppressMessages(
                    vroom(
                        anchorpointout_file,
                        col_names=TRUE,
                        delim="\t")
                )

                multiplicons <- suppressMessages(
                    vroom(
                        multiplicon_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )
                final_multiplicons <- fill(multiplicons, genome_x, list_x, .direction="down")
                colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                                  "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")

                searchGene <- input[["gene_intra"]]
                if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                    searched_multiplicon_list <- unique(final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]$multiplicon)
                    searched_multiplicon_df <- final_multiplicons[final_multiplicons$multiplicon %in% searched_multiplicon_list, ]
                    searched_multiplicon_list <- searched_multiplicon_df[searched_multiplicon_df$is_redundant == 0, ]$multiplicon
                    searched_anchor_points <- distinct(final_anchorpoints[final_anchorpoints$multiplicon %in% searched_multiplicon_list, ])

                    uiId <- "foundItemsMessage_intra"
                    output[[uiId]] <- renderUI({
                        if( length(searched_multiplicon_list) > 0 ){
                            fluidRow(
                                column(
                                    8,
                                    div(
                                        style="border: 1px solid #ccc;
                                               padding: 2px;
                                               margin-top: 35px;
                                               margin-left: -40px;
                                               border-radius: 10px;
                                               background-color: white;
                                               font-family: Times New Roman, Times, serif; white-space: pre-wrap;",

                                        if( length(searched_multiplicon_list) == 1 ){
                                            HTML(
                                                paste(
                                                    "<span style='color: #FF79BC; font-weight: bold;'>",
                                                    nrow(searched_anchor_points),
                                                    " Anchor Point is in Multiplicon (ID: <span style='color: #EA7500; font-weight: bold;'>",
                                                    searched_multiplicon_list[1],
                                                    "</span>)"
                                                )
                                            )
                                        }else{
                                            HTML(
                                                paste(
                                                    "<span style='color: #FF79BC; font-weight: bold;'>",
                                                    nrow(searched_anchor_points),
                                                    " Anchor Points are in Multiplicon (ID: <span style='color: #EA7500; font-weight: bold;'>",
                                                    paste(searched_multiplicon_list, collapse=", "),
                                                    "</span>)"
                                                )
                                            )
                                        }
                                    )
                                ),
                                column(
                                    4,
                                    actionButton(
                                        inputId="plotMicro_intra",
                                        "Draw Plot",
                                        icon=icon("pencil-alt"),
                                        status="secondary",
                                        class="my-start-button-class",
                                        style="color: #fff;
                                               background-color: #8080C0;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 32px 5px 5px 5px;"
                                    )
                                )
                            )
                        }
                        else{
                            div(
                                style="border: 1px solid #ccc;
                                       padding: 2px;
                                       margin-top: 30px;
                                       margin-left: -40px;
                                       border-radius: 10px;
                                       background-color: white;
                                       font-family: Times New Roman, Times, serif; white-space: pre-wrap;",
                                HTML("<span style='color: #FF79BC; font-weight: bold;'> No Anchor Point</span> is found!")
                            )
                        }
                    })

                    output$multiplicon_mirco_intra_plot <- renderUI({
                        div(
                            hr(class="setting"),
                            fluidRow(
                                column(
                                    3,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        pickerInput(
                                            inputId="multiplicon_choose_intra",
                                            label=HTML("Choose a <font color='orange'>multiplicon</font> to plot:"),
                                            options=list(
                                                title='Please select multiplicon below',
                                                `selected-text-format`="count > 1",
                                                `actions-box`=TRUE
                                            ),
                                            choices=NULL,
                                            selected=NULL,
                                            multiple=FALSE
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        prettyRadioButtons(
                                            inputId="scale_plotMicro_intra",
                                            label=HTML("<font color='orange'>Scale in</font>:"),
                                            choices=c("True length", "Gene number"),
                                            selected="True length",
                                            icon=icon("check"),
                                            status="info",
                                            animation="jelly"
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        prettyRadioButtons(
                                            inputId="link_plotMicro_intra",
                                            label=HTML("<font color='orange'>Link type</font>:"),
                                            choices=c("Pairwise", "All"),
                                            selected="Pairwise",
                                            icon=icon("check"),
                                            status="info",
                                            animation="jelly"
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        HTML("Color <font color='orange'>homolog genes</font>:"),
                                        div(
                                            style="padding: 20px 10px 5px 10px;
                                                   background-color: #FFF5EE;",
                                            prettyToggle(
                                                inputId="color_homolog_intra",
                                                label_on="Yes!",
                                                icon_on=icon("check"),
                                                status_on="info",
                                                status_off="warning",
                                                label_off="No..",
                                                value=TRUE,
                                                icon_off=icon("remove", verify_fa=FALSE)
                                            )
                                        )
                                    )
                                )
                            ),
                            hr(class="setting"),
                            fluidRow(
                                column(
                                    12,
                                    h6(HTML("<b>The Synteny Link Plot:</b>")),
                                    actionButton(
                                        "svg_vertical_spacing_add_micro_intra",
                                        "",
                                        icon("arrows-alt-v"),
                                        title="Expand vertical spacing"
                                    ),
                                    actionButton(
                                        "svg_vertical_spacing_sub_micro_intra",
                                        "",
                                        icon(
                                            "down-left-and-up-right-to-center",
                                            verify_fa=FALSE,
                                            class="rotate-135"
                                        ),
                                        title="Compress vertical spacing"
                                    ),
                                    actionButton(
                                        "svg_horizontal_spacing_add_micro_intra",
                                        "",
                                        icon("arrows-alt-h"),
                                        title="Expand horizontal spacing"
                                    ),
                                    actionButton(
                                        "svg_horizontal_spacing_sub_micro_intra",
                                        "",
                                        icon(
                                            "down-left-and-up-right-to-center",
                                            verify_fa=FALSE,
                                            class="rotate-45"
                                        ),
                                        title="Compress horizontal spacing"
                                    ),
                                    downloadButton_custom(
                                        "download_microSyntenicBlock_intra",
                                        title="Download the Plot",
                                        status="secondary",
                                        icon=icon("download"),
                                        label=HTML(""),
                                        class="my-download-button-class",
                                        style="color: #fff;
                                               background-color: #6B8E23;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 5px 5px 5px 5px;"
                                    )
                                ),
                                column(
                                    width=12,
                                    id="microSyntenicBlock_intra"
                                )
                            )
                        )
                    })

                    observe({
                        selected_multiplicons_df <- searched_multiplicon_df %>%
                            filter(is_redundant == 0)

                        selected_multiplicons_list <- selected_multiplicons_df$multiplicon

                        updatePickerInput(
                            session,
                            "multiplicon_choose_intra",
                            choices=selected_multiplicons_list,
                            selected=selected_multiplicons_list[1],
                            choicesOpt=list(
                                content=lapply(selected_multiplicons_list, function(choice) {
                                    tmp_level <- selected_multiplicons_df %>%
                                        filter(multiplicon == choice)
                                    HTML(
                                        paste0(
                                            "<div>Multiplicon: <span style='color: #2E8B57; font-weight: bold;'>", choice, "</span>",
                                            " Level <span style='color: #6A5ACD; font-weight: bold;'>", tmp_level$level, "</span></div>"
                                        )
                                    )
                                })
                            )
                        )
                    })

                }else{
                    shinyalert(
                        "Warning!",
                        "Please input the correct gene name ...",
                        type="warning",
                    )
                }
                Sys.sleep(.9)
                incProgress(amount=1, message="Searching Done")
            })
        }
    }
})

observeEvent(input[["plotMicro_intra"]], {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$multiplicon_choose_intra) && !is.null(input$multiplicon_choose_intra) ){
            if( isTruthy(input$gene_intra) && input$gene_intra != "" ){
                shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

                withProgress(message='Drawing Micro Synteny in progress', value=0, {
                    Sys.sleep(.5)
                    load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
                    intra_list <- input$iadhore_intra_species_list
                    intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
                    intra_species_dir <- dirname(intra_selected_df$comparing_Path)
                    genesFile <- paste0(intra_species_dir, "/genes.txt")
                    multiplicon_file <- paste0(intra_species_dir, "/multiplicons.txt")
                    anchorpointfile <- paste0(intra_species_dir, "/anchorpoints.txt")
                    anchorpoint_merged_file <- paste0(intra_species_dir, "/anchorpoints.merged_pos.txt")
                    anchorpointout_file <- paste0(intra_species_dir, "/anchorpoints.merged_pos_ks.txt")
                    ks_file <- paste0(intra_species_dir, "/anchorpoints.ks.txt")
                    genes_file <- paste0(intra_species_dir, "/genes.txt")

                    genes_df <- suppressMessages(
                        vroom(
                            genes_file,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )

                    syn_dir <- dirname(dirname(dirname(intra_selected_df$comparing_Path)))[1]
                    sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")
                    sp_gff_info_df <- suppressMessages(
                        vroom(
                            sp_gff_info_xls,
                            col_names=c("species", "cdsPath", "gffPath"),
                            delim="\t"
                        )
                    )
                    cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
                    gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
                    new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
                    new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
                    sp_gff_info_df$cdsPath <- new_cds_files
                    sp_gff_info_df$gffPath <- new_gff_files

                    querySpecies <- gsub("_", " ", intra_selected_df$comparing_ID)
                    subjectSpecies <- querySpecies

                    segmentsfile <- paste0(intra_species_dir, "/segments.txt")

                    segs <- suppressMessages(
                        vroom(
                            segmentsfile,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )

                    multiplicons <- suppressMessages(
                        vroom(
                            multiplicon_file,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )
                    final_multiplicons <- fill(multiplicons, genome_x, list_x, .direction="down")
                    colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                                      "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")

                    final_anchorpoints <- suppressMessages(
                        vroom(
                            anchorpointout_file,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )

                    searchGene <- input[["gene_intra"]]

                    if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                        searched_multiplicon_list <- unique(final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]$multiplicon)
                        searched_multiplicons_df <- final_multiplicons[final_multiplicons$multiplicon %in% searched_multiplicon_list, ]
                        searched_multiplicons_df <- searched_multiplicons_df[searched_multiplicons_df$is_redundant == 0, ]
                        searched_multiplicon_list <- searched_multiplicons_df$multiplicon
                        searched_anchor_points_df <- final_anchorpoints[final_anchorpoints$multiplicon %in% searched_multiplicon_list, ]

                        if( length(searched_multiplicon_list) == 0 ){
                            shinyalert(
                                "Warning!",
                                "No Multiplicon found! Please search the target gene or select multiplcon to plot first...",
                                type="warning"
                            )
                        }
                        else{
                            query_selected_chr_list <- unique(c(searched_anchor_points_df$listX, searched_anchor_points_df$listY))
                            subject_selected_chr_list <- query_selected_chr_list

                            searched_chrs_coord_df <- data.frame()

                            searched_multiplicon_df <- data.frame()
                            searched_chrs_df <- data.frame()
                            searched_genes_df <- data.frame()
                            searched_anchor_points_df <- data.frame()
                            for( i in 1:length(searched_multiplicon_list) ){
                                each_multiplicon <- searched_multiplicon_list[i]
                                # get the multiplicon level
                                each_multiplicon_df <- final_multiplicons %>%
                                    filter(multiplicon == each_multiplicon)
                                each_level <- each_multiplicon_df$level
                                # print(paste("multiplicon:", each_multiplicon, "level:", each_level))
                                each_multiplicon_df$searched_multiplicon <- each_multiplicon

                                tmp_multiplicon_df <- data.frame()

                                tmp_multiplicon_df <- rbind(tmp_multiplicon_df, each_multiplicon_df)
                                if( each_level > 2 ){
                                    # find the parent multiplcon
                                    previous_parent_multiplicon <- NA

                                    parent_multiplicon <- each_multiplicon_df$parent
                                    parent_multiplicon_df <- final_multiplicons %>%
                                        filter(multiplicon == parent_multiplicon)
                                    parent_multiplicon_df$searched_multiplicon <- each_multiplicon
                                    tmp_multiplicon_df <- rbind(tmp_multiplicon_df, parent_multiplicon_df)

                                    not_parent_multiplicon <- TRUE
                                    while( not_parent_multiplicon ){
                                        parent_multiplicon <- unique(final_multiplicons[final_multiplicons$multiplicon == parent_multiplicon, ]$parent)
                                        pre_multiplicon_df <- final_multiplicons %>%
                                            filter(multiplicon == parent_multiplicon)
                                        pre_multiplicon_df$searched_multiplicon <- each_multiplicon
                                        tmp_multiplicon_df <- rbind(tmp_multiplicon_df, pre_multiplicon_df)
                                        if( is.na(parent_multiplicon) ){
                                            break
                                        }
                                    }
                                }

                                searched_multiplicon_df <- rbind(searched_multiplicon_df, tmp_multiplicon_df)

                                # get segments
                                each_segs_df <- segs %>%
                                    filter(multiplicon == each_multiplicon)
                                each_segs_df$searched_multiplicon <- each_multiplicon

                                gff_file1 <- sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath
                                gff_df1 <- suppressMessages(
                                    vroom(
                                        gff_file1,
                                        delim="\t",
                                        comment="#",
                                        col_names=FALSE
                                    )
                                )
                                position_df1 <- gff_df1 %>%
                                    filter(gff_df1$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9)) %>%
                                    filter(X1 %in% query_selected_chr_list)
                                colnames(position_df1) <- c("seqchr", "gene", "start", "end", "strand")

                                start_subset <- select(position_df1, gene, start)
                                merged_data <- left_join(
                                    each_segs_df,
                                    start_subset,
                                    by=c("first"="gene")
                                )
                                end_subset <- select(position_df1, gene, end)
                                merged_data <- left_join(
                                    merged_data,
                                    end_subset,
                                    by=c("last"="gene")
                                )
                                each_segs_df <- merged_data %>%
                                    select(-id)
                                colnames(each_segs_df) <- c(
                                    "multiplicon", "genome", "list",
                                    "first", "last", "order", "searched_multiplicon",
                                    "min", "max"
                                )

                                searched_chrs_df <- rbind(searched_chrs_df, each_segs_df)

                                # get segments coord
                                each_seg_coord_df <- segs %>%
                                    filter(multiplicon == each_multiplicon)
                                each_seg_coord_df$searched_multiplicon <- each_multiplicon

                                genes_coord_subset <- select(genes_df, id, coordinate)
                                merged_data_tmp <- left_join(
                                    each_seg_coord_df,
                                    genes_coord_subset,
                                    by=c("first"="id")
                                )

                                merged_data_tmp <- left_join(
                                    merged_data_tmp,
                                    genes_coord_subset,
                                    by=c("last"="id")
                                )
                                each_seg_coord_df <- merged_data_tmp %>%
                                    select(-id)

                                colnames(each_seg_coord_df) <- c(
                                    "multiplicon", "genome", "list",
                                    "first", "last", "order", "searched_multiplicon",
                                    "min", "max"
                                )

                                searched_chrs_coord_df <- rbind(searched_chrs_coord_df, each_seg_coord_df)

                                # get gene info
                                each_genes_df <- position_df1 %>%
                                    inner_join(each_segs_df, by=c("seqchr"="list"), multiple="all") %>%
                                    filter(start >= min, end <= max) %>%
                                    distinct() %>%
                                    select(seqchr, gene, start, end, strand, searched_multiplicon, min, max) %>%
                                    mutate(start=start-min, end=end-min) %>%
                                    select(-min, -max)

                                tmp_genes_df <- each_genes_df %>%
                                    inner_join(genes_df, by=c("gene"="id"), multiple="all") %>%
                                    select(-genome, -list, -orientation)

                                tmp_genes_df$searched_multiplicon <- each_multiplicon
                                searched_genes_df <- rbind(searched_genes_df, tmp_genes_df)

                                # get anchor points
                                each_anchor_points_df <- final_anchorpoints %>%
                                    filter(geneX %in% tmp_genes_df$gene | geneY %in% tmp_genes_df$gene) %>%
                                    filter(multiplicon %in% tmp_multiplicon_df$multiplicon)
                                each_anchor_points_df$searched_multiplicon <- each_multiplicon

                                searched_anchor_points_df <- rbind(searched_anchor_points_df, each_anchor_points_df)
                            }

                            # print(searched_multiplicon_df)
                            # print(searched_genes_df)
                            # print(searched_chrs_df)
                            # print(searched_anchor_points_df)

                            # draw the micro level plot
                            widthSpacingMicro <- reactiveValues(
                                value=800
                            )
                            heightSpacingMicro <- reactiveValues(
                                value=50
                            )
                            observeEvent(input[["svg_vertical_spacing_add_micro_intra"]], {
                                heightSpacingMicro$value <- heightSpacingMicro$value + 50
                            })
                            observeEvent(input[["svg_vertical_spacing_sub_micro_intra"]], {
                                heightSpacingMicro$value <- heightSpacingMicro$value - 50
                            })
                            observeEvent(input[["svg_horizontal_spacing_add_micro_intra"]], {
                                widthSpacingMicro$value <- widthSpacingMicro$value + 50
                            })
                            observeEvent(input[["svg_horizontal_spacing_sub_micro_intra"]], {
                                widthSpacingMicro$value <- widthSpacingMicro$value - 50
                            })

                            #selectedGene_df <- rbind(selectedQueryGenes, selectedSubjectGenes)

                            # write.table(
                            #     searched_chrs_coord_df,
                            #     file=paste0(intra_species_dir, "/test.chr_coord.txt"),
                            #     col.names=T,
                            #     row.names=F,
                            #     quote=F,
                            #     sep="\t"
                            # )
                            # print(input$multiplicon_choose_intra)
                            # print(input[["gene_intra"]])
                            observe({
                                selected_multiplicons_df <- searched_multiplicon_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_intra)

                                heightMicroPlot_intra <- 150 * nrow(selected_multiplicons_df) + 100

                                selected_gene_df <- searched_genes_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_intra)

                                selected_anchor_point_df <- searched_anchor_points_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_intra)

                                # cluster genes
                                anchor_point_group_df <- selected_anchor_point_df[, c("geneX", "geneY")]

                                tmp_links_g <- graph_from_data_frame(anchor_point_group_df)
                                tmp_cluster_g <- clusters(tmp_links_g)

                                anchor_point_group_df$group <- tmp_cluster_g$membership[as.character(anchor_point_group_df$geneX)]

                                if( input$scale_plotMicro_intra == "True length" ){
                                    selected_chr_df <- searched_chrs_df %>%
                                        filter(searched_multiplicon == input$multiplicon_choose_intra)

                                    microSynPlotData <- list(
                                        "plot_id"="intra",
                                        "anchorpoints"=selected_anchor_point_df,
                                        "multiplicons"=selected_multiplicons_df,
                                        "genes"=distinct(selected_gene_df),
                                        "achorPointGroups"=anchor_point_group_df,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "chrs"=selected_chr_df,
                                        "targe_gene"=input[["gene_intra"]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightMicroPlot_intra,
                                        "heightScale"=heightSpacingMicro$value
                                    )
                                    if( isTruthy(input$color_homolog_intra) && input$color_homolog_intra){
                                        microSynPlotData[["color_gene"]] <- 1
                                    }else{
                                        microSynPlotData[["color_gene"]] <- 0
                                    }

                                    if( isTruthy(input$link_plotMicro_intra) && input$link_plotMicro_intra == "Pairwise" ){
                                        microSynPlotData[["link_all"]] <- 0
                                    }else{
                                        microSynPlotData[["link_all"]] <- 1
                                    }
                                    session$sendCustomMessage("microSynPlotting", microSynPlotData)
                                }
                                else{
                                    selected_chr_coord_df <- searched_chrs_coord_df %>%
                                        filter(searched_multiplicon == input$multiplicon_choose_intra)

                                    microSynPlotData <- list(
                                        "plot_id"="intra",
                                        "anchorpoints"=selected_anchor_point_df,
                                        "multiplicons"=selected_multiplicons_df,
                                        "genes"=distinct(selected_gene_df),
                                        "achorPointGroups"=anchor_point_group_df,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "chrs"=selected_chr_coord_df,
                                        "targe_gene"=input[["gene_intra"]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightMicroPlot_intra,
                                        "heightScale"=heightSpacingMicro$value
                                    )
                                    if( isTruthy(input$color_homolog_intra) && input$color_homolog_intra){
                                        microSynPlotData[["color_gene"]] <- 1
                                    }else{
                                        microSynPlotData[["color_gene"]] <- 0
                                    }

                                    if( isTruthy(input$link_plotMicro_intra) && input$link_plotMicro_intra == "Pairwise" ){
                                        microSynPlotData[["link_all"]] <- 0
                                    }else{
                                        microSynPlotData[["link_all"]] <- 1
                                    }
                                    session$sendCustomMessage("microSynPlottingGeneNumber", microSynPlotData)
                                }

                            })
                        }
                    }

                    Sys.sleep(.9)
                    incProgress(amount=1, message="Drawing Micro Synteny Done")
                })
            }
        }
        else{
            shinyalert(
                "Warning!",
                "Please select a multiplicon first and then switch on this ...",
                type="warning",
            )
        }
    }
})

observeEvent(input$confirm_inter_comparing_go, {
    if( isTruthy(input$inter_list_A) && isTruthy(input$inter_list_B) ){
        shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
        shinyjs::runjs("$('#confirm_inter_comparing_go').css('background-color', 'green');")
        updateActionButton(
            session,
            "confirm_inter_comparing_go",
            icon=icon("check")
        )

        setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_inter_comparing_go').css('background-color', '#C0C0C0');
            }, 6000);"

        shinyjs::runjs(setTimeoutFunction)

        collinearAnalysisDir <- collinear_analysis_dir_Val()

        load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

        tmp_comparing_id_1 <- paste0(input$inter_list_A[1], "_vs_", input$inter_list_B[1])
        tmp_comparing_id_2 <- paste0(input$inter_list_B[1], "_vs_", input$inter_list_A[1])
        comparing_df <- path_df[path_df$comparing_ID == tmp_comparing_id_1 |
                                    path_df$comparing_ID == tmp_comparing_id_2, ]

        split_values <- strsplit(comparing_df$comparing_ID, "_vs_")[[1]]

        query_species <- gsub("_", " ", split_values[1])
        subject_species <- gsub("_", " ", split_values[2])

        withProgress(message='Configuration in progress', value=0, {
            Sys.sleep(.2)
            incProgress(amount=.3, message="Configuring...")

            color_list <- c("#F5FFE8", "#ECF5FF", "#FDFFFF", "#FBFFFD", "#F0FFF0",
                            "#FBFBFF", "#FFFFF4", "#FFFCEC", "#FFFAF4", "#FFF3EE")
            color_list_selected <- rep(color_list, length.out=nrow(path_df))

            panelTitle <- paste0("<font color='#FFD374'><b><i>",
                                 query_species,
                                 "</i></font> versus <font color='#E1B8FF'><i>",
                                 subject_species, "</i></b></font>")
            queryChrPanelTitle <- HTML(paste("Select <font color='#68AC57'><i><b>", query_species, "</b></i></font> chromosomes:"))

            subjectChrPanelTitle <- HTML(paste("Select <font color='#8E549E'><i><b>", subject_species, "</b></i></font> Chromosomes:"))

            output$iadhore_output <- renderUI({
                div(
                    class="boxLike",
                    style="padding-right: 50px;
                               padding-left: 50px;
                               padding-top: 10px;
                               padding-bottom: 10px;
                               background-color: white",
                    fluidRow(
                        column(
                            width=12,
                            div(
                                style="padding-bottom: 10px;",
                                bsButton(
                                    inputId="plot_inter_button",
                                    label=HTML(panelTitle),
                                    style="info"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to see more details",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse("plot_panel_collapse_inter"),
                                bs_collapse(
                                    id="plot_panel_collapse_inter",
                                    show=TRUE,
                                    content=tags$div(
                                        class="well",
                                        fluidRow(
                                            div(
                                                style="padding-right: 30px;
                                                      padding-left: 30px;
                                                      padding-top: 10px;
                                                      padding-bottom: 10px;",
                                                fluidRow(
                                                    column(
                                                        2,
                                                        h5(HTML(paste0("<font color='orange'>", icon("dna"), "&nbsp;Chromosome</font> setting")))
                                                    ),
                                                    column(
                                                        3,
                                                        div(
                                                            style="padding: 12px 10px 5px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #F8F8FF",
                                                            sliderInput(
                                                                inputId="chr_num_cutoff",
                                                                label=HTML("Set the <font color='orange'>mininum gene number</font> in the chromosome:"),
                                                                min=0,
                                                                max=500,
                                                                step=50,
                                                                value=100
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        3,
                                                        div(
                                                            style="padding: 12px 10px 20px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #F8F8FF",
                                                            pickerInput(
                                                                inputId="synteny_query_chr_inter",
                                                                label=queryChrPanelTitle,
                                                                options=list(
                                                                    title='Please select chromosomes below',
                                                                    `selected-text-format`="count > 1",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=TRUE
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        3,
                                                        div(
                                                            style="padding: 12px 10px 20px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #F8F8FF",
                                                            pickerInput(
                                                                inputId="synteny_subject_chr_inter",
                                                                label=subjectChrPanelTitle,
                                                                options=list(
                                                                    title='Please select chromosomes below',
                                                                    `selected-text-format`="count > 1",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=TRUE
                                                            )
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        2,
                                                        h5(HTML("<font color='orange'>Anchor points</font> setting:"))
                                                    ),
                                                    column(
                                                        3,
                                                        div(
                                                            style="padding: 12px 10px 5px 10px;
                                                                   border-radius: 10px;
                                                                   background-color: #FFF5EE;",
                                                            sliderInput(
                                                                inputId="anchoredPointsCutoff_inter",
                                                                label=HTML("Set <font color='orange'>anchor points per multiplicon:</font>"),
                                                                min=3,
                                                                max=30,
                                                                step=1,
                                                                value=3
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        3,
                                                        actionButton(
                                                            inputId="synplot_go_inter",
                                                            "Draw Syntenty Plot",
                                                            icon=icon("pencil-alt"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #009393;
                                                                   border-color: #fff;
                                                                   padding: 5px 10px 5px 10px;
                                                                   margin: 50px 5px 5px 35px;"
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h6(HTML("<b>The Dot Plot:</b>")),
                                                        tags$style(
                                                            HTML(".rotate-135 {
                                                                    transform: rotate(135deg);
                                                                }"),
                                                            HTML(".rotate-45{
                                                                    transform: rotate(45deg);
                                                                }")
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_add_dot_inter",
                                                            "",
                                                            icon("arrows-alt-v", class="rotate-45"),
                                                            title="Expand spacing"
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_sub_dot_inter",
                                                            "",
                                                            icon(
                                                                "down-left-and-up-right-to-center",
                                                                verify_fa=FALSE,
                                                            ),
                                                            title="Compress spacing"
                                                        ),

                                                        downloadButton_custom(
                                                            "download_dotView_inter",
                                                            title="Download the Plot",
                                                            status="secondary",
                                                            icon=icon("download"),
                                                            label=HTML(""),
                                                            class="my-download-button-class",
                                                            style="color: #fff;
                                                                   background-color: #6B8E23;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;"
                                                        )
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="dotView_inter"
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h6(HTML("<b>The Parallel Link Plot:</b>"))
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="/*display: flex; align-items: center;*/
                                                                   text-align: center;
                                                                   margin-bottom: 10px;                                                   border-radius: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 10px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            actionButton(
                                                                "svg_vertical_spacing_add_rainbow_inter",
                                                                "",
                                                                icon("arrows-alt-v"),
                                                                title="Expand vertical spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_vertical_spacing_sub_rainbow_inter",
                                                                "",
                                                                icon(
                                                                    "down-left-and-up-right-to-center",
                                                                    verify_fa=FALSE,
                                                                    class="rotate-135"
                                                                ),
                                                                title="Compress vertical spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_horizontal_spacing_add_rainbow_inter",
                                                                "",
                                                                icon("arrows-alt-h"),
                                                                title="Expand horizontal spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_horizontal_spacing_sub_rainbow_inter",
                                                                "",
                                                                icon(
                                                                    "down-left-and-up-right-to-center",
                                                                    verify_fa=FALSE,
                                                                    class="rotate-45"
                                                                ),
                                                                title="Compress horizontal spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                "download_SyntenicBlock_inter",
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                class="my-download-button-class",
                                                                style="color: #fff;
                                                                   background-color: #6B8E23;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;"
                                                            )
                                                        )
                                                    ),
                                                    # column(
                                                    #     4,
                                                    #     div(
                                                    #         style="/*margin-bottom: 10px;*/
                                                    #                border-radius: 10px;
                                                    #                padding: 5px 10px 0px 10px;
                                                    #                background-color: #FFF5EE;",
                                                    #         prettyRadioButtons(
                                                    #             inputId="scale_data_inter",
                                                    #             label=HTML("<font color='orange'>Data used</font>:"),
                                                    #             choices=c("Anchor points", "Segments"),
                                                    #             selected="Anchor points",
                                                    #             icon=icon("check"),
                                                    #             inline=TRUE,
                                                    #             status="info",
                                                    #             animation="jelly"
                                                    #         )
                                                    #     )
                                                    # ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="margin-bottom: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 5px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            prettyRadioButtons(
                                                                inputId="scale_link_inter",
                                                                label=HTML("<font color='orange'>Scale in</font>:"),
                                                                choices=c("Gene number", "True length"),
                                                                selected="Gene number",
                                                                icon=icon("check"),
                                                                inline=TRUE,
                                                                status="info",
                                                                animation="jelly"
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="SyntenicBlock_inter"
                                                    )
                                                ),
                                                hr(class="splitting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h5(HTML("<font color='#00DB00'><b>Multiplicon-level Synteny</b></font>"))
                                                    )
                                                ),
                                                fluidRow(
                                                    column(
                                                        4,
                                                        textInput(
                                                            inputId="gene_inter",
                                                            label="Seach the Gene:",
                                                            value="",
                                                            width="100%",
                                                            placeholder="Gene Id"
                                                        )
                                                    ),
                                                    column(
                                                        1,
                                                        actionButton(
                                                            inputId="searchButton_inter",
                                                            "",
                                                            width="40px",
                                                            icon=icon("search"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #8080C0;
                                                                   border-color: #fff;
                                                                   margin: 30px 0px 0px -15px; "
                                                        )
                                                    ),
                                                    column(
                                                        7,
                                                        uiOutput("foundItemsMessage_inter")
                                                    ),
                                                ),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        uiOutput("multiplicon_mirco_inter_plot")
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            })

            incProgress(amount=1, message="Configuration Done")
            Sys.sleep(.4)
        })

        observe({
            if( length(collinearAnalysisDir) > 0 && !is.null(input$chr_num_cutoff) ){
                inter_species_dir <- dirname(comparing_df$comparing_Path)
                genesFile <- paste0(inter_species_dir, "/genes.txt")
                chr_gene_num_file <- paste0(inter_species_dir, "/chr_gene_nums.txt")

                if( !file.exists(chr_gene_num_file) ){
                    if( file.exists(genesFile) ){
                        genes <- suppressMessages(
                            vroom(
                                genesFile,
                                delim="\t",
                                col_names=TRUE
                            )
                        )
                        gene_num_df <- aggregate(coordinate ~ genome + list, genes, max)
                        colnames(gene_num_df) <- c("sp", "seqchr", "gene_num")
                        gene_num_df$gene_num <- gene_num_df$gene_num + 1
                        write.table(
                            gene_num_df,
                            file=chr_gene_num_file,
                            sep="\t",
                            quote=F,
                            row.names=FALSE
                        )
                    }
                    else{
                        shinyalert(
                            "Oops",
                            "Fail to find correct ouputs of i-ADHoRe for ", intra_list,". Please ensure the output of i-ADHoRe, and then try again...",
                            type="error"
                        )
                    }
                }else{
                    gene_num_df <- read.table(
                        chr_gene_num_file,
                        sep="\t",
                        header=TRUE
                    )
                }

                if( is.null(gene_num_df) ){
                    querys <- NULL
                }else{
                    querys <- gene_num_df %>%
                        filter(
                            gene_num >= input$chr_num_cutoff,
                            sp == gsub(" ", "_", query_species)
                        ) %>%
                        arrange(seqchr) %>%
                        pull(seqchr)
                }
                if( length(querys) > 0 ){
                    updatePickerInput(
                        session,
                        "synteny_query_chr_inter",
                        choices=gtools::mixedsort(querys),
                        choicesOpt=list(
                            content=lapply(gtools::mixedsort(querys), function(choice) {
                                HTML(paste0("<div style='color: #68AC57;'>", choice, "</div>"))
                            })
                        )
                    )
                }else{
                    shinyalert(
                        "Oops",
                        "No chromosome found. Please lower the cutoff of gene number in the chromosome, and then try again...",
                        type="error"
                    )
                }

                if( is.null(gene_num_df) ){
                    subjects <- NULL
                }else{
                    subjects <- gene_num_df %>%
                        filter(
                            gene_num >= input$chr_num_cutoff,
                            sp == gsub(" ", "_", subject_species)
                        ) %>%
                        arrange(seqchr) %>%
                        pull(seqchr)
                }
                if( length(subjects) > 0 ){
                    updatePickerInput(
                        session,
                        "synteny_subject_chr_inter",
                        choices=gtools::mixedsort(subjects),
                        choicesOpt=list(
                            content=lapply(gtools::mixedsort(subjects), function(choice) {
                                HTML(paste0("<div style='color: #68AC57;'>", choice, "</div>"))
                            })
                        )
                    )
                }else{
                    shinyalert(
                        "Oops",
                        "No chromosome found. Please lower the cutoff of gene number in the chromosome, and then try again...",
                        type="error"
                    )
                }
            }
        })
    }else{
        shinyalert(
            "Oops",
            "Please select the species first, and then click the confirm button...",
            type="error"
        )
    }
})

observeEvent(input$synplot_go_inter, {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$inter_list_A) && isTruthy(input$inter_list_B) ){
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

            output$foundItemsMessage_inter <- renderUI({
                HTML("")
            })

            output$multiplicon_mirco_inter_plot <- renderUI({
                HTML("")
            })

            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

            tmp_comparing_id_1 <- paste0(input$inter_list_A[1], "_vs_", input$inter_list_B[1])
            tmp_comparing_id_2 <- paste0(input$inter_list_B[1], "_vs_", input$inter_list_A[1])
            comparing_df <- path_df[path_df$comparing_ID == tmp_comparing_id_1 |
                                        path_df$comparing_ID == tmp_comparing_id_2, ]

            inter_species_dir <- dirname(comparing_df$comparing_Path)

            split_values <- strsplit(comparing_df$comparing_ID, "_vs_")[[1]]

            querySpecies <- gsub("_", " ", split_values[1])
            subjectSpecies <- gsub("_", " ", split_values[2])

            syn_dir <- dirname(dirname(dirname(comparing_df$comparing_Path)))[1]
            sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")

            sp_chr_len_file <- paste0(dirname(sp_gff_info_xls), "/species_chr_len.RData")
            load(sp_chr_len_file)

            sp_gff_info_df <- suppressMessages(
                vroom(
                    sp_gff_info_xls,
                    col_names=c("species", "cdsPath", "gffPath"),
                    delim="\t"
                )
            )
            cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
            gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
            new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
            new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
            sp_gff_info_df$cdsPath <- new_cds_files
            sp_gff_info_df$gffPath <- new_gff_files

            query_selected_chr_list <- input$synteny_query_chr_inter
            query_chr_len_df <- chr_len_df[chr_len_df$sp==split_values[1], ] %>%
                filter(seqchr %in% query_selected_chr_list)

            subject_selected_chr_list <- input$synteny_subject_chr_inter
            subject_chr_len_df <- chr_len_df[chr_len_df$sp==split_values[2], ] %>%
                filter(seqchr %in% subject_selected_chr_list)

            chr_gene_num_file <- paste0(inter_species_dir, "/chr_gene_nums.txt")

            gene_num_df <- read.table(
                chr_gene_num_file,
                sep="\t",
                header=TRUE
            )

            withProgress(message='Analyzing in progress', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.3, message="Preparing Data...")
                genesFile <- paste0(inter_species_dir, "/genes.txt")
                multiplicon_file <- paste0(inter_species_dir, "/multiplicons.txt")
                multiplicon_ks_file <- paste0(inter_species_dir, "/multiplicons.merged_ks.txt")
                anchorpointfile <- paste0(inter_species_dir, "/anchorpoints.txt")
                anchorpoint_merged_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos.txt")
                anchorpointout_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos_ks.txt")
                ks_file <- paste0(inter_species_dir, "/anchorpoints.ks.txt")

                if( file.exists(ks_file) ){
                    if( !file.exists(anchorpointout_file) ){
                        obtain_coordiantes_for_anchorpoints(
                            anchorpoints=anchorpointfile,
                            species1=querySpecies,
                            gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                            species2=subjectSpecies,
                            gff_file2=sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath,
                            out_file=anchorpoint_merged_file
                        )
                    }

                    if( !file.exists(multiplicon_ks_file) ){
                        obtain_mean_ks_for_each_multiplicon(
                            multiplicon_file=multiplicon_file,
                            anchorpoint_file=anchorpoint_merged_file,
                            ks_file=ks_file,
                            species1=querySpecies,
                            species2=subjectSpecies,
                            anchorpointout_file=anchorpointout_file,
                            outfile=multiplicon_ks_file
                        )
                    }
                }
                else{
                    shinyalert(
                        "Opps!",
                        paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of shinyWGD first ..."),
                        type="error",
                    )
                }

                Sys.sleep(.2)
                incProgress(amount=.3, message="Calculating Done")

                final_multiplicons <- suppressMessages(
                    vroom(
                        multiplicon_ks_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )

                final_anchorpoints <- suppressMessages(
                    vroom(
                        anchorpointout_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )

                query_chr_num_df <- gene_num_df %>%
                    filter(sp==gsub(" ", "_", querySpecies)) %>%
                    filter(seqchr %in% query_selected_chr_list)

                subject_chr_num_df <- gene_num_df %>%
                    filter(sp==gsub(" ", "_", subjectSpecies)) %>%
                    filter(seqchr %in% subject_selected_chr_list)

                anchoredPointScutoff <- "anchoredPointsCutoff_inter"

                selected_multiplicons <- final_multiplicons %>%
                    filter(listX %in% query_selected_chr_list) %>%
                    filter(listY %in% subject_selected_chr_list) %>%
                    filter(num_anchorpoints >= input[[anchoredPointScutoff]])

                selected_multiplicons_Id <- selected_multiplicons$multiplicon

                depth_list <- computing_depth(
                    anchorpoint_ks_file=anchorpointout_file,
                    multiplicon_id=selected_multiplicons_Id,
                    selected_query_chr=query_selected_chr_list,
                    selected_subject_chr=subject_selected_chr_list
                )
                query_selected_depth_list <- depth_list$query_depth
                subject_selected_depth_list <- depth_list$subject_depth

                selected_anchorpoints <- final_anchorpoints %>%
                    filter(listX %in% query_selected_chr_list) %>%
                    filter(listY %in% subject_selected_chr_list) %>%
                    filter(multiplicon %in% selected_multiplicons_Id)

                plotSize <- reactiveValues(
                    value=400
                )
                observeEvent(input[["svg_spacing_add_dot_inter"]], {
                    plotSize$value <- plotSize$value + 50
                })
                observeEvent(input[["svg_spacing_sub_dot_inter"]], {
                    plotSize$value <- plotSize$value - 50
                })
                Sys.sleep(.2)
                incProgress(amount=.3, message="Drawing Dot Plot...")

                observe({
                    plot_dot_num_data <- list(
                        "plot_id"="dotView_inter",
                        "multiplicons"=selected_multiplicons,
                        "anchorpoints"=selected_anchorpoints,
                        "query_sp"=querySpecies,
                        "query_chr_gene_nums"=query_chr_num_df,
                        "query_depths"=query_selected_depth_list,
                        "subject_sp"=subjectSpecies,
                        "subject_chr_gene_nums"=subject_chr_num_df,
                        "subject_depths"=subject_selected_depth_list,
                        "size"=plotSize$value
                    )
                    session$sendCustomMessage("Dot_Num_Plotting", plot_dot_num_data)
                })
                Sys.sleep(.2)
                incProgress(amount=1, message="Drawing Dot Plot Done")
            })

            # plot parallel figure
            withProgress(message='Parallel Syntenty Figure in progress', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.3, message="Drawing Parallel Syntenty Plot...")
                segmentsfile <- paste0(inter_species_dir, "/segments.txt")
                segs_pos_file <- paste0(inter_species_dir, "/segments.merged_pos.txt")

                observe({
                        widthSpacingRainbow <- reactiveValues(
                            value=800
                        )
                        heightSpacingRainbow <- reactiveValues(
                            value=300
                        )
                        observeEvent(input[["svg_vertical_spacing_add_rainbow_inter"]], {
                            heightSpacingRainbow$value <- heightSpacingRainbow$value + 50
                        })
                        observeEvent(input[["svg_vertical_spacing_sub_rainbow_inter"]], {
                            heightSpacingRainbow$value <- heightSpacingRainbow$value - 20
                        })
                        observeEvent(input[["svg_horizontal_spacing_add_rainbow_inter"]], {
                            widthSpacingRainbow$value <- widthSpacingRainbow$value + 50
                        })
                        observeEvent(input[["svg_horizontal_spacing_sub_rainbow_inter"]], {
                            widthSpacingRainbow$value <- widthSpacingRainbow$value - 50
                        })
                        if( input$scale_link_inter == "True length" ){
                            plot_parallel_data <- list(
                                "plot_id"="SyntenicBlock_inter",
                                "segs"=selected_anchorpoints,
                                "query_sp"=querySpecies,
                                "query_chr_lens"=query_chr_len_df,
                                "subject_sp"=subjectSpecies,
                                "subject_chr_lens"=subject_chr_len_df,
                                "width"=widthSpacingRainbow$value,
                                "height"=heightSpacingRainbow$value #,
                                # "anchor_pair"="anchor_pair"
                            )
                            session$sendCustomMessage("Parallel_Plotting", plot_parallel_data)
                        }
                        else{
                            plot_parallel_data <- list(
                                "plot_id"="SyntenicBlock_inter",
                                "anchorpoints"=selected_anchorpoints,
                                "query_sp"=querySpecies,
                                "query_chr_nums"=query_chr_num_df,
                                "subject_sp"=subjectSpecies,
                                "subject_chr_nums"=subject_chr_num_df,
                                "width"=widthSpacingRainbow$value,
                                "height"=heightSpacingRainbow$value
                            )
                            session$sendCustomMessage("Parallel_Number_Plotting", plot_parallel_data)
                        }
                    # }
                })

                Sys.sleep(.3)
                incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
            })
        }
    }
})

observeEvent(input[["searchButton_inter"]], {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$inter_list_A) && isTruthy(input$inter_list_B) ){
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

            tmp_comparing_id_1 <- paste0(input$inter_list_A[1], "_vs_", input$inter_list_B[1])
            tmp_comparing_id_2 <- paste0(input$inter_list_B[1], "_vs_", input$inter_list_A[1])
            comparing_df <- path_df[path_df$comparing_ID == tmp_comparing_id_1 |
                                        path_df$comparing_ID == tmp_comparing_id_2, ]

            split_values <- strsplit(comparing_df$comparing_ID, "_vs_")[[1]]

            querySpecies <- gsub("_", " ", split_values[1])
            subjectSpecies <- gsub("_", " ", split_values[2])

            inter_species_dir <- dirname(comparing_df$comparing_Path)
            genesFile <- paste0(inter_species_dir, "/genes.txt")
            multiplicon_file <- paste0(inter_species_dir, "/multiplicons.txt")
            multiplicon_ks_file <- paste0(inter_species_dir, "/multiplicons.merged_ks.txt")
            anchorpointfile <- paste0(inter_species_dir, "/anchorpoints.txt")
            anchorpoint_merged_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos.txt")
            anchorpointout_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos_ks.txt")
            ks_file <- paste0(inter_species_dir, "/anchorpoints.ks.txt")

            withProgress(message='Searching Gene in progress', value=0, {
                Sys.sleep(.8)
                incProgress(amount=.2, message="Preparing Data...")
                syn_dir <- dirname(dirname(dirname(comparing_df$comparing_Path)))[1]
                sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")
                sp_gff_info_df <- suppressMessages(
                    vroom(
                        sp_gff_info_xls,
                        col_names=c("species", "cdsPath", "gffPath"),
                        delim="\t"
                    )
                )
                cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
                gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
                new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
                new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
                sp_gff_info_df$cdsPath <- new_cds_files
                sp_gff_info_df$gffPath <- new_gff_files

                if( file.exists(ks_file) ){
                    if( !file.exists(anchorpointout_file) ){
                        obtain_coordiantes_for_anchorpoints(
                            anchorpoints=anchorpointfile,
                            species1=querySpecies,
                            gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                            species2=subjectSpecies,
                            gff_file2=sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath,
                            out_file=anchorpoint_merged_file
                        )
                    }

                    if( !file.exists(multiplicon_ks_file) ){
                        obtain_mean_ks_for_each_multiplicon(
                            multiplicon_file=multiplicon_file,
                            anchorpoint_file=anchorpoint_merged_file,
                            ks_file=ks_file,
                            species1=querySpecies,
                            species2=subjectSpecies,
                            anchorpointout_file=anchorpointout_file,
                            outfile=multiplicon_ks_file
                        )
                    }
                    Sys.sleep(.2)
                    incProgress(amount=.3, message="Calculating Done")
                }
                else{
                    shinyalert(
                        "Opps!",
                        paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of shinyWGD first ..."),
                        type="error",
                    )
                }

                final_anchorpoints <- suppressMessages(
                    vroom(
                        anchorpointout_file,
                        col_names=TRUE,
                        delim="\t")
                )

                multiplicons <- suppressMessages(
                    vroom(
                        multiplicon_file,
                        col_names=TRUE,
                        delim="\t"
                    )
                )
                final_multiplicons <- fill(multiplicons, genome_x, list_x, .direction="down")
                colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                                  "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")

                searchGene <- input[["gene_inter"]]
                if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                    searched_multiplicon_list <- unique(final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]$multiplicon)
                    searched_multiplicon_df <- final_multiplicons[final_multiplicons$multiplicon %in% searched_multiplicon_list, ]
                    searched_multiplicon_list <- searched_multiplicon_df[searched_multiplicon_df$is_redundant == 0, ]$multiplicon
                    searched_anchor_points <- distinct(final_anchorpoints[final_anchorpoints$multiplicon %in% searched_multiplicon_list, ])

                    uiId <- "foundItemsMessage_inter"
                    output[[uiId]] <- renderUI({
                        if( length(searched_multiplicon_list) > 0 ){
                            fluidRow(
                                column(
                                    8,
                                    div(
                                        style="border: 1px solid #ccc;
                                               padding: 2px;
                                               margin-top: 35px;
                                               margin-left: -40px;
                                               border-radius: 10px;
                                               background-color: white;
                                               font-family: Times New Roman, Times, serif; white-space: pre-wrap;",

                                        if( length(searched_multiplicon_list) == 1 ){
                                            HTML(
                                                paste("<span style='color: #FF79BC; font-weight: bold;'>",
                                                      nrow(searched_anchor_points),
                                                      " Anchor Point is in Multiplicon (ID: <span style='color: #EA7500; font-weight: bold;'>",
                                                      searched_multiplicon_list[1],
                                                      "</span>)"
                                                )
                                            )
                                        }else{
                                            HTML(
                                                paste("<span style='color: #FF79BC; font-weight: bold;'>",
                                                      nrow(searched_anchor_points),
                                                      " Anchor Points are in Multiplicon (ID: <span style='color: #EA7500; font-weight: bold;'>",
                                                      paste(searched_multiplicon_list, collapse=", "),
                                                      "</span>)"
                                                )
                                            )
                                        }
                                    )
                                ),
                                column(
                                    4,
                                    actionButton(
                                        inputId="plotMicro_inter",
                                        "Draw Plot",
                                        icon=icon("pencil-alt"),
                                        status="secondary",
                                        class="my-start-button-class",
                                        style="color: #fff;
                                               background-color: #8080C0;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 32px 5px 5px 5px;"
                                    )
                                )
                            )
                        }
                        else{
                            div(
                                style="border: 1px solid #ccc;
                                       padding: 2px;
                                       margin-top: 30px;
                                       margin-left: -40px;
                                       border-radius: 10px;
                                       background-color: white;
                                       font-family: Times New Roman, Times, serif; white-space: pre-wrap;",
                                HTML("<span style='color: #FF79BC; font-weight: bold;'> No Anchor Point</span> is found!")
                            )
                        }
                    })

                    output$multiplicon_mirco_inter_plot <- renderUI({
                        div(
                            hr(class="setting"),
                            fluidRow(
                                column(
                                    3,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        pickerInput(
                                            inputId="multiplicon_choose_inter",
                                            label=HTML("Choose a <font color='orange'>multiplicon</font> to plot:"),
                                            options=list(
                                                title='Please select multiplicon below',
                                                `selected-text-format`="count > 1",
                                                `actions-box`=TRUE
                                            ),
                                            choices=NULL,
                                            selected=NULL,
                                            multiple=FALSE
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        prettyRadioButtons(
                                            inputId="scale_plotMicro_inter",
                                            label=HTML("<font color='orange'>Scale in</font>:"),
                                            choices=c("True length", "Gene number"),
                                            selected="True length",
                                            icon=icon("check"),
                                            status="info",
                                            animation="jelly"
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        prettyRadioButtons(
                                            inputId="link_plotMicro_inter",
                                            label=HTML("<font color='orange'>Link type</font>:"),
                                            choices=c("Pairwise", "All"),
                                            selected="Pairwise",
                                            icon=icon("check"),
                                            status="info",
                                            animation="jelly"
                                        )
                                    )
                                ),
                                # column(
                                #     3,
                                #     div(
                                #         style="margin-bottom: 10px;
                                #                border-radius: 10px;
                                #                padding: 10px 10px 0px 10px;
                                #                background-color: #FFF5EE;",
                                #         sliderInput(
                                #             inputId="level_intra",
                                #             label=HTML("Set <font color='orange'>maximum level of multiplicon:</font>"),
                                #             min=2,
                                #             max=10,
                                #             step=1,
                                #             value=5
                                #         )
                                #     )
                                # ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        HTML("Color <font color='orange'>homolog genes</font>:"),
                                        div(
                                            style="padding: 20px 10px 5px 10px;
                                                   background-color: #FFF5EE;",
                                            prettyToggle(
                                                inputId="color_homolog_inter",
                                                label_on="Yes!",
                                                icon_on=icon("check"),
                                                status_on="info",
                                                status_off="warning",
                                                label_off="No..",
                                                value=TRUE,
                                                icon_off=icon("remove", verify_fa=FALSE)
                                            )
                                        )
                                    )
                                )
                            ),
                            hr(class="setting"),
                            fluidRow(
                                column(
                                    12,
                                    h6(HTML("<b>The Synteny Link Plot:</b>")),
                                    actionButton(
                                        "svg_vertical_spacing_add_micro_inter",
                                        "",
                                        icon("arrows-alt-v"),
                                        title="Expand vertical spacing"
                                    ),
                                    actionButton(
                                        "svg_vertical_spacing_sub_micro_inter",
                                        "",
                                        icon(
                                            "down-left-and-up-right-to-center",
                                            verify_fa=FALSE,
                                            class="rotate-135"
                                        ),
                                        title="Compress vertical spacing"
                                    ),
                                    actionButton(
                                        "svg_horizontal_spacing_add_micro_inter",
                                        "",
                                        icon("arrows-alt-h"),
                                        title="Expand horizontal spacing"
                                    ),
                                    actionButton(
                                        "svg_horizontal_spacing_sub_micro_inter",
                                        "",
                                        icon(
                                            "down-left-and-up-right-to-center",
                                            verify_fa=FALSE,
                                            class="rotate-45"
                                        ),
                                        title="Compress horizontal spacing"
                                    ),
                                    downloadButton_custom(
                                        "download_microSyntenicBlock_inter",
                                        title="Download the Plot",
                                        status="secondary",
                                        icon=icon("download"),
                                        label=HTML(""),
                                        class="my-download-button-class",
                                        style="color: #fff;
                                               background-color: #6B8E23;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 5px 5px 5px 5px;"
                                    )
                                ),
                                column(
                                    width=12,
                                    id="microSyntenicBlock_inter"
                                )
                            )
                        )
                    })

                    observe({
                        selected_multiplicons_df <- searched_multiplicon_df %>%
                            filter(is_redundant == 0)

                        selected_multiplicons_list <- selected_multiplicons_df$multiplicon

                        updatePickerInput(
                            session,
                            "multiplicon_choose_inter",
                            choices=selected_multiplicons_list,
                            selected=selected_multiplicons_list[1],
                            choicesOpt=list(
                                content=lapply(selected_multiplicons_list, function(choice) {
                                    tmp_level <- selected_multiplicons_df %>%
                                        filter(multiplicon == choice)
                                    HTML(
                                        paste0(
                                            "<div>Multiplicon: <span style='color: #2E8B57; font-weight: bold;'>", choice, "</span>",
                                            " Level <span style='color: #6A5ACD; font-weight: bold;'>", tmp_level$level, "</span></div>"
                                        )
                                    )
                                })
                            )
                        )
                    })

                }else{
                    shinyalert(
                        "Warning!",
                        "Please input the correct gene name ...",
                        type="warning",
                    )
                }
                Sys.sleep(.9)
                incProgress(amount=1, message="Searching Done")
            })
        }
    }
})

observeEvent(input[["plotMicro_inter"]], {
    collinearAnalysisDir <- collinear_analysis_dir_Val()
    if( length(collinearAnalysisDir) > 0 ){
        if( isTruthy(input$multiplicon_choose_inter) && !is.null(input$multiplicon_choose_inter) ){
            if( isTruthy(input$gene_inter) && input$gene_inter != "" ){
                shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
                withProgress(message='Drawing Micro Synteny in progress', value=0, {
                    Sys.sleep(.5)
                    load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
                    tmp_comparing_id_1 <- paste0(input$inter_list_A[1], "_vs_", input$inter_list_B[1])
                    tmp_comparing_id_2 <- paste0(input$inter_list_B[1], "_vs_", input$inter_list_A[1])
                    comparing_df <- path_df[path_df$comparing_ID == tmp_comparing_id_1 |
                                                path_df$comparing_ID == tmp_comparing_id_2, ]

                    split_values <- strsplit(comparing_df$comparing_ID, "_vs_")[[1]]

                    querySpecies <- gsub("_", " ", split_values[1])
                    subjectSpecies <- gsub("_", " ", split_values[2])

                    inter_species_dir <- dirname(comparing_df$comparing_Path)

                    genesFile <- paste0(inter_species_dir, "/genes.txt")
                    multiplicon_file <- paste0(inter_species_dir, "/multiplicons.txt")
                    anchorpointfile <- paste0(inter_species_dir, "/anchorpoints.txt")
                    anchorpoint_merged_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos.txt")
                    anchorpointout_file <- paste0(inter_species_dir, "/anchorpoints.merged_pos_ks.txt")
                    ks_file <- paste0(inter_species_dir, "/anchorpoints.ks.txt")
                    genes_file <- paste0(inter_species_dir, "/genes.txt")

                    genes_df <- suppressMessages(
                        vroom(
                            genes_file,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )

                    syn_dir <- dirname(dirname(dirname(comparing_df$comparing_Path)))[1]
                    sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")
                    sp_gff_info_df <- suppressMessages(
                        vroom(
                            sp_gff_info_xls,
                            col_names=c("species", "cdsPath", "gffPath"),
                            delim="\t"
                        )
                    )
                    cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
                    gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
                    new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
                    new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
                    sp_gff_info_df$cdsPath <- new_cds_files
                    sp_gff_info_df$gffPath <- new_gff_files

                    segmentsfile <- paste0(inter_species_dir, "/segments.txt")

                    segs <- suppressMessages(
                        vroom(
                            segmentsfile,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )

                    multiplicons <- suppressMessages(
                        vroom(
                            multiplicon_file,
                            col_names=TRUE,
                            delim="\t"
                        )
                    )
                    final_multiplicons <- fill(multiplicons, genome_x, list_x, .direction="down")
                    colnames(final_multiplicons) <- c("multiplicon", "genomeX", "listX", "parent", "genomeY", "listY", "level",
                                                      "num_anchorpoints", "profile_len", "startX", "endX", "startY", "endY", "is_redundant")

                    final_anchorpoints <- suppressMessages(
                        vroom(
                            anchorpointout_file,
                            col_names=TRUE,
                            delim="\t")
                    )

                    searchGene <- input[["gene_inter"]]
                    if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                        searched_multiplicon_list <- unique(final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]$multiplicon)
                        searched_multiplicons_df <- final_multiplicons[final_multiplicons$multiplicon %in% searched_multiplicon_list, ]
                        searched_multiplicons_df <- searched_multiplicons_df[searched_multiplicons_df$is_redundant == 0, ]
                        searched_multiplicon_list <- searched_multiplicons_df$multiplicon
                        searched_anchor_points_df <- final_anchorpoints[final_anchorpoints$multiplicon %in% searched_multiplicon_list, ]

                        if( length(searched_multiplicon_list) == 0 ){
                            shinyalert(
                                "Warning!",
                                "No Multiplicon found! Please search the target gene or select multiplcon to plot first...",
                                type="warning"
                            )
                        }
                        else{
                            # print(searchGene)
                            query_selected_chr_list <- unique(c(searched_anchor_points_df$listX, searched_anchor_points_df$listY))
                            subject_selected_chr_list <- query_selected_chr_list

                            searched_chrs_coord_df <- data.frame()

                            searched_multiplicon_df <- data.frame()
                            searched_chrs_df <- data.frame()
                            searched_genes_df <- data.frame()
                            searched_anchor_points_df <- data.frame()
                            for( i in 1:length(searched_multiplicon_list) ){
                                each_multiplicon <- searched_multiplicon_list[i]
                                # get the multiplicon level
                                each_multiplicon_df <- final_multiplicons %>%
                                    filter(multiplicon == each_multiplicon)
                                each_level <- each_multiplicon_df$level
                                # print(paste("multiplicon:", each_multiplicon, "level:", each_level))
                                each_multiplicon_df$searched_multiplicon <- each_multiplicon

                                tmp_multiplicon_df <- data.frame()

                                tmp_multiplicon_df <- rbind(tmp_multiplicon_df, each_multiplicon_df)
                                if( each_level > 2 ){
                                    # find the parent multiplcon
                                    previous_parent_multiplicon <- NA

                                    parent_multiplicon <- each_multiplicon_df$parent
                                    parent_multiplicon_df <- final_multiplicons %>%
                                        filter(multiplicon == parent_multiplicon)
                                    parent_multiplicon_df$searched_multiplicon <- each_multiplicon
                                    tmp_multiplicon_df <- rbind(tmp_multiplicon_df, parent_multiplicon_df)

                                    not_parent_multiplicon <- TRUE
                                    while( not_parent_multiplicon ){
                                        parent_multiplicon <- unique(final_multiplicons[final_multiplicons$multiplicon == parent_multiplicon, ]$parent)
                                        pre_multiplicon_df <- final_multiplicons %>%
                                            filter(multiplicon == parent_multiplicon)
                                        if( nrow(pre_multiplicon_df) > 0 ){
                                            pre_multiplicon_df$searched_multiplicon <- each_multiplicon
                                            tmp_multiplicon_df <- rbind(tmp_multiplicon_df, pre_multiplicon_df)
                                            if( is.na(parent_multiplicon) ){
                                                break
                                            }
                                        }else{
                                            break
                                        }
                                    }
                                }

                                searched_multiplicon_df <- rbind(searched_multiplicon_df, tmp_multiplicon_df)

                                # get segments
                                each_segs_df <- segs %>%
                                    filter(multiplicon == each_multiplicon)
                                each_segs_df$searched_multiplicon <- each_multiplicon

                                gff_file1 <- sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath
                                gff_df1 <- suppressMessages(
                                    vroom(
                                        gff_file1,
                                        delim="\t",
                                        comment="#",
                                        col_names=FALSE
                                    )
                                )
                                position_df1 <- gff_df1 %>%
                                    filter(gff_df1$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))
                                colnames(position_df1) <- c("seqchr", "gene", "start", "end", "strand")

                                gff_file2 <- sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath
                                gff_df2 <- suppressMessages(
                                    vroom(
                                        gff_file2,
                                        delim="\t",
                                        comment="#",
                                        col_names=FALSE
                                    )
                                )
                                position_df2 <- gff_df2 %>%
                                    filter(gff_df2$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9))
                                colnames(position_df2) <- c("seqchr", "gene", "start", "end", "strand")

                                position_df <- rbind(position_df1, position_df2)

                                start_subset <- select(position_df, gene, start)
                                merged_data <- left_join(
                                    each_segs_df,
                                    start_subset,
                                    by=c("first"="gene")
                                )

                                end_subset <- select(position_df, gene, end)
                                merged_data <- left_join(
                                    merged_data,
                                    end_subset,
                                    by=c("last"="gene")
                                )

                                each_segs_df <- merged_data %>%
                                    select(-id)
                                colnames(each_segs_df) <- c(
                                    "multiplicon", "genome", "list",
                                    "first", "last", "order", "searched_multiplicon",
                                    "min", "max"
                                )

                                searched_chrs_df <- rbind(searched_chrs_df, each_segs_df)

                                # get segments coord
                                each_seg_coord_df <- segs %>%
                                    filter(multiplicon == each_multiplicon)
                                each_seg_coord_df$searched_multiplicon <- each_multiplicon

                                genes_coord_subset <- select(genes_df, id, coordinate)
                                merged_data_tmp <- left_join(
                                    each_seg_coord_df,
                                    genes_coord_subset,
                                    by=c("first"="id")
                                )

                                merged_data_tmp <- left_join(
                                    merged_data_tmp,
                                    genes_coord_subset,
                                    by=c("last"="id")
                                )
                                each_seg_coord_df <- merged_data_tmp %>%
                                    select(-id)

                                colnames(each_seg_coord_df) <- c(
                                    "multiplicon", "genome", "list",
                                    "first", "last", "order", "searched_multiplicon",
                                    "min", "max"
                                )

                                searched_chrs_coord_df <- rbind(searched_chrs_coord_df, each_seg_coord_df)

                                # get gene info
                                each_genes_df <- position_df %>%
                                    inner_join(each_segs_df, by=c("seqchr"="list"), multiple="all") %>%
                                    filter(start >= min, end <= max) %>%
                                    distinct() %>%
                                    select(seqchr, gene, start, end, strand, searched_multiplicon, min, max) %>%
                                    mutate(start=start-min, end=end-min) %>%
                                    select(-min, -max)

                                tmp_genes_df <- each_genes_df %>%
                                    inner_join(genes_df, by=c("gene"="id"), multiple="all") %>%
                                    select(-genome, -list, -orientation)

                                tmp_genes_df$searched_multiplicon <- each_multiplicon
                                searched_genes_df <- rbind(searched_genes_df, tmp_genes_df)

                                # get anchor points
                                each_anchor_points_df <- final_anchorpoints %>%
                                    filter(geneX %in% tmp_genes_df$gene | geneY %in% tmp_genes_df$gene) %>%
                                    filter(multiplicon %in% tmp_multiplicon_df$multiplicon)
                                each_anchor_points_df$searched_multiplicon <- each_multiplicon

                                searched_anchor_points_df <- rbind(searched_anchor_points_df, each_anchor_points_df)
                            }

                            # draw the micro level plot
                            widthSpacingMicro <- reactiveValues(
                                value=900
                            )
                            heightSpacingMicro <- reactiveValues(
                                value=50
                            )
                            observeEvent(input[["svg_vertical_spacing_add_micro_inter"]], {
                                heightSpacingMicro$value <- heightSpacingMicro$value + 50
                            })
                            observeEvent(input[["svg_vertical_spacing_sub_micro_inter"]], {
                                heightSpacingMicro$value <- heightSpacingMicro$value - 50
                            })
                            observeEvent(input[["svg_horizontal_spacing_add_micro_inter"]], {
                                widthSpacingMicro$value <- widthSpacingMicro$value + 50
                            })
                            observeEvent(input[["svg_horizontal_spacing_sub_micro_inter"]], {
                                widthSpacingMicro$value <- widthSpacingMicro$value - 50
                            })

                            # print(input$multiplicon_choose_inter)
                            # print(input[["gene_inter"]])
                            observe({
                                selected_multiplicons_df <- searched_multiplicon_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_inter)

                                heightMicroPlot_intra <- 150 * nrow(selected_multiplicons_df) + 100

                                selected_gene_df <- searched_genes_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_inter)

                                selected_anchor_point_df <- searched_anchor_points_df %>%
                                    filter(searched_multiplicon == input$multiplicon_choose_inter)

                                # cluster genes
                                anchor_point_group_df <- selected_anchor_point_df[, c("geneX", "geneY")]

                                tmp_links_g <- graph_from_data_frame(anchor_point_group_df)
                                tmp_cluster_g <- clusters(tmp_links_g)

                                anchor_point_group_df$group <- tmp_cluster_g$membership[as.character(anchor_point_group_df$geneX)]

                                if( input$scale_plotMicro_inter == "True length" ){
                                    selected_chr_df <- searched_chrs_df %>%
                                        filter(searched_multiplicon == input$multiplicon_choose_inter)

                                    microSynPlotData <- list(
                                        "plot_id"="inter",
                                        "anchorpoints"=selected_anchor_point_df,
                                        "multiplicons"=selected_multiplicons_df,
                                        "genes"=distinct(selected_gene_df),
                                        "achorPointGroups"=anchor_point_group_df,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "chrs"=selected_chr_df,
                                        "targe_gene"=input[["gene_inter"]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightMicroPlot_intra,
                                        "heightScale"=heightSpacingMicro$value
                                    )
                                    if( isTruthy(input$color_homolog_inter) && input$color_homolog_inter ){
                                        microSynPlotData[["color_gene"]] <- 1
                                    }else{
                                        microSynPlotData[["color_gene"]] <- 0
                                    }

                                    if( isTruthy(input$link_plotMicro_inter) && input$link_plotMicro_inter == "Pairwise" ){
                                        microSynPlotData[["link_all"]] <- 0
                                    }else{
                                        microSynPlotData[["link_all"]] <- 1
                                    }
                                    session$sendCustomMessage("microSynInterPlotting", microSynPlotData)
                                }
                                else{
                                    selected_chr_coord_df <- searched_chrs_coord_df %>%
                                        filter(searched_multiplicon == input$multiplicon_choose_inter)

                                    microSynPlotData <- list(
                                        "plot_id"="inter",
                                        "anchorpoints"=selected_anchor_point_df,
                                        "multiplicons"=selected_multiplicons_df,
                                        "genes"=distinct(selected_gene_df),
                                        "achorPointGroups"=anchor_point_group_df,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "chrs"=selected_chr_coord_df,
                                        "targe_gene"=input[["gene_inter"]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightMicroPlot_intra,
                                        "heightScale"=heightSpacingMicro$value
                                    )
                                    if( isTruthy(input$color_homolog_inter) && input$color_homolog_inter ){
                                        microSynPlotData[["color_gene"]] <- 1
                                    }else{
                                        microSynPlotData[["color_gene"]] <- 0
                                    }

                                    if( isTruthy(input$link_plotMicro_inter) && input$link_plotMicro_inter == "Pairwise" ){
                                        microSynPlotData[["link_all"]] <- 0
                                    }else{
                                        microSynPlotData[["link_all"]] <- 1
                                    }
                                    session$sendCustomMessage("microSynInterPlottingGeneNumber", microSynPlotData)
                                }

                            })
                        }
                    }

                    Sys.sleep(.9)
                    incProgress(amount=1, message="Drawing Micro Synteny Done")
                })
            }
        }
        else{
            shinyalert(
                "Warning!",
                "Please select a multiplicon first and then switch on this ...",
                type="warning",
            )
        }
    }
})

observeEvent(input$confirm_multi_comparing_go, {
    if( isTruthy(input$iadhore_multiple_species_list) && !is.null(input$iadhore_multiple_species_list) ){
        if( length(input$iadhore_multiple_species_list) < 3 ){
            shinyalert(
                "Opps!",
                "Please choose at least three species to analyze the multiple-species-alignment",
                type="error"
            )
        }
        else{
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
            shinyjs::runjs("$('#confirm_multi_comparing_go').css('background-color', 'green');")
            updateActionButton(
                session,
                "confirm_multi_comparing_go",
                icon=icon("check")
            )

            setTimeoutFunction <- "setTimeout(function() {
                  $('#confirm_multi_comparing_go').css('background-color', '#C0C0C0');
                }, 6000);"

            shinyjs::runjs(setTimeoutFunction)

            collinearAnalysisDir <- collinear_analysis_dir_Val()
            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

            multiple_species_df <- path_df[path_df$comparing_ID == "Multiple", ]

            color_list_renew <- c(
                "#ff7f00", "#FFA750", "#0064A7", "#008DEC",
                "#088A00", "#0CD300", "#e31a1c", "#fb9a99", "#cab2d6"
            )
            total_species <- path_df %>%
                filter(comparing_ID %in% input$iadhore_multiple_species_list)
            color_list_selected_new <- rep(color_list_renew, length.out=nrow(total_species))

            species_choice <- gsub("_", " ", total_species$comparing_ID)

            output$iadhore_output <- renderUI({
                div(
                    class="boxLike",
                    style="padding-right: 50px;
                               padding-left: 50px;
                               padding-top: 10px;
                               padding-bottom: 10px;
                               background-color: white",
                    bsButton(
                        inputId="plot_button_multiple",
                        label=HTML("<b><font color='white'>Multiple Species Alignment</font></b>"),
                        style="warning"
                    ) %>%
                        bs_embed_tooltip(
                            title="Click to see more details",
                            placement="right",
                            trigger="hover",
                            options=list(container="body")
                        ) %>%
                        bs_attach_collapse("plot_panel_multiple_collapse"),
                    bs_collapse(
                        id="plot_panel_multiple_collapse",
                        show=TRUE,
                        content=tags$div(
                            class="well",
                            style="padding-right: 50px;
                                   padding-left: 50px;
                                   padding-top: 20px;
                                   padding-bottom: 20px;",
                            fluidRow(
                                column(
                                    12,
                                    div(
                                        style="padding: 12px 10px 5px 10px;
                                               border-radius: 10px;
                                               background-color: #F0FFF0",
                                        selectizeInput(
                                            inputId="order_of_display",
                                            label=HTML(paste0("Set the <font color='orange'><b>Order</b></font> of <font color='orange'><b>Species</b></font> to Display:")),
                                            choices=species_choice,
                                            selected=NULL,
                                            multiple=TRUE,
                                            options=list(
                                                placeholder="Order species below ...",
                                                render=I("{
                                                      option: function(item, escape) {
                                                        var species=item.label.replace(/_/g, ' ');
                                                        var style='color: #B97D4B; font-style: italic;';
                                                        return '<div style=\"' + style + '\">&nbsp;&nbsp;' + escape(species) + '</div>';
                                                      },
                                                      item: function(item, escape) {
                                                        var species=item.label.replace(/_/g, ' ');
                                                        var style='color: #B97D4B; font-style: italic;';
                                                        return '<div style=\"' + style + '\">&nbsp;&nbsp;' + escape(species) + '</div>';
                                                      }
                                                    }"
                                                )
                                            )
                                        )
                                    )
                                ),
                                column(
                                    12,
                                    hr(class="setting")
                                ),
                                column(
                                    12,
                                    h5(HTML(paste0("<font color='orange'>", icon("dna"), "&nbsp;Chromosome</font> setting")))
                                ),
                                # column(
                                #     12,
                                #     hr(class="setting")
                                # ),
                                lapply(seq_len(nrow(total_species)), function(ii) {
                                    each_row <- total_species[ii, ]
                                    each_dir <- dirname(each_row$comparing_Path)
                                    genesFile <- paste0(each_dir, "/genes.txt")
                                    if( !file.exists(genesFile) ){
                                        shinyalert(
                                            "Opps!",
                                            paste0("Error! Fail to access ", genesFile, ". Please check the i-ADHoRe outputs..."),
                                            type="error"
                                        )
                                    }
                                    genes <- suppressMessages(
                                        vroom(
                                            genesFile,
                                            delim="\t",
                                            col_names=TRUE
                                        )
                                    )
                                    gene_num_df <- aggregate(coordinate ~ genome + list, genes, max)
                                    colnames(gene_num_df) <- c("sp", "chr", "gene_num")
                                    gene_num_df$gene_num <- gene_num_df$gene_num + 1

                                    if( is.null(gene_num_df) ){
                                        querys <- NULL
                                    }else{
                                        querys <- gene_num_df %>%
                                            filter(gene_num>100) %>%
                                            # arrange(desc(gene_num)) %>%
                                            pull(chr)
                                    }

                                    species <- gsub("_", " ", total_species[ii, ]$comparing_ID)
                                    column(
                                        6,
                                        div(
                                            style="padding: 12px 10px 5px 10px;
                                                   border-radius: 10px;
                                                   background-color: #F8F8FF",
                                            pickerInput(
                                                inputId=paste0("multiple_synteny_query_chr_", total_species[ii, ]$comparing_ID),
                                                label=HTML(paste("<font color='", color_list_selected_new[ii], "'>", icon("dna"), "</font>Select <i><b><font color='", color_list_selected_new[ii], "'>", species, "</font></i></b> Chromosomes:")),
                                                options=list(
                                                    title='Please select chromosomes below',
                                                    `selected-text-format`="count > 1",
                                                    `actions-box`=TRUE
                                                ),
                                                choices=gtools::mixedsort(querys),
                                                choicesOpt=list(
                                                    content=lapply(gtools::mixedsort(querys), function(choice) {
                                                        HTML(paste0("<div style='color: ", color_list_selected_new[ii], ";'>", choice, "</div>"))
                                                    })
                                                ),
                                                multiple=TRUE
                                            )
                                        )
                                    )
                                }),
                                column(
                                    12,
                                    hr(class="setting")
                                ),
                                column(
                                    4,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        sliderInput(
                                            inputId="anchoredPointsCutoff_multiple",
                                            label=HTML("<font color='orange'>Cutoff for Anchored Points per Multiplicon:</font>"),
                                            min=3,
                                            max=50,
                                            step=1,
                                            value=3
                                        )
                                    )
                                ),
                                column(
                                    2,
                                    div(
                                        style="margin-bottom: 10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 5px 10px;
                                               background-color: #FFF5EE;",
                                        prettyRadioButtons(
                                            inputId="scale_multiple",
                                            label=HTML("<font color='orange'>Scale in</font>:"),
                                            choices=c("True length", "Gene number"),
                                            selected="True length",
                                            icon=icon("check"),
                                            status="info",
                                            animation="jelly"
                                        )
                                    )
                                ),
                                # column(
                                #     4,
                                #     sliderInput(
                                #         inputId="overlapCutoff_multiple",
                                #         label=HTML("<font color='#7D7DFF'>Cutoff for Overlapping between Sgements:</font>"),
                                #         min=10,
                                #         max=80,
                                #         step=5,
                                #         value=10,
                                #         post="%"
                                #     )
                                # ),
                                column(
                                    4,
                                    actionButton(
                                        inputId="synplot_multiple_go",
                                        "Draw Plot",
                                        icon=icon("play"),
                                        status="secondary",
                                        class="my-start-button-class",
                                        style="color: #fff;
                                               background-color: #009393;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 50px 5px 5px 5px;"
                                    )
                                ),
                                column(
                                    12,
                                    hr(class="setting")
                                ),
                                div(
                                    h6(HTML("<b>The Multiple Species Parallel Link Plot:</b><br></br>")),
                                    column(
                                        12,
                                        actionButton(
                                            "svg_vertical_spacing_add_multiple",
                                            "",
                                            icon("arrows-alt-v"),
                                            title="Expand vertical spacing"
                                        ),
                                        actionButton(
                                            "svg_vertical_spacing_sub_multiple",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-135"
                                            ),
                                            title="Compress vertical spacing"
                                        ),
                                        actionButton(
                                            "svg_horizontal_spacing_add_multiple",
                                            "",
                                            icon("arrows-alt-h"),
                                            title="Expand horizontal spacing"
                                        ),
                                        actionButton(
                                            "svg_horizontal_spacing_sub_multiple",
                                            "",
                                            icon(
                                                "down-left-and-up-right-to-center",
                                                verify_fa=FALSE,
                                                class="rotate-45"
                                            ),
                                            title="Compress horizontal spacing"
                                        ),
                                        downloadButton_custom(
                                            "parallel_download_multiple",
                                            title="Download the Plot",
                                            status="secondary",
                                            icon=icon("download"),
                                            label=HTML(""),
                                            class="my-download-button-class",
                                            style="color: #fff;
                                                   background-color: #6B8E23;
                                                   border-color: #fff;
                                                   padding: 5px 14px 5px 14px;
                                                   margin: 5px 5px 5px 5px;"
                                        )
                                    ),
                                    column(
                                        width=12,
                                        id="parallel_plot_multiple_species"
                                    )
                                )
                            )
                        )
                    )
                )
            })
        }
    }
})

observeEvent(input$synplot_multiple_go, {
    withProgress(message='Analyzing Multiple Species Alignment in progress...', value=0, {
        Sys.sleep(.2)
        incProgress(amount=.3, message="Computing Multiple Species Alignment...")

        # display multiple species alignment
        order_list <- input[["order_of_display"]]
        if( is.null(order_list) ){
            shinyalert(
                "Oops!",
                "Please set the order of species first...",
                type="error"
            )
        }
        else{
            shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

            collinearAnalysisDir <- collinear_analysis_dir_Val()
            load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))
            multiple_species_df <- path_df[path_df$comparing_ID == "Multiple", ]

            sp_gff_info_xls <- paste0(
                dirname(dirname(dirname(file.path(multiple_species_df$comparing_Path)))),
                "/Species.info.xls"
            )
            sp_gff_info_df <- suppressMessages(
                vroom(sp_gff_info_xls,
                      col_names=c("species", "cdsPath", "gffPath"),
                      delim="\t")
            ) %>%
                filter(species %in% gsub("_", " ", input$iadhore_multiple_species_list))

            cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
            gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
            new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
            new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
            sp_gff_info_df$cdsPath <- new_cds_files
            sp_gff_info_df$gffPath <- new_gff_files

            chr_len_df <- obtain_chromosome_length_filter(
                sp_gff_info_df
            )

            multiplicon_file <- paste0(dirname(multiple_species_df$comparing_Path), "/multiplicons.txt")
            multiplicon_df <- suppressMessages(
                vroom(
                    multiplicon_file,
                    col_names=TRUE,
                    delim="\t"
                )
            ) %>%
                filter(genome_x != genome_y) %>%
                filter(number_of_anchorpoints >= input[["anchoredPointsCutoff_multiple"]])

            segments_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.txt")
            segs_df <- suppressMessages(
                vroom(
                    segments_file,
                    col_names=TRUE,
                    delim="\t"
                )
            )

            genes_file <- paste0(dirname(multiple_species_df$comparing_Path), "/genes.txt")
            chr_gene_num_file <- paste0(dirname(multiple_species_df$comparing_Path), "/chr_gene_nums.txt")

            if( !file.exists(chr_gene_num_file) ){
                if( file.exists(genes_file) ){
                    genes <- suppressMessages(
                        vroom(
                            genes_file,
                            delim="\t",
                            col_names=TRUE
                        )
                    )
                    gene_num_df <- aggregate(coordinate ~ genome + list, genes, max)
                    colnames(gene_num_df) <- c("sp", "seqchr", "gene_num")
                    gene_num_df$gene_num <- gene_num_df$gene_num + 1
                    write.table(
                        gene_num_df,
                        file=chr_gene_num_file,
                        sep="\t",
                        quote=F,
                        row.names=FALSE
                    )
                }
                else{
                    shinyalert(
                        "Oops",
                        "Fail to find correct ouputs of i-ADHoRe for ", intra_list,". Please ensure the output of i-ADHoRe, and then try again...",
                        type="error"
                    )
                }
            }else{
                gene_num_df <- read.table(
                    chr_gene_num_file,
                    sep="\t",
                    header=TRUE
                )
            }

            if( file.exists(genes_file) ){
                genes_df <- suppressMessages(
                    vroom(
                        genes_file,
                        col_names=T,
                        delim="\t"
                    )
                )
            }

            # map coordinates to genes
            genes_coord_subset <- select(genes_df, id, coordinate)
            merged_data_tmp <- left_join(
                segs_df,
                genes_coord_subset,
                by=c("first"="id")
            )

            merged_data_tmp <- left_join(
                merged_data_tmp,
                genes_coord_subset,
                by=c("last"="id")
            )
            segs_df <- merged_data_tmp %>%
                select(-id)

            colnames(segs_df) <- c(
                "multiplicon", "genome", "list",
                "first", "last", "order",
                "min", "max"
            )

            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]
                if( is.null(selected_chrs) ){
                    shinyalert(
                        "Oops!",
                        paste0("Please select the chromosome of ", species, " first..."),
                        type="error"
                    )
                }
            }

            selected_multiplicon_df1 <- data.frame()
            selected_segs_df <- data.frame()
            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]

                filtered_df <- segs_df %>%
                    filter(genome == species) %>%
                    filter(list %in% selected_chrs)
                selected_segs_df <- rbind(selected_segs_df, filtered_df)

                filtered_df1 <- multiplicon_df %>%
                    filter(genome_x == species) %>%
                    filter(list_x %in% selected_chrs)
                selected_multiplicon_df1 <- rbind(selected_multiplicon_df1, filtered_df1)
            }

            selected_multiplicon_df <- data.frame()
            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]
                filtered_df <- selected_multiplicon_df1 %>%
                    filter(genome_y == species) %>%
                    filter(list_y %in% selected_chrs)
                selected_multiplicon_df <- rbind(selected_multiplicon_df, filtered_df)
            }
            selected_multiplicons <- selected_multiplicon_df %>% select(id)

            selected_segs_df <- selected_segs_df %>%
                filter(multiplicon %in% selected_multiplicons$id)

            rm(selected_multiplicon_df1, multiplicon_df)

            segments_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.txt")
            segs_pos_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.merged_pos.txt")
            # source("tools/obtain_coordinates_for_segments.multiple_species.R", local=T, encoding="UTF-8")
            #if( !file.exists(segs_pos_file) ){
            obtain_coordinates_for_segments_multiple(
                seg_df=selected_segs_df,
                gff_df=sp_gff_info_df,
                input=input,
                out_file=segs_pos_file
            )

            segs_pos_df <- suppressMessages(
                vroom(
                    segs_pos_file,
                    delim="\t",
                    col_names=TRUE
                )
            )

            chr_len_df <- chr_len_df$len_df

            selected_chr_len_data <- data.frame()
            selected_chr_order_data <- data.frame()
            selected_segs_data <- data.frame()
            for( i in 1:(length(order_list) - 1) ){
                incProgress(
                    amount=0.5/length(order_list),
                    message=paste0(
                        "Computing synteny between ",
                        gsub("_", " ", order_list[[i]]),
                        " and ",
                        gsub("_", " ", order_list[[i+1]]),
                        "..."
                    )
                )

                order_list[[i]]=gsub(" ", "_", order_list[[i]]);
                order_list[[i+1]]=gsub(" ", "_", order_list[[i+1]])
                query_info <- paste0("multiple_synteny_query_chr_", order_list[[i]])
                subject_info <- paste0("multiple_synteny_query_chr_", order_list[[i+1]])
                query_selected_chr_list <- gtools::mixedsort(input[[query_info]])
                query_chr_len_df <- chr_len_df[chr_len_df$sp==gsub(" ", "_", order_list[[i]]), ] %>%
                    filter(seqchr %in% query_selected_chr_list)
                subject_selected_chr_list <- gtools::mixedsort(input[[subject_info]])

                subject_chr_len_df <- chr_len_df[chr_len_df$sp==sub(" ", "_", order_list[[i+1]]), ] %>%
                    filter(seqchr %in% subject_selected_chr_list)

                selected_chr_len_data <- rbind(selected_chr_len_data, query_chr_len_df)
                selected_chr_len_data <- rbind(selected_chr_len_data, subject_chr_len_df)
                tmp_query_chr_order <- data.frame(
                    "species"=order_list[[i]],
                    "chrOrder"=paste0(query_selected_chr_list, collapse=",")
                )
                tmp_subject_chr_order <- data.frame(
                    "species"=order_list[[i+1]],
                    "chrOrder"=paste0(subject_selected_chr_list, collapse=",")
                )
                selected_chr_order_data <- rbind(selected_chr_order_data, tmp_query_chr_order)
                selected_chr_order_data <- rbind(selected_chr_order_data, tmp_subject_chr_order)
                # deal segments data
                selected_segs <- segs_pos_df %>%
                    filter((genomeX == order_list[[i]] & genomeY == order_list[[i+1]])
                           | (genomeX == order_list[[i+1]] & genomeY == order_list[[i]]))

                selected_segs_re <- data.frame()
                if( length(unique(selected_segs$genomeX)) == 2 ){
                    for( i in 1:nrow(selected_segs) ){
                        each_row <- selected_segs[i, ]
                        if( each_row$genomeX != order_list[[i+1]] ){
                            tmp <- each_row[2:8]
                            each_row[2:8] <- each_row[9:15]
                            each_row[9:15] <- tmp
                        }
                        selected_segs_re <- rbind(selected_segs_re, each_row)
                    }
                    selected_segs_data <- rbind(selected_segs_data, selected_segs_re)
                }
                else{
                    selected_segs_data <- rbind(selected_segs_data, selected_segs)
                }
            }

            selected_chr_len_data <- selected_chr_len_data[!duplicated(selected_chr_len_data), ]
            selected_chr_order_data <- selected_chr_order_data[!duplicated(selected_chr_order_data), ]

            selected_chr_num_df <- left_join(
                selected_chr_len_data,
                gene_num_df,
                by=c("sp"="sp", "seqchr"="seqchr")
            )

            Sys.sleep(.2)
            incProgress(amount=.6, message="Computing Done")

            Sys.sleep(.2)
            incProgress(amount=.8, message="Drawing Parallel Syntenty Plot for Multiple Species Alignment...")

            widthSpacingMultiple <- reactiveValues(
                value=800
            )
            heightSpacingMultiple <- reactiveValues(
                value=100 * nrow(sp_gff_info_df)
            )
            observeEvent(input[["svg_vertical_spacing_add_multiple"]], {
                heightSpacingMultiple$value <- heightSpacingMultiple$value + 50
            })
            observeEvent(input[["svg_vertical_spacing_sub_multiple"]], {
                heightSpacingMultiple$value <- heightSpacingMultiple$value - 50
            })
            observeEvent(input[["svg_horizontal_spacing_add_multiple"]], {
                widthSpacingMultiple$value <- widthSpacingMultiple$value + 50
            })
            observeEvent(input[["svg_horizontal_spacing_sub_multiple"]], {
                widthSpacingMultiple$value <- widthSpacingMultiple$value - 50
            })

            observe({
                if( input$scale_multiple == "True length" ){
                    plot_parallel_multiple_data <- list(
                        "plot_id"="multiple",
                        "segs"=selected_segs_data,
                        "sp_order"=order_list,
                        "chr_order"=selected_chr_order_data,
                        "overlap_cutoff"=input[["overlapCutoff_multiple"]],
                        "chr_lens"=selected_chr_len_data,
                        "width"=widthSpacingMultiple$value,
                        "height"=heightSpacingMultiple$value
                    )
                    session$sendCustomMessage("Parallel_Multiple_Plotting", plot_parallel_multiple_data)
                }else{
                    plot_parallel_multiple_data <- list(
                        "plot_id"="multiple",
                        "segs"=selected_segs_data,
                        "sp_order"=order_list,
                        "chr_order"=selected_chr_order_data,
                        "overlap_cutoff"=input[["overlapCutoff_multiple"]],
                        "chr_nums"=selected_chr_num_df,
                        "width"=widthSpacingMultiple$value,
                        "height"=heightSpacingMultiple$value
                    )
                    session$sendCustomMessage("Parallel_Multiple_Gene_Num_Plotting", plot_parallel_multiple_data)
                }
            })
        }
        Sys.sleep(.3)
        incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
    })
})

observeEvent(input$confirm_clustering_go, {
    if( isTruthy(input$cluster_species_A) && isTruthy(input$cluster_species_B) ){
        shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

        shinyjs::runjs("$('#confirm_clustering_go').css('background-color', 'green');")
        updateActionButton(
            session,
            "confirm_clustering_go",
            icon=icon("check")
        )

        setTimeoutFunction <- "setTimeout(function() {
                  $('#confirm_clustering_go').css('background-color', '#C0C0C0');
                }, 6000);"

        shinyjs::runjs(setTimeoutFunction)

        collinearAnalysisDir <- collinear_analysis_dir_Val()
        load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

        cluster_species_A <- gsub("_", " ", input$cluster_species_A)
        cluster_species_B <- gsub("_", " ", input$cluster_species_B)
        output$iadhore_output <- renderUI({
            div(
                class="boxLike",
                style="padding-right: 50px;
                       padding-left: 50px;
                       padding-top: 10px;
                       padding-bottom: 10px;
                       background-color: white",
                fluidRow(
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="cluster_plot_button",
                                label=HTML(paste0("<font color='#F4FFEE'><b>Clustering Analysis</b></font> for <font color='#FFD374'><b><i>", cluster_species_A, "</i></font> and <font color='#E1B8FF'><i>", cluster_species_B, "</i></b></font>")),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to see more details",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse(
                                    id="cluster_plot_panel_collapse"
                                ),
                            bs_collapse(
                                id="cluster_plot_panel_collapse",
                                show=TRUE,
                                content=tags$div(
                                    class="well",
                                    fluidRow(
                                        column(
                                            12,
                                            div(
                                                style="background-color: white;
                                                       padding-right: 50px;
                                                       padding-left: 50px;
                                                       padding-top: 10px;
                                                       padding-bottom: 10px;",
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        4,
                                                        div(
                                                            style="margin-bottom: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 10px 10px 5px 10px;
                                                                   background-color: #F0FFFF;",
                                                            sliderInput(
                                                                inputId="interactPointsCutoff",
                                                                label=HTML("Threshold for <font color='orange'>Anchor Points between Segments</font>:"),
                                                                min=0,
                                                                max=30,
                                                                step=1,
                                                                value=5
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        4,
                                                        div(
                                                            style="margin-bottom: 10px;
                                                                   border-radius: 10px;
                                                                   padding: 10px 10px 5px 10px;
                                                                   background-color: #F0FFFF;",
                                                            sliderInput(
                                                                inputId="corRCutoff",
                                                                label=HTML("Threshold for <font color='orange'>Pearson correlation coefficient <i>r</i></font> :"),
                                                                min=0,
                                                                max=1,
                                                                step=0.1,
                                                                value=0.3
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        3,
                                                        actionButton(
                                                            inputId="cluster_go",
                                                            "Start Clustering Analysis",
                                                            icon=icon("play"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #009393;
                                                                   border-color: #fff;
                                                                   padding: 5px 10px 5px 10px;
                                                                   margin: 50px 5px 5px 35px;"
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h6(HTML("<b>The Hierarchical Clustering Plot:</b>")),
                                                        tags$style(
                                                            HTML(".rotate-135 {
                                                                    transform: rotate(135deg);
                                                                }"),
                                                            HTML(".rotate-45{
                                                                    transform: rotate(45deg);
                                                                }")
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_add_cluster",
                                                            "",
                                                            icon("arrows-alt-v", class="rotate-45"),
                                                            title="Expand spacing"
                                                        ),
                                                        actionButton(
                                                            "svg_spacing_sub_cluster",
                                                            "",
                                                            icon(
                                                                "down-left-and-up-right-to-center",
                                                                verify_fa=FALSE,
                                                            ),
                                                            title="Compress spacing"
                                                        ),
                                                        downloadButton_custom(
                                                            "cluster_download",
                                                            title="Download the Plot",
                                                            status="secondary",
                                                            icon=icon("download"),
                                                            label=HTML(""),
                                                            class="my-download-button-class",
                                                            style="color: #fff;
                                                                   background-color: #6B8E23;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;"
                                                        )
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="clusterView"
                                                    ),
                                                    column(
                                                        width=12,
                                                        id="dendrogramTreeView"
                                                    )
                                                ),
                                                hr(class="splitting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        h5(HTML("<font color='#00DB00'><b>Putative Ancestral Regions</b></font>"))
                                                    ),
                                                    column(
                                                        12,
                                                        uiOutput("foundParsMessage")
                                                    ),
                                                ),
                                                fluidRow(
                                                    column(
                                                        6,
                                                        pickerInput(
                                                            inputId="pars_list",
                                                            label=HTML("Choose <b><font color='green'>PARs</font></b> to zoom in"),
                                                            options=list(
                                                                title='Please select PAR below',
                                                                `selected-text-format`="count > 1",
                                                                `actions-box`=TRUE
                                                            ),
                                                            choices=NULL,
                                                            selected=NULL,
                                                            multiple=FALSE
                                                        )
                                                    ),
                                                    column(
                                                        6,
                                                        actionButton(
                                                            inputId="zoomInPAR",
                                                            "",
                                                            icon=icon("search"),
                                                            status="secondary",
                                                            class="my-start-button-class",
                                                            style="color: #fff;
                                                                   background-color: #8080C0;
                                                                   border-color: #fff;
                                                                   margin: 30px 0px 0px -15px; "
                                                        )
                                                    )
                                                ),
                                                hr(class="setting"),
                                                fluidRow(
                                                    column(
                                                        12,
                                                        div(
                                                            style="padding: 0px 10px 0px 10px;",
                                                            HTML("<b>The PARs Dot Plot:</b>")
                                                        )
                                                    )
                                                ),
                                                fluidRow(
                                                    column(
                                                        2,
                                                        div(
                                                            style="/*margin-bottom: 10px;*/
                                                                   border-radius: 10px;
                                                                   padding: 0px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            prettyRadioButtons(
                                                                inputId="par_plot_type",
                                                                label=HTML("<font color='orange'>Plot type</font>:"),
                                                                choices=c("Dot", "Link"),
                                                                selected="Dot",
                                                                icon=icon("check"),
                                                                inline=TRUE,
                                                                status="info",
                                                                animation="jelly"
                                                            )
                                                        )
                                                    ),
                                                    column(
                                                        3,
                                                        div(
                                                            style="/*margin-bottom: 10px;*/
                                                                   border-radius: 10px;
                                                                   padding: 5px 10px 0px 10px;
                                                                   background-color: #FFF5EE;",
                                                            actionButton(
                                                                "svg_vertical_spacing_add_par",
                                                                "",
                                                                icon("arrows-alt-v", class="rotate-45"),
                                                                title="Expand spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_vertical_spacing_sub_par",
                                                                "",
                                                                icon("down-left-and-up-right-to-center", verify_fa=FALSE),
                                                                title="Compress spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                "PAR_download",
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label="",
                                                                class="my-download-button-class",
                                                                style="color: #fff;
                                                                       background-color: #6B8E23;
                                                                       border-color: #fff;
                                                                       padding: 5px 14px 5px 14px;
                                                                       margin: 5px 5px 5px 5px;"
                                                            )
                                                        )
                                                    )
                                                ),
                                                column(
                                                    width=12,
                                                    id="ParZoomIn"
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        })
    }
})

observeEvent(input$cluster_go, {
    withProgress(message='Clustering Analysis in progress...', value=0, {
        Sys.sleep(.2)
        shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

        incProgress(amount=.1, message="Preparing data...")
        collinearAnalysisDir <- collinear_analysis_dir_Val()
        load(paste0(collinearAnalysisDir, "/synteny.comparing.RData"))

        cluster_species_A <- input$cluster_species_A
        cluster_species_B <- input$cluster_species_B
        pattern1 <- paste0(cluster_species_A, "_vs_", cluster_species_B)
        pattern2 <- paste0(cluster_species_B, "_vs_", cluster_species_A)
        cluster_selected_df <- path_df[(path_df$comparing_ID %in% pattern1) | (path_df$comparing_ID %in% pattern2), ]

        sp_list_tmp <- unique(strsplit(cluster_selected_df$comparing_ID, split="_vs_")[[1]])
        querySpecies <- gsub("_", " ", sp_list_tmp[1])
        subjectSpecies <- gsub("_", " ", sp_list_tmp[2])

        iadhoreDir <- dirname(cluster_selected_df$comparing_Path)
        anchorpointFile <- paste0(iadhoreDir, "/anchorpoints.txt")
        ksFile <- paste0(iadhoreDir, "/anchorpoints.ks.txt")
        genesFile <- paste0(iadhoreDir, "/genes.txt")
        multiplicon_file <- paste0(iadhoreDir, "/multiplicons.txt")
        anchorpoint_merged_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos.cluster.txt")
        anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.cluster.txt")

        if( file.exists(ksFile) ){
            if( !file.exists(anchorpointout_file) ){
                Sys.sleep(.2)
                incProgress(amount=.1, message="Mapping data...")
                # source(file="tools/obtain_coordinates_for_anchorpoints_ks.R", local=T, encoding="UTF-8")
                obtain_coordiantes_for_anchorpoints_ks(
                    anchorpoints=anchorpointFile,
                    anchorpoints_ks=ksFile,
                    genes_file=genesFile,
                    out_file=anchorpoint_merged_file,
                    out_ks_file=anchorpointout_file,
                    species=gsub(" ", "_", querySpecies)
                )
            }
        }
        else{
            shinyalert(
                "Opps!",
                paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of shinyWGD first ..."),
                type="error",
            )
        }

        clusteringDir <- paste0(iadhoreDir, "/clusteringDir")
        if( !(dir.exists(clusteringDir)) ){
            dir.create(clusteringDir)
        }

        cutoffPoints <- input$interactPointsCutoff

        segmented_file <- paste0(clusteringDir, "/segmented.chr.", cutoffPoints, ".txt")
        segmented_anchopoints_file <- paste0(clusteringDir, "/segmented.anchorpoints.", cutoffPoints, ".txt")

        if( !(file.exists(segmented_anchopoints_file)) ){
            Sys.sleep(.2)
            incProgress(amount=.2, message="Segmenting...")
            # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
            get_segments(
                genes_file=genesFile,
                anchors_ks_file=anchorpointout_file,
                multiplicons_file=multiplicon_file,
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                num_anchors=cutoffPoints
            )
            Sys.sleep(.2)
            incProgress(amount=.1, message="Segmenting Done")
        }

        cluster_info_file <- paste0(clusteringDir, "/Clustering_info.", cutoffPoints, ".RData")
        if( !file.exists(cluster_info_file) ){
            Sys.sleep(.2)
            incProgress(amount=.1, message="Clustering...")
            # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
            cluster_synteny(
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                genes_file=genesFile,
                out_file=cluster_info_file
            )
            Sys.sleep(.2)
            incProgress(amount=.2, message="Clustering Done")
        }
        load(cluster_info_file)

        hcheightCutoff <- input$corRCutoff
        identified_cluster_file <- paste0(clusteringDir, "/Identified_Clusters.Num_", cutoffPoints, ".Hc_", hcheightCutoff, ".RData")
        # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
        if( !(file.exists(identified_cluster_file)) ){
            Sys.sleep(.2)
            incProgress(amount=.2, message="Identifying Clusters...")
            analysisEachCluster(
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                genes_file=genesFile,
                cluster_info_file=cluster_info_file,
                identified_cluster_file=identified_cluster_file,
                hcheight=hcheightCutoff
            )
        }
        load(identified_cluster_file)

        subject_chr_order <- cluster_info[[1]]$order
        query_chr_order <- cluster_info[[2]]$order
        subject_chr_labels <- cluster_info[[1]]$labels[subject_chr_order]
        query_chr_lables <- cluster_info[[2]]$labels[query_chr_order]

        Sys.sleep(.2)
        incProgress(amount=.8, message="Plotting")

        plotSize <- reactiveValues(
            value=500
        )
        observeEvent(input[["svg_spacing_add_cluster"]], {
            plotSize$value <- plotSize$value + 50
        })
        observeEvent(input[["svg_spacing_sub_cluster"]], {
            plotSize$value <- plotSize$value - 50
        })
        observe({
            segmented_chr <- read.table(
                segmented_file,
                header=TRUE,
                sep="\t"
            )
            segmented_anchopoints <- read.table(
                segmented_anchopoints_file,
                header=TRUE,
                sep="\t"
            )
            PARs_info <- c()
            if( length(identified_cluster_list) > 0 ){
                for( i in 1:length(identified_cluster_list) ){
                    each_PAR <- identified_cluster_list[[i]]$cluster_chr
                    each_PAR[["par_id"]] <- paste0("PAR ", identified_cluster_list[[i]]$par_id)
                    PARs_info <- c(PARs_info, each_PAR)
                }
            }

            if( is.null(PARs_info) ){
                shinyalert(
                    "Opps!",
                    "Fail to identify the significant PAR regions ...",
                    type="error",
                )
            }

            tree_bycol <- readLines(
                gsub(".RData", ".bycol.newick", cluster_info_file)
            )
            tree_byrow <- readLines(
                gsub(".RData", ".byrow.newick", cluster_info_file)
            )

            plot_cluster_synteny_data <- list(
                "plot_id"="clusterView",
                "segmented_chr"=segmented_chr,
                "segmented_anchorpoints"=segmented_anchopoints,
                "query_chr_order"=query_chr_order,
                "subject_chr_order"=subject_chr_order,
                "query_sp"=querySpecies,
                "subject_sp"=subjectSpecies,
                "size"=plotSize$value,
                "pars"=PARs_info,
                "tree_bycol"=tree_bycol,
                "tree_byrow"=tree_byrow,
                "r_cutoff"=hcheightCutoff
            )
            session$sendCustomMessage("Cluster_Synteny_Plotting", plot_cluster_synteny_data)

            PARs_list <- c()
            if( length(identified_cluster_list) > 0 ){
                for( i in 1:length(identified_cluster_list) ){
                    PAR_id <- paste0("PAR ", identified_cluster_list[[i]]$par_id)
                    each_PAR <- identified_cluster_list[[i]]
                    each_PAR[["par_id"]] <- PAR_id
                    PARs_list <- c(PARs_list, PAR_id)
                }
                updatePickerInput(
                    session,
                    "pars_list",
                    choices=PARs_list,
                    choicesOpt=list(
                        content=lapply(PARs_list, function(choice) {
                            HTML(paste0("<div style='color: green;'>", choice, "</div>"))
                        })
                    ),
                    selected=PARs_list[1]
                )
            }
        })

        observeEvent(input$zoomInPAR, {
            withProgress(message='Clustering Analysis in progress...', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.8, message="Zoom in ...")

                plotSize <- reactiveValues(
                    value=400
                )
                observeEvent(input[["svg_vertical_spacing_add_par"]], {
                    plotSize$value <- plotSize$value + 50
                })
                observeEvent(input[["svg_vertical_spacing_sub_par"]], {
                    plotSize$value <- plotSize$value - 50
                })
                observe({
                    if( length(identified_cluster_list) > 0 ){
                        for( i in 1:length(identified_cluster_list) ){
                            PAR_id <- paste0("PAR ", i)
                            each_PAR <- identified_cluster_list[[i]]

                            if( PAR_id == input$pars_list ){
                                if( input$par_plot_type == "Dot" ){
                                    plot_zoom_in_data <- list(
                                        "plot_id"="ParZoomIn",
                                        "par_id"=PAR_id,
                                        "segmented_chr"=each_PAR$cluster_chr,
                                        "segmented_anchorpoints"=each_PAR$cluster_anchorpoints,
                                        "query_chr_labels"=query_chr_lables,
                                        "subject_chr_labels"=subject_chr_labels,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "size"=plotSize$value
                                    )
                                    session$sendCustomMessage("Cluster_Zoom_In_Plotting", plot_zoom_in_data)
                                }else{
                                    # print(each_PAR$cluster_anchorpoints)
                                    # print(each_PAR$cluster_chr)
                                    plot_zoom_in_data <- list(
                                        "plot_id"="ParZoomIn",
                                        "par_id"=PAR_id,
                                        "segmented_chr"=each_PAR$cluster_chr,
                                        "segmented_anchorpoints"=each_PAR$cluster_anchorpoints,
                                        "query_chr_labels"=query_chr_lables,
                                        "subject_chr_labels"=subject_chr_labels,
                                        "query_sp"=querySpecies,
                                        "subject_sp"=subjectSpecies,
                                        "size"=plotSize$value
                                    )
                                    session$sendCustomMessage("Cluster_Zoom_In_Link_Plotting", plot_zoom_in_data)
                                }
                            }
                        }
                    }
                    else{
                        shinyalert(
                            "Oops!",
                            "No Putative Ancestral Regions found. Change the parameter and try again",
                            type="error"
                        )
                    }
                })
            })
        })
        Sys.sleep(.3)
        incProgress(amount=1, message="Done")
    })
})
