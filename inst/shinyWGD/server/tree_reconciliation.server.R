observeEvent(input$whale_TreeRecon_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the TreeRecon"),
            size="xl",
            uiOutput("whale_TreeRecon_example_panel")
        )
    )

    output$whale_TreeRecon_example_panel <- renderUI({
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
                            "After successfully operating the code of <font color='green'><i>Whale</i></font> created by <b>shinyWGD</b>, ",
                            "users need to compress the Whale result into a compressed file and the upload this file to the <b>TreeRecon</b> module of <b>shinyWGD</b>. ",
                            "<p></p><p>How to compress the result, please follow the code of <font color='green'><i><b>archive_compress_files_for_TreeRecon.shell</b></i></font> in the <b>Whale_wd</b> folder. ",
                            "<p>User can upload this compressed file, this mudule will analyze the potential WGD events among the studied species",
                            "<p><br></br></p>",
                            "<p>To download the demo data, <a href='https://github.com/li081766/shinyWGD_Demo_Data/blob/main/4sp_Whale_TreeRecon.tar.gz' target='_blank'>click here</a>.</p>",
                            "<p><br></br></p>"
                        )
                    )
                )
            )
        )
    })
})

# example_data_dir <- "/www/bioinformatics01_rw/ShinyWGD/Example_4Sp/"
example_data_dir <- file.path(getwd(), "demo_data")
whale_TreeRecon_example_dir <- file.path(example_data_dir, "Example_Whale_TreeRecon")
whale_check_file <- paste0(whale_TreeRecon_example_dir, "/run_Critical_branch_model_200/output/chaincritical.csv")

if( !dir.exists(whale_TreeRecon_example_dir) & !file.exists(whale_check_file) ){
    withProgress(message='Downloading tree reconciliation demo data...', value=0, {
        if( !dir.exists(example_data_dir) ){
            dir.create(example_data_dir)
        }
        dir.create(whale_TreeRecon_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

        downloadAndExtractData <- function() {
            download.file(
                "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_Example_Whale_TreeRecon.tar.gz",
                destfile=file.path(getwd(), "data.zip"),
                mode="wb"
            )

            system(
                paste(
                    "tar xzf",
                    shQuote(file.path(getwd(), "data.zip")),
                    "-C",
                    shQuote(whale_TreeRecon_example_dir)
                )
            )

            file.remove(file.path(getwd(), "data.zip"))
        }

        downloadAndExtractData()

        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
}else if( dir.exists(whale_TreeRecon_example_dir) & !file.exists(whale_check_file) ){
    withProgress(message='Downloading tree reconciliation demo data...', value=0, {
        system(
            paste("rm -rf ", whale_TreeRecon_example_dir)
        )
        dir.create(whale_TreeRecon_example_dir)

        Sys.sleep(.2)
        incProgress(amount=.3, message="Downloading in progress. Please wait...")

        downloadAndExtractData <- function() {
            download.file(
                "https://github.com/li081766/shinyWGD_Demo_Data/raw/main/4sp_Example_Whale_TreeRecon.tar.gz",
                destfile=file.path(getwd(), "data.zip"),
                mode="wb"
            )

            system(
                paste(
                    "tar xzf",
                    shQuote(file.path(getwd(), "data.zip")),
                    "-C",
                    shQuote(whale_TreeRecon_example_dir)
                )
            )

            file.remove(file.path(getwd(), "data.zip"))
        }

        downloadAndExtractData()

        Sys.sleep(.2)
        incProgress(amount=1, message="Done")
    })
}

buttonTreeReconClicked <- reactiveVal(NULL)
whale_analysis_dir_Val <- reactiveVal(whale_TreeRecon_example_dir)

observeEvent(input$whale_data_zip_file, {
    buttonTreeReconClicked("fileInput")

    base_dir <- tempdir()
    timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
    whaleAnalysisDir <- file.path(base_dir, paste0("Whale_output_", gsub("[ :\\-]", "_", timestamp)))
    dir.create(whaleAnalysisDir)
    system(
        paste(
            "tar xzf",
            input$whale_data_zip_file$datapath,
            "-C",
            whaleAnalysisDir
        )
    )
    whale_analysis_dir_Val(whaleAnalysisDir)
})

observe({
    if( is.null(buttonTreeReconClicked()) ){
        whaleAnalysisDir <- whale_TreeRecon_example_dir
        if( length(whaleAnalysisDir) > 0 ){
            output$selectedTreeReconDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'>TreeRecon Analysis</font></b>"))
                    )
                )
            })
        }
    }
    else if( buttonTreeReconClicked() == "fileInput" ){
        whaleAnalysisDir <- whale_analysis_dir_Val()
        if( length(whaleAnalysisDir) > 0 ){
            dirName <- basename(whaleAnalysisDir)
            output$selectedTreeReconDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(
                            paste(
                                "Selected Directory:<br><b><font color='#EE82EE'>",
                                gsub("Ks_data", "Whale_data_", dirName),
                                "</font></b>"
                            )
                        )
                    )
                )
            })
        }
    }
    else if( buttonTreeReconClicked() == "actionButton" ){
        whaleAnalysisDir <- whale_TreeRecon_example_dir
        if( length(whaleAnalysisDir) > 0 ){
            output$selectedTreeReconDirName <- renderUI({
                column(
                    12,
                    div(
                        style="background-color: #FAF0E6;
                               margin-top: 5px;
                               padding: 10px 10px 1px 10px;
                               border-radius: 10px;
                               text-align: center;",
                        HTML(paste("<b>Example:<br><font color='#EE82EE'>TreeRecon Analysis</font></b>"))
                    )
                )
            })
        }
    }
})

