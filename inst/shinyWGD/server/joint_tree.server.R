observeEvent(input$MCMC_tree_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>Phylogenetic Tree</b></font> file"),
            size="xl",
            uiOutput("MCMC_tree_example_panel")
        )
    )

    output$MCMC_tree_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    h5(HTML("<br></br><font color='green'><b>Phylogenetic Tree</b></font> Example:"))
                ),
                column(
                    12,
                    verbatimTextOutput("UltrametricTreeExample"),
                    HTML(
                        paste0(
                            "The format of the tree is <b>Newick</b>. <br>",
                            "Users can click the text of the species name to change the color or add a symbol to the species in the <b>right Tree panel</b>. <br>",
                            "Users can click the branch to add the WGD events into the branch.<br></br>"
                        )
                    )
                ),
                hr(class="setting"),
                column(
                    12,
                    h5(HTML("<font color='green'><b>Time Tree</b></font> Example:"))
                ),
                column(
                    12,
                    verbatimTextOutput("TimeTreeExample"),
                    HTML(
                        paste0(
                            "The format of the time tree is in <b>Newick</b>, same as the output of <b>TimeTreeFetcher</b> of <b>shinyWGD</b>. <br>",
                            "Be careful with the time unit, please use the <b>100 million years</b> as the time scale.<br>",
                            "Users can click the text of the species name to change the color or add a symbol to the species in the <b>right Tree panel</b>. <br>",
                            "Users can click the branch to add the WGD events into the branch.<br></br>"
                        )
                    )
                ),
                hr(class="setting"),
                column(
                    12,
                    h5(HTML("<font color='green'><b>MCMCTree Tree</b></font> Example:"))
                ),
                column(
                    12,
                    verbatimTextOutput("MCMCTreeExample"),
                    HTML(
                        paste0(
                            "The format of the tree is the output file of <b>MCMCTree</b>, named <b>FigTree.tre</b>. <br>",
                            "Users can also upload a nexus tree with the divergence time information by revising the part after <b>\"=\"</b>. <br>",
                            "Be careful with the time unit, please use the <b>100 million years</b> as the time scale.<br>",
                            "Users can click the text of the species name to change the color or add a symbol to the species in the <b>right Tree panel</b>. <br>",
                            "Users can click the branch to add the WGD events into the branch.<br></br>"
                        )
                    )
                )
            )
        )
    })

    output$MCMCTreeExample <- renderText({
        "#NEXUS
BEGIN TREES;

        UTREE 1 = (((((Oryza_sativa: 0.976947, Ananas_comosus: 0.976947) [&95%HPD={0.926361, 1.05635}]: 0.182469, Elaeis_guineensis: 1.159417) [&95%HPD={1.05857, 1.26857}]: 0.118543, (Asparagus_officinalis: 1.122381, Phalaenopsis_equestris: 1.122381) [&95%HPD={1.00604, 1.20401}]: 0.155580) [&95%HPD={1.16136, 1.39443}]: 0.205808, (Spirodela_polyrhiza: 1.267766, Zostera_marina: 1.267766) [&95%HPD={1.06518, 1.44988}]: 0.216003) [&95%HPD={1.34808, 1.6164}]: 0.061015, Vitis_vinifera: 1.544783) [&95%HPD={1.429, 1.64351}];

END;"
    })

    output$UltrametricTreeExample <- renderText({
        "(((((Oryza_sativa, Ananas_comosus), Elaeis_guineensis), (Asparagus_officinalis, Phalaenopsis_equestris)), (Spirodela_polyrhiza, Zostera_marina)), Vitis_vinifera);"
    })

    output$TimeTreeExample <- renderText({
        "(Asparagus_officinalis:117.61,(Apostasia_shenzhenica:84.55,(Dendrobium_catenatum:52.11,Phalaenopsis_equestris:52.11):32.44):33.06);"
    })
})

