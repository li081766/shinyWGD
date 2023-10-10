shinyDirChoose(input, "dir", roots=c(computer="/"))
observeEvent(input$dir, {
    output$selectedDir <- renderText({
        if( !is.null(input$dir) ){
            parseDirPath(roots=c(computer="/"), input$dir)
        }
    })
})

output$ksanalysisPanel <- renderUI({
    dirPath <- parseDirPath(roots=c(computer="/"), input$dir)
    ksfiles <- list.files(path=dirPath, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
    species_info_file <- list.files(path=dirPath, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
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
            species_tree_df <- data.frame(Species=character(),
                                          id=integer(),
                                          pId=integer(),
                                          stringsAsFactors=FALSE)
        }
    }
    if( any(grepl("ortholog_distributions", ksfiles)) | any(grepl("paralog_distributions", ksfiles)) ){
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })

        div(class="boxLike",
            style="background-color: #FBFEEC;
                   padding-bottom: 10px;
                   padding-top: 10px;",
            fluidRow(
                div(
                    style="padding-bottom: 5px;
                       padding-top: 5px;
                       padding-left: 10px;",
                    h5(icon("cog"), HTML("Select <font color='#bb5e00'><b><i>K</i><sub>s</sub></b></font> to analyze")),
                    hr(class="setting"),
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="paralogous_ks_button",
                                label=HTML("<font color='#EBD1FC'><b>&nbsp;Paralog <i>K</i><sub>s</sub>&nbsp;&#x25BC;</b></font>"),
                                icon=icon("list"),
                                style="info"
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
                                    prettyCheckboxGroup(
                                        inputId="paralog_ks_files_list",
                                        label="Choose:",
                                        choiceNames=lapply(unlist(species_list), function(choice) {
                                            HTML(paste0("<div style='color: steelblue; font-style: italic;'>", choice, "</div>"))
                                        }),
                                        choiceValues=c(unlist(species_list)),
                                        icon=icon("check"),
                                        shape="round",
                                        status="success",
                                        fill=TRUE,
                                        animation="jelly"
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
                                label=HTML("<font color='#FF9191'><b>&nbsp;Ortholog <i>K</i><sub>s</sub>&nbsp;&#x25BC;</b></font>"),
                                icon=icon("list"),
                                style="info"
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
                                        label=HTML("<b><font color='#38B0E4'>Group A</font></b>"),
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
                                    pickerInput(
                                        inputId="ortholog_ks_files_list_B",
                                        label=HTML("<b><font color='#B97D4B'>Group B</font></b>"),
                                        options=list(
                                            title='Please select species below',
                                            `selected-text-format`="count > 1",
                                            `actions-box`=TRUE
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #B97D4B; font-style: italic;'>", choice, "</div>")
                                            })
                                        ),
                                        multiple=TRUE
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
                                label=HTML("<font color='white'><b>&nbsp;Substitution Rate Correction&nbsp;&#x25BC;</b></font>"),
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
                                        label=HTML("Choose <b><font color='#54B4D3'>Focal</font></b> species:"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
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
                                                paste0("<div style='color: #fc8d59; font-style: italic;'>", choice, "</div>")
                                            })
                                        )
                                    ),
                                    pickerInput(
                                        inputId="select_study_species",
                                        label=HTML("Choose <b><font color='#C699FF'>Other</font></b> species to analyze:"),
                                        options=list(
                                            title='Please select one or multiple species below',
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
                                    hr(class="setting"),
                                    pickerInput(
                                        inputId="select_focal_species",
                                        label=HTML("Choose <b><font color='#54B4D3'>Focal</font></b> species to draw paralog <b><i>K</i><sub>s</sub></b> distribution (optional):"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=unlist(species_list),
                                        choicesOpt=list(
                                            content=lapply(unlist(species_list), function(choice) {
                                                paste0("<div style='color: #54B4D3; font-style: italic;'>", choice, "</div>")
                                            })
                                        )
                                    ),
                                )
                            )
                        )
                    ),
                    column(
                        12,
                        hr(class="setting"),
                        uiOutput("ksanalysissettingPanel")
                    )
                )
            )
        )
    }
})

observeEvent(input$ortholog_ks_files_list_A, {
    if( !is.null(input$dir) ){
        dirPath <- parseDirPath(roots=c(computer="/"), input$dir)
        ksfiles <- list.files(path=dirPath, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=dirPath, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        names_df <- map_informal_name_to_latin_name(species_info_file[1])
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]
        species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
            replace_informal_name_to_latin_name(names_df, x)
        })
        selected_species <- input$ortholog_ks_files_list_A
        remaining_species <- setdiff(unlist(species_list), selected_species)
        updatePickerInput(
            session,
            "ortholog_ks_files_list_B",
            choices=remaining_species,
            choicesOpt=list(
                content=lapply(remaining_species, function(choice) {
                    paste0("<div style='color: #B97D4B; font-style: italic;'>", choice, "</div>")
                })
            )
        )
    }
    updatePrettyCheckboxGroup(
        session,
        "paralog_ks_files_list",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "select_ref_species",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "select_outgroup_species",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "select_study_species",
        selected=character(0)
    )
})