output$selectedSubAnalysisDir <- renderUI({
    whaleAnalysisDir <- whale_analysis_dir_Val()
    all_subdirs <- list.dirs(
        whaleAnalysisDir,
        full.names=TRUE,
        recursive=FALSE
    )
    all_whale_study_list <- basename(all_subdirs[grep("^run_", basename(all_subdirs))])

    fluidRow(
        style="padding-top: 20px;",
        column(
            12,
            pickerInput(
                inputId="select_sub_study",
                label=HTML("Please select a <b>sub-study</b> to check the <b>Whale</b> result."),
                options=list(
                    title='Please select sub-study below'
                ),
                choices=all_whale_study_list,
                choicesOpt=list(
                    content=lapply(all_whale_study_list, function(each) {
                        element <- strsplit(each, "_")[[1]]
                        HTML(
                            paste0(
                                "<b>",
                                element[2], " ", element[3],
                                "</b>. Chain: <b>",
                                element[5],
                                "</b>"
                            )
                        )
                    })
                ),
                #selected=all_whale_study_list[1],
                width="400px"
            )
        )
    )
})

observeEvent(input$whale_TreeRecon_example, {
    buttonTreeReconClicked("actionButton")
    whale_analysis_dir_Val(whale_TreeRecon_example_dir)
})

widthTreeReconSpacing <- reactiveValues(value=500)
heightTreeReconSpacing <- reactiveValues(value=NULL)

observe({
    whaleAnalysisDir <- whale_analysis_dir_Val()
    speciesTreeFile <- paste0(whaleAnalysisDir, "/species_timetree.nwk")
    speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
    closeAllConnections()
    sp_count <- str_count(speciesTree, ":")
    trunc_val <- as.numeric(sp_count) * 20
    heightTreeReconSpacing$value <- trunc_val
})

observeEvent(input$TreeRecon_svg_vertical_spacing_add_species, {
    heightTreeReconSpacing$value <- heightTreeReconSpacing$value + 50
})
observeEvent(input$TreeRecon_svg_vertical_spacing_sub_species, {
    heightTreeReconSpacing$value <- heightTreeReconSpacing$value - 50
})
observeEvent(input$TreeRecon_svg_horizontal_spacing_add_species, {
    widthTreeReconSpacing$value <- widthTreeReconSpacing$value + 50
})
observeEvent(input$TreeRecon_svg_horizontal_spacing_sub_species, {
    widthTreeReconSpacing$value <- widthTreeReconSpacing$value - 50
})

observe({
    whaleAnalysisDir <- whale_analysis_dir_Val()
    species_tree_data <- list(
        "width"=widthTreeReconSpacing$value[1]
    )
    speciesTreeFile <- paste0(whaleAnalysisDir, "/species_timetree.nwk")
    speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))

    wgdNoteFile <- paste0(whaleAnalysisDir, "/wgdNodes.txt")
    wgdNoteFile_content <- readLines(wgdNoteFile)
    wgdNoteFile_content <- wgdNoteFile_content[wgdNoteFile_content != ""]
    wgdNoteInfo <- data.frame(
        wgd=gsub(":", " ", gsub("(wgd[0-9]+): (.+?) - (.+)", "\\1", wgdNoteFile_content)),
        comp=gsub("wgd[0-9]+: (.+?) - (.+)", "\\1:\\2", wgdNoteFile_content)
    )

    closeAllConnections()

    species_tree_data[["speciesTree"]] <- speciesTree[1]
    species_tree_data[["wgdNote"]] <- wgdNoteInfo
    species_tree_data[["height"]] <- heightTreeReconSpacing$value[1]
    species_tree_data[["tree_plot_div"]] <- "speciesWhaleTreeRecon_plot"
    session$sendCustomMessage("speciesTreeUpdatedPlot", species_tree_data)
    output$whaleReconTreeDesPanel <- renderUI({
        fluidRow(
            column(
                10,
                HTML("In the above plot, the WGD with the <b><font color='green'>solid green bars</font></b> are supported with <b>retention rates (q)</b> significantly different from zero, while the <b><font color='#6F6B0A'>hollow WGD bars</font></b> are the ones with retention rates not different from zero."),
            )
        )
    })
})

