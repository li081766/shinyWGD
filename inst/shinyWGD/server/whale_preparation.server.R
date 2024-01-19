output$whaleDataUploadPanel <- renderUI({
    fluidRow(
        div(class="boxLike",
            style="background-color: #FAF9F6;
                   margin: 5px 5px 5px 5px;
                   padding: 5px 10px 10px 10px;",
            column(
                12,
                h4(icon("upload"), "Uploading"),
                hr(class="setting"),
                HTML("Uploading the Analysis Directory:</br>"),
                h5(HTML("<font color='green'><b><i>shinyWGD</i> OrthoFinder Analysis</b></font> Data")),
                fluidRow(
                    class="justify-content-left",
                    style="padding-bottom: 15px;
                           padding-top: 5px",
                    column(
                        12,
                        div(
                            style="padding-left: 10px;
                                   position: relative;",
                            fileInput(
                                'orthofinder_data_zip_file',
                                label=h6(icon("file-zipper"), HTML("Upload the <b>Zipped</b> File")),
                                multiple=FALSE,
                                accept=c(
                                    ".zip",
                                    ".gz"
                                ),
                                width="80%"
                            ),
                            actionButton(
                                inputId="orthofinder_data_example",
                                "",
                                icon=icon("question"),
                                status="secondary",
                                class="my-start-button-class",
                                title="Click to use the example data to demo run the Whale Preparation",
                                style="color: #fff;
                                       background-color: #87CEEB;
                                       border-color: #fff;
                                       position: absolute;
                                       top: 63%;
                                       left: 90%;
                                       margin-top: -15px;
                                       margin-left: -15px;
                                       padding: 5px 14px 5px 10px;
                                       width: 30px; height: 30px; border-radius: 50%;"
                            )
                        )
                    ),
                    column(
                        12,
                        uiOutput("selectedOrthoFinderDirName")
                    )
                )
            ),
            column(
                12,
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        div(
                            style="padding-left: 10px;
                                   position: relative;",
                            fileInput(
                                inputId="uploadSpeciesTimeTree",
                                label=HTML("<font color='green'><b>Species Time Tree</b></font> in <font color='red'><b><i>Newick</b></i></font>:"),
                                width="80%"
                            ),
                            actionButton(
                                inputId="newick_time_file_example",
                                "",
                                icon=icon("question"),
                                status="secondary",
                                class="my-start-button-class",
                                title="Click to see the example of the Newick Time Tree File",
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
                )
            ),
            column(
                12,
                hr(class="setting"),
                h6(
                    HTML(
                        "If you don’t ensure the evolutionary relationships among the studied species, please use the ",
                    )
                ),
                actionLink(
                    "go_extracting_tree",
                    HTML(
                        paste0(
                            "<i class='fas fa-tree' style='color: #5151A2;'>&nbsp;</i>",
                            "<font color='#5151A2'>",
                            "<i><b>TimeTreeFetcher</b></i></font>"
                        )
                    )
                ),
                h6(
                    HTML(
                        "module of shinyWGD to obtain a tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a>."
                    )
                )
            )
        )
    )
})

observeEvent(input$orthofinder_data_example, {
    showModal(
        modalDialog(
            title=HTML("The description of the demo data used to prepare the <b>Whale inputs</b>"),
            size="xl",
            uiOutput("orthofinder_data_example_panel")
        )
    )

    output$orthofinder_data_example_panel <- renderUI({
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
                            "<p>In the demo data, we selected four species: <i>Apostasia shenzhenica</i>, <i>Phalaenopsis equestris</i>, <i>Asparagus officinalis</i>, and <i>Dendrobium catenatum</i>, as also used in <b><i>K</i><sub>s</sub>Dist</b> module and <b>Collinearity</b> module, to generate the data.</p>",
                            "<p>First, we followed the preparation steps in the Data Preparation Page of the <b>shinyWGD</b> server to create the script for the corresponding package, <b>OrthoFinder</b>. ",
                            "We then submitted the job to the PSB computing server to obtain the output.</p>",
                            "<p>After obtaining the output, the data used for the preparation will be archived and compressed to a file, named by <b><i>OrthoFinderOutput_for_Whale.tar.gz</i></b>. ",
                            "<p>Users can upload the compressed file and start the preparation process.</p>",
                            "<p>After uploading the time tree of the studied species, users have the capability to specify the clade of interest, enabling them to selectively focus on particular gene families (",
                            "see more <a href='https://github.com/arzwa/Whale.jl/blob/master/scripts/orthofilter.py' target='_blank'>click here</a>). ",
                            "Additionally, users can identify and insert potential Whole Genome Duplication (WGD) events for subsequent analysis. ",
                            "The flexibility extends to choosing the appropriate model within the <b>Whale</b> and configuring the Markov Chain Monte Carlo (MCMC) chain.</p>",
                            "<p>To expedite the validation process, users can choose a subset of gene families for a rapid assessment of Whale's performance. ",
                            "This functionality allows for a quick check of the algorithm's run on a smaller, manageable dataset before executing a comprehensive analysis on the entire set of gene families.</p>",
                            "<p>To download the demo data, <a href='https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_OrthoFinderOutput_for_Whale.tar.gz' target='_blank'>click here</a>.</p>",
                            "<p><br></br></p>"
                        )
                    ),
                    h5(
                        HTML(
                            "<hr><p><b><font color='#BDB76B'>For true data</font></b>"
                        )
                    ),
                    HTML(
                        "<p>Users should upload the zipped-file, named as <b><i>OrthoFinderOutput_for_Whale.tar.gz</i></b> in the <b>Analysis-*</b> folder created by <b>shinyWGD</b>, to start the <b>Whale Preparation</b>.</p>"
                    )
                )
            )
        )
    })
})