observeEvent(input$paralogous_ks_button, {
    updatePickerInput(
        session,
        "select_ref_species",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "select_outgroup_species",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "select_study_species",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "ortholog_ks_files_list_A",
        selected=character(0)
    )
    updatePickerInput(
        session,
        "ortholog_ks_files_list_B",
        selected=character(0)
    )

    dirPath <- parseDirPath(roots=c(computer="/"), input$dir)
    species_info_file <- list.files(path=dirPath, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)

    newick_tree_file <- paste0(dirname(species_info_file), "/tree.newick")
    newick_tree <- readLines(newick_tree_file)
    session$sendCustomMessage("findOutgroup", newick_tree)

    observeEvent(input$treeOrderList, {
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

        updatePickerInput(
            session,
            "select_ref_species",
            choices=species_tree_df$Species,
            choicesOpt=list(
                content=lapply(species_tree_df$Species, function(choice) {
                    paste0("<div style='color: #54B4D3; font-style: italic;'>", choice, "</div>")
                })
            )
        )
    })
})

observe({
    if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
        if( !is.null(input$dir) ){
            observeEvent(input$treeOrderList, {
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

                bait_id <- species_tree_df[species_tree_df$Species == input$select_ref_species, "id"]
                bait_pId <- species_tree_df[species_tree_df$Species == input$select_ref_species, "pId"]
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
                        choices=filtered_study_df$Species,
                        choicesOpt=list(
                            content=lapply(filtered_study_df$Species, function(choice) {
                                paste0("<div style='color: #998ec3; font-style: italic;'>", choice, "</div>")
                            })
                        )
                    )
                })
            })
        }
        updatePrettyCheckboxGroup(
            session,
            "paralog_ks_files_list",
            selected=character(0)
        )
        updatePickerInput(
            session,
            "ortholog_ks_files_list_A",
            selected=character(0)
        )
        updatePickerInput(
            session,
            "ortholog_ks_files_list_B",
            selected=character(0)
        )
    }
})

output$ksanalysissettingPanel <- renderUI({
    output <- tagList(
        fluidRow(
            column(
                12,
                actionButton(
                    inputId="ks_configure_go",
                    HTML("Configure <b><i>K</i><sub>s</sub></b> Analysis"),
                    icon=icon("cog"),
                    status="secondary",
                    style="color: #fff;
                           background-color: #27ae60;
                           border-color: #fff;
                           padding: 5px 14px 5px 14px;
                           margin: 5px 5px 5px 5px;
                           animation: glowing 5300ms infinite;"
                )
            )
        )
    )
})

