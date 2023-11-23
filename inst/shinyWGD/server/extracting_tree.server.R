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
            column(
                12,
                HTML("<br>Each row of this file contains a <font color='orange'>Species <b><i>Latin Name</i></b></font>.</br><br>"),
            ),
            fluidRow(
                column(
                    12,
                    div(
                        style="padding-left: 20px;
                               position: relative;",
                        fileInput(
                            'upload_species_name_list_file',
                            "Upload Species List File:",
                            multiple=FALSE,
                            width="80%",
                            accept=c(
                                ".txt",
                                ".xls"
                            )
                        ),
                        actionButton(
                            inputId="species_name_example",
                            "",
                            icon=icon("question"),
                            title="Click to see the example of species name file",
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
            column(
                12,
                hr(class="setting"),
                actionButton(
                    inputId="extract_tree_go",
                    "Extract Tree",
                    width="100%",
                    icon=icon("tree"),
                    title="Click to start the process",
                    status="secondary",
                    class="my-start-button-class",
                    style="color: #fff;
                          background-color: #27ae60;
                          border-color: #fff;
                          padding: 5px 14px 5px 14px;
                          margin-bottom: 20px;"
                ),
                div(
                    id="extract_progress_container_js"
                )
            )
        )
    )
})

observeEvent(input$species_name_example, {
    species_name_file <- "www/content/species_name_example.xls"
    showModal(
        modalDialog(
            title="The example file",
            size="xl",
            uiOutput("speceisNameExamplePanel")
        )
    )

    output$speceisNameExampleTxt <- renderText({
        command_info <- readChar(
            species_name_file,
            file.info(species_name_file)$size
        )
    })

    output$speceisNameExamplePanel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    h5(
                        HTML(
                            paste0(
                                "Each row of this file contains a <font color='orange'>Species <b><i>Latin Name</i></b></font>"
                            )
                        )
                    ),
                    verbatimTextOutput(
                        "speceisNameExampleTxt",
                        placeholder=TRUE
                    )
                )
            )
        )
    })
})


output$timeTreeOrgPlot <- renderUI({
    div(class="boxLike",
        style="padding-top: 10px;
               padding-right: 50px;
               padding-left: 50px;
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
                           padding: 10px 10px 0px 10px;
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
                4,
                div(
                    style="text-align: center;
                           margin: 10px 10px 10px 10px;
                           border-radius: 10px;
                           padding: 10px 10px 10px 10px;
                           background-color: #FFF5EE;",
                    downloadButton_custom(
                        "download_nwk_tree",
                        title="Download the Tree in Newick",
                        status="secondary",
                        icon=icon("download"),
                        label=".nwk",
                        class="my-download-button-class",
                        style="color: #fff;
                               background-color: #6B8E23;
                               border-color: #fff;
                               padding: 5px 14px 5px 14px;
                               margin: 5px 5px 5px 5px;"
                    ),
                    downloadButton_custom(
                        "download_nexus_tree",
                        title="Download the Tree in Nexus",
                        status="secondary",
                        icon=icon("download"),
                        label=".nexus",
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
                12,
                div(
                    style="margin: 10px 10px 10px 10px;
                           padding: 10px 10px 0px 10px;",
                    id="timetreeOrg_plot"
                )
            )
        ),
        column(
            12,
            uiOutput("species_info_timetreeOrg")
        ),
        h6(
            HTML("<font color='red'><b>Note</b></font> TimeTree database does not include all the species.
                 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the species are not included in the TimeTree database,
                 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;you should ensure the relationship in other ways."
            )
        )
    )
})

observeEvent(input$extract_tree_go, {
    if( !is.null(input$upload_species_name_list_file) ){
        shinyjs::runjs("document.querySelectorAll('svg').forEach(function(svg) { svg.remove() })")
        shinyjs::runjs('$("#timetreeOrg_plot").html("");')
        shinyjs::runjs('$("#species_info_timetreeOrg").html("");')

        progress_data <- list("actionbutton"="extract_tree_go",
                              "container"="extract_progress_container_js")
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )

        species_name_file <- input$upload_species_name_list_file$datapath
        prefix <- paste0(dirname(species_name_file), "/obtained")
        withProgress(message='Extracting in progress', value=0, {
            incProgress(amount=.1, message="Checking the upload file")
            updateProgress(
                container="extract_progress_container_js",
                width=10,
                type="Extracting tree"
            )

            species_data <- readLines(species_name_file)
            species_data <- str_trim(species_data, side="right")
            latin_name_pattern <- "^[A-Z][a-z]+ [a-z]+$"
            invalid_rows <- which(!grepl(latin_name_pattern, species_data))
            if( length(invalid_rows) == 0 ){
                incProgress(amount=.25, message="Contacting with timetree.org ...")
                updateProgress(
                    container="extract_progress_container_js",
                    width=25,
                    type="Extracting tree"
                )
                Sys.sleep(1)

                tryCatch(
                    withCallingHandlers(
                        species_info_df <- TimeTreeFecher(species_name_file, prefix)
                    ),
                    error=function(e) {
                        shinyalert(
                            "Oops!",
                            paste0(e$message, ". Fail to extract tree from Timetree.org. Please try other ways!"),
                            type="error"
                        )
                    }
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
                            }
                            else{
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
                }

                if( nrow(species_info_df) > 0 ){
                    output$species_info_timetreeOrg <- renderUI({
                        div(
                            style="padding-top: 10px;
                                   padding-right: 50px;
                                   padding-left: 50px;
                                   background-color: white;",
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
                                            h4(HTML("<b><font color='#9B3A4D'>Species info</font></b>"))
                                        ),
                                        column(
                                            12,
                                            species_info_df %>%
                                                setNames(., colnames(.) %>% gsub("group_id", "Group id", .)) %>%
                                                setNames(., colnames(.) %>% gsub("species_list", "Included species", .)) %>%
                                                datatable(
                                                    rownames=FALSE
                                                ) %>%
                                                formatStyle(
                                                    "Included species",
                                                    fontStyle="italic"
                                                )
                                        ),
                                        "The species in the same group share the identical time recordes in TimeTree.org"
                                    )
                                )
                            )
                        )
                    })
                }

                updateProgress("extract_progress_container_js", 100, "Extracting tree")
                incProgress(amount=1)
                Sys.sleep(1)
                incProgress(amount=1)
            }
            else{
                shinyalert(
                    "Oops",
                    paste("Invalid Latin names in rows:", invalid_rows, collapse = ", "),
                    type="error"
                )
            }
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
