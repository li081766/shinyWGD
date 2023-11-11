output$ObtainTreeFromTimeTreeSettingDisplay <- renderUI({
    div(class="boxLike",
        style="background-color: #F5FFE8;
               padding-left: 20px;
               padding-right: 20px;
               padding-top: 10px;",
        fluidRow(
            column(
                12,
                h4(
                    icon("tree", style="color: #64A600;"),
                    HTML("Extracting Tree from <font color='#64A600'><a href=\"http://www.timetree.org/\">TimeTree.org</a></font>")
                )
            )
        ),
        hr(class="setting"),
        fluidRow(
            column(
                12,
                HTML(
                    "If you don’t ensure the evolutionary relationships among the studied species, click the button below to obtain a tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a>."
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
            column(
                12,
                fileInput(
                    'upload_species_name_list_file',
                    HTML("Upload Species List File:<br>Each row of this file contains a species"),
                    multiple=FALSE,
                    width="100%",
                    accept=c(
                        ".txt",
                        ".xls"
                    )
                )
            ),
            column(
                12,
                hr(class="setting"),
                actionButton(
                    inputId="extract_tree_go",
                    "Extract Tree",
                    width="100%",
                    icon=icon("tree"),
                    status="secondary",
                    style="color: #fff;
                          background-color: #019858;
                          border-color: #fff;
                          padding: 5px 14px 5px 14px;
                          margin-bottom: 20px;
                          animation: glowing 5300ms infinite;"
                ),
                div(
                    id="extract_progress_container_js"
                )
            )
        )
    )
})

observeEvent(input$extract_tree_go, {
    if( !is.null(input$upload_species_name_list_file) ){
        progress_data <- list("actionbutton"="extract_tree_go",
                              "container"="extract_progress_container_js")
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )

        species_name_file <- input$upload_species_name_list_file$datapath
        prefix <- paste0(dirname(species_name_file), "/obtained")
        withProgress(message='Extracting in progress', value=0, {
            incProgress(amount=.15, message="Contacting with timetree.org ...")
            updateProgress(
                container="extract_progress_container_js",
                width=15,
                type="Extracting tree"
            )
            Sys.sleep(1)

            system(
                paste(
                    "Rscript tools/obtain_newick_tree_from_timetree.R ",
                    "-i", species_name_file,
                    "-p", prefix
                )
            )

            incProgress(amount=.7, message="Drawing tree...")
            updateProgress(
                container="extract_progress_container_js",
                width=70,
                type="Extracting tree"
            )
            Sys.sleep(1)

            median_time_newick_tree_file <- paste0(prefix, ".sum_median_time.nwk")
            if( file.exists(median_time_newick_tree_file) ){
                output$TimetreeNewick <- renderText({
                    CommandText <- readChar(median_time_newick_tree_file, file.info(median_time_newick_tree_file)$size)
                })

                output$timeTreeOrgPlot <- renderUI({
                    div(class="boxLike",
                        style="padding-top: 10px;
                               padding-right: 10px;
                               padding-left: 10px;
                               background-color: white;",
                        fluidRow(
                            column(
                                12,
                                h4(HTML("The Tree Extracted from <font color='#64A600'> <a href=\"http://www.timetree.org/\">TimeTree.org</a>")),
                            )
                        ),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                4,
                                div(
                                    style="margin: 10px 10px 0px 10px;
                                           border-radius: 10px;
                                           padding: 10px 10px 10px 10px;
                                           background-color: #FFF5EE;",
                                    prettyRadioButtons(
                                        inputId="timetree_method",
                                        label=HTML("<font color='orange'>Strategy used</font>:"),
                                        choices=c("As timetree.org", "Median time"),
                                        selected="As timetree.org",
                                        icon=icon("check"),
                                        inline=TRUE,
                                        status="info",
                                        animation="jelly"
                                    )
                                ),
                            ),
                            column(
                                3,
                                div(
                                    style="margin: 10px 10px 10px 10px;
                                           border-radius: 10px;
                                           padding: 10px 10px 10px 10px;
                                           background-color: #FFF5EE;",
                                    downloadButton_custom(
                                        "download_nwk_tree",
                                        title="Download the Tree in Newick",
                                        status="secondary",
                                        icon=icon("download"),
                                        label=".nwk",
                                        style="color: #fff;
                                               background-color: #019858;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 5px 5px 5px 5px;
                                               animation: glowingD 5000ms infinite;"
                                    ),
                                    downloadButton_custom(
                                        "download_nexus_tree",
                                        title="Download the Tree in Nexus",
                                        status="secondary",
                                        icon=icon("download"),
                                        label=".nexus",
                                        style="color: #fff;
                                               background-color: #019858;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 5px 5px 5px 5px;
                                               animation: glowingD 5000ms infinite;"
                                    )
                                )
                            ),
                            column(
                                12,
                                div(
                                    style="margin: 10px 10px 10px 10px;
                                           padding: 10px 10px 0px 10px;",
                                    id="timetreeOrg_plot"
                                )
                            )
                        ),
                        h6(
                            HTML("<font color='red'><b>Note</b></font> TimeTree database does not include all the species.
                                 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the species are not included in the TimeTree database,
                                 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;you should ensure the relationship in other ways."
                            )
                        )
                    )
                })

                widthSpacing <- reactiveValues(value=500)
                heightSpacing <- reactiveValues(value=NULL)

                speciesTree <- readLines(textConnection(readChar(median_time_newick_tree_file, file.info(median_time_newick_tree_file)$size)))
                sp_count <- str_count(speciesTree, ":")
                trunc_val <- as.numeric(sp_count) * 20
                heightSpacing$value <- trunc_val[1]

                species_tree_data <- list(
                    "width"=widthSpacing$value
                )

                observe({
                    if( isTruthy(input$timetree_method) ){
                        if( input$timetree_method == "As timetree.org"){
                            tree_nexus_file <- paste0(prefix, ".as_timetree.nexus")
                            tree_nwk_file <- paste0(prefix, ".as_timetree.nwk")
                            speciesTree <- readLines(textConnection(readChar(tree_nexus_file, file.info(tree_nexus_file)$size)))
                            closeAllConnections()

                            output$download_nexus_tree <- downloadHandler(
                                filename=function(){
                                    "obtained.as_timetree.nexus"
                                },
                                content=function(file){
                                    file.copy(tree_nexus_file, file)
                                }
                            )

                            output$download_nwk_tree <- downloadHandler(
                                filename=function(){
                                    "obtained.as_timetree.nwk"
                                },
                                content=function(file){
                                    file.copy(tree_nwk_file, file)
                                }
                            )
                        }else{
                            tree_nexus_file <- paste0(prefix, ".sum_median_time.nexus")
                            tree_nwk_file <- paste0(prefix, ".sum_median_time.nwk")
                            speciesTree <- readLines(textConnection(readChar(tree_nexus_file, file.info(tree_nexus_file)$size)))
                            closeAllConnections()

                            output$download_nexus_tree <- downloadHandler(
                                filename=function(){
                                    "obtained.sum_median_time.nexus"
                                },
                                content=function(file){
                                    file.copy(tree_nexus_file, file)
                                }
                            )

                            output$download_nwk_tree <- downloadHandler(
                                filename=function(){
                                    "obtained.sum_median_time.nwk"
                                },
                                content=function(file){
                                    file.copy(tree_nwk_file, file)
                                }
                            )
                        }

                        species_tree_data[["timeTreeOrgTree"]] <- speciesTree
                        species_tree_data[["height"]] <- heightSpacing$value
                        session$sendCustomMessage("timeTreeOrgPlot", species_tree_data)
                    }
                })
            }else{
                shinyalert(
                    "Oops",
                    "Fail to extract tree from Timetree.org. Please try other ways!",
                    type="error"
                )
            }
            updateProgress("extract_progress_container_js", 100, "Extracting tree")
            incProgress(amount=1)
            Sys.sleep(1)
            incProgress(amount=1)
        })
    }
    else{
        shinyalert(
            "Oops",
            "Please upload species name list first, then switch on this",
            type="error"
        )
    }
})