observeEvent(input$ks_configure_go, {
    withProgress(message='Configure in progress', value=0, {
        output$ks_analysis_output <- renderUI({
            if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
                panelTitle <- h4(HTML("<b><font color='#9B3A4D'>Ortholog <i>K</i><sub>s</sub></font> Age Distribution</b>"))
            }else if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
                panelTitle <- h4(HTML("<b><font color='#8E549E'>Paralog <i>K</i><sub>s</sub></font> Age Distribution</b>"))
            }else{
                panelTitle <- h4(HTML("<b><font color='#91cf60'>Substitution Rate Correction</font></b>"))
            }
            div(
                class="boxLike",
                style="background-color: #FDFFFF;
                       padding-left: 40px;
                       padding-bottom: 10px;
                       padding-right: 40px;
                       padding-top: 10px;",
                column(
                    12,
                    panelTitle
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        6,
                        uiOutput("plotSizePanel")
                    ),
                    column(
                        6,
                        actionButton(
                            inputId="ks_plot_go",
                            HTML("Start <b><i>K</i><sub>s</sub></b> Analysis"),
                            icon=icon("play"),
                            status="secondary",
                            title="click to start",
                            style="color: #fff;
                                   background-color: #27ae60;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;
                                   animation: glowing 5300ms infinite;"
                        )
                    )
                ),
                fluidRow(
                    column(
                        12,
                        uiOutput("plotOutputPanel")
                    )
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        uiOutput("parameterPanel")
                    )
                ),
                if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
                    fluidRow(
                        hr(class="setting"),
                        column(
                            12,
                            uiOutput("ks_peak_table_output")
                        )
                    )
                }
            )
        })

        Sys.sleep(.2)
        incProgress(amount=.5, message="Configure done ...")
        incProgress(amount=1)
        Sys.sleep(.1)
    })

    output$plotOutputPanel <- renderUI({
        if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
            fluidRow(
                fluidRow(
                    column(
                        width=12,
                        div(
                            id="Wgd_plot_paralog"
                        )
                    )
                )
            )
        }
        else if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
            fluidRow(
                fluidRow(
                    column(
                        width=12,
                        div(
                            id="Wgd_plot_ortholog"
                        )
                    )
                )
            )
        }
        else{
            fluidRow(
                column(
                    12,
                    div(
                        id="Wgd_plot_rate"
                    )
                )
            )
        }
    })

    output$parameterPanel <- renderUI({
        if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
            fluidRow(
                column(
                    4,
                    sliderInput(
                        inputId="ks_maxK_multiple",
                        label=HTML("Set the <b><font color='orange'><i>K</i><sub>s</sub> limit</font></b>:"),
                        min=0,
                        step=1,
                        max=10,
                        value=5
                    )
                ),
                column(
                    4,
                    uiOutput("singleYlimit")
                ),
                column(
                    4,
                    sliderInput(
                        inputId="ks_transparency_multiple",
                        label=HTML("Set the <b><font color='orange'>Transparency</font></b>:"),
                        min=0,
                        max=1,
                        step=0.1,
                        value=0.5
                    )
                )
            )
        }
        else if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
            fluidRow(
                column(
                    4,
                    selectInput(
                        inputId="plot_mode_option_multiple",
                        label=HTML("Select the <b><font color='orange'>Mode</font></b> to plot:"),
                        choices=c("weighted", "average", "min", "pairwise"),
                        multiple=FALSE,
                        selected="weighted"
                    )
                ),
                column(
                    4,
                    sliderInput(
                        inputId="ks_binWidth_multiple",
                        label=HTML("Set the <b><font color='orange'>BinWidth</font></b>:"),
                        min=0,
                        max=0.2,
                        step=0.01,
                        value=0.1
                    )
                ),
                column(
                    4,
                    sliderInput(
                        inputId="ks_maxK_multiple",
                        label=HTML("Set the <b><font color='orange'><i>K</i><sub>s</sub> limit</font></b>:"),
                        min=0,
                        step=1,
                        max=10,
                        value=5
                    )
                )
            )
        }
        else if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
            if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){
                fluidRow(
                    column(
                        4,
                        selectInput(
                            inputId="plot_mode_option_multiple",
                            label=HTML("Select the <b><font color='orange'>Mode</font></b> to plot:"),
                            choices=c("weighted", "average", "min", "pairwise"),
                            multiple=FALSE,
                            selected="weighted"
                        )
                    ),
                    column(
                        4,
                        sliderInput(
                            inputId="ks_binWidth_multiple",
                            label=HTML("Set the <b><font color='orange'>BinWidth</font></b>:"),
                            min=0,
                            max=0.2,
                            step=0.01,
                            value=0.1
                        )
                    ),
                    column(
                        4,
                        sliderInput(
                            inputId="ks_transparency_multiple",
                            label=HTML("Set the <b><font color='orange'>Transparency</font></b>:"),
                            min=0,
                            max=1,
                            step=0.1,
                            value=0.5
                        )
                    ),
                    hr(class="setting"),
                    column(
                        12,
                        fluidRow(
                            column(
                                4,
                                sliderInput(
                                    inputId="ks_maxK_multiple",
                                    label=HTML("Set the <b><font color='orange'><i>K</i><sub>s</sub> limit</font></b>:"),
                                    min=0,
                                    step=1,
                                    max=10,
                                    value=5
                                )
                            ),
                            column(
                                4,
                                uiOutput("y1AxisPanel")
                            ),
                            column(
                                4,
                                uiOutput("y2AxisPanel")
                            )
                        )
                    )
                )
            }else{
                fluidRow(
                    column(
                        12,
                        fluidRow(
                            column(
                                4,
                                sliderInput(
                                    inputId="ks_maxK_multiple",
                                    label=HTML("Set the <b><font color='orange'><i>K</i><sub>s</sub> limit</font></b>:"),
                                    min=0,
                                    step=1,
                                    max=10,
                                    value=5
                                )
                            ),
                            column(
                                4,
                                uiOutput("y1AxisPanel")
                            ),
                            column(
                                4,
                                sliderInput(
                                    inputId="ks_transparency_multiple",
                                    label=HTML("Set the <b><font color='orange'>Transparency</font></b>:"),
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
        }
    })

    output$singleYlimit <- renderUI({
        if( isTruthy(input$ortholog_ks_files_list_A) ){
            fluidRow(
                column(
                    12,
                    sliderInput(
                        inputId="y_limit_single",
                        label=HTML("Set the <b><font color='orange'>Y limit</font></b>:"),
                        min=0,
                        step=0.2,
                        max=5,
                        value=2
                    )
                )
            )
        }
    })

    output$y1AxisPanel <- renderUI({
        if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
            fluidRow(
                column(
                    12,
                    sliderInput(
                        inputId="y_limit_single",
                        label=HTML("Set the <b><font color='orange'>Y limit</font></b>:"),
                        min=0,
                        step=0.2,
                        max=5,
                        value=2
                    )
                )
            )
        }
        if( isTruthy(input$select_ref_species)  & input$select_ref_species != "" ){
            if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){
                fluidRow(
                    column(
                        12,
                        sliderInput(
                            inputId="y_limit_multiple",
                            label=HTML("Set the <b><font color='orange'>Y1 limit</font></b>:"),
                            min=0,
                            step=500,
                            max=8000,
                            value=3000,
                        )
                    )
                )
            }
            else{
                fluidRow(
                    column(
                        12,
                        sliderInput(
                            inputId="y_limit_single",
                            label=HTML("Set the <b><font color='orange'>Y limit</font></b>:"),
                            min=0,
                            step=0.2,
                            max=5,
                            value=2
                        )
                    )
                )
            }
        }
    })

    output$y2AxisPanel <- renderUI({
        if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
            if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){
                fluidRow(
                    column(
                        12,
                        sliderInput(
                            inputId="y2_limit_multiple",
                            label=HTML("Set the <b><font color='orange'>Y2 limit</font></b>:"),
                            min=0,
                            step=0.2,
                            max=5,
                            value=2
                        )
                    )
                )
            }
        }
    })

    output$plotSizePanel <- renderUI({
        fluidRow(
            column(
                12,
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
                    icon("compress", class="rotate-135"),
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
                    icon("compress", class="rotate-45"),
                    title="Compress horizontal spacing"
                ),
                if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
                    downloadButton_custom(
                        "ksPlotOrthologousDownload",
                        title="Download the Plot",
                        status="secondary",
                        icon=icon("download"),
                        label=".svg",
                        style="color: #fff;
                          background-color: #019858;
                          border-color: #fff;
                          padding: 5px 14px 5px 14px;
                          margin: 5px 5px 5px 5px;
                          animation: glowingD 5000ms infinite;"
                    )
                }else if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
                    downloadButton_custom(
                        "ksPlotParalogousDownload",
                        title="Download the Plot",
                        status="secondary",
                        icon=icon("download"),
                        label=".svg",
                        style="color: #fff;
                          background-color: #019858;
                          border-color: #fff;
                          padding: 5px 14px 5px 14px;
                          margin: 5px 5px 5px 5px;
                          animation: glowingD 5000ms infinite;"
                    )
                }else{
                    downloadButton_custom(
                        "ksPlotRateDownload",
                        title="Download the Plot",
                        status="secondary",
                        icon=icon("download"),
                        label=".svg",
                        style="color: #fff;
                               background-color: #019858;
                               border-color: #fff;
                               padding: 5px 14px 5px 14px;
                               margin: 5px 5px 5px 5px;
                               animation: glowingD 5000ms infinite;"
                    )
                }
            )
        )
    })
})

