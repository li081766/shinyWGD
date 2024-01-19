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
ks_check_file <- paste0(ks_example_dir, "/ksrates_wd/ortholog_distributions/wgd_Oryza2_Vitis4/Oryza2_Vitis4.ks.tsv")

if( !dir.exists(ks_example_dir) & !file.exists(ks_check_file) ){
    withProgress(message='Downloading Ks demo data...', value=0, {
        if( !dir.exists(example_data_dir) ){
            dir.create(example_data_dir)
        }
        dir.create(ks_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

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

        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
}else if( dir.exists(ks_example_dir) & !file.exists(ks_check_file) ){
    withProgress(message='Downloading Ks demo data...', value=0, {
        system(
            paste("rm -rf ", ks_example_dir)
        )
        dir.create(ks_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

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
        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
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

        ref_species_remaining <- sort(species_tree_df[, 1])

        div(class="boxLike",
            style="background-color: #FBFEEC;",
            fluidRow(
                div(
                    style="padding-bottom: 5px;
                           padding-top: 5px;
                           padding-left: 10px;",
                    h5(icon("cog"), HTML("Select a <font color='#bb5e00'><b>submodule</b></font> to start")),
                    # column(
                    #     12,
                    #     hr(class="setting")
                    # ),
                    column(
                        width=12,
                        div(
                            style="padding-top: 10px;
                                   padding-bottom: 10px;",
                            bsButton(
                                inputId="paralogous_ks_button",
                                label=HTML("<font color='white'><b>&nbsp;Paralogous <i>K</i><sub>s</sub> distribution&nbsp;&nbsp;&nbsp;&#x25BC;</b></font>"),
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
                                label=HTML("<font color='white'><b>&nbsp;Orthologous <i>K</i><sub>s</sub> distribution&nbsp;&#x25BC;</b></font>"),
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
                                        label=HTML("Select <b><font color='#38B0E4'>Species</font></b> to compare"),
                                        options=list(
                                            title='Please select species below',
                                            `selected-text-format`="count > 1",
                                            "max-options"=5
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: steelblue; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=TRUE
                                    ),
                                    pickerInput(
                                        inputId="ortholog_paranome_species",
                                        label=HTML("Select <b><font color='#fc8d59'>Species</font></b> to draw <font color='#fc8d59'><b>paralogous <i>K</i><sub>s</sub> distribution</b></font> (optional):"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #fc8d59; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=FALSE
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
                                label=HTML("<font color='white'><b>&nbsp;Relative rate test analysis&nbsp;&nbsp;&nbsp;&nbsp;&#x25BC;</b></font>"),
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
                                        choices=ref_species_remaining,
                                        choicesOpt=list(
                                            content=lapply(ref_species_remaining, function(choice) {
                                                choice <- gsub("_", " ", choice)
                                                paste0("<div style='color: #54B4D3; font-style: italic;'>", choice, "</div>")
                                            })
                                        )
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
                                            title='Please select species below',
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
                    ),
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="phylo_ks_button",
                                label=HTML("<font color='white'><b>&nbsp;Phylo-<i>K</i><sub>s</sub> analysis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#x25BC;</b></font>"),
                                icon=icon("list"),
                                style="success"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to set",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("phylo_ks_collapse"),
                            bs_collapse(
                                id="phylo_ks_collapse",
                                content=tags$div(
                                    class="well",
                                    fluidRow(
                                        column(
                                            12,
                                            div(
                                                style="padding-left: 10px;
                                                       position: relative;",
                                                fileInput(
                                                    inputId="uploadPhyloKsTree",
                                                    label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Tree</b></font> File:"),
                                                    width="80%",
                                                    accept=c(".newick", ".tre", ".tree")
                                                ),
                                                actionButton(
                                                    inputId="phylo_ks_tree_example",
                                                    "",
                                                    icon=icon("question"),
                                                    status="secondary",
                                                    title="Click to see the example of Ks Unit Tree file",
                                                    class="my-start-button-class",
                                                    style="color: #fff;
                                                           background-color: #87CEEB;
                                                           border-color: #fff;
                                                           position: absolute;
                                                           top: 53%;
                                                           left: 90%;
                                                           margin-top: -15px;
                                                           margin-left: -15px;
                                                           padding: 5px 14px 5px 10px;
                                                           width: 30px; height: 30px; border-radius: 50%;"
                                                )
                                            )
                                        )
                                    ),
                                    fluidRow(
                                        column(
                                            12,
                                            div(
                                                style="padding-left: 10px;
                                                       position: relative;",
                                                fileInput(
                                                    inputId="uploadPhyloKsPeakTable",
                                                    label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Peak</b></font> File (Optional):"),
                                                    width="80%",
                                                    accept=c(".csv", ".txt", ".xls")
                                                ),
                                                actionButton(
                                                    inputId="phylo_ks_peaks_example",
                                                    "",
                                                    icon=icon("question"),
                                                    title="Click to see the example of Ks Peak file",
                                                    status="secondary",
                                                    class="my-start-button-class",
                                                    style="color: #fff;
                                                           background-color: #87CEEB;
                                                           border-color: #fff;
                                                           position: absolute;
                                                           top: 53%;
                                                           left: 90%;
                                                           margin-top: -15px;
                                                           margin-left: -15px;
                                                           padding: 5px 14px 5px 10px;
                                                           width: 30px; height: 30px; border-radius: 50%;"
                                                )
                                            )
                                        )
                                    ),
                                    div(
                                        class="d-flex justify-content-end",
                                        actionButton(
                                            inputId="confirm_phylo_ks_go",
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

observeEvent(input$phylo_ks_tree_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b><i>K</i><sub>s</sub> Unit Tree</b></font> file"),
            size="xl",
            uiOutput("phylo_ks_tree_example_panel")
        )
    )

    output$phylo_ks_tree_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("phyloKsUnitTreeExample"),
                    HTML(
                        paste0(
                            "<b>shinyWGD</b> uses the single-copy gene families built by <b>OrthoFinder</b> to calculate the <i>K</i><sub>s</sub> unit tree. <br>",
                            "Users can check the tree in the <b>Orthofinder_wd</b> folder, named <b>singleCopyGene.ds_tree.newick</b>.<br>",
                            "Once uploading the tree file in the <font color='green'><i>K</i><sub>s</sub> Tree</font> File panel, the <i>K</i><sub>s</sub> unit tree will displayed in the right side of the page. <br>"
                        )
                    )
                )
            )
        )
    })

    output$phyloKsUnitTreeExample <- renderText({
        "(((Phalaenopsis_equestris: 0.236436, Dendrobium_catenatum: 0.167833): 0.243397, Apostasia_shenzhenica: 0.443454): 0.597705, Asparagus_officinalis: 0.485116);"
    })
})

observeEvent(input$phylo_ks_peaks_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b><i>K</i><sub>s</sub> peaks table</b></font> file"),
            size="xl",
            uiOutput("phylo_ks_peaks_example_panel")
        )
    )

    ks_peak_data_file <- "www/content/ks_peaks_example.xls"
    output$phyloKsPeakExampleTable <- renderTable({
        species_info_example <- read.table(
            ks_peak_data_file,
            header=TRUE,
            sep="\t",
            quote=""
        )
        colnames(species_info_example) <- gsub("\\.", " ", colnames(species_info_example))
        colnames(species_info_example)[4] <- "95% Confidence Interval"

        species_info_example
    })

    output$phylo_ks_peaks_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    tableOutput("phyloKsPeakExampleTable"),
                    HTML(
                        paste0(
                            "After uploading the <i>K</i><sub>s</sub> peak file, the corresponding <i>K</i><sub>s</sub> peaks of each studied species will be placed into the <i>K</i><sub>s</sub> unit tree.<br>"
                        )
                    )
                )
            )
        )
    })
})

observeEvent(input$rate_correct_button, {
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("phylo_ks_collapse").style.display="none";')
})

observeEvent(input$paralogous_ks_button, {
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("phylo_ks_collapse").style.display="none";')
})

observeEvent(input$orthologous_ks_button, {
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="block";')
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("phylo_ks_collapse").style.display="none";')
})

observeEvent(input$phylo_ks_button, {
    shinyjs::runjs('document.getElementById("ortholog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("rate_correction_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("paralog_ks_files_collapse").style.display="none";')
    shinyjs::runjs('document.getElementById("phylo_ks_collapse").style.display="block";')
})

observeEvent(input$select_ref_species, {
    if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
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
    }
})

observeEvent(input$confirm_paralog_ks_go, {
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

    # shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

    shinyjs::addClass(selector = "#Wgd_plot_paralog", class = "my-svg-container")
    shinyjs::runjs('$(".my-svg-container").empty();')

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
                                   padding: 10px 10px 10px -1px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="distribution_choice",
                                label=HTML("<font color='orange'><i>K</i><sub>s</sub> Distribution</font>:"),
                                choices=c("All", "Paranome", "Anchor pairs"),
                                selected="All",
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        )
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
                                choices=c("Paranome", "Anchor pairs"),
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        )
                    ),
                    column(
                        4,
                        div(
                            style="background-color: #F8F8FF;
                                   padding: 10px 10px 1px 10px;
                                   border-radius: 10px;",
                            prettyRadioButtons(
                                inputId="sizer_choice",
                                label=HTML("<font color='orange'>Sizer analysis</font>:"),
                                choices=c("Paranome", "Anchor pairs"),
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
                                inputId="distribution_choice",
                                label=HTML("<font color='orange'><i>K</i><sub>s</sub> Distribution</font>:"),
                                choices=c("Paranome"),
                                selected="Paranome",
                                icon=icon("check"),
                                status="info",
                                animation="jelly"
                            )
                        )
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
                                selected="Paranome",
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
                                selected="Paranome",
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
                        h4(HTML("<b><font color='#9B3A4D'>Paralogous <i>K</i><sub>s</sub></font> Age Distribution</b>"))
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
                                8,
                                uiOutput("data_choosing")
                            ),
                            column(
                                2,
                                actionButton(
                                    inputId="paralog_ks_plot_go",
                                    "Start",
                                    icon=icon("play"),
                                    status="secondary",
                                    title="Click to start",
                                    class="my-start-button-class",
                                    style="color: #fff;
                                           background-color: #27ae60;
                                           border-color: #fff;
                                           padding: 5px 14px 5px 14px;
                                           margin: 25px 5px 5px 5px;"
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
                                12,
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
                            6,
                            div(
                                id="Wgd_plot_paralog"
                            )
                        ),
                        column(
                            6,
                            uiOutput("ks_peak_table_output")
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
                                            label=HTML("<font color='orange'>Y axis limit</font>:"),
                                            min=0,
                                            max=6000,
                                            step=200,
                                            value=2000
                                        )
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
                                        )
                                    )
                                )
                            )
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