observeEvent(input$wgd_time_table_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'>WGD Events Table</b></font> file"),
            size="xl",
            uiOutput("wgd_time_example_panel")
        )
    )

    wgd_time_data_file <- "www/content/wgd_time_table_example.xls"
    output$wgdTimeExampleTable <- renderTable({
        wgd_info_example <- read.table(
            wgd_time_data_file,
            header=FALSE,
            col.names=c("Species", "WGD events", "color"),
            sep="\t",
            quote="",
            comment.char=""
        )
        colnames(wgd_info_example) <- gsub("\\.", " ", colnames(wgd_info_example))

        wgd_info_example
    })

    output$wgd_time_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    tableOutput("wgdTimeExampleTable"),
                    HTML(
                        paste0(
                            "After uploading the file, the corresponding <b>WGD</b> events of each studied species will be placed into the tree.<br>"
                        )
                    )
                )
            )
        )
    })
})

ksTreeRv <- reactiveValues(data=NULL, clear=FALSE)
timeTreeRv <- reactiveValues(data=NULL, clear=FALSE)

observeEvent(input$uploadKsTree, {
    ksTreeRv$clear <- FALSE
}, priority=1000)

observeEvent(input$uploadTimeTree, {
    timeTreeRv$clear <- FALSE
}, priority=1000)

widthSpacing <- reactiveValues(value=500)
heightSpacing <- reactiveValues(value=NULL)

observe({
    if( isTruthy(input$uploadKsTree) || isTruthy(input$uploadTimeTree) ){
        if( isTruthy(input$uploadKsTree) ){
            ksTreeFile <- input$uploadKsTree$datapath
            ksTree <- readLines(textConnection(readChar(ksTreeFile, file.info(ksTreeFile)$size)))
            closeAllConnections()
            sp_count <- str_count(ksTree[1], ":")
        }
        if( isTruthy(input$uploadTimeTree) ){
            timeTreeFile <- input$uploadTimeTree$datapath
            timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
            closeAllConnections()
            if( any(grep("=", timeTreeInfo)) ){
                timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
                sp_count <- str_count(timeTree, ":")
            }else{
                sp_count <- as.numeric(str_count(timeTreeInfo[1], ",")) * 2
            }
        }
        trunc_val <- as.numeric(sp_count) * 20
        heightSpacing$value <- trunc_val
    }
})

observeEvent(input$svg_vertical_spacing_add, {
    heightSpacing$value <- heightSpacing$value + 50
})
observeEvent(input$svg_vertical_spacing_sub, {
    heightSpacing$value <- heightSpacing$value - 50
})
observeEvent(input$svg_horizontal_spacing_add, {
    widthSpacing$value <- widthSpacing$value + 50
})
observeEvent(input$svg_horizontal_spacing_sub, {
    widthSpacing$value <- widthSpacing$value - 50
})

observe({
    if( isTruthy(input$uploadKsTree) || isTruthy(input$uploadTimeTree) ){
        joint_tree_data <- list(
            "width"=widthSpacing$value
        )
        if( isTruthy(input$uploadKsTree) ){
            ksTreeFile <- input$uploadKsTree$datapath
            ksTree <- readLines(textConnection(readChar(ksTreeFile, file.info(ksTreeFile)$size)))
            closeAllConnections()
            joint_tree_data[["ksTree"]] <- ksTree[1]
        }
        if( isTruthy(input$uploadTimeTree) ){
            timeTreeFile <- input$uploadTimeTree$datapath
            timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
            closeAllConnections()
            if( any(grep("=", timeTreeInfo)) ){
                timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
                joint_tree_data[["timeTree"]] <- timeTree

                if( isTruthy(input$uploadTimeTable) ){
                    timeTableFile <- input$uploadTimeTable$datapath
                    timeTable <- suppressMessages(
                        vroom(
                            timeTableFile,
                            col_names=c("species", "wgds", "color"),
                            delim="\t"
                        )
                    )
                    joint_tree_data[["wgdtable"]] <- timeTable
                }
            }else{
                joint_tree_data[["ultrametricTree"]] <- timeTreeInfo[1]
            }
        }
        if( isTruthy(input$uploadKsPeakTable) ){
            ksPeakTableFile <- input$uploadKsPeakTable$datapath
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
            joint_tree_data[["ksPeak"]] <- ksPeak
        }

        joint_tree_data[["height"]] <- heightSpacing$value
        joint_tree_data[["plot_id"]] <- "jointtree_plot"
        joint_tree_data[["download_id"]] <- "jointTreePlotDownload"
        session$sendCustomMessage("jointTreePlot", joint_tree_data)
    }
})
