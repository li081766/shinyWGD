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
                            "Be careful with the time scale, please select the proper time scale in the <b>Time Tree Setting</b> panel.<br>",
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
                            "Be careful with the time time scale, please select the proper time scale in the <b>Time Tree Setting</b> panel.<br>",
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

        UTREE 1=(((((Oryza_sativa: 0.976947, Ananas_comosus: 0.976947) [&95%HPD={0.926361, 1.05635}]: 0.182469, Elaeis_guineensis: 1.159417) [&95%HPD={1.05857, 1.26857}]: 0.118543, (Asparagus_officinalis: 1.122381, Phalaenopsis_equestris: 1.122381) [&95%HPD={1.00604, 1.20401}]: 0.155580) [&95%HPD={1.16136, 1.39443}]: 0.205808, (Spirodela_polyrhiza: 1.267766, Zostera_marina: 1.267766) [&95%HPD={1.06518, 1.44988}]: 0.216003) [&95%HPD={1.34808, 1.6164}]: 0.061015, Vitis_vinifera: 1.544783) [&95%HPD={1.429, 1.64351}];

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

preDateWGDsRef <- reactiveValues(value=NULL)
observe({
    if( isTruthy(input$uploadTimeTree) ){
        timeTreeFile <- input$uploadTimeTree$datapath
        timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
        closeAllConnections()
        if( any(grep("\\d", timeTreeInfo)) ){
            output$timeTreeSettingPanel <- renderUI({
                div(class="boxLike",
                    style="background-color: #F5FFFA;",
                    h5(icon("cog"), HTML("Time Tree Setting")),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            div(
                                style="padding-left: 10px;
                                       position: relative;",
                                awesomeRadio(
                                    inputId="vizTree_time_scale",
                                    label=HTML("<b>Time scale</b>:"),
                                    choices=c("100 MYA", "1 MYA"),
                                    selected="100 MYA",
                                    inline=TRUE
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
                                    inputId="uploadTimeTable",
                                    label=HTML("<b>WGDs Time </b> File:"),
                                    width="80%",
                                    accept=c(".csv", ".txt", ".xls")
                                ),
                                actionButton(
                                    inputId="wgd_time_table_example",
                                    "",
                                    icon=icon("question"),
                                    status="secondary",
                                    title="Click to see the example of WGD time file",
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
                    )
                )
            })
        }else{
            output$timeTreeSettingPanel <- renderUI({""})
        }

        if( any(grep("=", timeTreeInfo)) ){
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            timeTree <- sub("^[^=]*=", "", timeTree)
            tree <- read.tree(text=timeTree)
            species_in_tree <- tree$tip.label
        }else{
            tree <- read.tree(timeTreeFile)
            species_in_tree <- tree$tip.label
        }

        if( length(species_in_tree) > 0 ){
            pre_dated_wgds <- suppressMessages(
                vroom(
                    file="www/content/validated_WGD_dates.info.xls",
                    delim="\t",
                    col_names=TRUE
                )
            )
            pre_dated_wgds$Species <- gsub(" ", "_", pre_dated_wgds$Species)
            filtered_pre_dated_wgds <- subset(pre_dated_wgds, Species %in% species_in_tree)
            filtered_pre_dated_wgds <- pre_dated_wgds[grepl(paste(species_in_tree, collapse="|"), pre_dated_wgds$Species), ]

            unique_dbs <- unique(filtered_pre_dated_wgds$Author)
            preDateWGDsRef$value <- length(unique_dbs)
            if( nrow(filtered_pre_dated_wgds) > 0 ){
                dated_wgd_ui_parts <- c()
                for( i in 1:length(unique_dbs) ){
                    tmp_dated_wgds <- filtered_pre_dated_wgds[filtered_pre_dated_wgds$Author == unique_dbs[i], ]
                    tmp_dated_wgds <- tmp_dated_wgds[order(tmp_dated_wgds$Species), ]
                    tmp_author <- unique(tmp_dated_wgds$Author)
                    tmp_DOI <- unique(tmp_dated_wgds$DOI)
                    tmp_dated_wgds_list <- sapply(1:nrow(tmp_dated_wgds), function(x) {
                        paste0(
                            "<i><b><font color='#DAA520'>",
                            gsub("_", " ", tmp_dated_wgds[x, "Species"]),
                            "</i></b></font><br>90% CI: <b><font color='#6B8E23'>",
                            tmp_dated_wgds[x, "90% CI"],
                            "</font></b>",
                            " MYA"
                        )
                    }, simplify="list")

                    dated_wgd_ui_parts[[i]] <- fluidRow(
                        column(
                            12,
                            HTML(
                                paste0(
                                    "Dated WGDs from <a href='", tmp_DOI, "' target='_blank'><b>",
                                    tmp_author, "</b></a>"
                                )
                            )
                        ),
                        column(
                            12,
                            # pickerInput(
                            #     inputId=paste0("dated_wgds_", i),
                            #     label=HTML("<font color='orange'>Choose WGDs</font>:&nbsp;"),
                            #     options=list(
                            #         title='Please select dated WGDs below'
                            #     ),
                            #     choices=tmp_dated_wgds_list,
                            #     choicesOpt=list(
                            #         content=lapply(tmp_dated_wgds_list, function(choice) {
                            #             HTML(choice)
                            #         })
                            #     ),
                            #     selected=NULL,
                            #     multiple=TRUE
                            # ),
                            div(
                                style="padding-top: 10px;
                                       padding-bottom: 10px;",
                                bsButton(
                                    inputId=paste0("dated_wgds_button_", i),
                                    label=HTML("<font color='white'>&nbsp;Dated WGDs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#x25BC;</font>"),
                                    icon=icon("list"),
                                    style="success"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to choose wgds",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse(paste0("dated_wgds_button_collapse_", i)),
                                bs_collapse(
                                    id=paste0("dated_wgds_button_collapse_", i),
                                    content=tags$div(
                                        class="well",
                                        checkboxGroupInput(
                                            inputId=paste0("pre_wgds_select_", i),
                                            label="",
                                            choices=tmp_dated_wgds_list,
                                            selected=FALSE
                                        ),
                                        tags$script(
                                            HTML(paste0("
                                                $(document).ready(function() {
                                                  $('#pre_wgds_select_", i, " .checkbox label span').map(function(){
                                                    this.innerHTML=$(this).text();
                                                  });
                                                });
                                              ")
                                            )
                                        ),
                                        colorPickr(
                                            inputId=paste0("select_pre_wgds_color_", i),
                                            label="Pick a color (swatches + opacity):",
                                            swatches=scales::viridis_pal()(10),
                                            opacity=TRUE
                                        ),
                                    )
                                )
                            )
                        )
                    )
                }

                output$preDatedWGDsSettingPanel <- renderUI({
                    div(class="boxLike",
                        style="background-color: #F5F5F5;",
                        h5(icon("book"), HTML("Dated WGDs from Literatures")),
                        hr(class="setting"),
                        dated_wgd_ui_parts
                    )
                })
            }else{
                output$preDatedWGDsSettingPanel <- renderUI({""})
            }
        }
    }
})

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
            if( any(grep("\\d", timeTreeInfo)) ){
                vizTreeTimeScale <- gsub(" MYA", "", input$vizTree_time_scale)
                if( any(grep("=", timeTreeInfo)) ){
                    timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
                    joint_tree_data[["timeScale"]] <- vizTreeTimeScale
                    joint_tree_data[["timeTree"]] <- timeTree
                }else{
                    joint_tree_data[["timeScale"]] <- vizTreeTimeScale
                    joint_tree_data[["timeTree"]] <- timeTreeInfo[1]
                }
                selected_pre_dated_wgd_df <- data.frame()
                if( preDateWGDsRef$value >0 ){
                    extract_info <- function(element) {
                        split_string <- unlist(strsplit(element, ">"))
                        species <- gsub("<.*", "", split_string[4])
                        if( vizTreeTimeScale == "1" ){
                            wgds_range <- gsub("</.*", "", split_string[10])
                            wgds <- as.numeric(unlist(strsplit(wgds_range, "-"))) / 100
                            wgds <- paste(wgds, collapse="-")
                        }else{
                            wgds <- gsub("</.*", "", split_string[10])
                        }
                        return(data.frame(species=species, wgds=wgds, stringsAsFactors=FALSE))
                    }
                    for( i in 1:preDateWGDsRef$value ){
                        tmp_pre_id <- paste0("pre_wgds_select_", i)
                        tmp_pre_color <- paste0("select_pre_wgds_color_", i)
                        each_wgd_df <- do.call(rbind, lapply(input[[tmp_pre_id]], extract_info))
                        if( !is.null(each_wgd_df) && ncol(each_wgd_df) > 1 ){
                            each_wgd_df$color <- input[[tmp_pre_color]]
                            selected_pre_dated_wgd_df <- rbind(
                                selected_pre_dated_wgd_df,
                                each_wgd_df
                            )
                        }
                    }
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
                    if( ncol(selected_pre_dated_wgd_df) > 1 ){
                        selected_pre_dated_wgd_df <- rbind(
                            selected_pre_dated_wgd_df,
                            timeTable
                        )
                    }else{
                        selected_pre_dated_wgd_df <- timeTable
                    }
                }
                if( ncol(selected_pre_dated_wgd_df) > 1 ){
                    joint_tree_data[["wgdtable"]] <- selected_pre_dated_wgd_df
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