observeEvent(input$distribution_choice, {
    if( isTruthy(input$distribution_choice) && input$distribution_choice == "Paranome" ){
        updatePrettyRadioButtons(
            session,
            "gmm_choice",
            choices=c("Paranome"),
            selected="Paranome"
        )
        updatePrettyRadioButtons(
            session,
            "sizer_choice",
            choices=c("Paranome"),
            selected="Paranome"
        )
    }else if( isTruthy(input$distribution_choice) && input$distribution_choice == "Anchor pairs" ){
        updatePrettyRadioButtons(
            session,
            "gmm_choice",
            choices=c("Anchor pairs"),
            selected="Anchor pairs"
        )
        updatePrettyRadioButtons(
            session,
            "sizer_choice",
            choices=c("Anchor pairs"),
            selected="Anchor pairs"
        )
    }else if( isTruthy(input$distribution_choice) && input$distribution_choice == "All" ){
        updatePrettyRadioButtons(
            session,
            "gmm_choice",
            choices=c("Paranome", "Anchor pairs"),
            selected="Paranome"
        )
        updatePrettyRadioButtons(
            session,
            "sizer_choice",
            choices=c("Paranome", "Anchor pairs"),
            selected="Paranome"
        )
    }
})

output$ks_peak_table_output <- renderUI({
    if( isTruthy(input$gmm_comp_paralog) && input$gmm_comp_paralog != "" ){
        fluidRow(
            column(
                10,
                fluidRow(
                    column(
                        12,
                        h5(HTML("<b><font color='#9B3A4D'><i>K</i><sub>s</sub></font></b> Peak Info")),
                        DTOutput("selected_gmm_table")
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
                                       margin: 25px 5px 5px 5px;"
                            )
                        )
                    )
                )
            )
        )
    }
})