example_data_dir <- file.path(getwd(), "demo_data")
whale_example_dir <- file.path(example_data_dir, "Example_Whale_Preparation")
og_check_file <- paste0(whale_example_dir, "/OrthoFinderOutputDir/Results_Nov18/MultipleSequenceAlignments/OG0002009.fa")

if( !dir.exists(whale_example_dir) & !file.exists(og_check_file) ){
    withProgress(message='Downloading Whale preparation demo data...', value=0, {
        if( !dir.exists(example_data_dir) ){
            dir.create(example_data_dir)
        }
        dir.create(whale_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

        downloadAndExtractData <- function() {
            download.file(
                "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_OrthoFinderOutput_for_Whale.tar.gz",
                destfile=file.path(getwd(), "whale.data.zip"),
                mode="wb"
            )

            system(
                paste(
                    "tar xzf",
                    shQuote(file.path(getwd(), "whale.data.zip")),
                    "-C",
                    shQuote(whale_example_dir)
                )
            )

            file.remove(file.path(getwd(), "whale.data.zip"))
        }

        downloadAndExtractData()
        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
}else if( dir.exists(whale_example_dir) & !file.exists(og_check_file) ){
    withProgress(message='Downloading Whale preparation demo data...', value=0, {
        system(
            paste("rm -rf ", whale_example_dir)
        )
        dir.create(whale_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

        downloadAndExtractData <- function() {
            download.file(
                "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_OrthoFinderOutput_for_Whale.tar.gz",
                destfile=file.path(getwd(), "whale.data.zip"),
                mode="wb"
            )

            system(
                paste(
                    "tar xzf",
                    shQuote(file.path(getwd(), "whale.data.zip")),
                    "-C",
                    shQuote(whale_example_dir)
                )
            )

            file.remove(file.path(getwd(), "whale.data.zip"))
        }

        downloadAndExtractData()
        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
}

buttonWhalePreparationClicked <- reactiveVal(NULL)
orthofinder_whale_analysis_dir_Val <- reactiveVal(whale_example_dir)

observeEvent(input$orthofinder_data_zip_file, {
    buttonWhalePreparationClicked("fileInput")

    base_dir <- tempdir()
    timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
    OrthoFinderWhaleAnalysisDir <- file.path(base_dir, paste0("Whale_Preparation_data_", gsub("[ :\\-]", "_", timestamp)))
    dir.create(OrthoFinderWhaleAnalysisDir)
    orthofinder_output_file <- "OrthoFinder_result.tar.gz"
    system(
        paste(
            "cp",
            input$orthofinder_data_zip_file$datapath,
            paste0(OrthoFinderWhaleAnalysisDir, "/", orthofinder_output_file)
        )
    )
    orthofinder_whale_analysis_dir_Val(OrthoFinderWhaleAnalysisDir)
})

observeEvent(input$orthofinder_data_example, {
    buttonWhalePreparationClicked("actionButton")
    orthofinder_whale_analysis_dir_Val(whale_example_dir)
})

observe({
    if( is.null(buttonWhalePreparationClicked()) ){
        OrthoFinderWhaleAnalysisDir <- whale_example_dir
        if( length(OrthoFinderWhaleAnalysisDir) > 0 ){
            output$selectedOrthoFinderDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'>Whale Preparation</font></b>"))
                    )
                )
            })
        }
    }
    else if( buttonWhalePreparationClicked() == "fileInput" ){
        OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
        if( length(OrthoFinderWhaleAnalysisDir) > 0 ){
            dirName <- basename(OrthoFinderWhaleAnalysisDir)
            output$selectedOrthoFinderDirName <- renderUI({
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
    else if( buttonWhalePreparationClicked() == "actionButton" ){
        OrthoFinderWhaleAnalysisDir <- whale_example_dir
        if( length(OrthoFinderWhaleAnalysisDir) > 0 ){
            output$selectedOrthoFinderDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'>Whale Preparation</font></b>"))
                    )
                )
            })
        }
    }
})

observeEvent(input$newick_time_file_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>Newick Time Tree</b></font> file"),
            size="xl",
            uiOutput("newick_time_file_example_panel")
        )
    )

    output$newick_time_file_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("newickTimeTreeExample"),
                    HTML(
                        paste0(
                            "<font color='green'><i aria-label='warning icon' class='fa fa-warning fa-fw' role='presentation'></i></font> The time scale on the tree is in units of <b>100 millions of years ago</b>.<br>",
                            "see more <a href='https://en.wikipedia.org/wiki/Newick_format#:~:text=In%20mathematics%2C%20Newick%20tree%20format,Maddison%2C%20Christopher%20Meacham%2C%20F.' target='_blank'>click here</a>."
                        )
                    )
                )
            )
        )
    })

    output$newickTimeTreeExample <- renderText({
        "(Asparagus_officinalis:117.61,(Apostasia_shenzhenica:84.55,(Dendrobium_catenatum:52.11,Phalaenopsis_equestris:52.11):32.44):33.06);"
    })
})

