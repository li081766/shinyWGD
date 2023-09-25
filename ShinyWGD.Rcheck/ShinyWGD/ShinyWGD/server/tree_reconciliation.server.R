shinyDirChoose(input, "aleDir", roots=c(computer="/"))

speciesTreeRv <- reactiveValues(data=NULL, clear=FALSE)

observeEvent(input$uploadSpeciesTree, {
    speciesTreeRv$clear <- FALSE
}, priority=1000)

widthSpacing <- reactiveValues(value=500)
heightSpacing <- reactiveValues(value=NULL)

observe({
    if( isTruthy(input$uploadSpeciesTree) ){
        speciesTreeFile <- input$uploadSpeciesTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()
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

observe({
    if( isTruthy(input$uploadSpeciesTree) ){
        species_tree_data <- list(
            "width"=widthSpacing$value
        )
        speciesTreeFile <- input$uploadSpeciesTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()

        species_tree_data[["speciesTree"]] <- speciesTree

        species_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("speciesTreePlot", species_tree_data)
    }
})

output$wgdOutput <- renderText({
    text <- input$wgdInput
    text
})

observe({
    aleDirPath <- parseDirPath(roots=c(computer="/"), input$aleDir)
    aleFileCount <- length(list.files(aleDirPath))
    output$numberAleFiles <- renderUI({
        column(
            12,
            if( aleFileCount > 1 ){
                h6(HTML(paste0("<font color='green'><b>", aleFileCount, "</font></b> ALE files will be used." )))
            }else{
                h6(HTML(paste0("<font color='green'><b>", aleFileCount, "</font></b> ALE file will be used." )))
            }
        )
    })
    wgdNum <- toupper(as.english(length(input$wgdInput)))
    if( length(input$wgdInput) > 1 ){
        note <- HTML(paste0("<font color='#F75000'><b>", wgdNum, "</b></font> WGD events will be examinated."))
    }else{
        note <- HTML(paste0("<font color='#F75000'><b>", wgdNum, "</b></font> WGD event will be examinated."))
    }
    # output$wgdCommnadPanel <- renderUI({
    #     fluidRow(
    #         column(
    #             id="wgdSetting",
    #             width=12,
    #             div(class="boxLike",
    #                 style="background-color: #FFFFF9;",
    #                 h4(icon("cog"), "Hypothetical WGDs"),
    #                 hr(class="setting"),
    #                 h5(HTML("<font color='#AD1F1F'>hypothetical WGDs</font> to test:")),
    #                 fluidRow(
    #                     column(
    #                         12,
    #                         verbatimTextOutput(
    #                             "wgdOutput",
    #                             placeholder=TRUE)
    #                     )
    #                 ),
    #                 note
    #             )
    #         )
    #     )
    # })
    output$whaleCommandPanel <- renderUI({
        fluidRow(
            column(
                id="WhaleSetting",
                width=12,
                h4(icon("cog"), HTML("<b><i>Whale</b></i> Setting")),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        selectInput(
                            inputId="select_whale_model",
                            label=HTML("<b>Base Model</b> for <b><i>Whale</b></i>:"),
                            choices=c(
                                "Constant-rates model",
                                "Relaxed branch-specific DL+WGD model",
                                "Critical branch-specific DL+WGD model"),
                            width="100%",
                            multiple=FALSE,
                            selected="Constant-rates model"
                        ),
                        sliderInput(
                            inputId="select_chain_num",
                            label=HTML("Set the <b><font color='orange'>Chain</font></b> for <b><i>Whale</b></i>:"),
                            min=100,
                            max=500,
                            step=50,
                            value=200
                        ),
                        hr(class="setting"),
                        h5(HTML("<font color='#AD1F1F'>Hypothetical WGDs</font> to test:")),
                        fluidRow(
                            column(
                                12,
                                verbatimTextOutput(
                                    "wgdOutput",
                                    placeholder=TRUE
                                )
                            )
                        ),
                        note,
                        hr(class="setting")
                    ),
                    column(
                        12,
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
                                )
                            )
                        ),
                        div(class="float-left",
                            actionButton(
                                inputId="whale_configure_go",
                                HTML("Start <b><i>Whale</b></i>"),
                                icon=icon("play"),
                                status="secondary",
                                style="color: #fff;
                                       background-color: #019858;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;
                                       animation: glowing 5300ms infinite;"
                            )
                        ),
                        div(class="float-right",
                            downloadButton(
                                outputId="whale_data_download",
                                label="Download",
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
    })
})

whale_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Whale_wd"))
if( !file.exists(whale_dir) ){
    dir.create(whale_dir)
}
observeEvent(input$whale_configure_go, {
    wgdNodeFile <- paste0(whale_dir, "/wgdNodes.txt")

    withProgress(message='Run in progress', value=0, {
        incProgress(amount=.1, message="Preparing whale command file...")
        Sys.sleep(.1)

        # Output the wgd Nodes to a file
        writeLines(input$wgdInput, wgdNodeFile)

        if( is.null(input$wgdInput) ){
            shinyalert(
                "Opps",
                "Please add the Hypothetical WGD events to the tree first...",
                type="error"
            )
        }

        aleDirPath <- parseDirPath(roots=c(computer="/"), input$aleDir)

        # Run Whale
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

        whaleCommandFile <- paste0(running_dir, "/run_whale.jl")

        speciesTreeFile <- input$uploadSpeciesTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()

        contains_underscore <- any(sapply(speciesTree, function(line) grepl("_", line)))

        if( contains_underscore ){
            incProgress(amount=.1, message="Change species names...")
            Sys.sleep(.2)
            system(
                paste(
                    "python",
                    "tools/rename_species.py",
                    input$uploadSpeciesTree$datapath,
                    aleDirPath,
                    wgdNodeFile
                )
            )
            new_nwk <- paste0(input$uploadSpeciesTree$datapath, ".updated.nwk")
            new_ale <- paste0(aleDirPath, ".updated")
            new_wgd <- paste0(wgdNodeFile, ".updated.txt")

            incProgress(amount=.3, message="Run whale command...")
            Sys.sleep(.4)

            system(
                paste(
                    "sh",
                    "tools/prepare_Whale_command.v2.sh",
                    new_nwk,
                    new_ale,
                    new_wgd,
                    whaleCommandFile,
                    whaleModel,
                    input$select_chain_num
                )
            )
        }else{
            incProgress(amount=.5, message="Run whale command...")
            Sys.sleep(.4)

            system(
                paste(
                    "sh",
                    "tools/prepare_Whale_command.v2.sh",
                    input$uploadSpeciesTree$datapath,
                    aleDirPath,
                    wgdNodeFile,
                    whaleCommandFile,
                    whaleModel,
                    input$select_chain_num
                )
            )
        }

        julia_path <- Sys.which("julia")

        if( julia_path == "" ){
            shinyalert(
                "Error",
                "This step will use Julia to run the code. Please make sure that you have already installed Julia in the system's PATH variable first...",
                type="error"
            )
        }
        else {
            system(paste(
                "julia",
                whaleCommandFile
            ))
        }

    })
    # output$whaleModelTxt <- renderText({
    #     whaleModelFile <- paste0(running_dir, "/output/model.txt")
    #     whaleBranchModelFile <- paste0(running_dir, "/output/bmodel.txt")
    #     if( file.exists(whaleBranchModelFile) ){
    #         model_info <- readChar(
    #             whaleBranchModelFile,
    #             file.info(whaleBranchModelFile)$size
    #         )
    #     }else{
    #         model_info <- readChar(
    #             whaleModelFile,
    #             file.info(whaleModelFile)$size
    #         )
    #     }
    # })
    # output$mcmcChainSummaryTxt <- renderText({
    #     mcmcChainSummaryFile <- paste0(running_dir, "/output/MCMCchain.s")
    #     if( file.exists(mcmcChainSummaryFile) ){
    #         summary_info <- readChar(
    #             mcmcChainSummaryFile,
    #             file.info(mcmcChainSummaryFile)$size
    #         )
    #     }
    # })
    output$posteriorMeanBayesFactorTxT <- renderText({
        posteriorMeanBayesFactorFile <- paste0(running_dir, "/output/posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt")
        if( file.exists(posteriorMeanBayesFactorFile) ){
            mean_factor_info <- readChar(
                posteriorMeanBayesFactorFile,
                file.info(posteriorMeanBayesFactorFile)$size
            )
        }
        else{
            shinyalert(
                "Error",
                "The output of Whale is uncorrect. Please make sure that you have the proper input setting...",
                type="error"
            )
        }
    })
    panelTitle <- ""
    if( whaleModel == "Constant_rates" ){
        panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>constant-rates model</i></b></font>"))
    }else if( whaleModel == "Relaxed_branch" ){
        panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>relaxed branch-specific DLWGD model</i></b></font>"))
    }else{
        panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>critical branch-specific DLWGD model</i></b></font>"))
    }
    output$whaleConfigurePanel <- renderUI({
        fluidRow(
            column(
                id="whaleConfigure",
                width=12,
                div(class="boxLike",
                    style="background-color: #F2FFE4 ;",
                    panelTitle,
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            h5(HTML("Hypothetical WGDs: the <font color='orange'>posterior mean of duplicate retention rate (q)</font> and the <font color='orange'>Bayes factor (K)</font>")),
                            verbatimTextOutput(
                                "posteriorMeanBayesFactorTxT",
                                placeholder=TRUE
                            ),
                            #h6(HTML("<font color='red'>Note:</font> if K < 1, <i>H</i><sub>1</sub> supported, not worth more than a bare mention; K > 1, <i>H</i><sub>0</sub> supported.<br>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspIf K < 0.1, strong evidence against <i>H</i><sub>0</sub>")),
                            h6(HTML("This is the log10 Bayes factor in favor of the <i>q</i> = 0 model. A Bayes factor <font color='red'><b>smaller than -2</b></font> could be considered as evidence in favor of the <i>q</i> ≠ 0 model compared to the <i>q</i> = 0 mode."))
                        )
                    ),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            h5("Please download the analysis data through the left Download button to see more details about the julia script, the model, and MCMC chains.")
                        )
                    )
                        # column(
                        #     12,
                        #     h5(HTML("The Chains MCMC chain summary info")),
                        #     verbatimTextOutput(
                        #         "mcmcChainSummaryTxt",
                        #         placeholder=TRUE
                        #     ),
                        #     h6(HTML("<font color='red'>Note:</font> if the <code>ESS</code> is less than 100, please increase the chain and restart <font color='#a23400'><b><i>Whale</b></i></font>"))
                        # ),
                        # hr(class="setting"),
                        # column(
                        #     12,
                        #     h5(HTML("The model used in <font color='#a23400'><i><b>whale</b></i></font>:")),
                        #     verbatimTextOutput(
                        #         "whaleModelTxt",
                        #         placeholder=TRUE
                        #     )
                        # )
                #    )
                )
            )
        )
    })
})