output$whaleOutputPanel <- renderUI({
    fluidRow(
        column(
            6,
            h5(HTML("<b>Hypothetic WGDs</b>:")),
            verbatimTextOutput(
                "wgdNoteSummaryTxt",
                placeholder=TRUE
            )
        ),
        column(
            6,
            uiOutput("selectedSubAnalysisDir")
        )
    )
})

widthPosteriorSpacing <- reactiveValues(value=900)
heightPosteriorSpacing <- reactiveValues(value=NULL)
observeEvent(input$posterior_svg_vertical_spacing_add_species, {
    heightPosteriorSpacing$value <- heightPosteriorSpacing$value + 50
})
observeEvent(input$posterior_svg_vertical_spacing_sub_species, {
    heightPosteriorSpacing$value <- heightPosteriorSpacing$value - 50
})
observeEvent(input$posterior_svg_horizontal_spacing_add_species, {
    widthPosteriorSpacing$value <- widthPosteriorSpacing$value + 50
})
observeEvent(input$posterior_svg_horizontal_spacing_sub_species, {
    widthPosteriorSpacing$value <- widthPosteriorSpacing$value - 50
})

observe({
    whaleAnalysisDir <- whale_analysis_dir_Val()

    wgdNoteFile <- paste0(whaleAnalysisDir, "/wgdNodes.txt")
    if( file.exists(wgdNoteFile) ){
        wgdNoteFile_content <- readLines(wgdNoteFile)
        wgdNoteFile_content <- wgdNoteFile_content[wgdNoteFile_content != ""]
        heightPosteriorSpacing$value <- ceiling(length(wgdNoteFile_content) / 4) * 300
    }
})

observe({
    if( isTruthy(input$select_sub_study) && input$select_sub_study != "" ){
        whaleAnalysisDir <- whale_analysis_dir_Val()

        subStudyAnalysisDir <- paste0(whaleAnalysisDir, "/", input$select_sub_study)

        whaleModelFile <- paste0(subStudyAnalysisDir, "/output/model.txt")
        whaleBranchModelFile <- paste0(subStudyAnalysisDir, "/output/bmodel.txt")
        whaleOutputFile <- paste0(
            subStudyAnalysisDir,
            "/output/",
            "posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt"
        )

        if( !file.exists(whaleOutputFile) ){
            shinyalert(
                "Opps",
                "No correct result of Whale is detected. Please make sure the operation of Whale without errors...",
                type="error"
            )
        }
        else{
            chain_files <- list.files(
                path=subStudyAnalysisDir,
                pattern="chain.*\\.csv$",
                full.names=TRUE,
                recursive=TRUE
            )

            suppressMessages(
                chain_info_df <- vroom(
                    chain_files[1],
                    delim=",",
                    col_names=TRUE
                )
            )

            posterior_dist_df <- chain_info_df[, grepl("^q", names(chain_info_df))]
            colnames(posterior_dist_df) <- gsub("^q", "wgd", colnames(posterior_dist_df))

            posterior_dist_data <- list(
                "width"=widthPosteriorSpacing$value[1]
            )
            posterior_dist_data[["posterior_dist_df"]] <- posterior_dist_df
            posterior_dist_data[["height"]] <- heightPosteriorSpacing$value[1]
            posterior_dist_data[["posterior_plot_div"]] <- "posterior_Dist_plot_div"
            session$sendCustomMessage("posteriorDistPlot", posterior_dist_data)
        }
    }
})