observeEvent(input$paralog_ks_plot_go, {
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")

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
        files_list <- selected_paralog_ksfile_df$path
        ks_file <- selected_paralog_ksfile_df$path
        ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

        if( isTruthy(input$distribution_choice) && input$distribution_choice == "Paranome" ){
            files_list_new <- c(ks_file)
        }else if( isTruthy(input$distribution_choice) && input$distribution_choice == "Anchor pairs" ){
            files_list_new <- c(ks_anchor_file)
        }else if( isTruthy(input$distribution_choice) && input$distribution_choice == "All" ){
            files_list_new <- c(ks_file, ks_anchor_file)
        }

        if( input$gmm_choice == "Paranome" ){
            ks_title <- gsub(".tsv$", "", basename(ks_file))
        }else{
            ks_title <- gsub(".tsv$", "", basename(ks_anchor_file))
        }

        gmm_pre_outfile <- paste0(dirname(ks_file), "/", ks_title, ".gmm.Rdata")

        withProgress(message='Analyzing in progress', value=0, {
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
            ks_data <- ksDist[ksDist$title == ks_title, ]
            ks_value <- ks_data$ks

            Sys.sleep(.2)
            incProgress(
                amount=0.2,
                message=paste0("GMM modelling for ", ks_title, " ...")
            )

            # GMM modelling
            if( file.exists(gmm_pre_outfile) ){
                load(gmm_pre_outfile)
            }else{
                df <- ks_mclust_v2(ks_value)
                save(df, file=gmm_pre_outfile)
            }
            df$title <- ks_title
            ks.mclust <- rbind(ks.mclust, df)

            ks.mclust$lower_bound <- qlnorm(0.025, meanlog=ks.mclust$mean, sdlog=ks.mclust$sigmasq)
            ks.mclust$upper_bound <- qlnorm(0.975, meanlog=ks.mclust$mean, sdlog=ks.mclust$sigmasq)

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
            best_comp <- gmm_BIC_df[gmm_BIC_df$BIC == max(gmm_BIC_df$BIC), ]
            gmm_BIC_list <- sapply(1:nrow(gmm_BIC_df), function(i) {
                paste0(
                    "comp: <b>",
                    gmm_BIC_df[i, "comp"],
                    "</b>, BIC: <b>",
                    round(gmm_BIC_df[i, "BIC"], 2),
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
                ),
                selected=gmm_BIC_list[best_comp$comp]
            )

            incProgress(
                amount=0.3,
                message=paste0("SiZer analyzing for ", ks_title, " ...")
            )

            #Sizer modelling
            sizer_pre_paranome_outfile <- paste0(dirname(ks_file), "/", ks_title, ".sizer.paranome.Rdata")
            sizer_pre_anchor_point_outfile <- paste0(dirname(ks_file), "/", ks_title, ".sizer.anchorpoint.Rdata")
            if( input$gmm_choice == "Paranome" ){
                if( file.exists(sizer_pre_paranome_outfile) ){
                    load(sizer_pre_paranome_outfile)
                }else{
                    ks_file_tmp <- ks_file
                    ksd_tmp <- read.wgd_ksd(ks_file_tmp)
                    ks_value_tmp <- ksd_tmp$ks_dist$Ks[ksd_tmp$ks_dist$Ks <= input[["ks_maxK_paralog"]]]
                    df_sizer <- SiZer(
                        ks_value_tmp,
                        gridsize=c(500, 50),
                        bw=c(0.01, 5)
                    )
                    save(df_sizer, file=sizer_pre_paranome_outfile)
                }
            }
            else{
                if( file.exists(sizer_pre_anchor_point_outfile) ){
                    load(sizer_pre_anchor_point_outfile)
                }else{
                    ks_file_tmp <- ks_anchor_file
                    ksd_tmp <- read.wgd_ksd(ks_file_tmp)
                    ks_value_tmp <- ksd_tmp$ks_dist$Ks[ksd_tmp$ks_dist$Ks <= input[["ks_maxK_paralog"]]]
                    df_sizer <- SiZer(
                        ks_value_tmp,
                        gridsize=c(500, 50),
                        bw=c(0.01, 5)
                    )
                    save(df_sizer, file=sizer_pre_anchor_point_outfile)
                }
            }

            ks.sizer[[ks_title]] <- list(
                species=ks_title,
                sizer=df_sizer$sizer,
                map=df_sizer$map,
                bw=df_sizer$bw
            )

            Sys.sleep(.2)
            incProgress(amount=.5, message="Calculating done...")

            widthPhyloKsSpacing <- reactiveValues(
                value=500
            )
            heightPhyloKsSpacing <- reactiveValues(
                value=500
            )

            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value - 50
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
                        "width"=widthPhyloKsSpacing$value,
                        "height"=heightPhyloKsSpacing$value,
                        "dataType"=input$gmm_choice
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
                        "width"=widthPhyloKsSpacing$value,
                        "height"=heightPhyloKsSpacing$value,
                        "dataType"=input$gmm_choice
                    )
                }
                session$sendCustomMessage("Paralog_Bar_Plotting", plot_wgd_data)
            })
            Sys.sleep(.2)
            incProgress(amount=.4, message="Ploting done...")

            observeEvent(input$gmm_comp_paralog, {
                if( file.exists(emmix_outfile) && input$gmm_comp_paralog != "" ){
                    ks.mclust <- read.table(
                        emmix_outfile,
                        header=TRUE,
                        sep="\t"
                    )

                    selected_comp <- as.numeric(
                        regmatches(input$gmm_comp_paralog, regexpr("\\d+", input$gmm_comp_paralog))
                    )

                    selected_gmm_info <- ks.mclust[ks.mclust$comp == selected_comp, ]
                    selected_gmm_info$CI <- paste0(
                        round(selected_gmm_info$lower_bound, 2),
                        "-",
                        round(selected_gmm_info$upper_bound, 2)
                    )
                    selected_gmm_info <- selected_gmm_info[c("comp", "BIC", "mode", "CI")]
                    selected_gmm_info$mode <- round(selected_gmm_info$mode, 2)
                    selected_gmm_info$BIC <- round(selected_gmm_info$BIC, 2)
                    selected_gmm_info$Species <- input$paralog_ks_files_list
                    selected_gmm_info[["Peak in"]] <- input$gmm_choice
                    selected_gmm_info <- selected_gmm_info[c("mode", "CI", "comp")]

                    shinyInputTest <- function(FUN, len, id, ...) {
                        inputs <- character(len)
                        for( i in seq_len(len) ){
                            inputs[i] <- as.character(
                                tagList(
                                    div(
                                        style="padding-bottom: -20px; margin-bottom: -25px; ",
                                        FUN(paste0(id, i), label=NULL, width="10px", ...)
                                    )
                                )
                            )
                        }
                        inputs
                    }

                    selected_gmm_info_with_checkb <- cbind(
                        Select=shinyInputTest(checkboxInput, nrow(selected_gmm_info), "checkb"),
                        selected_gmm_info
                    )

                    select_row_js <- c(
                        "$('[id^=checkb]').on('click', function(){",
                        "  var id = this.getAttribute('id');",
                        "  var i = parseInt(/checkb(\\d+)/.exec(id)[1]);",
                        "  var checkbox = $('[id^=checkb]:eq(' + (i - 1) + ')');",
                        "  var value = checkbox.prop('checked');",
                        "  var secondColValue = $('[id^=checkb]:eq(' + (i - 1) + ')').closest('tr').find('td:eq(1)').text();",
                        "  var info = [{row: i, peak: secondColValue, value: value}];",
                        "  Shiny.setInputValue('gmm_true_peaks:DT.cellInfo', info);",
                        "})"
                    )

                    output$selected_gmm_table <- renderDT({
                        selected_gmm_info_with_checkb %>%
                            setNames(., colnames(.) %>% gsub("CI", "95% Confidence Interval", .)) %>%
                            setNames(., colnames(.) %>% gsub("mode", "Peak", .)) %>%
                            setNames(., colnames(.) %>% gsub("comp", "Component", .)) %>%
                            setNames(., colnames(.) %>% gsub("Select", "Select to plot", .)) %>%
                            datatable(
                                options=list(
                                    searching=FALSE,
                                    lengthMenu=list(c(-1), c('All')),
                                    paging=FALSE,
                                    info=FALSE,
                                    dom='t'
                                ),
                                rownames=FALSE,
                                escape=FALSE,
                                editable=list(target="cell", disable=list(columns=7)),
                                selection="none",
                                callback=JS(select_row_js)
                            )

                    }, server=FALSE)

                    selected_comp <- as.numeric(
                        regmatches(input$gmm_comp_paralog, regexpr("\\d+", input$gmm_comp_paralog))
                    )

                    ksMclust <- ks.mclust %>%
                        filter(comp == selected_comp) %>%
                        ungroup()

                    selected_best_gmm_info <- reactiveVal(data.frame())
                    observeEvent(input$gmm_true_peaks, {
                        selected_gmm_info_tmp <- ksMclust[input$gmm_true_peaks$row, ]
                        if( input$gmm_true_peaks$value ){
                            selected_best_gmm_info(rbind(selected_best_gmm_info(), selected_gmm_info_tmp))
                        }else{
                            row_to_remove <- input$gmm_true_peaks$row
                            updated_data <- selected_best_gmm_info()[rownames(selected_best_gmm_info()) != row_to_remove, ]
                            selected_best_gmm_info(updated_data)
                        }
                    })

                    observe({
                        if( input$gmm_comp_paralog != "" ){
                            selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[["ks_maxK_paralog"]], ]
                            names_df <- map_informal_name_to_latin_name(species_info_file[1])

                            ploted_gmm_lines_info <- selected_best_gmm_info()
                            if( nrow(ploted_gmm_lines_info) > 0 ){
                                ploted_gmm_lines_info <- ploted_gmm_lines_info[order(ploted_gmm_lines_info$mode), ]

                                plot_wgd_data <- list(
                                    "plot_id"="Wgd_plot_paralog",
                                    "species_list"=names_df,
                                    "ks_title"=ks_title,
                                    "ks_bar_df"=selectedBarData,
                                    "paralog_id"=paralog_id,
                                    "mclust_df"=ploted_gmm_lines_info,
                                    "sizer_list"=ks.sizer,
                                    "xlim"=input[["ks_maxK_paralog"]],
                                    "ylim"=input[["y_limit_paralog"]],
                                    "color"="",
                                    "opacity"=input[["ks_transparency_paralog"]],
                                    "width"=widthPhyloKsSpacing$value,
                                    "height"=heightPhyloKsSpacing$value,
                                    "dataType"=input$gmm_choice
                                )
                            }else{
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
                                    "width"=widthPhyloKsSpacing$value,
                                    "height"=heightPhyloKsSpacing$value,
                                    "dataType"=input$gmm_choice
                                )
                            }
                            session$sendCustomMessage("Paralog_Bar_Plotting", plot_wgd_data)
                        }
                    })

                    output$ksPeakCsvDownload <- downloadHandler(
                        filename=function() {
                            paste0(
                                gsub(" ", "_", paralog_species),
                                ".paralogous_Ks_peaksInfo.csv"
                            )
                        },
                        content=function(file) {
                            download_df <- selected_best_gmm_info()[c("mode", "lower_bound", "upper_bound")]
                            download_df["95% Confidence Interval"] <- paste0(
                                round(download_df$lower_bound, 2),
                                "-",
                                round(download_df$upper_bound, 2)
                            )
                            download_df$Species <- paralog_species
                            download_df["Peak in"] <- input$gmm_choice
                            download_df$mode <- round(download_df$mode, 2)
                            download_df <- download_df[, c("Species", "Peak in", "mode", "95% Confidence Interval")]
                            names(download_df) <- c("Species", "Peak in", "Peak", "95% Confidence Interval")
                            download_df <- download_df[order(download_df$Peak), ]

                            write.table(
                                download_df,
                                file=file,
                                sep="\t",
                                quote=FALSE,
                                row.names=FALSE
                            )
                        }
                    )
                }
            })
        })
    }
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
        if( isTruthy(input$ortholog_ks_files_list_A) && length(input$ortholog_ks_files_list_A) > 1 ){
            withProgress(message='Configure in progress', value=0, {
                output$ks_analysis_output <- renderUI({
                    div(
                        class="boxLike",
                        style="background-color: #FDFFFF;
                               padding-bottom: 10px;
                               padding-top: 10px;",
                        column(
                            12,
                            h4(HTML("<b><font color='#9B3A4D'>Orthologous <i>K</i><sub>s</sub></font> Age Distribution</b>"))
                        ),
                        div(
                            style="padding: 10px 10px 10px 10px;",
                            hr(class="setting"),
                            fluidRow(
                                column(
                                    2,
                                    h5(HTML("<b><font color='orange'><i>K</i><sub>s</sub> </font></b> setting:")),
                                ),
                                if( !isTruthy(input$ortholog_paranome_species) ){
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
                                                        max=5,
                                                        value=5
                                                    )
                                                )
                                            ),
                                            column(
                                                3,
                                                actionButton(
                                                    inputId="ortholog_ks_plot_go",
                                                    # HTML("Start<br><b>ortholog <i>K</i><sub>s</sub></b></br>analysis"),
                                                    "Start",
                                                    icon=icon("play"),
                                                    status="secondary",
                                                    class="my-start-button-class",
                                                    title="Click to start",
                                                    style="color: #fff;
                                                           background-color: #27ae60;
                                                           border-color: #fff;
                                                           padding: 5px 14px 5px 14px;
                                                           margin: 25px 5px 5px 5px;"
                                                )
                                            )
                                        )
                                    )
                                }
                                else{
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
                                                        max=5,
                                                        value=5
                                                    )
                                                )
                                            ),
                                            column(
                                                4,
                                                div(
                                                    style="/*display: flex; align-items: center; */
                                                           margin-bottom: -10px;
                                                           border-radius: 10px;
                                                           padding: 10px 10px 0px 10px;
                                                           background-color: #FFF5EE;",
                                                    pickerInput(
                                                        inputId="plot_ortholog_paralog_species",
                                                        label=HTML("<font color='orange'>Data</font> used for <font color='orange'>Paralogous <i>K</i><sub>s</sub> Distribution</font>:"),
                                                        choices=c("All", "Paranome", "Anchor pairs"),
                                                        multiple=FALSE,
                                                        selected="All",
                                                        inline=TRUE
                                                    )
                                                )
                                            ),
                                            column(
                                                2,
                                                actionButton(
                                                    inputId="ortholog_ks_plot_go",
                                                    # HTML("Start<br><b>ortholog <i>K</i><sub>s</sub></b></br>analysis"),
                                                    "Start",
                                                    icon=icon("play"),
                                                    status="secondary",
                                                    class="my-start-button-class",
                                                    title="Click to start",
                                                    style="color: #fff;
                                                           background-color: #27ae60;
                                                           border-color: #fff;
                                                           padding: 5px 14px 5px 14px;
                                                           margin: 25px 5px 5px 5px;"
                                                )
                                            )
                                        )
                                    )
                                }
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
                            if( isTruthy(input$ortholog_paranome_species) ){
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
                                                    inputId="y2_limit_ortholog_paralog",
                                                    label=HTML("<font color='orange'>Retained Duplicates Y axis limit</font>:"),
                                                    min=0,
                                                    step=200,
                                                    max=6000,
                                                    value=2000
                                                )
                                            )
                                        ),
                                        column(
                                            4,
                                            div(
                                                style="padding: 12px 10px 5px 10px;
                                                       border-radius: 10px;
                                                       background-color: #F0FFFF",
                                                sliderInput(
                                                    inputId="y_limit_ortholog",
                                                    label=HTML("<font color='orange'>Ortholog Density Y axis limit</font>:"),
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
                                                    label=HTML("<font color='orange'>Transparency</font>:"),
                                                    min=0,
                                                    max=1,
                                                    step=0.1,
                                                    value=0.5
                                                )
                                            )
                                        )
                                    )
                                )
                            }
                            else{
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
                                                    label=HTML("<font color='orange'>Y axis limit</font>:"),
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
                                                    label=HTML("<font color='orange'>Transparency</font>:"),
                                                    min=0,
                                                    max=1,
                                                    step=0.1,
                                                    value=0.5
                                                )
                                            )
                                        )
                                    )
                                )
                            }
                        )
                    )
                })

                Sys.sleep(.2)
                incProgress(amount=.5, message="Configure done ...")
                incProgress(amount=1)
                Sys.sleep(.1)
            })
        }else{
            shinyalert(
                "Oops!",
                "Please choose at lease two species for orthologous study!",
                type="error"
            )
        }
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
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
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
            ksfiles <- list.files(path=ksAnalysisDir, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
            species_info_file <- list.files(path=ksAnalysisDir, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
            ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
            paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

            names_df <- map_informal_name_to_latin_name(species_info_file[1])

            widthPhyloKsSpacing <- reactiveValues(
                value=1000
            )
            heightPhyloKsSpacing <- reactiveValues(
                value=350
            )
            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value - 50
            })

            speciesA <- input$ortholog_ks_files_list_A

            files_list <- c()

            for( i in 1:length(speciesA) ){
                pattenEach <- which(names_df$latin_name == gsub("_", " ", speciesA[[i]]))
                each_informal_name <- names_df$informal_name[pattenEach]
                species_A_file <- ortholog_ksfiles[grepl(each_informal_name, ortholog_ksfiles)]
                for( j in 1:length(speciesA) ){
                    if( j > i ){
                        pattenEach_B <- which(names_df$latin_name == gsub("_", " ", speciesA[[j]]))
                        species_A_B_file <- species_A_file[grepl(pattenEach_B, species_A_file)]
                        if( !is.null(species_A_B_file) ){
                            files_list <- c(files_list, species_A_B_file)
                        }
                    }
                }
            }
            files_list <- unique(files_list)

            full_data <- calculateKsDistribution4wgd_multiple(
                files_list,
                maxK=input[["ks_maxK_ortholog"]],
            )
            denData <- full_data$density

            newick_tree_file <- paste0(dirname(species_info_file), "/tree.newick")
            treeTopology <- readLines(textConnection(readChar(newick_tree_file, file.info(newick_tree_file)$size)))
            closeAllConnections()

            ks_bar_data <- NULL

            if( isTruthy(input$ortholog_paranome_species) ){
                ortholog_paranome_informal_name <- names_df[names_df$latin_name == input$ortholog_paranome_species, ]$informal_name
                selected_ks_files <- c()
                selected_paralog_ks_file <- paralog_ksfiles[grepl(ortholog_paranome_informal_name, paralog_ksfiles)]
                selected_paralog_anchor_ks_file <- gsub("ks.tsv$", "ks_anchors.tsv", selected_paralog_ks_file)
                if( input$plot_ortholog_paralog_species == "All" ){
                    selected_ks_files <- c(selected_ks_files, selected_paralog_ks_file)
                    selected_ks_files <- c(selected_ks_files, selected_paralog_anchor_ks_file)
                }
                else if( input$plot_ortholog_paralog_species == "Anchor pairs" ){
                    selected_ks_files <- c(selected_ks_files, selected_paralog_anchor_ks_file)
                }
                else{
                    selected_ks_files <- c(selected_ks_files, selected_paralog_ks_file)
                }

                selected_ks_data <- calculateKsDistribution4wgd_multiple(
                    selected_ks_files
                )

                ks_bar_data <- selected_ks_data$bar
            }

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
                    "width"=widthPhyloKsSpacing$value,
                    "height"=heightPhyloKsSpacing$value,
                    "tree_topology"=treeTopology[1]
                )

                if( !is.null(ks_bar_data) ){
                    selected_paralog_ks_bar_data <- ks_bar_data[ks_bar_data$ks <= input[["ks_maxK_ortholog"]], ]
                    plot_wgd_data[["ks_bar_df"]] <- selected_paralog_ks_bar_data
                    plot_wgd_data[["y2lim"]] <- input$y2_limit_ortholog_paralog
                    plot_wgd_data[["ortholog_paralog_species"]] <- input$ortholog_paranome_species
                }

                session$sendCustomMessage("Otholog_Density_Tree_Plotting", plot_wgd_data)
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

            # if( isTruthy(input$select_focal_species) & input$select_focal_species != ""  ){
                output$rate_ks_setting <- renderUI({
                    fluidRow(
                        column(
                            12,
                            fluidRow(
                                column(
                                    4,
                                    div(
                                        style="/*display: flex; align-items: center; */
                                               margin-bottom: -10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 0px 10px;
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
                                        style="/*display: flex; align-items: center; */
                                               margin-bottom: -10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 0px 10px;
                                               background-color: #FFF5EE;",
                                        pickerInput(
                                            inputId="plot_reference_species_data",
                                            label=HTML("<font color='orange'>Data</font> used for <font color='orange'>Paralogous <i>K</i><sub>s</sub> Distribution</font>:"),
                                            choices=c("All", "Paranome", "Anchor pairs"),
                                            multiple=FALSE,
                                            selected="All",
                                            inline=TRUE
                                        )
                                    )
                                )
                            )
                        ),
                        column(
                            12,
                            hr(class="setting"),
                            fluidRow(
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
                                               margin-bottom: -10px;
                                               border-radius: 10px;
                                               padding: 10px 10px 0px 10px;
                                               background-color: #FFF5EE;",
                                        sliderInput(
                                            inputId="ks_maxK_rate",
                                            label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
                                            min=0,
                                            step=1,
                                            max=5,
                                            value=5
                                        )
                                    )
                                ),
                                column(
                                    3,
                                    actionButton(
                                        inputId="rate_plot_go",
                                        "Start",
                                        icon=icon("play"),
                                        status="secondary",
                                        title="Click to start",
                                        class="my-start-button-class",
                                        style="color: #fff;
                                               background-color: #27ae60;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 13px 5px 15px 5px;"
                                    )
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
                                    inputId="y2_limit_rate",
                                    label=HTML("<font color='orange'>Ortholog Density Y axis limit</font>:"),
                                    min=0,
                                    step=0.2,
                                    max=5,
                                    value=2
                                )
                            )
                        ),
                        column(
                            4,
                            div(
                                style="padding: 12px 10px 5px 10px;
                                       border-radius: 10px;
                                       background-color: #F0FFFF",
                                sliderInput(
                                    inputId="y1_limit_rate",
                                    label=HTML("<font color='orange'>Retained Duplicates Y axis limit</font>:"),
                                    min=0,
                                    step=200,
                                    max=6000,
                                    value=2500
                                )
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
                                    label=HTML("<font color='orange'>Transparency</font>:"),
                                    min=0,
                                    max=1,
                                    step=0.1,
                                    value=0.5
                                )
                            )
                        )
                    )
                })
            # }
            # else{
            #     output$rate_ks_setting <- renderUI({
            #         fluidRow(
            #             column(
            #                 4,
            #                 div(
            #                     style="/*display: flex; align-items: center; */
            #                                        margin-bottom: -10px;
            #                                        border-radius: 10px;
            #                                        padding: 10px 10px 0px 10px;
            #                                        background-color: #FFF5EE;",
            #                     sliderInput(
            #                         inputId="ks_maxK_rate",
            #                         label=HTML("<font color='orange'><i>K</i><sub>s</sub> limit</font>:&nbsp;"),
            #                         min=0,
            #                         step=1,
            #                         max=10,
            #                         value=5
            #                     )
            #                 )
            #             )
            #         )
            #     })
            #
            #     output$rate_figure_setting <- renderUI({
            #         fluidRow(
            #             column(
            #                 4,
            #                 div(
            #                     style="padding: 12px 10px 5px 10px;
            #                                    border-radius: 10px;
            #                                    background-color: #F0FFFF",
            #                     sliderInput(
            #                         inputId="y1_limit_rate",
            #                         label=HTML("Set the <font color='orange'>Y axis limit</font>:"),
            #                         min=0,
            #                         step=0.2,
            #                         max=5,
            #                         value=2
            #                     ),
            #                 )
            #             ),
            #             column(
            #                 4,
            #                 div(
            #                     style="padding: 12px 10px 5px 10px;
            #                                    border-radius: 10px;
            #                                    background-color: #F0FFFF",
            #                     sliderInput(
            #                         inputId="opacity_rate",
            #                         label=HTML("Set the <font color='orange'>Transparency</font>:"),
            #                         min=0,
            #                         max=1,
            #                         step=0.1,
            #                         value=0.5
            #                     )
            #                 )
            #             )
            #         )
            #     })
            # }


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
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
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
            widthPhyloKsSpacing <- reactiveValues(
                value=1100
            )
            heightPhyloKsSpacing <- reactiveValues(
                value=350
            )
            observeEvent(input$ks_svg_vertical_spacing_add, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_vertical_spacing_sub, {
                heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value - 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_add, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value + 50
            })
            observeEvent(input$ks_svg_horizontal_spacing_sub, {
                widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value - 50
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

            ref2outgroup_id <- gsub(".tsv$", "", basename(ref2outgroupFile))

            ks_files_for_correction <- c()

            mode_df <- data.frame()
            for( i in 1:length(studySpecies) ){
                pattenEach <- which(names_df$latin_name == gsub("_", " ", studySpecies[[i]]))
                each_informal_name <- names_df$informal_name[pattenEach]
                ref2studyFile <- ortholog_ksfiles[grepl(ref_informal_name, ortholog_ksfiles) & grepl(each_informal_name, ortholog_ksfiles)]
                study2outgroupFile <- ortholog_ksfiles[grepl(each_informal_name, ortholog_ksfiles) & grepl(outgroup_informal_name, ortholog_ksfiles)]
                ks_selected_files <- c(ks_selected_files, study2outgroupFile)

                ks_files_for_correction <- c(ks_files_for_correction, ref2studyFile)

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

            # if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){

            req(input[["ks_binWidth_rate"]])
            req(input[["plot_mode_option_rate"]])
            req(input[["plot_reference_species_data"]])

                pattenFocal <- which(names_df$latin_name == gsub("_", " ", input$select_ref_species))
                each_focal_name <- names_df$informal_name[pattenFocal]

                ks_file <- paralog_ksfiles[grepl(each_focal_name, paralog_ksfiles)]
                paralog_id <- gsub(".ks.tsv$", "", basename(ks_file))

                ks_anchor_file <- gsub(".ks.tsv$", ".ks_anchors.tsv", ks_file)

                files_list_new <- c()
                if( input$plot_reference_species_data == "All" ){
                    files_list_new <- c(files_list_new, ks_file)
                    files_list_new <- c(files_list_new, ks_anchor_file)
                }
                else if( input$plot_reference_species_data == "Anchor pairs" ){
                    files_list_new <- c(files_list_new, ks_anchor_file)
                }
                else{
                    files_list_new <- c(files_list_new, ks_file)
                }

                files_list_new <- c(files_list_new, ks_selected_files)

                full_data <- calculateKsDistribution4wgd_multiple(
                    files_list_new,
                    plot.mode=input[["plot_mode_option_rate"]],
                    maxK=input[["ks_maxK_rate"]],
                    binWidth=input[["ks_binWidth_rate"]]
                )
                barData <- full_data$bar
                denData <- full_data$density

                full_data_correction <- calculateKsDistribution4wgd_multiple(
                    ks_files_for_correction,
                    plot.mode=input[["plot_mode_option_rate"]],
                    maxK=input[["ks_maxK_rate"]],
                    binWidth=input[["ks_binWidth_rate"]]
                )
                denData_for_correction <- full_data_correction$density

                Sys.sleep(.2)
                incProgress(amount=.4, message="Calculating done...")

                observe({
                    selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[["ks_maxK_rate"]], ]
                    selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[["ks_maxK_rate"]], ]
                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_rate",
                        "ks_density_df"=selectedDenData,
                        "ks_density_for_correct_df"=denData_for_correction,
                        "ref2outgroup_id"=ref2outgroup_id,
                        "species_list"=names_df,
                        "ks_bar_df"=selectedBarData,
                        "rate_correction_df"=mode_df,
                        "paralog_id"=paralog_id,
                        "paralogSpecies"=gsub("_", " ", input$select_ref_species),
                        "xlim"=input[["ks_maxK_rate"]],
                        "ylim"=input[["y1_limit_rate"]],
                        "y2lim"=input[["y2_limit_rate"]],
                        "color"="",
                        "opacity"=input[["opacity_rate"]],
                        "width"=widthPhyloKsSpacing$value,
                        "height"=heightPhyloKsSpacing$value
                    )
                    session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
                })
            # }
            # else{
            #     plot_wgd_data <- list(
            #         "paralog_id"=""
            #     )
            #     files_list <- ks_selected_files
            #
            #     full_data <- calculateKsDistribution4wgd_multiple(
            #         files_list
            #     )
            #     denData <- full_data$density
            #     Sys.sleep(.2)
            #     incProgress(amount=.4, message="Calculating done...")
            #
            #     observe({
            #         selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[["ks_maxK_rate"]], ]
            #         plot_wgd_data <- list(
            #             "plot_id"="Wgd_plot_rate",
            #             "ks_density_df"=selectedDenData,
            #             "rate_correction_df"=mode_df,
            #             "species_list"=names_df,
            #             "xlim"=input[["ks_maxK_rate"]],
            #             "y2lim"=input[["y1_limit_rate"]],
            #             "color"="",
            #             "opacity"=input[["opacity_rate"]],
            #             "width"=widthPhyloKsSpacing$value,
            #             "height"=heightPhyloKsSpacing$value
            #         )
            #         session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
            #     })
            # }
            Sys.sleep(.2)
            incProgress(amount=.4, message="Ploting done...")
        })
    }
})