observeEvent(input$go_extracting_tree, {
    updateNavbarPage(inputId="shinywgd", selected="extracting_tree")
    shinyjs::runjs(
        'setTimeout(function () {
            document.querySelector("#ObtainTreeFromTimeTreeSettingDisplay").scrollIntoView({
                behavior: "smooth",
                block: "start",
            });
        }, 100);
    ')
})

speciesTimeTreeRv <- reactiveValues(data=NULL, clear=FALSE)

observeEvent(input$uploadSpeciesTimeTree, {
    speciesTimeTreeRv$clear <- FALSE
}, priority=1000)

widthSpacing <- reactiveValues(value=400)
heightSpacing <- reactiveValues(value=NULL)

observe({
    if( isTruthy(input$uploadSpeciesTimeTree) ){
        speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()
        sp_count <- str_count(speciesTree, ":")
        trunc_val <- as.numeric(sp_count) * 20
        heightSpacing$value <- trunc_val
    }
    else{
        speciesTree <- "(Asparagus_officinalis:117.61,(Apostasia_shenzhenica:84.55,(Dendrobium_catenatum:52.11,Phalaenopsis_equestris:52.11):32.44):33.06);"
        sp_count <- str_count(speciesTree, ":")
        trunc_val <- as.numeric(sp_count) * 20
        heightSpacing$value <- trunc_val
    }
})

observeEvent(input$svg_vertical_spacing_add_species, {
    heightSpacing$value <- heightSpacing$value + 30
})
observeEvent(input$svg_vertical_spacing_sub_species, {
    heightSpacing$value <- heightSpacing$value - 30
})
observeEvent(input$svg_horizontal_spacing_add_species, {
    widthSpacing$value <- widthSpacing$value + 30
})
observeEvent(input$svg_horizontal_spacing_sub_species, {
    widthSpacing$value <- widthSpacing$value - 30
})

# species_in_Tree_list <- reactiveVal(NULL)