observe({
    whaleAnalysisDir <- whale_analysis_dir_Val()

    wgdNoteFile <- paste0(whaleAnalysisDir, "/wgdNodes.txt")
    if( file.exists(wgdNoteFile) ){
        wgdNoteFile_content <- readLines(wgdNoteFile)
        wgdNoteFile_content <- wgdNoteFile_content[wgdNoteFile_content != ""]

        output$wgdNoteSummaryTxt <- renderText({
            formatted_text <- paste(wgdNoteFile_content, collapse="\n")
            return(formatted_text)
        })
    }

    if( isTruthy(input$select_sub_study) && input$select_sub_study != "" ){
        subStudyAnalysisDir <- paste0(whaleAnalysisDir, "/", input$select_sub_study)

        whaleModelFile <- paste0(subStudyAnalysisDir, "/output/model.txt")
        whaleBranchModelFile <- paste0(subStudyAnalysisDir, "/output/bmodel.txt")
        whaleOutputFile <- paste0(
            subStudyAnalysisDir,
            "/output/",
            "posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt"
        )

        if( !file.exists(whaleOutputFile) ){
            shinyalert(
                "Opps",
                "No correct result of Whale is detected. Please make sure the operation of Whale without errors...",
                type="error"
            )
        }
        else{
            # update plot
            species_tree_updated_data <- list(
                "width"=widthTreeReconSpacing$value
            )
            speciesTreeFile <- paste0(whaleAnalysisDir, "/species_timetree.nwk")
            speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
            closeAllConnections()

            species_tree_updated_data[["speciesTree"]] <- speciesTree
            species_tree_updated_data[["height"]] <- heightTreeReconSpacing$value

            # read whale output and determine which wgd events are retained by whale
            lines <- readLines(whaleOutputFile, warn=FALSE)
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
            session$sendCustomMessage("speciesTreeUpdatedPlotOLD", species_tree_updated_data)

            whaleModel <- gsub("run_", "", input$select_sub_study)
            whaleModel <- gsub("_model_\\d+", "", whaleModel)
            panelTitle <- ""
            if( whaleModel == "Constant_rates" ){
                panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>constant-rates DL + WGD model</i></b></font>"))
                posteriorPanelTitleTexT <- h5(HTML("The <font color='#FA9B21'><b>posterior distributions</b></font> of the WGD <b>retention rates (q)</b> for the hypothetic WGDs in <font color='#FA9B21'><b><i>constant-rates DL + WGD model</i></b></font>"))
            }else if( whaleModel == "Relaxed_branch" ){
                panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>relaxed branch-specific DL + WGD model</i></b></font>"))
                posteriorPanelTitleTexT <- h5(HTML("The <font color='#FA9B21'><b>posterior distributions</b></font> of the WGD <b>retention rates (q)</b> for the hypothetic WGDs in <font color='#FA9B21'><b><i>relaxed branch-specific DL + WGD model</i></b></font>"))
            }else{
                panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>critical branch-specific DL + WGD model</i></b></font>"))
                posteriorPanelTitleTexT <- h5(HTML("The <font color='#FA9B21'><b>posterior distributions</b></font> of the WGD <b>retention rates (q)</b> for the hypothetic WGDs in <font color='#FA9B21'><b><i>critical branch-specific DL + WGD model</i></b></font>"))
            }

            output$posteriorPanelTitle <- renderUI({
                column(
                    12,
                    posteriorPanelTitleTexT
                )
            })

            output$whaleModelTxt <- renderText({
                whaleModelFile <- paste0(subStudyAnalysisDir, "/output/model.txt")
                whaleBranchModelFile <- paste0(subStudyAnalysisDir, "/output/bmodel.txt")
                if( file.exists(whaleBranchModelFile) ){
                    model_info <- readChar(
                        whaleBranchModelFile,
                        file.info(whaleBranchModelFile)$size
                    )
                }else{
                    model_info <- readChar(
                        whaleModelFile,
                        file.info(whaleModelFile)$size
                    )
                }
            })

            output$mcmcChainSummaryTxt <- renderText({
                mcmcChainSummaryFile <- paste0(subStudyAnalysisDir, "/output/MCMCchain.s")
                if( file.exists(mcmcChainSummaryFile) ){
                    summary_info <- readChar(
                        mcmcChainSummaryFile,
                        file.info(mcmcChainSummaryFile)$size
                    )
                }
            })

            output$posteriorMeanBayesFactorTxT <- renderText({
                posteriorMeanBayesFactorFile <- paste0(subStudyAnalysisDir, "/output/posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt")
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

            output$whaleTextOutputPanel <- renderUI({
                fluidRow(
                    column(
                        id="whaleConfigure",
                        width=12,
                        hr(class="splitting"),
                        panelTitle,
                        hr(class="setting"),
                        fluidRow(
                            column(
                                12,
                                h5(HTML("Hypothetic WGDs: the <font color='orange'>posterior mean of duplicate retention rate (q)</font> and the <font color='orange'>Bayes factor (K)</font>")),
                                verbatimTextOutput(
                                    "posteriorMeanBayesFactorTxT",
                                    placeholder=TRUE
                                ),
                                h6(HTML("This is the log10 Bayes factor in favor of the <i>q</i> = 0 model. A Bayes factor <font color='red'><b>smaller than -2</b></font> could be considered as evidence in favor of the <i>q</i> &#x2260; 0 model compared to the <i>q</i> = 0 mode."))
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                12,
                                h5("Please download the analysis data through the left Download button to see more details about the julia script, the model, and MCMC chains.")
                            )
                        ),
                        column(
                            12,
                            h5(HTML("The Chains MCMC chain summary info")),
                            verbatimTextOutput(
                                "mcmcChainSummaryTxt",
                                placeholder=TRUE
                            ),
                            h6(HTML("<font color='red'>Note:</font> if the <code>ESS</code> is less than 100, please increase the chain and restart <font color='#a23400'><b><i>Whale</b></i></font>"))
                        ),
                        hr(class="setting"),
                        column(
                            12,
                            h5(HTML("The model used in <font color='#a23400'><i><b>whale</b></i></font>:")),
                            verbatimTextOutput(
                                "whaleModelTxt",
                                placeholder=TRUE
                            )
                        )
                    )
                )
            })
        }
    }
})

#'
#' output$wgdOutput <- renderText({
#'     text <- input$wgdInput
#'     text
#' })
#'
#' observe({
#'     aleDirPath <- parseDirPath(roots=c(computer="/"), input$aleDir)
#'     aleFileCount <- length(list.files(aleDirPath))
#'     output$numberAleFiles <- renderUI({
#'         column(
#'             12,
#'             if( aleFileCount > 1 ){
#'                 h6(HTML(paste0("<font color='green'><b>", aleFileCount, "</font></b> ALE files will be used." )))
#'             }else{
#'                 h6(HTML(paste0("<font color='green'><b>", aleFileCount, "</font></b> ALE file will be used." )))
#'             }
#'         )
#'     })
#'     wgdNum <- toupper(as.english(length(input$wgdInput)))
#'     if( length(input$wgdInput) > 1 ){
#'         note <- HTML(paste0("<font color='#F75000'><b>", wgdNum, "</b></font> WGD events will be examinated."))
#'     }else{
#'         note <- HTML(paste0("<font color='#F75000'><b>", wgdNum, "</b></font> WGD event will be examinated."))
#'     }
#'     # output$wgdCommnadPanel <- renderUI({
#'     #     fluidRow(
#'     #         column(
#'     #             id="wgdSetting",
#'     #             width=12,
#'     #             div(class="boxLike",
#'     #                 style="background-color: #FFFFF9;",
#'     #                 h4(icon("cog"), "Hypothetic WGDs"),
#'     #                 hr(class="setting"),
#'     #                 h5(HTML("<font color='#AD1F1F'>Hypothetic WGDs</font> to test:")),
#'     #                 fluidRow(
#'     #                     column(
#'     #                         12,
#'     #                         verbatimTextOutput(
#'     #                             "wgdOutput",
#'     #                             placeholder=TRUE)
#'     #                     )
#'     #                 ),
#'     #                 note
#'     #             )
#'     #         )
#'     #     )
#'     # })
#'     output$whaleCommandPanel <- renderUI({
#'         fluidRow(
#'             column(
#'                 id="WhaleSetting",
#'                 width=12,
#'                 h4(icon("cog"), HTML("<b><i>Whale</b></i> Setting")),
#'                 hr(class="setting"),
#'                 fluidRow(
#'                     column(
#'                         12,
#'                         selectInput(
#'                             inputId="select_whale_model",
#'                             label=HTML("<b>Base Model</b> for <b><i>Whale</b></i>:"),
#'                             choices=c(
#'                                 "Constant-rates model",
#'                                 "Relaxed branch-specific DL+WGD model",
#'                                 "Critical branch-specific DL+WGD model"),
#'                             width="100%",
#'                             multiple=FALSE,
#'                             selected="Constant-rates model"
#'                         ),
#'                         sliderInput(
#'                             inputId="select_chain_num",
#'                             label=HTML("Set the <b><font color='orange'>Chain</font></b> for <b><i>Whale</b></i>:"),
#'                             min=100,
#'                             max=500,
#'                             step=50,
#'                             value=200
#'                         ),
#'                         hr(class="setting"),
#'                         h5(HTML("<font color='#AD1F1F'>Hypothetic WGDs</font> to test:")),
#'                         fluidRow(
#'                             column(
#'                                 12,
#'                                 verbatimTextOutput(
#'                                     "wgdOutput",
#'                                     placeholder=TRUE
#'                                 )
#'                             )
#'                         ),
#'                         note,
#'                         hr(class="setting")
#'                     ),
#'                     column(
#'                         12,
#'                         tags$head(
#'                             tags$style(HTML(
#'                                 "@keyframes glowing {
#'                                          0% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
#'                                          50% { background-color: #73BF00; box-shadow: 0 0 20px #43b0d1; }
#'                                          100% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
#'                                          }
#'                                         @keyframes glowingD {
#'                                          0% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
#'                                          50% { background-color: #8C8C00; box-shadow: 0 0 20px #43b0d1; }
#'                                          100% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
#'                                          }"
#'                                 )
#'                             )
#'                         ),
#'                         div(class="float-left",
#'                             actionButton(
#'                                 inputId="whale_configure_go",
#'                                 HTML("Start <b><i>Whale</b></i>"),
#'                                 icon=icon("play"),
#'                                 status="secondary",
#'                                 style="color: #fff;
#'                                        background-color: #019858;
#'                                        border-color: #fff;
#'                                        padding: 5px 14px 5px 14px;
#'                                        margin: 5px 5px 5px 5px;
#'                                        animation: glowing 5300ms infinite;"
#'                             )
#'                         ),
#'                         div(class="float-right",
#'                             downloadButton(
#'                                 outputId="whale_data_download",
#'                                 label="Download",
#'                                 #width="215px",
#'                                 icon=icon("download"),
#'                                 status="secondary",
#'                                 style="background-color: #5151A2;
#'                                padding: 5px 10px 5px 10px;
#'                                margin: 5px 5px 5px 5px;
#'                                animation: glowingD 5000ms infinite; "
#'                             )
#'                         )
#'                     )
#'                 )
#'             )
#'         )
#'     })
#' })
#'
#' whale_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Whale_wd"))
#' if( !file.exists(whale_dir) ){
#'     dir.create(whale_dir)
#' }
#' observeEvent(input$whale_configure_go, {
#'     wgdNodeFile <- paste0(whale_dir, "/wgdNodes.txt")
#'
#'     withProgress(message='Run in progress', value=0, {
#'         incProgress(amount=.1, message="Preparing whale command file...")
#'         Sys.sleep(.1)
#'
#'         # Output the wgd Nodes to a file
#'         writeLines(input$wgdInput, wgdNodeFile)
#'
#'         if( is.null(input$wgdInput) ){
#'             shinyalert(
#'                 "Opps",
#'                 "Please add the Hypothetic WGD events to the tree first...",
#'                 type="error"
#'             )
#'         }
#'
#'         aleDirPath <- parseDirPath(roots=c(computer="/"), input$aleDir)
#'
#'         # Run Whale
#'         whaleModel <- ""
#'         if( input$select_whale_model == "Constant-rates model" ){
#'             whaleModel <- "Constant_rates"
#'         }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
#'             whaleModel <- "Relaxed_branch"
#'         }else{
#'             whaleModel <- "Critical_branch"
#'         }
#'
#'         subStudyAnalysisDir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)
#'         if( !file.exists(subStudyAnalysisDir) ){
#'             dir.create(subStudyAnalysisDir)
#'         }
#'
#'         whaleCommandFile <- paste0(subStudyAnalysisDir, "/run_whale.jl")
#'
#'         speciesTreeFile <- input$uploadSpeciesTree$datapath
#'         speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
#'         closeAllConnections()
#'
#'         contains_underscore <- any(sapply(speciesTree, function(line) grepl("_", line)))
#'
#'         if( contains_underscore ){
#'             incProgress(amount=.1, message="Change species names...")
#'             Sys.sleep(.2)
#'             system(
#'                 paste(
#'                     "python",
#'                     "tools/rename_species.py",
#'                     input$uploadSpeciesTree$datapath,
#'                     aleDirPath,
#'                     wgdNodeFile
#'                 )
#'             )
#'             new_nwk <- paste0(input$uploadSpeciesTree$datapath, ".updated.nwk")
#'             new_ale <- paste0(aleDirPath, ".updated")
#'             new_wgd <- paste0(wgdNodeFile, ".updated.txt")
#'
#'             incProgress(amount=.3, message="Run whale command...")
#'             Sys.sleep(.4)
#'
#'             system(
#'                 paste(
#'                     "sh",
#'                     "tools/prepare_Whale_command.v2.sh",
#'                     new_nwk,
#'                     new_ale,
#'                     new_wgd,
#'                     whaleCommandFile,
#'                     whaleModel,
#'                     input$select_chain_num
#'                 )
#'             )
#'         }else{
#'             incProgress(amount=.5, message="Run whale command...")
#'             Sys.sleep(.4)
#'
#'             system(
#'                 paste(
#'                     "sh",
#'                     "tools/prepare_Whale_command.v2.sh",
#'                     input$uploadSpeciesTree$datapath,
#'                     aleDirPath,
#'                     wgdNodeFile,
#'                     whaleCommandFile,
#'                     whaleModel,
#'                     input$select_chain_num
#'                 )
#'             )
#'         }
#'
#'         julia_path <- Sys.which("julia")
#'
#'         if( julia_path == "" ){
#'             shinyalert(
#'                 "Error",
#'                 "This step will use Julia to run the code. Please make sure that you have already installed Julia in the system's PATH variable first...",
#'                 type="error"
#'             )
#'         }
#'         else {
#'             system(paste(
#'                 "julia",
#'                 whaleCommandFile
#'             ))
#'         }
#'
#'     })
#'     # output$whaleModelTxt <- renderText({
#'     #     whaleModelFile <- paste0(subStudyAnalysisDir, "/output/model.txt")
#'     #     whaleBranchModelFile <- paste0(subStudyAnalysisDir, "/output/bmodel.txt")
#'     #     if( file.exists(whaleBranchModelFile) ){
#'     #         model_info <- readChar(
#'     #             whaleBranchModelFile,
#'     #             file.info(whaleBranchModelFile)$size
#'     #         )
#'     #     }else{
#'     #         model_info <- readChar(
#'     #             whaleModelFile,
#'     #             file.info(whaleModelFile)$size
#'     #         )
#'     #     }
#'     # })
#'     # output$mcmcChainSummaryTxt <- renderText({
#'     #     mcmcChainSummaryFile <- paste0(subStudyAnalysisDir, "/output/MCMCchain.s")
#'     #     if( file.exists(mcmcChainSummaryFile) ){
#'     #         summary_info <- readChar(
#'     #             mcmcChainSummaryFile,
#'     #             file.info(mcmcChainSummaryFile)$size
#'     #         )
#'     #     }
#'     # })
#'     output$posteriorMeanBayesFactorTxT <- renderText({
#'         posteriorMeanBayesFactorFile <- paste0(subStudyAnalysisDir, "/output/posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt")
#'         if( file.exists(posteriorMeanBayesFactorFile) ){
#'             mean_factor_info <- readChar(
#'                 posteriorMeanBayesFactorFile,
#'                 file.info(posteriorMeanBayesFactorFile)$size
#'             )
#'         }
#'         else{
#'             shinyalert(
#'                 "Error",
#'                 "The output of Whale is uncorrect. Please make sure that you have the proper input setting...",
#'                 type="error"
#'             )
#'         }
#'     })
#'     panelTitle <- ""
#'     if( whaleModel == "Constant_rates" ){
#'         panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>constant-rates model</i></b></font>"))
#'     }else if( whaleModel == "Relaxed_branch" ){
#'         panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>relaxed branch-specific DLWGD model</i></b></font>"))
#'     }else{
#'         panelTitle <- h4(icon("poll"), HTML("Whale Output in <font color='#FA9B21'><b><i>critical branch-specific DLWGD model</i></b></font>"))
#'     }
#'     output$whaleConfigurePanel <- renderUI({
#'         fluidRow(
#'             column(
#'                 id="whaleConfigure",
#'                 width=12,
#'                 div(class="boxLike",
#'                     style="background-color: #F2FFE4 ;",
#'                     panelTitle,
#'                     hr(class="setting"),
#'                     fluidRow(
#'                         column(
#'                             12,
#'                             h5(HTML("Hypothetic WGDs: the <font color='orange'>posterior mean of duplicate retention rate (q)</font> and the <font color='orange'>Bayes factor (K)</font>")),
#'                             verbatimTextOutput(
#'                                 "posteriorMeanBayesFactorTxT",
#'                                 placeholder=TRUE
#'                             ),
#'                             #h6(HTML("<font color='red'>Note:</font> if K < 1, <i>H</i><sub>1</sub> supported, not worth more than a bare mention; K > 1, <i>H</i><sub>0</sub> supported.<br>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspIf K < 0.1, strong evidence against <i>H</i><sub>0</sub>")),
#'                             h6(HTML("This is the log10 Bayes factor in favor of the <i>q</i> = 0 model. A Bayes factor <font color='red'><b>smaller than -2</b></font> could be considered as evidence in favor of the <i>q</i> ≠ 0 model compared to the <i>q</i> = 0 mode."))
#'                         )
#'                     ),
#'                     hr(class="setting"),
#'                     fluidRow(
#'                         column(
#'                             12,
#'                             h5("Please download the analysis data through the left Download button to see more details about the julia script, the model, and MCMC chains.")
#'                         )
#'                     )
#'                         # column(
#'                         #     12,
#'                         #     h5(HTML("The Chains MCMC chain summary info")),
#'                         #     verbatimTextOutput(
#'                         #         "mcmcChainSummaryTxt",
#'                         #         placeholder=TRUE
#'                         #     ),
#'                         #     h6(HTML("<font color='red'>Note:</font> if the <code>ESS</code> is less than 100, please increase the chain and restart <font color='#a23400'><b><i>Whale</b></i></font>"))
#'                         # ),
#'                         # hr(class="setting"),
#'                         # column(
#'                         #     12,
#'                         #     h5(HTML("The model used in <font color='#a23400'><i><b>whale</b></i></font>:")),
#'                         #     verbatimTextOutput(
#'                         #         "whaleModelTxt",
#'                         #         placeholder=TRUE
#'                         #     )
#'                         # )
#'                 #    )
#'                 )
#'             )
#'         )
#'     })
#' })
#'
#' observeEvent(input$update_output, {
#'     whale_dir <- paste0(paste0(tempdir(), "/Analysis_", Sys.Date(), "/Whale_wd"))
#'     whaleModel <- ""
#'     if( input$select_whale_model == "Constant-rates model" ){
#'         whaleModel <- "Constant_rates"
#'     }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
#'         whaleModel <- "Relaxed_branch"
#'     }else{
#'         whaleModel <- "Critical_branch"
#'     }
#'
#'     subStudyAnalysisDir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)
#'     whaleOutputFile <- paste0(
#'         subStudyAnalysisDir,
#'         "/output/",
#'         "posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt"
#'     )
#'     if( !file.exists(whaleOutputFile) ){
#'         shinyalert(
#'             "Warning!",
#'             "Please run Whale first. Then switch this button ...",
#'             type="warning",
#'         )
#'     }else{
#'         species_tree_updated_data <- list(
#'             "width"=widthTreeReconSpacing$value
#'         )
#'         speciesTreeFile <- input$uploadSpeciesTree$datapath
#'         speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
#'         closeAllConnections()
#'
#'         species_tree_updated_data[["speciesTree"]] <- speciesTree
#'         species_tree_updated_data[["height"]] <- heightTreeReconSpacing$value
#'
#'         # read whale output and determine which wgd events are retained by whale
#'         lines <- readLines(whaleOutputFile)
#'         lines <- lines[-(1:4)]
#'
#'         dataTmp <- strsplit(lines, "\\s+\\|\\s+|\\s+")
#'         data_cleaned <- lapply(dataTmp, function(x) x[x != ""])
#'         data_matrix <- do.call(rbind, data_cleaned)
#'
#'         whaleOutTmp <- data.frame(data_matrix, stringsAsFactors=FALSE)
#'         col_names <- c("id", "cut", "wgdId", "q", "K")
#'         colnames(whaleOutTmp) <- col_names
#'         whaleOut <- whaleOutTmp[c("wgdId", "q", "K")]
#'         whaleOut$K <- apply(whaleOut, 1, function(row) gsub("[><]", "", row["K"]))
#'         species_tree_updated_data[["wgdInfo"]] <- whaleOut
#'         session$sendCustomMessage("speciesTreeUpdatedPlot", species_tree_updated_data)
#'     }
#' })
#'
#' output$whale_data_download <- downloadHandler(
#'     filename=function(){
#'         paste0("Whale_output.", Sys.Date(), ".tgz")
#'     },
#'     content=function(file){
#'         withProgress(message='Downloading in progress', value=0, {
#'             incProgress(amount=.1, message="Compressing files...")
#'             shinyalert(
#'                 "Note",
#'                 "Pleae wait for compressing the files. Do not close the window",
#'                 type="info"
#'             )
#'             run_dir <- getwd()
#'             setwd(paste0(paste0(tempdir(), "/Analysis_", Sys.Date())))
#'             system(
#'                 paste0(
#'                     "tar czf ", file,
#'                     " --dereference ",
#'                     "Whale_wd"
#'                 )
#'             )
#'             incProgress(amount=.9, message="Downloading file...")
#'             incProgress(amount=1)
#'             Sys.sleep(.1)
#'             setwd(run_dir)
#'         })
#'     }
#' )