observeEvent(input$ks_plot_go, {
    dirPath <- parseDirPath(roots=c(computer="/"), input$dir)
    species_info_file <- list.files(path=dirPath, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
    if( file.exists(species_info_file[1]) ){
        paralog_species <- input$paralog_ks_files_list
        dirPath <- parseDirPath(roots=c(computer="/"), input$dir)
        ksfiles <- list.files(path=dirPath, pattern="\\.ks.tsv$", full.names=TRUE, recursive=TRUE)
        species_info_file <- list.files(path=dirPath, pattern="Species.info.xls", full.names=TRUE, recursive=TRUE)
        ortholog_ksfiles <- ksfiles[grepl("ortholog_distributions", ksfiles)]
        paralog_ksfiles <- ksfiles[grepl("paralog_distributions", ksfiles)]

        # infer the peaks of paralog ks
        ksPeaksFile <- paste0(dirPath, "/ksrates_wd/ksPeaks.xls")
        if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
            if( !(file.exists(ksPeaksFile)) ){
                names_df <- map_informal_name_to_latin_name(species_info_file[1])

                species_list <- lapply(gsub(".ks.tsv", "", basename(paralog_ksfiles)), function(x) {
                    replace_informal_name_to_latin_name(names_df, x)
                })

                paralog_ksfile_df <- data.frame(
                    species=unlist(species_list),
                    path=paralog_ksfiles)
                # source(file="tools/find_peaks_resample_95_CI.R", local=TRUE, encoding="UTF-8")
                withProgress(message='Inference the Peaks of the paralog Ks in progress', value=0, {
                    combined_i <- "multiple"
                    maxK <- input[[paste0("ks_maxK_", combined_i)]]
                    peaks_df <- data.frame()
                    for( i in 1:nrow(paralog_ksfile_df) ){
                        each_row = paralog_ksfile_df[i, ]

                        incProgress(
                            amount=0.8/nrow(paralog_ksfile_df),
                            message=paste0("Find peaks for ", each_row$species, " ...")
                        )

                        anchors_file <- gsub("ks.tsv", "ks_anchors.tsv", each_row$path)
                        if( file.exists(anchors_file) ){
                            anchors_df <- read.table(
                                anchors_file,
                                header=TRUE,
                                sep="\t"
                            )
                            anchors_ks <- anchors_df[anchors_df$Ks>=0 & anchors_df$Ks<=maxK, ]$Ks
                            anchors_peaks <- PeaksInKsDistributionValues(anchors_ks, peak.maxK=3)
                            bs_CI_list <- c()
                            for( i in 1:length(anchors_peaks) ){
                                bootPeak <- bootStrapPeaks(anchors_ks, peak.index=i, rep=500, peak.maxK=3)
                                bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                                bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                                bs_CI_list <- c(bs_CI_list, bs_CI)
                            }
                            each_peak_df <- data.frame(
                                species=rep(each_row$species, length(anchors_peaks)),
                                peak=anchors_peaks,
                                CI=bs_CI_list
                            )
                            peaks_df <- rbind(peaks_df, each_peak_df)
                        }
                        else{
                            raw_df <- read.table(
                                each_row$path,
                                header=TRUE,
                                sep="\t"
                            )
                            raw_ks <- raw_df[raw_df$Ks>=0 & raw_df$Ks<=maxK, ]$Ks
                            all_peaks <- PeaksInKsDistributionValues(raw_ks, peak.maxK=3)
                            bs_CI_list <- c()
                            for( i in 1:length(all_peaks) ){
                                each_peak <- round(all_equal[i], 2)
                                bootPeak <- bootStrapPeaks(raw_ks, peak.index=i, rep=500, peak.maxK=3)
                                bs_peak_95_interval <- quantile(bootPeak, c(0.025, 0.975))
                                bs_CI <- paste(round(bs_peak_95_interval[1], 2), "-", round(bs_peak_95_interval[2], 2), sep="")
                                bs_CI_list <- c(bs_CI_list, bs_CI)
                            }
                            each_peak_df <- data.frame(
                                species=rep(each_row$species, length(anchors_peaks)),
                                peak=format(all_peaks, nsmall=2),
                                CI=bs_CI_list
                            )
                            peaks_df <- rbind(peaks_df, each_peak_df)
                        }
                    }

                    col_names <- c("Species", "Peak", "95% Confidence Interval")
                    colnames(peaks_df) <- col_names
                    write.table(
                        peaks_df,
                        file=ksPeaksFile,
                        row.names=FALSE,
                        sep="\t",
                        quote=FALSE
                    )
                    Sys.sleep(.2)
                    incProgress(amount=.2, message="Find peaks done")
                })
            }
            else{
                peaksInfo <- read.table(
                    ksPeaksFile,
                    header=TRUE,
                    sep="\t"
                )
                output$ks_peak_table_output <- renderUI({
                    selected_peaks_info <- peaksInfo[peaksInfo$Species %in% input$paralog_ks_files_list, ]
                    output$ks_peak_table_output <- renderUI({
                        fluidRow(
                            column(
                                8,
                                hr(class="splitting"),
                                fluidRow(
                                    column(
                                        6,
                                        h4(HTML("<b><font color='#9B3A4D'>Paralog <i>K</i><sub>s</sub></font></b> Peaks"))
                                    ),
                                    column(
                                        12,
                                        selected_peaks_info %>%
                                            setNames(., colnames(.) %>% gsub("X95\\.\\.Confidence\\.Interval", "95% Confidence Interval", .)) %>%
                                            datatable(
                                                options=list(
                                                    searching=TRUE
                                                ),
                                                rownames=FALSE
                                            ) %>%
                                            formatStyle(
                                                "Species",
                                                fontWeight='bold',
                                                fontStyle="italic"
                                            )
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
                                                style="color: #fff;
                                                      background-color: #019858;
                                                      border-color: #fff;
                                                      padding: 5px 14px 5px 14px;
                                                      margin: 5px 5px 5px 5px;
                                                      animation: glowingD 5000ms infinite;"
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    })
                })

                output$ksPeakCsvDownload <- downloadHandler(
                    filename = function() {
                        "peaksInfo.csv"
                    },
                    content = function(file) {
                        write.csv(peaksInfo, file)
                    }
                )
            }
        }

        withProgress(message='Analyzing in progress', value=0, {
            # source(file="tools/calculateKsDistribution4wgd_multiple.v2.R", local=TRUE, encoding="UTF-8")
            if( isTruthy(input$ortholog_ks_files_list_A) & !(isTruthy(input$paralog_ks_files_list)) ){
                widthSpacing <- reactiveValues(
                    value=600
                )
                heightSpacing <- reactiveValues(
                    value=350
                )
                observeEvent(input$ks_svg_vertical_spacing_add, {
                    heightSpacing$value <- heightSpacing$value + 50
                })
                observeEvent(input$ks_svg_vertical_spacing_sub, {
                    heightSpacing$value <- heightSpacing$value - 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_add, {
                    widthSpacing$value <- widthSpacing$value + 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_sub, {
                    widthSpacing$value <- widthSpacing$value - 50
                })
                combined_i <- "multiple"
                speciesA <- input$ortholog_ks_files_list_A
                speciesB <- input$ortholog_ks_files_list_B

                patternA <- paste(sub(" .*", "", speciesA), collapse="|")
                matched_paths <- ortholog_ksfiles[grepl(patternA, ortholog_ksfiles)]
                patternB <- paste(sub(" .*", "", speciesB), collapse="|")
                files_list <- matched_paths[grepl(patternB, matched_paths)]

                full_data <- calculateKsDistribution4wgd_multiple(
                    files_list,
                    maxK=input[[paste0("ks_maxK_", combined_i)]],
                )
                denData <- full_data$density

                Sys.sleep(.2)
                incProgress(amount=.4, message="Calculating done...")

                observe({
                    selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[[paste0("ks_maxK_", combined_i)]], ]
                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_ortholog",
                        "ks_density_df"=selectedDenData,
                        "xlim"=input[[paste0("ks_maxK_", combined_i)]],
                        "ylim"=input[["y_limit_single"]],
                        "color"="",
                        "opacity"=input[[paste0("ks_transparency_", combined_i)]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                    session$sendCustomMessage("Otholog_Density_Plotting", plot_wgd_data)
                })
                Sys.sleep(.2)
                incProgress(amount=.4, message="Ploting done...")
            }
            else if( !(isTruthy(input$ortholog_ks_files_list_A)) & isTruthy(input$paralog_ks_files_list) ){
                pattern <- paste(sub(" .*", "", paralog_species), collapse="|")
                files_list <- paralog_ksfiles[grepl(pattern, paralog_ksfiles)]

                modify_elements <- function(x) {
                    if (grepl("paralog_distributions", x) & grepl("ks.tsv", x)) {
                        anchors_file <- gsub("ks.tsv", "ks_anchors.tsv", x)
                        if (file.exists(anchors_file)) {
                            x <- c(x, anchors_file)
                        }
                    }
                    return(x)
                }
                combined_i <- "multiple"
                files_list_new <- unlist(lapply(files_list, modify_elements))
                numRows <- ceiling(length(files_list) / 2)
                widthSpacing <- reactiveValues(
                    value=1000
                )
                heightSpacing <- reactiveValues(
                    value=450 * numRows
                )

                observeEvent(input$ks_svg_vertical_spacing_add, {
                    heightSpacing$value <- heightSpacing$value + 50
                })
                observeEvent(input$ks_svg_vertical_spacing_sub, {
                    heightSpacing$value <- heightSpacing$value - 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_add, {
                    widthSpacing$value <- widthSpacing$value + 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_sub, {
                    widthSpacing$value <- widthSpacing$value - 50
                })

                full_data <- calculateKsDistribution4wgd_multiple(
                    files_list_new,
                    plot.mode=input[[paste0("plot_mode_option_", combined_i)]],
                    maxK=input[[paste0("ks_maxK_", combined_i)]],
                    binWidth=input[[paste0("ks_binWidth_", combined_i)]],
                )
                barData <- full_data$bar
                ksDist <- full_data$density

                subset_data <- function(data) {
                    unique_species <- unique(sapply(strsplit(data$title, "\\."), function(x) x[1]))
                    subset <- data[FALSE, ]

                    for (species in unique_species) {
                        ks_anchors_title <- paste0(species, ".ks_anchors")
                        ks_title <- paste0(species, ".ks")

                        if (ks_anchors_title %in% data$title) {
                            subset <- rbind(subset, data[data$title == ks_anchors_title, ])
                        } else {
                            subset <- rbind(subset, data[data$title == ks_title, ])
                        }
                    }
                    return(subset)
                }
                subset <- subset_data(ksDist)

                paralogSpecies <- files_list[grep("paralog_distributions", files_list)]
                paralog_id <- gsub(".ks.tsv$", "", basename(paralogSpecies))

                Sys.sleep(.2)
                incProgress(amount=.2, message="GMM modelling ...")

                # Log-Normal mixturing analyses
                # source("tools/emmix.R", local=T, encoding="UTF-8")
                # source("tools/running_emmix.R", local=T, encoding="UTF-8")
                # source("tools/from_features.R", local=T, encoding="UTF-8")
                # source("tools/ksv.R", local=T, encoding="UTF-8")
                #source("tools/SiZer.kde.R", local=T, encoding="UTF-8")
                ks.mclust <- data.frame()
                ks.sizer <- list()

                grouped_data <- split(subset$ks, subset$title)

                for( j in 1:length(grouped_data) ){
                    ks_title <- names(grouped_data)[j]
                    ks_value <- grouped_data[[j]]
                    bin_width <- unique(subset$binWidth[subset$title == ks_title])

                    Sys.sleep(.2)
                    incProgress(
                        amount=0.5/length(grouped_data),
                        message=paste0("GMM and Sizer modelling for ", ks_title, " ...")
                    )

                    # GMM modelling
                    df <- ks_mclust_v2(ks_value)
                    df$title <- ks_title
                    ks.mclust <- rbind(ks.mclust, df)

                    #Sizer modelling
                    ks_file_tmp <- files_list_new[grep(ks_title, files_list_new)]

                    ksd_tmp <- read.wgd_ksd(ks_file_tmp)

                    ks_value_tmp <- ksd_tmp$ks_dist$Ks[ksd_tmp$ks_dist$Ks <= input[[paste0("ks_maxK_", combined_i)]]]

                    df_sizer <- SiZer(
                        ks_value_tmp,
                        gridsize=c(500, 50),
                        bw=c(0.01, 5)
                    )

                    ks.sizer[[ks_title]] <- list(
                        species=ks_title,
                        sizer=df_sizer$sizer,
                        map=df_sizer$map,
                        bw=df_sizer$bw
                    )
                }
                ks.bic <- unique(ks.mclust[, c("title", "comp", "BIC")])
                write.table(
                    ks.mclust,
                    file=paste0(dirPath, "/ksrates_wd/emmix.output.xls"),
                    row.names=FALSE,
                    sep="\t",
                    quote=FALSE
                )
                ksMclust <- ks.mclust %>%
                    mutate(BIC=-BIC) %>%
                    group_by(title) %>%
                    filter(BIC == min(BIC)) %>%
                    ungroup()

                Sys.sleep(.2)
                incProgress(amount=.5, message="Calculating done...")

                observe({
                    selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[[paste0("ks_maxK_", combined_i)]], ]
                    names_df <- map_informal_name_to_latin_name(species_info_file[1])

                    plot_wgd_data <- list(
                        "plot_id"="Wgd_plot_paralog",
                        "species_list"=names_df,
                        "ks_bar_df"=selectedBarData,
                        "paralog_id"=paralog_id,
                        "mclust_df"=ksMclust,
                        "sizer_list"=ks.sizer,
                        "xlim"=input[[paste0("ks_maxK_", combined_i)]],
                        "ylim"=input[[paste0("y_limit_", combined_i)]],
                        "color"="",
                        "opacity"=input[[paste0("ks_transparency_", combined_i)]],
                        "width"=widthSpacing$value,
                        "height"=heightSpacing$value
                    )
                    session$sendCustomMessage("Paralog_Bar_Plotting", plot_wgd_data)
                })
                Sys.sleep(.2)
                incProgress(amount=.4, message="Ploting done...")
            }
            else if( isTruthy(input$select_ref_species) && input$select_ref_species != "" ){
                widthSpacing <- reactiveValues(
                    value=600
                )
                heightSpacing <- reactiveValues(
                    value=350
                )
                observeEvent(input$ks_svg_vertical_spacing_add, {
                    heightSpacing$value <- heightSpacing$value + 50
                })
                observeEvent(input$ks_svg_vertical_spacing_sub, {
                    heightSpacing$value <- heightSpacing$value - 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_add, {
                    widthSpacing$value <- widthSpacing$value + 50
                })
                observeEvent(input$ks_svg_horizontal_spacing_sub, {
                    widthSpacing$value <- widthSpacing$value - 50
                })

                req(input[["ks_maxK_multiple"]])

                refSpecies <- input$select_ref_species
                outgroupSpecies <- input$select_outgroup_species
                studySpecies <- input$select_study_species

                ks_selected_files <- c()

                patternRef <- paste(sub(" .*", "", refSpecies), collapse="|")
                patternOutgroup <- paste(sub(" .*", "", outgroupSpecies), collapse="|")
                ref2outgroupFile <- ortholog_ksfiles[grepl(patternRef, ortholog_ksfiles) & grepl(patternOutgroup, ortholog_ksfiles)]
                ks_selected_files <- c(ks_selected_files, ref2outgroupFile)

                mode_df <- data.frame()
                for( i in 1:length(studySpecies) ){
                    patternEach <- paste(sub(" .*", "", studySpecies[[i]]), collapse="|")
                    ref2studyFile <- ortholog_ksfiles[grepl(patternRef, ortholog_ksfiles) & grepl(patternEach, ortholog_ksfiles)]
                    study2outgroupFile <- ortholog_ksfiles[grepl(patternEach, ortholog_ksfiles) & grepl(patternOutgroup, ortholog_ksfiles)]
                    ks_selected_files <- c(ks_selected_files, study2outgroupFile)

                    # relative rate test
                    # source("tools/substitution_rate_correction.R", local=T, encoding="UTF-8")
                    study.mode <- relativeRate(
                        ref2outgroupFile,
                        study2outgroupFile,
                        ref2studyFile,
                        KsMax=input[["ks_maxK_multiple"]]
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

                if( isTruthy(input$select_focal_species) & input$select_focal_species != "" ){
                    patternFocal <- paste(sub(" .*", "", input$select_focal_species), collapse="|")
                    focalKsFile <- paralog_ksfiles[grepl(patternFocal, paralog_ksfiles)]
                    paralog_id <- gsub(".ks.tsv$", "", basename(focalKsFile))
                    ks_selected_files <- c(ks_selected_files, focalKsFile)

                    files_list <- ks_selected_files
                    sort_by_filename <- function(x) {
                        filenames <- gsub("^.*/", "", x)
                        order(filenames)
                    }
                    files_list <- files_list[sort_by_filename(files_list)]

                    modify_elements <- function(x) {
                        if (grepl("paralog_distributions", x) & grepl("ks.tsv", x)) {
                            anchors_file <- gsub("ks.tsv", "ks_anchors.tsv", x)
                            if (file.exists(anchors_file)) {
                                x <- c(x, anchors_file)
                            }
                        }
                        return(x)
                    }

                    files_list_new <- unlist(lapply(files_list, modify_elements))
                    combined_i <- "multiple"
                    req(input[[paste0("ks_binWidth_", combined_i)]])
                    req(input[[paste0("plot_mode_option_", combined_i)]])

                    full_data <- calculateKsDistribution4wgd_multiple(
                        files_list_new,
                        plot.mode=input[[paste0("plot_mode_option_", combined_i)]],
                        maxK=input[[paste0("ks_maxK_", combined_i)]],
                        binWidth=input[[paste0("ks_binWidth_", combined_i)]],
                    )
                    barData <- full_data$bar
                    denData <- full_data$density
                    Sys.sleep(.2)
                    incProgress(amount=.4, message="Calculating done...")

                    observe({
                        selectedBarData <- barData[barData$ks >= 0 & barData$ks <= input[[paste0("ks_maxK_", combined_i)]], ]
                        selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[[paste0("ks_maxK_", combined_i)]], ]
                        plot_wgd_data <- list(
                            "plot_id"="Wgd_plot_rate",
                            "ks_density_df"=selectedDenData,
                            "ks_bar_df"=selectedBarData,
                            "rate_correction_df"=mode_df,
                            "paralog_id"=paralog_id,
                            "paralogSpecies"=input$select_focal_species,
                            "xlim"=input[[paste0("ks_maxK_", combined_i)]],
                            "ylim"=input[[paste0("y_limit_", combined_i)]],
                            "y2lim"=input[[paste0("y2_limit_", combined_i)]],
                            "color"="",
                            "opacity"=input[[paste0("ks_transparency_", combined_i)]],
                            "width"=widthSpacing$value,
                            "height"=heightSpacing$value
                        )
                        session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
                    })
                }else{
                    plot_wgd_data <- list(
                        "paralog_id"=""
                    )
                    files_list <- ks_selected_files
                    combined_i <- "multiple"

                    full_data <- calculateKsDistribution4wgd_multiple(
                        files_list
                    )
                    denData <- full_data$density
                    Sys.sleep(.2)
                    incProgress(amount=.4, message="Calculating done...")

                    observe({
                        selectedDenData <- denData[denData$ks >= 0 & denData$ks <= input[[paste0("ks_maxK_", combined_i)]], ]
                        plot_wgd_data <- list(
                            "plot_id"="Wgd_plot_rate",
                            "ks_density_df"=selectedDenData,
                            "rate_correction_df"=mode_df,
                            "xlim"=input[[paste0("ks_maxK_", combined_i)]],
                            "y2lim"=input[["y_limit_single"]],
                            "color"="",
                            "opacity"=input[[paste0("ks_transparency_", combined_i)]],
                            "width"=widthSpacing$value,
                            "height"=heightSpacing$value
                        )
                        session$sendCustomMessage("Bar_Density_Plotting", plot_wgd_data)
                    })
                }
                Sys.sleep(.2)
                incProgress(amount=.4, message="Ploting done...")
            }
            Sys.sleep(.5)
            incProgress(amount=0.1, message="All done...")
            incProgress(amount=1)
            Sys.sleep(.1)
        })
    }
})