observe({
    if( isTruthy(input$uploadSpeciesTimeTree) ){
        species_tree_data <- list(
            "width"=widthSpacing$value
        )
        speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()

        species_tree_data[["speciesTree"]] <- speciesTree[1]

        # species_in_Tree_list(regmatches(speciesTree[1], gregexpr("[A-Za-z_]+", speciesTree[1]))[[1]])

        species_tree_data[["height"]] <- heightSpacing$value[1]
        species_tree_data[["tree_plot_div"]] <- "speciesTree_plot"
        session$sendCustomMessage("speciesTreePlot", species_tree_data)
    }
    else{
        species_tree_data <- list(
            "width"=widthSpacing$value
        )
        dome_tree <- "(Asparagus_officinalis:117.61,(Apostasia_shenzhenica:84.55,(Dendrobium_catenatum:52.11,Phalaenopsis_equestris:52.11):32.44):33.06);"
        # species_in_Tree_list(regmatches(dome_tree, gregexpr("[A-Za-z_]+", dome_tree))[[1]])

        species_tree_data[["speciesTree"]] <- dome_tree
        species_tree_data[["height"]] <- heightSpacing$value[1]
        species_tree_data[["tree_plot_div"]] <- "speciesTree_plot"
        session$sendCustomMessage("speciesTreePlot", species_tree_data)
    }
})

wgdEventNote <- reactiveVal(NULL)

observe({
    OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
    if( length(OrthoFinderWhaleAnalysisDir) > 0 ){
        wgdNum <- toupper(as.english(length(input$wgdInput)))
        if( length(input$wgdInput) > 0 ){
            note <- HTML(paste0("<font color='#AD1F1F'><b>", wgdNum, "</b></font> WGD events will be examinated."))
        }else{
            note <- HTML(paste0("<font color='#C0C0C0'><b>", wgdNum, "</b></font> WGD event will be examinated."))
        }
        wgdEventNote(note)
    }
})

