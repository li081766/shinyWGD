observeEvent(input$ks_tree_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b><i>K</i><sub>s</sub> Unit Tree</b></font> file"),
            size="xl",
            uiOutput("ks_tree_example_panel")
        )
    )

    output$ks_tree_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("KsUnitTreeExample"),
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

    output$KsUnitTreeExample <- renderText({
        "(((((Oryza_sativa: 0.851278, Ananas_comosus: 0.414701): 0.161500, Elaeis_guineensis: 0.305355): 0.072762, (Asparagus_officinalis: 0.555063, Phalaenopsis_equestris: 0.759018): 0.059749): 0.134396, (Spirodela_polyrhiza: 0.960412, Zostera_marina: 0.984538): 0.046686): 0.779397, Vitis_vinifera: 0.042369);"
    })
})

observeEvent(input$ks_peaks_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b><i>K</i><sub>s</sub> peaks table</b></font> file"),
            size="xl",
            uiOutput("ks_peaks_example_panel")
        )
    )

    ks_peak_data_file <- "www/content/ks_peaks_example.xls"
    output$ksPeakExampleTable <- renderTable({
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

    output$ks_peaks_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    tableOutput("ksPeakExampleTable"),
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

observeEvent(input$MCMC_tree_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>MCMCTree Output Tree</b></font> file"),
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
                    verbatimTextOutput("MCMCTreeExample"),
                    HTML(
                        paste0(
                            "Users can upload a nexus tree with the divergence time information. <br>",
                            "The format of the tree is the output file of <b>MCMCTree</b>, named <b>FigTree.tre</b>. <br>",
                            "Be careful with the time unit, please use the <b>100 million years</b> as the time scale.<br>",
                            "Users can click the text of the species name to change the color or add a symbol to the species. <br>",
                            "Users can click the branch to add a WGD into the branch.<br>"
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
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            sp_count <- str_count(timeTree, ":")
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
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            joint_tree_data[["timeTree"]] <- timeTree
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
        joint_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("jointTreePlot", joint_tree_data)
    }
})