observeEvent(input$update_output, {
    whale_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Whale_wd"))
    whaleModel <- ""
    if( input$select_whale_model == "Constant-rates model" ){
        whaleModel <- "Constant_rates"
    }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
        whaleModel <- "Relaxed_branch"
    }else{
        whaleModel <- "Critical_branch"
    }

    running_dir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)
    whaleOutputFile <- paste0(
        running_dir,
        "/output/",
        "posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt"
    )
    if( !file.exists(whaleOutputFile) ){
        shinyalert(
            "Warning!",
            "Please run Whale first. Then switch this button ...",
            type="warning",
        )
    }else{
        species_tree_updated_data <- list(
            "width"=widthSpacing$value
        )
        speciesTreeFile <- input$uploadSpeciesTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()

        species_tree_updated_data[["speciesTree"]] <- speciesTree
        species_tree_updated_data[["height"]] <- heightSpacing$value

        # read whale output and determine which wgd events are retained by whale
        lines <- readLines(whaleOutputFile)
        lines <- lines[-(1:4)]

        dataTmp <- strsplit(lines, "\\s+\\|\\s+|\\s+")
        data_cleaned <- lapply(dataTmp, function(x) x[x != ""])
        data_matrix <- do.call(rbind, data_cleaned)

        whaleOutTmp <- data.frame(data_matrix, stringsAsFactors=FALSE)
        col_names <- c("id", "cut", "wgdId", "q", "K")
        colnames(whaleOutTmp) <- col_names
        whaleOut <- whaleOutTmp[c("wgdId", "q", "K")]
        whaleOut$K <- apply(whaleOut, 1, function(row) gsub("[><]", "", row["K"]))
        species_tree_updated_data[["wgdInfo"]] <- whaleOut
        session$sendCustomMessage("speciesTreeUpdatedPlot", species_tree_updated_data)
    }
})

output$whale_data_download <- downloadHandler(
    filename=function(){
        paste0("Whale_output.", Sys.Date(), ".tgz")
    },
    content=function(file){
        withProgress(message='Downloading in progress', value=0, {
            incProgress(amount=.1, message="Compressing files...")
            shinyalert(
                "Note",
                "Pleae wait for compressing the files. Do not close the window",
                type="info"
            )
            run_dir <- getwd()
            setwd(paste0(paste0(tempdir(), "/Analysis_", Sys.Date())))
            system(
                paste0(
                    "tar czf ", file,
                    " --dereference ",
                    "Whale_wd"
                )
            )
            incProgress(amount=.9, message="Downloading file...")
            incProgress(amount=1)
            Sys.sleep(.1)
            setwd(run_dir)
        })
    }
)