observe({
    OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
    if( length(OrthoFinderWhaleAnalysisDir) > 0 ){
        output$whaleCommandPanel <- renderUI({
            fluidRow(
                div(class="boxLike",
                    style="background-color: white;
                           margin: 5px 5px 5px 5px;
                           padding: 5px 10px 10px 10px;",
                    column(
                        id="WhaleSetting",
                        width=12,
                        h4(icon("cog"), HTML("<b><i>Whale</b></i> Setting")),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                8,
                                h6(HTML("<font color='#AD1F1F'>Hypothetic WGDs</font> to test:")),
                                verbatimTextOutput(
                                    "wgdNeededTestedID",
                                    placeholder=TRUE
                                ),
                                wgdEventNote()
                            ),
                            column(
                                12,
                                fluidRow(
                                    column(
                                        12,
                                        hr(class="setting")
                                    ),
                                    # column(
                                    #     4,
                                    #     div(
                                    #         style="background-color: #F8F8FF;
                                    #                padding: 10px 10px 1px 10px;
                                    #                border-radius: 10px;",
                                    #         pickerInput(
                                    #             inputId="cladeSpecies",
                                    #             label=HTML("Please set a <b>clade species</b> to select the proper gene families. See more <a href='https://github.com/arzwa/Whale.jl/blob/master/scripts/orthofilter.py' target='_blank'>click here</a>."),
                                    #             options=list(
                                    #                 title='Please select species below'
                                    #             ),
                                    #             choices=species_in_Tree_list(),
                                    #             choicesOpt=list(
                                    #                 content=lapply(species_in_Tree_list(), function(choice) {
                                    #                     choice <- gsub("_", " ", choice)
                                    #                     paste0("<div style='color: steelblue; font-style: italic;'>", choice, "</div>")
                                    #                 })
                                    #             ),
                                    #             multiple=FALSE
                                    #         )
                                    #     )
                                    # ),
                                    column(
                                        4,
                                        div(
                                            style="background-color: #F8F8FF;
                                                   padding: 10px 10px 10px 10px;
                                                   border-radius: 10px;",
                                            selectInput(
                                                inputId="select_whale_model",
                                                label=HTML("<b>Base Model</b> for <b><i>Whale</b></i>:"),
                                                choices=c(
                                                    "Constant-rates model",
                                                    "Relaxed branch-specific DL+WGD model",
                                                    "Critical branch-specific DL+WGD model"
                                                ),
                                                width="100%",
                                                multiple=FALSE,
                                                selected="Constant-rates model"
                                            )
                                        )
                                    ),
                                    column(
                                        4,
                                        div(
                                            style="background-color: #F8F8FF;
                                                   padding: 10px 10px 1px 10px;
                                                   border-radius: 10px;",
                                            sliderInput(
                                                inputId="select_chain_num",
                                                label=HTML("Set the <b><font color='orange'>Chain</font></b> for <b><i>Whale</b></i>:"),
                                                min=100,
                                                max=1000,
                                                step=100,
                                                value=200
                                            )
                                        )
                                    ),
                                    column(
                                        4,
                                        div(
                                            style="background-color: #FAF0E6;
                                                   padding: 10px 10px 1px 10px;
                                                   border-radius: 10px;",
                                            sliderInput(
                                                inputId="input_gf_num",
                                                label=HTML("Choose a subset of gene families to quickly check <b><i>Whale</b></i> (Optional, recommended: 50):"),
                                                min=0,
                                                max=100,
                                                step=10,
                                                value=0
                                            )
                                        )
                                    )
                                )
                            ),
                            # column(
                            #     12,
                            #     fluidRow(
                            #         column(
                            #             12,
                            #             hr(class="setting")
                            #         ),
                            #         column(
                            #             7,
                            #             sliderInput(
                            #                 inputId="input_gf_num",
                            #                 label=HTML("Choose a small portion of gene families to quickly check the running of <b><i>Whale</b></i> (recommended: 50):"),
                            #                 min=0,
                            #                 max=200,
                            #                 step=10,
                            #                 value=0
                            #             )
                            #         )
                            #     )
                            # ),
                            column(
                                12,
                                hr(class="setting")
                            ),
                            column(
                                width=10,
                                div(
                                    class="row",
                                    div(
                                        class="col text-left",
                                        actionButton(
                                            inputId="whale_configure_go",
                                            HTML("Create <b><i>Whale</i></b> Codes"),
                                            icon=icon("play"),
                                            title="Start the configuration process",
                                            status="secondary",
                                            class="my-start-button-class",
                                            style="color: #fff;
                                                   background-color: #019858;
                                                   border-color: #fff;
                                                   padding: 5px 8px 5px 8px;"
                                        )
                                    ),
                                    div(
                                        class="col text-center",
                                        downloadButton(
                                            outputId="whale_prepared_data_download",
                                            label="Download Data to operate Whale",
                                            icon=icon("download"),
                                            title="Click to download the data",
                                            status="secondary",
                                            class="my-download-button-class",
                                            style="color: #fff;
                                                   background-color: #6B8E23;
                                                   border-color: #fff;
                                                   padding: 5px 8px 5px 8px;"
                                        )
                                    ),
                                    div(
                                        class="col text-right",
                                        style="padding: 5px 4px 5px 4px;",
                                        actionLink(
                                            "go_whale_codes",
                                            HTML(
                                                paste0(
                                                    "<font color='#5151A2'>",
                                                    icon("share"),
                                                    " Go to <i><b>Whale</b></i> Instructions</font>"
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

output$wgdNeededTestedID <- renderText({
    text <- input$wgdInput
    text
})

observeEvent(input$whale_configure_go, {
    OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
    whale_dir <- paste0(OrthoFinderWhaleAnalysisDir, "/Whale_wd")
    if( !dir.exists(whale_dir) ){
        dir.create(whale_dir)
    }
    # if( is.null(input$cladeSpecies) || input$cladeSpecies == "" ){
    #     shinyalert(
    #         "Opps",
    #         "Please add the clade species first...",
    #         type="error"
    #     )
    # }
    # else
    if( is.null(input$wgdInput) ){
        shinyalert(
            "Opps",
            "Please add the Hypothetical WGD events to the tree first...",
            type="error"
        )
    }
    else{
        archive_shell_file <- paste0(whale_dir, "/archive_compress_files_for_TreeRecon.shell")
        if( !file.exists(archive_shell_file) ){
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/archive_compress_files_for_TreeRecon.shell"),
                    whale_dir
                )
            )
        }

        wgdNodeFile <- paste0(whale_dir, "/wgdNodes.txt")
        writeLines(input$wgdInput, wgdNodeFile)

        uploaded_tree_file <- paste0(whale_dir, "/species_timetree.nwk")
        if( isTruthy(input$uploadSpeciesTimeTree) ){
            speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
            if( !file.exists(uploaded_tree_file) ){
                system(
                    paste(
                        "cp",
                        speciesTreeFile,
                        uploaded_tree_file
                    )
                )
            }
        }else{
            demo_tree <- "(Asparagus_officinalis:117.61,(Apostasia_shenzhenica:84.55,(Dendrobium_catenatum:52.11,Phalaenopsis_equestris:52.11):32.44):33.06);"
            writeLines(demo_tree, uploaded_tree_file)
            speciesTreeFile <- uploaded_tree_file
        }

        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        contains_underscore <- any(sapply(speciesTree, function(line) grepl("_", line)))

        aleDirPath <- paste0(whale_dir, "/selected_tree_ALE_files")
        scriptPath <- paste0(whale_dir, "/script_bin")
        if( !dir.exists(scriptPath) ){
            dir.create(scriptPath)
        }
        if( !dir.exists(aleDirPath) ){
            withProgress(message='Creating the codes to prepare ALE files...', value=0, {
                if( !file.exists(paste0(scriptPath, "/preparing_Whale_inputs.shell")) ){
                    system(
                        paste(
                            "cp",
                            paste0(getwd()[1], "/tools/preparing_Whale_inputs.shell"),
                            scriptPath
                        )
                    )
                }
                # if( !file.exists(paste0(scriptPath, "/orthofilter.py")) ){
                #     system(
                #         paste(
                #             "cp",
                #             paste0(getwd()[1], "/tools/Whale.jl/scripts/orthofilter.py"),
                #             scriptPath
                #         )
                #     )
                # }
                if( !file.exists(paste0(scriptPath, "/ccddata.py")) ){
                    system(
                        paste(
                            "cp",
                            paste0(getwd()[1], "/tools/Whale.jl/scripts/ccddata.py"),
                            scriptPath
                        )
                    )
                }
                if( !file.exists(paste0(scriptPath, "/ccdfilter.py")) ){
                    system(
                        paste(
                            "cp",
                            paste0(getwd()[1], "/tools/Whale.jl/scripts/ccdfilter.py"),
                            scriptPath
                        )
                    )
                }

                whale_prepare_cmd_file <- paste0(whale_dir, "/run_ale_preparing.sh")
                cmd_con <- file(whale_prepare_cmd_file, open="w")
                writeLines(
                    c(
                        "#!/bin/bash",
                        "",
                        "#SBATCH -p all",
                        "#SBATCH -c 4",
                        "#SBATCH --mem 2G",
                        paste0("#SBATCH -o ", basename(whale_prepare_cmd_file), ".os%j"),
                        paste0("#SBATCH -e ", basename(whale_prepare_cmd_file), ".es%j"),
                        ""
                    ),
                    cmd_con
                )

                # writeLines(paste0("cd ", whale_dir), cmd_con)
                writeLines(
                    "tar xzf ../OrthoFinder_result.tar.gz -C ../",
                    cmd_con
                )
                writeLines("alignmentsDir=$(ls -d ../OrthoFinderOutputDir/Results_*)", cmd_con)
                # focal_species_w <- gsub(" ", "_", input$cladeSpecies)
                writeLines(
                    paste0(
                        "sh ",
                        "./script_bin/preparing_Whale_inputs.shell \\\n",
                        "\t../orthogroups.filtered.tsv \\\n",
                        "\t$alignmentsDir \\\n",
                        # "\t", focal_species_w, " \\\n",
                        "\t4"
                    ),
                    cmd_con
                )
                if( contains_underscore ){
                    aleUpdatedDirPath <- paste0(aleDirPath, ".updated")
                    if( !dir.exists(aleUpdatedDirPath) ){
                        incProgress(amount=.5, message="Change species names...")
                        Sys.sleep(.2)
                        if( !file.exists(paste0(scriptPath, "/rename_species.py")) ){
                            system(
                                paste(
                                    "cp",
                                    paste0(getwd()[1], "/tools/rename_species.py"),
                                    scriptPath
                                )
                            )
                        }
                        writeLines(
                            paste(
                                "python",
                                "./script_bin/rename_species.py",
                                "species_timetree.nwk",
                                "selected_tree_ALE_files",
                                "wgdNodes.txt"
                            ),
                            cmd_con
                        )
                    }
                    speciesTreeFile <- paste0(gsub(".nwk", "", uploaded_tree_file), ".updated.nwk")
                    aleDirPath <- paste0(aleDirPath, ".updated")
                    wgdNodeFile <- paste0(gsub(".txt", "", wgdNodeFile), ".updated.txt")
                }

                # writeLines("cd ..", cmd_con)
                # writeLines("tar czf orthofinderOutputDir.tar.gz orthofinderOutputDir && rm -r orthofinderOutputDir", cmd_con)
                close(cmd_con)
            })
        }

        withProgress(message='preparing in progress', value=0, {
            incProgress(amount=.1, message="Creating Whale command file...")
            Sys.sleep(.1)

            # Preparing Whale command lines
            whaleModel <- ""
            if( input$select_whale_model == "Constant-rates model" ){
                whaleModel <- "Constant_rates"
            }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
                whaleModel <- "Relaxed_branch"
            }else{
                whaleModel <- "Critical_branch"
            }

            running_dir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)
            if( !file.exists(running_dir) ){
                dir.create(running_dir)
            }
            whaleCommandFile <- paste0(running_dir, "/whale.jl")
            whale_cmd_file <- paste0(running_dir, "/run_Whale_", whaleModel, ".sh")
            whale_cmd_con <- file(whale_cmd_file, open="w")

            writeLines(
                c(
                    "#!/bin/bash",
                    "",
                    "#SBATCH -p all",
                    "#SBATCH -c 4",
                    "#SBATCH --mem 8G",
                    paste0("#SBATCH -o ", basename(whale_cmd_file), ".so%j"),
                    paste0("#SBATCH -e ", basename(whale_cmd_file), ".se%j"),
                    ""
                ),
                whale_cmd_con
            )
            # writeLines(
            #     "module load julia",
            #     whale_cmd_con
            # )

            incProgress(amount=.5, message="Write whale command lines into file...")
            Sys.sleep(.4)

            if( !file.exists(paste0(scriptPath, "/prepare_Whale_command.v2.sh")) ){
                system(
                    paste(
                        "cp",
                        paste0(getwd()[1], "/tools/prepare_Whale_command.v2.sh"),
                        scriptPath
                    )
                )
            }

            if( input$input_gf_num != "" && input$input_gf_num > 0 ){
                writeLines(
                    paste(
                        "sh",
                        "../script_bin/prepare_Whale_command.v2.sh",
                        paste0("../", basename(speciesTreeFile)),
                        paste0("../", basename(aleDirPath)),
                        paste0("../", basename(wgdNodeFile)),
                        paste0("whale.", whaleModel, "_", input$select_chain_num, ".jl"),
                        whaleModel,
                        input$select_chain_num,
                        input$input_gf_num
                    ),
                    whale_cmd_con
                )
            }else{
                writeLines(
                    paste(
                        "sh",
                        "../script_bin/prepare_Whale_command.v2.sh",
                        paste0("../", basename(speciesTreeFile)),
                        paste0("../", basename(aleDirPath)),
                        paste0("../", basename(wgdNodeFile)),
                        paste0("whale.", whaleModel, "_", input$select_chain_num, ".jl"),
                        whaleModel,
                        input$select_chain_num
                    ),
                    whale_cmd_con
                )
            }

            writeLines(
                paste(
                    "julia",
                    paste0("whale.", whaleModel, "_", input$select_chain_num, ".jl")
                ),
                whale_cmd_con
            )

            close(whale_cmd_con)
            closeAllConnections()
        })
    }
})

observeEvent(input$go_whale_codes, {
    OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
    whale_dir <- paste0(OrthoFinderWhaleAnalysisDir, "/Whale_wd")
    alePreparingCommadFile <- paste0(whale_dir, "/run_ale_preparing.sh")

    whaleModel <- ""
    if( input$select_whale_model == "Constant-rates model" ){
        whaleModel <- "Constant_rates"
    }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
        whaleModel <- "Relaxed_branch"
    }else{
        whaleModel <- "Critical_branch"
    }

    running_dir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)

    whaleCommandFile <- paste0(running_dir, "/run_Whale_", whaleModel, ".sh")

    if( !file.exists(alePreparingCommadFile) & !file.exists(whaleCommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-Whale-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        output$alePreparingCommandTxt <- renderText({
            command_info <- readChar(
                alePreparingCommadFile,
                file.info(alePreparingCommadFile)$size
            )
        })

        output$whaleCommandTxt <- renderText({
            command_info <- readChar(
                whaleCommandFile,
                file.info(whaleCommandFile)$size
            )
        })

        showModal(
            modalDialog(
                title="",
                size="xl",
                uiOutput("whaleParameterPanel")
            )
        )

        output$whaleParameterPanel <- renderUI({
            fluidRow(
                div(
                    style="padding-bottom: 10px;
                           padding-left: 20px;
                           padding-right: 20px;
                           max-width: 100%;
                           overflow-x: auto;",
                    column(
                        12,
                        h5(HTML(paste0("Instructions to initiate the <font color='green'><b><i>Whale</i></b></font> analysis."))),
                        h6(
                            HTML(
                                paste0(
                                    "After decompressing the download file, please navigate to the folder: ",
                                    "<b><i><font color='#5F9EA0'>Whale_wd</b></i></font> ",
                                    "and execute <b><font color='#CD853F'>run_ale_preparing.sh</b></font> to generate input files for <font color='green'><b><i>whale</i></b></font>.",
                                    "<br><br><b><i>MrBayes</i></b> and <b><i>ALEobserve</i></b> are required for creating <b><i>ale</i></b> files. ",
                                    "Ensure these tools are installed.",
                                    "<br><br>After successfully generating <b><i>ale</i></b> files, proceed to the folder: <b><i><font color='#5F9EA0'>",
                                    basename(running_dir), "</b></i></font> ",
                                    "and run <b><font color='#CD853F'>run_Whale_", whaleModel, ".sh</b></font>.",
                                    "This script will create and execute the <font color='green'><b><i>whale</i></b></font> script.",
                                    "<br><br>Please ensure <b><i>Julia</i></b> is installed."
                                )
                            )
                        ),
                        hr(class="setting"),
                        h5(HTML(paste0("The command line to prepare the inputs for <font color='green'><b><i>whale</i></b></font>:"))),
                        verbatimTextOutput(
                            "alePreparingCommandTxt",
                            placeholder=TRUE
                        ),
                        h5(HTML(paste0("The command line for <font color='green'><b><i>whale</i></b></font>:"))),
                        verbatimTextOutput(
                            "whaleCommandTxt",
                            placeholder=TRUE
                        )
                    )
                )
            )
        })
    }
})

output$whale_prepared_data_download <- downloadHandler(
    filename=function(){
        OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
        paste0(basename(OrthoFinderWhaleAnalysisDir), ".tgz")
    },
    content=function(file){
        OrthoFinderWhaleAnalysisDir <- orthofinder_whale_analysis_dir_Val()
        whale_dir <- paste0(OrthoFinderWhaleAnalysisDir, "/Whale_wd")
        alePreparingCommadFile <- paste0(whale_dir, "/run_ale_preparing.sh")

        whaleModel <- ""
        if( input$select_whale_model == "Constant-rates model" ){
            whaleModel <- "Constant_rates"
        }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
            whaleModel <- "Relaxed_branch"
        }else{
            whaleModel <- "Critical_branch"
        }

        running_dir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)

        whaleCommandFile <- paste0(running_dir, "/run_Whale_", whaleModel, ".sh")

        if( !file.exists(alePreparingCommadFile) & !file.exists(whaleCommandFile) ){
            shinyalert(
                "Oops",
                "Please click the Create-Whale-Codes button first, then switch this on",
                type="error"
            )
        }
        else{
            shinyjs::runjs('$("#progress_modal_whale").modal("show");')
            withProgress(message='Downloading in progress', value=0, {
                incProgress(amount=.1, message="Compressing files...")
                # shinyalert(
                #     "Note",
                #     "Please wait for compressing the files. Do not close the page.",
                #     type="info"
                # )
                run_dir <- getwd()
                setwd(dirname(OrthoFinderWhaleAnalysisDir))
                system(
                    paste(
                        "tar czf",
                        file,
                        basename(OrthoFinderWhaleAnalysisDir)
                    )
                )

                incProgress(amount=.9, message="Downloading file ...")
                incProgress(amount=1)
                Sys.sleep(.1)
                setwd(run_dir)
            })
            shinyjs::runjs('$("#progress_modal_whale").modal("hide");');
        }
    }
)