observeEvent(input$confirm_phylo_ks_go, {
    shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
    shinyjs::runjs("$('#confirm_phylo_ks_go').css('background-color', 'green');")
    updateActionButton(
        session,
        "confirm_phylo_ks_go",
        icon=icon("check")
    )

    setTimeoutFunction <- "setTimeout(function() {
              $('#confirm_phylo_ks_go').css('background-color', '#C0C0C0');
              //$('#confirm_phylo_ks_go').empty();
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

    output$ks_analysis_output <- renderUI({
        div(
            class="boxLike",
            style="background-color: white;
                   padding-bottom: 10px;
                   padding-top: 10px",
            fluidRow(
                column(
                    9,
                    tags$style(
                        HTML(".rotate-135 {
                                transform: rotate(135deg);
                            }"),
                        HTML(".rotate-45{
                                transform: rotate(45deg);
                            }")
                    ),
                    actionButton(
                        "phylo_ks_svg_vertical_spacing_add",
                        "",
                        icon("arrows-alt-v"),
                        title="Expand vertical spacing"
                    ),
                    actionButton(
                        "phylo_ks_svg_vertical_spacing_sub",
                        "",
                        icon(
                            "down-left-and-up-right-to-center",
                            verify_fa=FALSE,
                            class="rotate-135"
                        ),
                        title="Compress vertical spacing"
                    ),
                    actionButton(
                        "phylo_ks_svg_horizontal_spacing_add",
                        "",
                        icon("arrows-alt-h"),
                        title="Expand horizontal spacing"
                    ),
                    actionButton(
                        "phylo_ks_svg_horizontal_spacing_sub",
                        "",
                        icon(
                            "down-left-and-up-right-to-center",
                            verify_fa=FALSE,
                            class="rotate-45"
                        ),
                        title="Compress horizontal spacing"
                    ),
                    downloadButton_custom(
                        "phyloKsTreePlotDownload",
                        status="secondary",
                        icon=icon("download"),
                        title="Download the plot",
                        class="my-donwload-button-class",
                        label=HTML(""),
                        style="color: #fff;
                              background-color: #6B8E23;
                              border-color: #fff;
                              padding: 5px 14px 5px 14px;
                              margin: 5px 5px 5px 5px;"
                    )
                ),
                column(
                    12,
                    div(
                        id="phylo_ks_tree_plot",
                    )
                )
            )
        )
    })


    widthPhyloKsSpacing <- reactiveValues(value=600)
    heightPhyloKsSpacing <- reactiveValues(value=NULL)

    observe({
        if( isTruthy(input$uploadPhyloKsTree) ){
            phyloKsTreeFile <- input$uploadPhyloKsTree$datapath
            phyloKsTree <- readLines(textConnection(readChar(phyloKsTreeFile, file.info(phyloKsTreeFile)$size)))
            closeAllConnections()
            sp_count <- str_count(phyloKsTree[1], ":")
            trunc_val <- as.numeric(sp_count) * 20
            heightPhyloKsSpacing$value <- trunc_val
        }
    })

    observeEvent(input$phylo_ks_svg_vertical_spacing_add, {
        heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value + 50
    })
    observeEvent(input$phylo_ks_svg_vertical_spacing_sub, {
        heightPhyloKsSpacing$value <- heightPhyloKsSpacing$value - 50
    })
    observeEvent(input$phylo_ks_svg_horizontal_spacing_add, {
        widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value + 50
    })
    observeEvent(input$phylo_ks_svg_horizontal_spacing_sub, {
        widthPhyloKsSpacing$value <- widthPhyloKsSpacing$value - 50
    })

    observe({
        if( isTruthy(input$uploadPhyloKsTree) ){
            phyloKsTreeFile <- input$uploadPhyloKsTree$datapath
            phyloKsTree <- readLines(textConnection(readChar(phyloKsTreeFile, file.info(phyloKsTreeFile)$size)))
            closeAllConnections()

            phylo_ks_tree_data <- list(
                "width"=widthPhyloKsSpacing$value
            )

            phylo_ks_tree_data[["ksTree"]] <- phyloKsTree[1]

            if( isTruthy(input$uploadPhyloKsPeakTable) ){
                ksPeakTableFile <- input$uploadPhyloKsPeakTable$datapath
                ksPeak <- suppressMessages(
                    vroom(
                        ksPeakTableFile,
                        col_names=c("species", "type", "peak", "confidence_interval"),
                        delim="\t",
                        skip=1
                    )
                )
                if( ncol(ksPeak) == 4 ){
                    color_list <- c(
                        "#ff7f00", "#FFA750", "#0064A7", "#008DEC",
                        "#088A00", "#0CD300", "#e31a1c", "#fb9a99", "#cab2d6"
                    )
                    ksPeak$color <- color_list[match(ksPeak$species, unique(ksPeak$species))]
                }
                phylo_ks_tree_data[["ksPeak"]] <- ksPeak
            }

            phylo_ks_tree_data[["height"]] <- heightPhyloKsSpacing$value
            phylo_ks_tree_data[["plot_id"]] <- "phylo_ks_tree_plot"
            phylo_ks_tree_data[["download_id"]] <- "phyloKsTreePlotDownload"
            session$sendCustomMessage("jointTreePlot", phylo_ks_tree_data)
        }
    })
})

