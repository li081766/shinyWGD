shinyDirChoose(input, "iadhoredir", roots=c(computer="/"))
observeEvent(input$iadhoredir, {
    output$selectediadhoreDir <- renderText({
        if( !is.null(input$iadhoredir) ){
            parseDirPath(roots=c(computer="/"), input$iadhoredir)
        }
    })
    dirPath <- parseDirPath(roots=c(computer="/"), input$iadhoredir)
    iadhorefiles <- list.files(path=dirPath, pattern="multiplicons.txt", full.names=TRUE, recursive=TRUE)
    multipleSpeciesIadhoreFile <- iadhorefiles[grepl("Multiple_Species", iadhorefiles)]
    iadhorefiles <- iadhorefiles[!(grepl("paralog_distributions", iadhorefiles))]
    iadhorefiles <- iadhorefiles[!(grepl("Multiple_Species", iadhorefiles))]
    if( length(dirPath) > 0 ){
        if( length(iadhorefiles) == 0 ){
            shinyalert(
                "Oops!",
                "No i-ADHoRe output file found. Please provide the correct path...",
                type="error",
            )
        }
    }
    output$iadhoreanalysisPanel <- renderUI({
        fluidRow(
            div(
                style="padding-right: 10px;
                       padding-left: 10px;",
                #h5(icon("list"), HTML("Select <font color='#bb5e00'><b>i-ADHoRe</b></font> output to analyze")),
                h5(icon("cog"), HTML("<font color='#bb5e00'><b>Synteny Analysis<b></font>")),
                column(
                    12,
                    uiOutput("iadhoresettingPanel")
                ),
                hr(class="setting"),
                #HTML("<br>"),
                h5(icon("cog"), HTML("<font color='#bb5e00'><b>Clustering Analysis<b></font>")),
                column(
                    12,
                    uiOutput("clusteringSettingPanel")
                ),
                hr(class="setting"),
                #HTML("<br>"),
                column(
                    12,
                    actionButton(
                        inputId="iadhore_config_go",
                        "Configure Analysis",
                        width="200px",
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

    split_paths <- strsplit(iadhorefiles, split="/")
    comparing_list <- lapply(split_paths, function(x){
        x[length(x)-1]
    })
    comparing_list <- gsub("i-adhore.", "", comparing_list)
    intra_list <- list()
    inter_list <- list()
    lapply(seq_along(comparing_list), function(i){
        sp_list_tmp <- unique(strsplit(comparing_list[i], split="_vs_")[[1]])
        if( length(sp_list_tmp) == 1 ){
            intra_list <<- append(intra_list, sp_list_tmp[1])
        }else{
            inter_list <<- append(inter_list, comparing_list[i])
        }
    })

    inter_list <- unlist(inter_list)
    intra_list <- unlist(intra_list)

    path_df <- data.frame(
        comparing_ID=character(),
        comparing_Type=character(),
        comparing_Path=character()
    )
    for( i in intra_list ){
        tmp_path_i <- iadhorefiles[grepl(paste0(i, "_vs_", i), iadhorefiles)]
        path_df <- rbind(
            path_df,
            data.frame(
                comparing_ID=i,
                comparing_Type="Intra",
                comparing_Path=tmp_path_i
            )
        )
    }
    for( i in inter_list ){
        tmp_path_i <- iadhorefiles[grepl(i, iadhorefiles)]
        path_df <- rbind(
            path_df,
            data.frame(
                comparing_ID=i,
                comparing_Type="Inter",
                comparing_Path=tmp_path_i
            )
        )
    }
    # Add multiple species to the path_df
    if( length(multipleSpeciesIadhoreFile) > 0 ){
        path_df <- rbind(
            path_df,
            data.frame(
                comparing_ID="Multiple",
                comparing_Type="Multiple",
                comparing_Path=multipleSpeciesIadhoreFile[1]
            )
        )
    }
    if( is.not.null(intra_list) && is.not.null(inter_list) ){
        output$iadhoresettingPanel <- renderUI({
            output <- tagList(
                fluidRow(
                    style="padding-right: 10px;
                           padding-left: 10px;",
                    column(
                        width=12,
                        div(
                            style="padding-bottom: 10px;",
                            bsButton(
                                inputId="iadhore_intra_species_list_button",
                                label=HTML("<font color='#DCFEE3'><b>&nbsp;Intra-comparing: &nbsp;&#x25BC;</b></font>"),
                                icon=icon("list"),
                                style="info"
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to choose species",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                ) %>%
                                bs_attach_collapse("iadhore_intra_species_list_collapse"),
                            bs_collapse(
                                id="iadhore_intra_species_list_collapse",
                                content=tags$div(
                                    class="well",
                                    # prettyCheckboxGroup(
                                    #     inputId="iadhore_intra_species_list",
                                    #     label="Choose:",
                                    #     choiceValues=intra_list,
                                    #     choiceNames=lapply(intra_list, function(choice) {
                                    #         HTML(paste0("<div style='color: #55CC6D; font-style: italic;'>", gsub("_", " ", choice), "</div>"))
                                    #     }),
                                    #     icon=icon("check"),
                                    #     shape="round",
                                    #     status="success",
                                    #     fill=TRUE,
                                    #     animation="jelly"
                                    # ),
                                    pickerInput(
                                        inputId="iadhore_intra_species_list",
                                        label=HTML("<b><font color='#38B0E4'>Species:</font></b>"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=intra_list,
                                        choicesOpt=list(
                                            content=lapply(intra_list, function(choice) {
                                                species <- gsub("_", " ", choice)
                                                HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                            })
                                        ),
                                        multiple=FALSE
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
                                inputId="iadhore_inter_species_list_button",
                                label=HTML("<font color='#FFD374'><b>&nbsp;Inter-comparing:&nbsp;&#x25BC;</b></font>"),
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
                                        inputId="inter_list_A",
                                        label=HTML("<b><font color='#38B0E4'>Species A</font></b>"),
                                        options=list(
                                            title='Please select species below'
                                        ),
                                        choices=intra_list,
                                        choicesOpt=list(
                                            content=lapply(intra_list, function(choice) {
                                                species <- gsub("_", " ", choice)
                                                HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                            })
                                        ),
                                        multiple=FALSE
                                    ),
                                    pickerInput(
                                        inputId="inter_list_B",
                                        label=HTML("<b><font color='#B97D4B'>Species B</font></b>"),
                                        options=list(
                                            title='Please select species below',
                                            `selected-text-format`="count > 1",
                                            `actions-box`=TRUE
                                        ),
                                        choices=intra_list,
                                        choicesOpt=list(
                                            content=lapply(intra_list, function(choice) {
                                                species <- gsub("_", " ", choice)
                                                HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                                            })
                                        ),
                                        multiple=FALSE
                                    )
                                )
                            )
                        )
                    ),
                    if( length(multipleSpeciesIadhoreFile) > 0 ){
                        column(
                            width=12,
                            div(
                                style="padding-bottom: 10px;",
                                bsButton(
                                    inputId="iadhore_multiple_species_list_button",
                                    label=HTML("<font color='white'><b>&nbsp;Multiple Species comparing: &nbsp;&#x25BC;</b></font>"),
                                    icon=icon("list"),
                                    style="warning",
                                    size="small"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to choose species",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse("iadhore_multiple_species_list_collapse"),
                                bs_collapse(
                                    id="iadhore_multiple_species_list_collapse",
                                    content=tags$div(
                                        class="well",
                                        style="background-color: #F5FFE8;",
                                        prettyCheckboxGroup(
                                            inputId="iadhore_multiple_species_list",
                                            label=HTML("Choose <b><i><font color='#E46A1B'>at least Three</font></b></i> Species:"),
                                            choiceValues=intra_list,
                                            choiceNames=lapply(intra_list, function(choice) {
                                                HTML(paste0("<div style='color: #727EFA; font-style: italic;'>", gsub("_", " ", choice), "</div>"))
                                            }),
                                            icon=icon("check"),
                                            shape="round",
                                            status="success",
                                            fill=TRUE,
                                            animation="jelly"
                                        )
                                    )
                                )
                            )
                        )
                    }
                )
            )
        })
        output$clusteringSettingPanel <- renderUI({
            fluidRow(
                style="padding-right: 10px; padding-left: 10px",
                column(
                    width=12,
                    div(
                        style="padding-bottom: 10px;",
                        bsButton(
                            inputId="clustering_button",
                            label=HTML("<font color='#93F35F'><b>&nbsp;Setting:&nbsp;&#x25BC;</b></font>"),
                            icon=icon("list"),
                            style="info"
                        ) %>%
                            bs_embed_tooltip(
                                title="Click to choose species",
                                placement="right",
                                trigger="hover",
                                options=list(container="body")
                            ) %>%
                            bs_attach_collapse("clustering_files_collapse"),
                        bs_collapse(
                            id="clustering_files_collapse",
                            content=tags$div(
                                class="well",
                                pickerInput(
                                    inputId="cluster_species_A",
                                    label=HTML("<b><font color='#38B0E4'>Species A</font></b>"),
                                    options=list(
                                        title='Please select species below'
                                    ),
                                    choices=intra_list,
                                    choicesOpt=list(
                                        content=lapply(intra_list, function(choice) {
                                            species <- gsub("_", " ", choice)
                                            HTML(paste0("<div style='color: #38B0E4; font-style: italic;'>", species, "</div>"))
                                        })
                                    ),
                                    multiple=FALSE
                                ),
                                pickerInput(
                                    inputId="cluster_species_B",
                                    label=HTML("<b><font color='#B97D4B'>Species B</font></b>"),
                                    options=list(
                                        title='Please select species below',
                                        `selected-text-format`="count > 1",
                                        `actions-box`=TRUE
                                    ),
                                    choices=intra_list,
                                    choicesOpt=list(
                                        content=lapply(intra_list, function(choice) {
                                            species <- gsub("_", " ", choice)
                                            HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                                        })
                                    ),
                                    multiple=FALSE
                                )
                            )
                        )
                    )
                )
            )
        })
    }
    if( nrow(path_df) > 0 ){
        save(path_df, file=paste0(dirPath, "/tmp.comparing.RData"))
    }
    observe({
        if( isTruthy(input$inter_list_A) ){
            list_A_species <- input$inter_list_A
            remaining_species <- setdiff(intra_list, list_A_species)
            updatePickerInput(
                session,
                "inter_list_B",
                choices=remaining_species,
                choicesOpt=list(
                    content=lapply(remaining_species, function(choice) {
                        species <- gsub("_", " ", choice)
                        HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                    })
                )
            )
            updatePickerInput(
                session,
                "iadhore_intra_species_list",
                selected=character(0)
            )
        }

        if( isTruthy(input$cluster_species_A) ){
            list_A_species <- input$cluster_species_A
            remaining_species <- setdiff(intra_list, list_A_species)
            updatePickerInput(
                session,
                "cluster_species_B",
                choices=remaining_species,
                choicesOpt=list(
                    content=lapply(remaining_species, function(choice) {
                        species <- gsub("_", " ", choice)
                        HTML(paste0("<div style='color: #B97D4B; font-style: italic;'>", species, "</div>"))
                    })
                )
            )
            updatePickerInput(
                session,
                "iadhore_intra_species_list",
                selected=character(0)
            )
            updatePickerInput(
                session,
                "inter_list_A",
                selected=character(0)
            )
            updatePickerInput(
                session,
                "inter_list_B",
                selected=character(0)
            )
        }
    })
})

observeEvent(input$iadhore_config_go, {
    withProgress(message='Configuration in progress', value=0, {
        Sys.sleep(.2)
        incProgress(amount=.3, message="Configuring...")

        dirPath <- parseDirPath(roots=c(computer="/"), input$iadhoredir)
        load(paste0(dirPath, "/tmp.comparing.RData"))

        color_list <- c("#F5FFE8", "#ECF5FF", "#FDFFFF", "#FBFFFD", "#F0FFF0",
                        "#FBFBFF", "#FFFFF4", "#FFFCEC", "#FFFAF4", "#FFF3EE")
        color_list_selected <- rep(color_list, length.out=nrow(path_df))

        intra_list <- input$iadhore_intra_species_list
        intra_selected_df <- path_df[path_df$comparing_ID %in% intra_list, ]
        inter_list_A <- input$inter_list_A
        inter_list_B <- input$inter_list_B
        inter_list_A_linked <- gsub(" ", "_", inter_list_A)
        inter_list_B_linked <- gsub(" ", "_", inter_list_B)
        inter_selected_df <- data.frame()
        for( each in inter_list_B_linked ){
            pattern1 <- paste0(inter_list_A_linked[1], "_vs_", each)
            pattern2 <- paste0(each, "_vs_", inter_list_A_linked[1])
            matched_df <- path_df[(path_df$comparing_ID %in% pattern1) | (path_df$comparing_ID %in% pattern2), ]
            inter_selected_df <- rbind(inter_selected_df, matched_df)
        }
        selected_df <- rbind(intra_selected_df, inter_selected_df)
        if( nrow(selected_df) > 0 ){
            output$iadhore_output <- renderUI({
                plot_output_list <- lapply(1:nrow(selected_df), function(x) {
                    each_row <- selected_df[x, ]
                    each_title <- strsplit(each_row$comparing_ID, split="_vs_")[[1]]
                    each_title[1] <- gsub("_", " ", each_title[1])
                    if( length(each_title) == 1 ){
                        panelTitle <- paste0("<font color='#DCFEE3'><b>", x, ".&nbsp;<i>", each_title[1], "</i></b></font>")
                        queryChrPanelTitle <- HTML(paste("<font color='#68AC57'>", icon("dna"), "</font>Select <font color='#68AC57'><i><b>", each_title[1], "</b></i></font> Chromosomes:"))
                        button_style <- "info"
                    }else{
                        each_title[2] <- gsub("_", " ", each_title[2])
                        panelTitle <- paste0("<font color='#FFD374'><b>", x,".&nbsp;<i>", each_title[1], "</i></font> versus <font color='#E1B8FF'><i>", each_title[2], "</i></b></font>")
                        queryChrPanelTitle <- HTML(paste("<font color='#68AC57'>", icon("dna"), "</font>Select <font color='#68AC57'><i><b>", each_title[1], "</b></i></font> Chromosomes:"))
                        subjectChrPanelTitle <- HTML(paste("<font color='#8E549E'>", icon("dna"), "</font>Select <font color='#8E549E'><i><b>", each_title[2], "</b></i></font> Chromosomes:"))
                        button_style <- "success"
                    }
                    div(
                        class="boxLike",
                        style="padding-right: 50px;
                               padding-left: 50px;
                               padding-top: 10px;
                               padding-bottom: 10px;
                               background-color: white",
                        fluidRow(
                            column(
                                width=12,
                                div(
                                    style="padding-bottom: 10px;",
                                    bsButton(
                                        inputId=paste0("plot_button_", x),
                                        label=HTML(panelTitle),
                                        style=button_style
                                    ) %>%
                                        bs_embed_tooltip(
                                            title="Click to see more details",
                                            placement="right",
                                            trigger="hover",
                                            options=list(container="body")
                                        ) %>%
                                        bs_attach_collapse(
                                            paste0("plot_panel_collapse_", x)
                                        ),
                                    bs_collapse(
                                        id=paste0("plot_panel_collapse_", x),
                                        show=TRUE,
                                        content=tags$div(
                                            class="well",
                                            fluidRow(
                                                div(
                                                    style=paste0(
                                                        "background-color: ",
                                                        color_list_selected[x],
                                                        "; padding-right: 50px;
                                                             padding-left: 50px;
                                                             padding-top: 10px;
                                                             padding-bottom: 10px;"
                                                    ),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h5(HTML("<font color='#FFA500'><b>Chromosome-level Synteny</b></font><br>"))
                                                        ),
                                                        column(
                                                            6,
                                                            pickerInput(
                                                                inputId=paste0("synteny_query_chr_", x),
                                                                label=queryChrPanelTitle,
                                                                options=list(
                                                                    title='Please select chromosomes below',
                                                                    `selected-text-format`="count > 2",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=TRUE
                                                            )
                                                        ),
                                                        column(
                                                            6,
                                                            if( length(each_title) == 2 ){
                                                                uiOutput(paste0("subjectChrPanel_", x))
                                                            }
                                                        )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            4,
                                                            sliderInput(
                                                                inputId=paste0("anchoredPointsCutoff_", x),
                                                                label=HTML("<font color='orange'>Set Anchored Points per Multiplicon:</font>"),
                                                                min=3,
                                                                max=30,
                                                                step=1,
                                                                value=3
                                                            )
                                                        ),
                                                        column(
                                                            6,
                                                            tags$head(
                                                                tags$style(HTML(
                                                                    "@keyframes glowing {
                                                                     0% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
                                                                     50% { background-color: #64A600; box-shadow: 0 0 20px #43b0d1; }
                                                                     100% { background-color: #548C00; box-shadow: 0 0 5px #0795ab; }
                                                                     }
                                                                @keyframes glowingD {
                                                                     0% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
                                                                     50% { background-color: #8C8C00; box-shadow: 0 0 20px #43b0d1; }
                                                                     100% { background-color: #5B5B00; box-shadow: 0 0 5px #0795ab; }
                                                                     }"
                                                                ))
                                                            ),
                                                            actionButton(
                                                                inputId=paste0("synplot_go_", x),
                                                                "Draw Syntenty Plot",
                                                                icon=icon("pencil-alt"),
                                                                status="secondary",
                                                                style="color: #fff;
                                                                   background-color: #009393;
                                                                   border-color: #fff;
                                                                   padding: 5px 10px 5px 10px;
                                                                   margin: 50px 5px 5px 35px;
                                                                   animation: glowing 5000ms infinite; "
                                                            )
                                                        )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h6(HTML("<b>The Dot Plot:</b>")),
                                                            tags$style(
                                                                HTML(".rotate-135 {
                                                                    transform: rotate(135deg);
                                                                }"),
                                                                HTML(".rotate-45{
                                                                    transform: rotate(45deg);
                                                                }")
                                                            ),
                                                            actionButton(
                                                                paste0("svg_spacing_add_dot_", x),
                                                                "",
                                                                icon("arrows-alt-v", class="rotate-45"),
                                                                title="Expand spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_spacing_sub_dot_", x),
                                                                "",
                                                                icon("compress"),
                                                                title="Compress spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                paste0("Dot_download_", x),
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                style="color: #fff;
                                                                   background-color: #019858;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;
                                                                   animation: glowingD 5000ms infinite;"
                                                            )
                                                        ),
                                                        column(
                                                            width=12,
                                                            id=paste0("dotView_", x)
                                                        ),
                                                        # column(
                                                        #     width=12,
                                                        #     id=paste0("dotView_png_", x)
                                                        # )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h6(HTML("<b>The Parallel Link Plot:</b>")),
                                                            actionButton(
                                                                paste0("svg_vertical_spacing_add_rainbow_", x),
                                                                "",
                                                                icon("arrows-alt-v"),
                                                                title="Expand vertical spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_vertical_spacing_sub_rainbow_", x),
                                                                "",
                                                                icon("compress", class="rotate-135"),
                                                                title="Compress vertical spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_horizontal_spacing_add_rainbow_", x),
                                                                "",
                                                                icon("arrows-alt-h"),
                                                                title="Expand horizontal spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_horizontal_spacing_sub_rainbow_", x),
                                                                "",
                                                                icon("compress", class="rotate-45"),
                                                                title="Compress horizontal spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                paste0("Synteny_download_", x),
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                style="color: #fff;
                                                                   background-color: #019858;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;
                                                                   animation: glowingD 5000ms infinite;"
                                                            )
                                                        ),
                                                        column(
                                                            width=12,
                                                            id=paste0("SyntenicBlock_", x)
                                                        )
                                                    ),
                                                    hr(class="splitting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h5(HTML("<font color='#00DB00'><b>Multiplicon-level Synteny</b></font>"))
                                                        )
                                                    ),
                                                    fluidRow(
                                                        column(
                                                            5,
                                                            textInput(
                                                                inputId=paste0("gene_", x),
                                                                label="Seach the Gene:",
                                                                value="",
                                                                width="100%",
                                                                placeholder="Gene Id"
                                                            )
                                                        ),
                                                        column(
                                                            1,
                                                            actionButton(
                                                                inputId=paste0("searchButton_", x),
                                                                "",
                                                                width="40px",
                                                                icon=icon("search"),
                                                                status="secondary",
                                                                style="color: #fff;
                                                                   background-color: #8080C0;
                                                                   border-color: #fff;
                                                                   margin: 32px 0px 0px -15px; "
                                                            )
                                                        ),
                                                        column(
                                                            6,
                                                            uiOutput(paste0("foundItemsMessage_", x))
                                                        ),
                                                    ),
                                                    fluidRow(
                                                        column(
                                                            6,
                                                            pickerInput(
                                                                inputId=paste0("multiplicon_plot_", x),
                                                                label=HTML("Choose <b>Multiplicon</b> to Plot"),
                                                                options=list(
                                                                    title='Please select multiplicon below',
                                                                    `selected-text-format`="count > 2",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=TRUE
                                                            )
                                                        ),
                                                        column(
                                                            6,
                                                            actionButton(
                                                                inputId=paste0("plotMicro_", x),
                                                                "Draw Plot",
                                                                icon=icon("pencil-alt"),
                                                                status="secondary",
                                                                style="color: #fff;
                                                                   background-color: #8080C0;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 35px 5px 5px 5px;
                                                                   animation: glowing 5000ms infinite; "
                                                            )
                                                        )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h6(HTML("<b>The Synteny Link Plot:</b>")),
                                                            actionButton(
                                                                paste0("svg_vertical_spacing_add_micro_", x),
                                                                "",
                                                                icon("arrows-alt-v"),
                                                                title="Expand vertical spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_vertical_spacing_sub_micro_", x),
                                                                "",
                                                                icon("compress", class="rotate-135"),
                                                                title="Compress vertical spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_horizontal_spacing_add_micro_", x),
                                                                "",
                                                                icon("arrows-alt-h"),
                                                                title="Expand horizontal spacing"
                                                            ),
                                                            actionButton(
                                                                paste0("svg_horizontal_spacing_sub_micro_", x),
                                                                "",
                                                                icon("compress", class="rotate-45"),
                                                                title="Compress horizontal spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                paste0("microSyn_download_", x),
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                style="color: #fff;
                                                               background-color: #019858;
                                                               border-color: #fff;
                                                               padding: 5px 14px 5px 14px;
                                                               margin: 5px 5px 5px 5px;
                                                               animation: glowingD 5000ms infinite;"
                                                            )
                                                        ),
                                                        column(
                                                            width=12,
                                                            id=paste0("microSyntenicBlock_", x)
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
            })

            # update the chromosome options for inter- / intra- comparing
            incProgress(amount=.9, message="Updating Chromosomes Setting...")
            lapply(1:nrow(selected_df), function(x){
                each_row <- selected_df[x, ]
                each_dir <- dirname(each_row$comparing_Path)
                genesFile <- paste0(each_dir, "/genes.txt")
                if( file.exists(genesFile) ){
                    genes <- suppressMessages(
                        vroom(
                            genesFile,
                            delim="\t",
                            col_names=TRUE
                        )
                    )
                    gene_num_df <- aggregate(remapped_coordinate ~ genome + list, genes, max)
                    colnames(gene_num_df) <- c("sp", "chr", "gene_num")
                    gene_num_df$gene_num <- gene_num_df$gene_num + 1
                    if( each_row$comparing_Type=="Inter" ){
                        sp_list_tmp <- unique(strsplit(each_row$comparing_ID, split="_vs_")[[1]])

                        queryChrs <- gene_num_df %>%
                            filter(sp==sp_list_tmp[1])

                        observe({
                            if( is.null(queryChrs) ){
                                querys <- NULL
                            }else{
                                querys <- queryChrs %>%
                                    filter(gene_num>500) %>%
                                    arrange(desc(gene_num)) %>%
                                    pull(chr)
                            }
                            updatePickerInput(
                                session,
                                paste0("synteny_query_chr_", x),
                                choices=querys,
                                choicesOpt=list(
                                    content=lapply(querys, function(choice) {
                                        HTML(paste0("<div style='color: #68AC57;'>", choice, "</div>"))
                                    })
                                )
                            )
                        })

                        subjectChrs <- gene_num_df %>%
                            filter(sp==sp_list_tmp[2])
                        if( is.null(subjectChrs) ){
                            subjects <- NULL
                        }else{
                            subjects <- subjectChrs %>%
                                filter(gene_num>500) %>%
                                arrange(desc(gene_num)) %>%
                                pull(chr)
                        }

                        subjectChrPanelTitle <- HTML(paste("<font color='#8E549E'>", icon("dna"), "</font>Select <font color='#8E549E'><i><b>", gsub("_", " ", sp_list_tmp[2]), "</b></i></font> Chromosomes:"))
                        output[[paste0("subjectChrPanel_", x)]] <- renderUI({
                            column(
                                12,
                                pickerInput(
                                    inputId=paste0("synteny_subject_chr_", x),
                                    label=subjectChrPanelTitle,
                                    options=list(
                                        title='Please select chromosomes below',
                                        `selected-text-format`="count > 2",
                                        `actions-box`=TRUE
                                    ),
                                    choices=subjects,
                                    choicesOpt=list(
                                        content=lapply(subjects, function(choice) {
                                            HTML(paste0("<div style='color: #8E549E;'>", choice, "</div>"))
                                        })
                                    ),
                                    selected=NULL,
                                    multiple=TRUE
                                )
                            )
                        })
                    }
                    if( each_row$comparing_Type=="Intra" ){
                        sp_list_tmp <- unique(strsplit(each_row$comparing_ID, split="_vs_")[[1]])
                        queryChrs <- gene_num_df %>%
                            filter(sp==sp_list_tmp[1])

                        observe({
                            if( is.null(queryChrs) ){
                                querys <- NULL
                            }else{
                                querys <- queryChrs %>%
                                    filter(gene_num>500) %>%
                                    arrange(desc(gene_num)) %>%
                                    pull(chr)
                            }
                            updatePickerInput(
                                session,
                                paste0("synteny_query_chr_", x),
                                choices=querys,
                                choicesOpt=list(
                                    content=lapply(querys, function(choice) {
                                        HTML(paste0("<div style='color: #68AC57;'>", choice, "</div>"))
                                    })
                                )
                            )
                        })
                    }
                }
            })
        }

        if( isTruthy(input$cluster_species_A) ){
            cluster_species_A <- gsub("_", " ", input$cluster_species_A)
            cluster_species_B <- gsub("_", " ", input$cluster_species_B)
            output$iadhore_output <- renderUI({
                div(
                    class="boxLike",
                    style="padding-right: 50px;
                           padding-left: 50px;
                           padding-top: 10px;
                           padding-bottom: 10px;
                           background-color: white",
                    fluidRow(
                        column(
                            width=12,
                            div(
                                style="padding-bottom: 10px;",
                                bsButton(
                                    inputId="cluster_plot_button",
                                    label=h5(HTML(paste0("<font color='#F4FFEE'><b>Clustering Analysis</b></font> for <font color='#FFD374'><b><i>", cluster_species_A, "</i></font> and <font color='#E1B8FF'><i>", cluster_species_B, "</i></b></font>"))),
                                    style="success"
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to see more details",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    ) %>%
                                    bs_attach_collapse(
                                        id="cluster_plot_panel_collapse"
                                    ),
                                bs_collapse(
                                    id="cluster_plot_panel_collapse",
                                    show=TRUE,
                                    content=tags$div(
                                        class="well",
                                        fluidRow(
                                            column(
                                                12,
                                                div(
                                                    style="background-color: #F4FFEE;
                                                           padding-right: 50px;
                                                           padding-left: 50px;
                                                           padding-top: 10px;
                                                           padding-bottom: 10px;",
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            5,
                                                            sliderInput(
                                                                inputId="interactPointsCutoff",
                                                                label=HTML("Set threshold for <font color='#C4EC00'><b>anchor points between segments</b></font>:"),
                                                                min=0,
                                                                max=30,
                                                                step=1,
                                                                value=20
                                                            )
                                                        ),
                                                        column(
                                                            4,
                                                            sliderInput(
                                                                inputId="corRCutoff",
                                                                label=HTML("Set threshold for <font color='#00ECE5'><b>Pearson correlation coefficient <i>r</i></b></font> :"),
                                                                min=0,
                                                                max=1,
                                                                step=0.1,
                                                                value=0.3
                                                            )
                                                        ),
                                                        column(
                                                            3,
                                                            actionButton(
                                                                inputId="cluster_go",
                                                                "Start Clustering Analysis",
                                                                icon=icon("play"),
                                                                status="secondary",
                                                                style="color: #fff;
                                                                   background-color: #009393;
                                                                   border-color: #fff;
                                                                   padding: 5px 10px 5px 10px;
                                                                   margin: 50px 5px 5px 35px;
                                                                   animation: glowing 5000ms infinite; "
                                                            )
                                                        )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h6(HTML("<b>The Hierarchical Clustering Plot:</b>")),
                                                            tags$style(
                                                                HTML(".rotate-135 {
                                                                    transform: rotate(135deg);
                                                                }"),
                                                                HTML(".rotate-45{
                                                                    transform: rotate(45deg);
                                                                }")
                                                            ),
                                                            actionButton(
                                                                "svg_spacing_add_cluster",
                                                                "",
                                                                icon("arrows-alt-v", class="rotate-45"),
                                                                title="Expand spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_spacing_sub_cluster",
                                                                "",
                                                                icon("compress"),
                                                                title="Compress spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                "cluster_download",
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label=HTML(""),
                                                                style="color: #fff;
                                                                   background-color: #019858;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;
                                                                   animation: glowingD 5000ms infinite;"
                                                            )
                                                        ),
                                                        column(
                                                            width=12,
                                                            id="clusterView"
                                                        ),
                                                        column(
                                                            width=12,
                                                            id="dendrogramTreeView"
                                                        )
                                                    ),
                                                    hr(class="splitting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h5(HTML("<font color='#00DB00'><b>Putative Ancestral Regions</b></font>"))
                                                        ),
                                                        column(
                                                            12,
                                                            uiOutput("foundParsMessage")
                                                        ),
                                                    ),
                                                    fluidRow(
                                                        column(
                                                            6,
                                                            pickerInput(
                                                                inputId="pars_list",
                                                                label=HTML("Choose <b><font color='green'>PARs</font></b> to zoom in"),
                                                                options=list(
                                                                    title='Please select PAR below',
                                                                    `selected-text-format`="count > 2",
                                                                    `actions-box`=TRUE
                                                                ),
                                                                choices=NULL,
                                                                selected=NULL,
                                                                multiple=FALSE
                                                            )
                                                        ),
                                                        column(
                                                            6,
                                                            actionButton(
                                                                inputId="zoomInPAR",
                                                                "",
                                                                icon=icon("search"),
                                                                status="secondary",
                                                                style="color: #fff;
                                                                       background-color: #8080C0;
                                                                       border-color: #fff;
                                                                       margin: 32px 0px 0px -15px; "
                                                            )
                                                        )
                                                    ),
                                                    hr(class="setting"),
                                                    fluidRow(
                                                        column(
                                                            12,
                                                            h6(HTML("<b>The PARs Dot Plot:</b>")),
                                                            actionButton(
                                                                "svg_vertical_spacing_add_par",
                                                                "",
                                                                icon("arrows-alt-v", class="rotate-45"),
                                                                title="Expand spacing"
                                                            ),
                                                            actionButton(
                                                                "svg_vertical_spacing_sub_par",
                                                                "",
                                                                icon("compress"),
                                                                title="Compress spacing"
                                                            ),
                                                            downloadButton_custom(
                                                                "PAR_download",
                                                                title="Download the Plot",
                                                                status="secondary",
                                                                icon=icon("download"),
                                                                label="",
                                                                style="color: #fff;
                                                                   background-color: #019858;
                                                                   border-color: #fff;
                                                                   padding: 5px 14px 5px 14px;
                                                                   margin: 5px 5px 5px 5px;
                                                                   animation: glowingD 5000ms infinite;"
                                                            )
                                                        ),
                                                        column(
                                                            width=12,
                                                            id="ParZoomIn"
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
                )
            })
        }

        if( !is.null(input$iadhore_multiple_species_list) ){
            if( length(input$iadhore_multiple_species_list) < 3 ){
                shinyalert(
                    "Opps!",
                    "Please choose at least three species to analyze the multiple-species-alignment",
                    type="error"
                )
            }
            else{
                multiple_species_df <- path_df[path_df$comparing_ID == "Multiple", ]
                color_list_renew <- c(
                    "#ff7f00", "#FFA750", "#0064A7", "#008DEC",
                    "#088A00", "#0CD300", "#e31a1c", "#fb9a99", "#cab2d6"
                )
                total_species <- path_df %>%
                    filter(comparing_ID %in% input$iadhore_multiple_species_list)
                color_list_selected_new <- rep(color_list_renew, length.out=nrow(total_species))
                species_choice <- gsub("_", " ", total_species$comparing_ID)
                output$iadhore_multiple_species_output <- renderUI({
                    div(
                        style="padding-right: 10px;
                                   padding-left: 10px;
                                   padding-top: 10px;
                                   padding-bottom: 10px;
                                   background-color: rgba(253, 244, 255, 0.4);",
                        bsButton(
                            inputId="plot_button_multiple",
                            label=HTML("<b><font color='white'>X. Multiple Species Alignment</font></b>"),
                            style="warning"
                        ) %>%
                            bs_embed_tooltip(
                                title="Click to see more details",
                                placement="right",
                                trigger="hover",
                                options=list(container="body")
                            ) %>%
                            bs_attach_collapse("plot_panel_multiple_collapse"),
                        bs_collapse(
                            id="plot_panel_multiple_collapse",
                            content=tags$div(
                                class="well",
                                fluidRow(
                                    column(
                                        12,
                                        h4(HTML("<b><font color='#D9B300'>Multiple Species Alignment</font></b>"))
                                    ),
                                    hr(class="setting"),
                                    lapply(seq_len(nrow(total_species)), function(ii) {
                                        each_row <- total_species[ii, ]
                                        each_dir <- dirname(each_row$comparing_Path)
                                        genesFile <- paste0(each_dir, "/genes.txt")
                                        if( !file.exists(genesFile) ){
                                            shinyalert(
                                                "Opps!",
                                                paste0("Error! Fail to access ", genesFile, ". Please check the i-ADHoRe outputs..."),
                                                type="error"
                                            )
                                        }
                                        genes <- suppressMessages(
                                            vroom(
                                                genesFile,
                                                delim="\t",
                                                col_names=TRUE
                                            )
                                        )
                                        gene_num_df <- aggregate(remapped_coordinate ~ genome + list, genes, max)
                                        colnames(gene_num_df) <- c("sp", "chr", "gene_num")
                                        gene_num_df$gene_num <- gene_num_df$gene_num + 1

                                        if( is.null(gene_num_df) ){
                                            querys <- NULL
                                        }else{
                                            querys <- gene_num_df %>%
                                                filter(gene_num>500) %>%
                                                arrange(desc(gene_num)) %>%
                                                pull(chr)
                                        }

                                        species <- gsub("_", " ", total_species[ii, ]$comparing_ID)
                                        column(
                                            6,
                                            pickerInput(
                                                inputId=paste0("multiple_synteny_query_chr_", total_species[ii, ]$comparing_ID),
                                                label=HTML(paste("<font color='", color_list_selected_new[ii], "'>", icon("dna"), "</font>Select <i><b><font color='", color_list_selected_new[ii], "'>", species, "</font></i></b> Chromosomes:")),
                                                options=list(
                                                    title='Please select chromosomes below',
                                                    `selected-text-format`="count > 2",
                                                    `actions-box`=TRUE
                                                ),
                                                choices=querys,
                                                choicesOpt=list(
                                                    content=lapply(querys, function(choice) {
                                                        HTML(paste0("<div style='color: ", color_list_selected_new[ii], ";'>", choice, "</div>"))
                                                    })
                                                ),
                                                multiple=TRUE
                                            )
                                        )
                                    }),
                                    hr(class="setting"),
                                    column(
                                        12,
                                        selectizeInput(
                                            inputId="order_of_display",
                                            label=HTML(paste0("Set the <font color='#ff7575'><b>Order</b></font> of <font color='#ff7575'><b>Species</b></font> to Display:")),
                                            choices=species_choice,
                                            selected=NULL,
                                            multiple=TRUE,
                                            options=list(
                                                placeholder="Order species below ...",
                                                render=I("{
                                                  option: function(item, escape) {
                                                    var species=item.label.replace(/_/g, ' ');
                                                    var style='color: #B97D4B; font-style: italic;';
                                                    return '<div style=\"' + style + '\">&nbsp;&nbsp;' + escape(species) + '</div>';
                                                  },
                                                  item: function(item, escape) {
                                                    var species=item.label.replace(/_/g, ' ');
                                                    var style='color: #B97D4B; font-style: italic;';
                                                    return '<div style=\"' + style + '\">&nbsp;&nbsp;' + escape(species) + '</div>';
                                                  }
                                                }"
                                                )
                                            )
                                        )
                                    ),
                                    hr(class="setting"),
                                    column(
                                        4,
                                        sliderInput(
                                            inputId="anchoredPointsCutoff_multiple",
                                            label=HTML("<font color='orange'>Cutoff for Anchored Points per Multiplicon:</font>"),
                                            min=3,
                                            max=50,
                                            step=1,
                                            value=3
                                        )
                                    ),
                                    column(
                                        4,
                                        sliderInput(
                                            inputId="overlapCutoff_multiple",
                                            label=HTML("<font color='#7D7DFF'>Cutoff for Overlapping between Sgements:</font>"),
                                            min=10,
                                            max=80,
                                            step=5,
                                            value=10,
                                            post="%"
                                        )
                                    ),
                                    column(
                                        2,
                                        actionButton(
                                            inputId="synplot_go_last",
                                            "Draw Plot",
                                            #width="110px",
                                            icon=icon("play"),
                                            status="secondary",
                                            style="color: #fff;
                                               background-color: #009393;
                                               border-color: #fff;
                                               padding: 5px 14px 5px 14px;
                                               margin: 50px 5px 5px 5px;
                                               animation: glowing 5300ms infinite; "
                                        )
                                    ),
                                    hr(class="setting"),
                                    div(
                                        #style=paste0("width: 900px; height: ", (nrow(total_species) - 1) * 200, "px;"),
                                        h6(HTML("<b>The Multiple Species Parallel Link Plot:</b><br></br>")),
                                        column(
                                            12,
                                            actionButton(
                                                "svg_vertical_spacing_add_multiple",
                                                "",
                                                icon("arrows-alt-v"),
                                                title="Expand vertical spacing"
                                            ),
                                            actionButton(
                                                "svg_vertical_spacing_sub_multiple",
                                                "",
                                                icon("compress", class="rotate-135"),
                                                title="Compress vertical spacing"
                                            ),
                                            actionButton(
                                                "svg_horizontal_spacing_add_multiple",
                                                "",
                                                icon("arrows-alt-h"),
                                                title="Expand horizontal spacing"
                                            ),
                                            actionButton(
                                                "svg_horizontal_spacing_sub_multiple",
                                                "",
                                                icon("compress", class="rotate-45"),
                                                title="Compress horizontal spacing"
                                            ),
                                            downloadButton_custom(
                                                "parallel_download_last",
                                                title="Download the Plot",
                                                status="secondary",
                                                icon=icon("download"),
                                                label=HTML(""),
                                                style="color: #fff;
                                                   background-color: #019858;
                                                   border-color: #fff;
                                                   padding: 5px 14px 5px 14px;
                                                   margin: 5px 5px 5px 5px;
                                                   animation: glowingD 5000ms infinite;"
                                            )
                                        ),
                                        column(
                                            width=12,
                                            id="parallel_plot_multiple_species"
                                        )
                                    )
                                )
                            )
                        )
                    )
                })
            }
        }

        if( nrow(selected_df) > 0 ){
            syn_dir <- dirname(dirname(dirname(selected_df$comparing_Path)))[1]
            # get the segments and chr lengths of selected chrs
            sp_gff_info_xls <- paste0(file.path(syn_dir), "/Species.info.xls")
            sp_gff_info_df <- suppressMessages(
                vroom(sp_gff_info_xls,
                      col_names=c("species", "cdsPath", "gffPath"),
                      delim="\t")
            )
            cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
            gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
            new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
            new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
            sp_gff_info_df$cdsPath <- new_cds_files
            sp_gff_info_df$gffPath <- new_gff_files
            # source(file="tools/obtain_chromosome_length.R", local=T, encoding="UTF-8")
            chr_num_len_df <- obtain_chromosome_length(sp_gff_info_xls)
            lapply(1:nrow(selected_df), function(x){
                each_row <- selected_df[x, ]
                if( each_row$comparing_Type=="Inter" ){
                    sp_list_tmp <- unique(strsplit(each_row$comparing_ID, split="_vs_")[[1]])
                    querySpecies <- gsub("_", " ", sp_list_tmp[1])
                    subjectSpecies <- gsub("_", " ", sp_list_tmp[2])

                    synplot_go_tmp <- paste0("synplot_go_", x)
                    observeEvent(input[[synplot_go_tmp]], {
                        chr_len_df <- chr_num_len_df$len_df
                        renew_x <- x
                        query_chr_Input <- paste0("synteny_query_chr_", renew_x)
                        query_selected_chr_list <- input[[query_chr_Input]]
                        query_chr_len_df <- chr_len_df[chr_len_df$sp==querySpecies, ] %>%
                            filter(seqchr %in% query_selected_chr_list)
                        subject_chr_Input<- paste0("synteny_subject_chr_", renew_x)
                        subject_selected_chr_list <- input[[subject_chr_Input]]
                        subject_chr_len_df <- chr_len_df[chr_len_df$sp==subjectSpecies, ] %>%
                            filter(seqchr %in% subject_selected_chr_list)

                        iadhoreDir <- dirname(each_row$comparing_Path)

                        withProgress(message='Analyzing in progress', value=0, {
                            Sys.sleep(.2)
                            incProgress(amount=.2, message="Calculating ...")
                            genesFile <- paste0(iadhoreDir, "/genes.txt")
                            multiplicon_file <- paste0(iadhoreDir, "/multiplicons.txt")
                            multiplicon_ks_file <- paste0(iadhoreDir, "/multiplicons.merged_ks.txt")
                            anchorpointfile <- paste0(iadhoreDir, "/anchorpoints.txt")
                            anchorpoint_merged_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos.txt")
                            anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                            ks_file <- paste0(iadhoreDir, "/anchorpoints.ks.txt")

                            if( file.exists(ks_file) ){
                                if( !file.exists(anchorpointout_file) ){
                                    # source(file="tools/obtain_coordinates_for_anchorpoints.R", local=T, encoding="UTF-8")
                                    obtain_coordiantes_for_anchorpoints(
                                        anchorpoints=anchorpointfile,
                                        species1=querySpecies,
                                        gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                                        species2=subjectSpecies,
                                        gff_file2=sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath,
                                        out_file=anchorpoint_merged_file
                                    )
                                }

                                if( !file.exists(multiplicon_ks_file) ){
                                    # source(file="tools/obtain_mean_ks_for_multiplicons.v2.R", local=T, encoding="UTF-8")
                                    obtain_mean_ks_for_each_multiplicon(
                                        multiplicon_file=multiplicon_file,
                                        anchorpoint_file=anchorpoint_merged_file,
                                        ks_file=ks_file,
                                        species1=querySpecies,
                                        species2=subjectSpecies,
                                        anchorpointout_file=anchorpointout_file,
                                        outfile=multiplicon_ks_file
                                    )
                                }
                            }
                            else{
                                shinyalert(
                                    "Opps!",
                                    paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of ShinyWGD first ..."),
                                    type="error",
                                )
                            }

                            final_multiplicons <- suppressMessages(
                                vroom(multiplicon_ks_file,
                                      col_names=TRUE,
                                      delim="\t")
                            )

                            final_anchorpoints <- suppressMessages(
                                vroom(anchorpointout_file,
                                      col_names=TRUE,
                                      delim="\t")
                            )

                            anchoredPointScutoff <- paste0("anchoredPointsCutoff_", renew_x)
                            selected_multiplicons <- final_multiplicons %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% subject_selected_chr_list) %>%
                                filter(num_anchorpoints >= input[[anchoredPointScutoff]])
                            selected_multiplicons_Id <- selected_multiplicons$multiplicon

                            chr_num_df <- chr_num_len_df$num_df

                            genes <- suppressMessages(
                                vroom(
                                    genesFile,
                                    delim="\t",
                                    col_names=TRUE
                                )
                            )
                            gene_num_df <- aggregate(remapped_coordinate ~ genome + list, genes, max)
                            colnames(gene_num_df) <- c("sp", "seqchr", "num")
                            gene_num_df$gene_num <- gene_num_df$num + 1

                            query_chr_num_df <- gene_num_df %>%
                                filter(sp==gsub(" ", "_", querySpecies)) %>%
                                filter(seqchr %in% query_selected_chr_list)
                            subject_chr_num_df <- gene_num_df %>%
                                filter(sp==gsub(" ", "_", subjectSpecies)) %>%
                                filter(seqchr %in% subject_selected_chr_list)

                            # source(file="tools/computeAnchorPointDepth.R", local=T, encoding="UTF-8")
                            depth_list <- computing_depth(
                                anchorpoint_ks_file=anchorpointout_file,
                                multiplicon_id=selected_multiplicons_Id,
                                selected_query_chr=query_selected_chr_list,
                                selected_subject_chr=subject_selected_chr_list
                            )
                            query_selected_depth_list <- depth_list$query_depth
                            subject_selected_depth_list <- depth_list$subject_depth

                            selected_anchorpoints <- final_anchorpoints %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% subject_selected_chr_list) %>%
                                filter(multiplicon %in% selected_multiplicons_Id)

                            incProgress(amount=.3, message="Drawing Dot Plot...")
                            Sys.sleep(.2)

                            plotSize <- reactiveValues(
                                value=400
                            )
                            observeEvent(input[[paste0("svg_spacing_add_dot_", renew_x)]], {
                                plotSize$value <- plotSize$value + 50
                            })
                            observeEvent(input[[paste0("svg_spacing_sub_dot_", renew_x)]], {
                                plotSize$value <- plotSize$value - 50
                            })
                            observe({
                                plot_dot_num_data <- list(
                                    "plot_id"=x,
                                    "multiplicons"=selected_multiplicons,
                                    "anchorpoints"=selected_anchorpoints,
                                    "query_sp"=querySpecies,
                                    "query_chr_gene_nums"=query_chr_num_df,
                                    "query_depths"=query_selected_depth_list,
                                    "subject_sp"=subjectSpecies,
                                    "subject_chr_gene_nums"=subject_chr_num_df,
                                    "subject_depths"=subject_selected_depth_list,
                                    "size"=plotSize$value
                                )
                                session$sendCustomMessage("Dot_Num_Plotting", plot_dot_num_data)
                            })
                            Sys.sleep(.2)
                            incProgress(amount=1, message="Drawing Dot Plot Done")
                        })
                        # plot parallel figure
                        withProgress(message='Parallel Syntenty Figure in progress', value=0, {
                            Sys.sleep(.2)
                            incProgress(amount=.3, message="Drawing Parallel Syntenty Plot...")
                            segmentsfile <- paste0(iadhoreDir, "/segments.txt")
                            segs_pos_file <- paste0(iadhoreDir, "/segments.merged_pos.txt")
                            if( ! file.exists(segs_pos_file) ){
                                # source("tools/obtain_coordinates_for_segments.v2.R", local=T, encoding="UTF-8")
                                obtain_coordiantes_for_segments(
                                    seg_file=segmentsfile,
                                    sp1=gsub(" ", "_", querySpecies),
                                    gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                                    sp2=gsub(" ", "_", subjectSpecies),
                                    gff_file2=sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath,
                                    out_file=segs_pos_file
                                )
                            }
                            segs_data <- suppressMessages(
                                vroom(
                                    segs_pos_file,
                                    delim="\t"
                                )
                            )
                            selected_segs_data <- segs_data %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% subject_selected_chr_list) %>%
                                filter(multiplicon %in% selected_multiplicons_Id)

                            widthSpacingRainbow <- reactiveValues(
                                value=800
                            )
                            heightSpacingRainbow <- reactiveValues(
                                value=300
                            )
                            observeEvent(input[[paste0("svg_vertical_spacing_add_rainbow_", x)]], {
                                heightSpacingRainbow$value <- heightSpacingRainbow$value + 20
                            })
                            observeEvent(input[[paste0("svg_vertical_spacing_sub_rainbow_", x)]], {
                                heightSpacingRainbow$value <- heightSpacingRainbow$value - 20
                            })
                            observeEvent(input[[paste0("svg_horizontal_spacing_add_rainbow_", x)]], {
                                widthSpacingRainbow$value <- widthSpacingRainbow$value + 20
                            })
                            observeEvent(input[[paste0("svg_horizontal_spacing_sub_rainbow_", x)]], {
                                widthSpacingRainbow$value <- widthSpacingRainbow$value - 20
                            })
                            observe({
                                plot_parallel_data <- list(
                                    "plot_id"=x,
                                    "segs"=selected_segs_data,
                                    "query_sp"=querySpecies,
                                    "query_chr_lens"=query_chr_len_df,
                                    "subject_sp"=subjectSpecies,
                                    "subject_chr_lens"=subject_chr_len_df,
                                    "width"=widthSpacingRainbow$value,
                                    "height"=heightSpacingRainbow$value
                                )
                                session$sendCustomMessage("Parallel_Plotting", plot_parallel_data)
                            })

                            Sys.sleep(.3)
                            incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
                        })
                    })
                    observeEvent(input[[paste0("searchButton_", x)]], {
                        iadhoreDir <- dirname(each_row$comparing_Path)
                        anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                        final_anchorpoints <- suppressMessages(
                            vroom(anchorpointout_file,
                                  col_names=TRUE,
                                  delim="\t")
                        )

                        searchGene <- input[[paste0("gene_", x)]]
                        searchMultiplicon <- final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]
                        if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                            withProgress(message='Searching Gene in progress', value=0, {
                                Sys.sleep(.8)
                                search_data <- list(
                                    "plot_id"=x,
                                    "geneId"=searchMultiplicon
                                )
                                session$sendCustomMessage("searchGene", search_data)
                                output[[paste0("foundItemsMessage_", x)]] <- renderUI({
                                    if( !is.null(input[[paste0("foundMultiplicons_", x)]]) ){
                                        updatePickerInput(
                                            session,
                                            paste0("multiplicon_plot_", x),
                                            choices=input[[paste0("foundMultiplicons_", x)]],
                                            choicesOpt=list(
                                                content=lapply(input[[paste0("foundMultiplicons_", x)]], function(choice) {
                                                    HTML(paste0("<div style='color: orange; font-style: italic;'>Multiplicon: ", choice, "</div>"))
                                                })
                                            ),
                                        )
                                    }
                                    message <- paste("<div style='border: 1px solid #ccc; padding: 2px; margin-top: 30px; margin-left: -40px; border-radius: 10px; background-color: white; font-family: Times New Roman, Times, serif; white-space: pre-wrap;'>",
                                                     input[[paste0("foundItemsMessage_", x)]], "</div>")
                                    HTML(message)
                                })
                                Sys.sleep(.9)
                                incProgress(amount=1, message="Searching Done")
                            })
                        }else{
                            shinyalert(
                                "Warning!",
                                "Please input the correct gene name ...",
                                type="warning",
                            )
                        }
                    })
                    observeEvent(input[[paste0("plotMicro_", x)]], {
                        withProgress(message='Drawing Micro Synteny in progress', value=0, {
                            Sys.sleep(.5)

                            if( is.null(input[[paste0("multiplicon_plot_", x)]]) ){
                                shinyalert(
                                    "Warning!",
                                    "No Multiplicon found! Please search the target gene or select multiplcon to plot first...",
                                    type="warning"
                                )
                            }else{
                                iadhoreDir <- dirname(each_row$comparing_Path)
                                anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                                final_anchorpoints <- suppressMessages(
                                    vroom(anchorpointout_file,
                                          col_names=TRUE,
                                          delim="\t")
                                )

                                renew_x <- x
                                query_chr_Input <- paste0("synteny_query_chr_", renew_x)
                                query_selected_chr_list <- input[[query_chr_Input]]

                                subject_chr_Input<- paste0("synteny_subject_chr_", renew_x)
                                subject_selected_chr_list <- input[[subject_chr_Input]]

                                gff_file1 <- sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath
                                gff_df1 <- suppressMessages(
                                    vroom(gff_file1,
                                          delim="\t",
                                          comment="#",
                                          col_names=FALSE)
                                )
                                position_df1 <- gff_df1 %>%
                                    filter(gff_df1$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9)) %>%
                                    filter(X1 %in% query_selected_chr_list)

                                colnames(position_df1) <- c("seqchr", "gene", "start", "end", "strand")

                                gff_file2 <- sp_gff_info_df[sp_gff_info_df$species==subjectSpecies, ]$gffPath
                                gff_df2 <- suppressMessages(
                                    vroom(gff_file2,
                                          delim="\t",
                                          comment="#",
                                          col_names=FALSE)
                                )
                                position_df2 <- gff_df2 %>%
                                    filter(gff_df2$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9)) %>%
                                    filter(X1 %in% subject_selected_chr_list)

                                colnames(position_df2) <- c("seqchr", "gene", "start", "end", "strand")
                                selectedQueryGenes <- data.frame()
                                selectedSubjectGenes <- data.frame()
                                selectedAnchorPoints <- data.frame()
                                chrListX <- data.frame()
                                chrListY <- data.frame()
                                for( multiplicon in input[[paste0("multiplicon_plot_", x)]] ){
                                    selectedAnchorPointsT <- final_anchorpoints[final_anchorpoints$multiplicon==multiplicon, ]
                                    selectedAnchorPoints <- rbind(selectedAnchorPoints, selectedAnchorPointsT)
                                    cutoffX <- selectedAnchorPointsT %>%
                                        group_by(listX) %>%
                                        summarize(min=min(startX),
                                                  max=max(endX))

                                    cutoffX[["multiplicon"]] <- multiplicon
                                    chrListX <- rbind(chrListX, cutoffX)

                                    selectedQueryGenesT <- position_df1 %>%
                                        inner_join(cutoffX, by=c("seqchr"="listX")) %>%
                                        filter(start >= min, end <= max) %>%
                                        mutate(start=start - min,
                                               end=end - min)
                                    selectedQueryGenesT[["multiplicon"]] <- multiplicon
                                    selectedQueryGenes <- rbind(selectedQueryGenes, selectedQueryGenesT)

                                    cutoffY <- selectedAnchorPointsT %>%
                                        group_by(listY) %>%
                                        summarize(min=min(startY),
                                                  max=max(endY))
                                    cutoffY[["multiplicon"]] <- multiplicon
                                    chrListY <- rbind(chrListY, cutoffY)

                                    selectedSubjectGenesT <- position_df2 %>%
                                        inner_join(cutoffY, by=c("seqchr"="listY")) %>%
                                        filter(start >= min, end <= max) %>%
                                        mutate(start=start - min,
                                               end=end - min)
                                    selectedSubjectGenesT[["multiplicon"]] <- multiplicon
                                    selectedSubjectGenes <- rbind(selectedSubjectGenes, selectedSubjectGenesT)
                                }
                                widthSpacingMicro <- reactiveValues(
                                    value=800
                                )
                                heightSpacingMicro <- reactiveValues(
                                    value=200
                                )
                                observeEvent(input[[paste0("svg_vertical_spacing_add_micro_", x)]], {
                                    heightSpacingMicro$value <- heightSpacingMicro$value + 20
                                })
                                observeEvent(input[[paste0("svg_vertical_spacing_sub_micro_", x)]], {
                                    heightSpacingMicro$value <- heightSpacingMicro$value - 20
                                })
                                observeEvent(input[[paste0("svg_horizontal_spacing_add_micro_", x)]], {
                                    widthSpacingMicro$value <- widthSpacingMicro$value + 20

                                })
                                observeEvent(input[[paste0("svg_horizontal_spacing_sub_micro_", x)]], {
                                    widthSpacingMicro$value <- widthSpacingMicro$value - 20
                                })

                                observe({
                                    microSynPlotData <- list(
                                        "plot_id"=renew_x,
                                        #"multiplicon"=multiplicon[1],
                                        "anchorpoints"=selectedAnchorPoints,
                                        "query_sp"=querySpecies,
                                        "query_chr_info"=chrListX,
                                        "query_chr_genes"=selectedQueryGenes,
                                        "subject_sp"=subjectSpecies,
                                        "subject_chr_info"=chrListY,
                                        "subject_chr_genes"=selectedSubjectGenes,
                                        "targe_gene"=input[[paste0("gene_", x)]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightSpacingMicro$value
                                    )
                                    session$sendCustomMessage("microSynPlotting", microSynPlotData)
                                })

                                Sys.sleep(.9)
                                incProgress(amount=1, message="Drawing Micro Synteny Done")
                            }
                        })
                    })
                }
                if( each_row$comparing_Type=="Intra" ){
                    querySpecies <- gsub("_", " ", each_row$comparing_ID)
                    subjectSpecies <- gsub("_", " ", each_row$comparing_ID)

                    synplot_go_tmp <- paste0("synplot_go_", x)
                    observeEvent(input[[synplot_go_tmp]], {
                        chr_len_df <- chr_num_len_df$len_df
                        renew_x <- x
                        query_chr_Input <- paste0("synteny_query_chr_", renew_x)
                        query_selected_chr_list <- input[[query_chr_Input]]
                        query_chr_len_df <- chr_len_df[chr_len_df$sp==querySpecies, ] %>%
                            filter(seqchr %in% query_selected_chr_list)
                        subject_chr_len_df <- query_chr_len_df

                        iadhoreDir <- dirname(each_row$comparing_Path)

                        withProgress(message='Analyzing in progress', value=0, {
                            Sys.sleep(.2)
                            incProgress(amount=.3, message="Preparing Data...")
                            genesFile <- paste0(iadhoreDir, "/genes.txt")
                            multiplicon_file <- paste0(iadhoreDir, "/multiplicons.txt")
                            multiplicon_ks_file <- paste0(iadhoreDir, "/multiplicons.merged_ks.txt")
                            anchorpointfile <- paste0(iadhoreDir, "/anchorpoints.txt")
                            anchorpoint_merged_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos.txt")
                            anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                            ks_file <- paste0(iadhoreDir, "/anchorpoints.ks.txt")

                            if( file.exists(ks_file) ){
                                if( !file.exists(anchorpointout_file) ){
                                    # source(file="tools/obtain_coordinates_for_anchorpoints_ks.R", local=T, encoding="UTF-8")
                                    # obtain_coordiantes_for_anchorpoints_ks(
                                    #     anchorpoints=anchorpointfile,
                                    #     anchorpoints_ks=ks_file,
                                    #     genes_file=genesFile,
                                    #     out_file=anchorpoint_merged_file,
                                    #     out_ks_file=anchorpointout_file,
                                    #     species=gsub(" ", "_", querySpecies)
                                    # )
                                    # source(file="tools/obtain_coordinates_for_anchorpoints.R", local=T, encoding="UTF-8")
                                    obtain_coordiantes_for_anchorpoints(
                                        anchorpoints=anchorpointfile,
                                        species1=querySpecies,
                                        gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                                        out_file=anchorpoint_merged_file
                                    )
                                }

                                if( !file.exists(multiplicon_ks_file) ){
                                    # source(file="tools/obtain_mean_ks_for_multiplicons.R", local=T, encoding="UTF-8")
                                    obtain_mean_ks_for_each_multiplicon(
                                        multiplicon_file=multiplicon_file,
                                        anchorpoint_file=anchorpoint_merged_file,
                                        ks_file=ks_file,
                                        species1=querySpecies,
                                        anchorpointout_file=anchorpointout_file,
                                        outfile=multiplicon_ks_file
                                    )
                                }
                            }
                            else{
                                shinyalert(
                                    "Opps!",
                                    paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of ShinyWGD first ..."),
                                    type="error",
                                )
                            }

                            Sys.sleep(.2)
                            incProgress(amount=.3, message="Calculating Done")

                            final_multiplicons <- suppressMessages(
                                vroom(multiplicon_ks_file,
                                      col_names=TRUE,
                                      delim="\t")
                            )

                            final_anchorpoints <- suppressMessages(
                                vroom(anchorpointout_file,
                                      col_names=TRUE,
                                      delim="\t")
                            )

                            genes <- suppressMessages(
                                vroom(
                                    genesFile,
                                    delim="\t",
                                    col_names=TRUE
                                )
                            )
                            gene_num_df <- aggregate(remapped_coordinate ~ genome + list, genes, max)
                            colnames(gene_num_df) <- c("sp", "seqchr", "num")
                            gene_num_df$gene_num <- gene_num_df$num + 1

                            query_chr_num_df <- gene_num_df %>%
                                filter(sp==gsub(" ", "_", querySpecies)) %>%
                                filter(seqchr %in% query_selected_chr_list)

                            anchoredPointScutoff <- paste0("anchoredPointsCutoff_", renew_x)

                            selected_multiplicons <- final_multiplicons %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% query_selected_chr_list) %>%
                                filter(num_anchorpoints >= input[[anchoredPointScutoff]])
                            selected_multiplicons_Id <- selected_multiplicons$multiplicon

                            chr_num_df <- chr_num_len_df$num_df

                            # source(file="tools/computeAnchorPointDepth.R", local=T, encoding="UTF-8")
                            depth_list <- computing_depth_paranome(
                                anchorpoint_ks_file=anchorpointout_file,
                                multiplicon_id=selected_multiplicons_Id,
                                selected_query_chr=query_selected_chr_list
                            )
                            query_selected_depth_list <- depth_list$depth
                            subject_selected_depth_list <- depth_list$depth

                            selected_anchorpoints <- final_anchorpoints %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% query_selected_chr_list) %>%
                                filter(multiplicon %in% selected_multiplicons_Id)

                            plotSize <- reactiveValues(
                                value=400
                            )
                            observeEvent(input[[paste0("svg_spacing_add_dot_", renew_x)]], {
                                plotSize$value <- plotSize$value + 50
                            })
                            observeEvent(input[[paste0("svg_spacing_sub_dot_", renew_x)]], {
                                plotSize$value <- plotSize$value - 50
                            })
                            Sys.sleep(.2)
                            incProgress(amount=.3, message="Drawing Dot Plot...")

                            observe({
                                plot_dot_num_data <- list(
                                    "plot_id"=x,
                                    "multiplicons"=selected_multiplicons,
                                    "anchorpoints"=selected_anchorpoints,
                                    "query_sp"=querySpecies,
                                    "query_chr_gene_nums"=query_chr_num_df,
                                    "query_depths"=query_selected_depth_list,
                                    "subject_sp"=subjectSpecies,
                                    "subject_chr_gene_nums"=query_chr_num_df,
                                    "subject_depths"=subject_selected_depth_list,
                                    "size"=plotSize$value
                                )
                                session$sendCustomMessage("Dot_Num_Plotting_paranome", plot_dot_num_data)
                            })
                            Sys.sleep(.2)
                            incProgress(amount=1, message="Drawing Dot Plot Done")
                        })
                        # plot parallel figure
                        withProgress(message='Parallel Syntenty Figure in progress', value=0, {
                            Sys.sleep(.2)
                            incProgress(amount=.3, message="Drawing Parallel Syntenty Plot...")
                            segmentsfile <- paste0(iadhoreDir, "/segments.txt")
                            segs_pos_file <- paste0(iadhoreDir, "/segments.merged_pos.txt")
                            if( !file.exists(segs_pos_file) ){
                                # source("tools/obtain_coordinates_for_segments.v2.R", local=T, encoding="UTF-8")
                                obtain_coordiantes_for_segments(
                                    seg_file=segmentsfile,
                                    gff_file1=sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath,
                                    out_file=segs_pos_file
                                )
                            }
                            segs_data <- suppressMessages(
                                vroom(
                                    segs_pos_file,
                                    delim="\t"
                                )
                            )
                            selected_segs_data <- segs_data %>%
                                filter(listX %in% query_selected_chr_list) %>%
                                filter(listY %in% query_selected_chr_list) %>%
                                filter(multiplicon %in% selected_multiplicons_Id)

                            widthSpacingRainbow <- reactiveValues(
                                value=800
                            )
                            heightSpacingRainbow <- reactiveValues(
                                value=300
                            )
                            observeEvent(input[[paste0("svg_vertical_spacing_add_rainbow_", x)]], {
                                heightSpacingRainbow$value <- heightSpacingRainbow$value + 20
                            })
                            observeEvent(input[[paste0("svg_vertical_spacing_sub_rainbow_", x)]], {
                                heightSpacingRainbow$value <- heightSpacingRainbow$value - 20
                            })
                            observeEvent(input[[paste0("svg_horizontal_spacing_add_rainbow_", x)]], {
                                widthSpacingRainbow$value <- widthSpacingRainbow$value + 20
                            })
                            observeEvent(input[[paste0("svg_horizontal_spacing_sub_rainbow_", x)]], {
                                widthSpacingRainbow$value <- widthSpacingRainbow$value - 20
                            })
                            observe({
                                plot_parallel_data <- list(
                                    "plot_id"=x,
                                    "segs"=selected_segs_data,
                                    "query_sp"=querySpecies,
                                    "query_chr_lens"=query_chr_len_df,
                                    "subject_sp"=subjectSpecies,
                                    "subject_chr_lens"=subject_chr_len_df,
                                    "width"=widthSpacingRainbow$value,
                                    "height"=heightSpacingRainbow$value
                                )
                                session$sendCustomMessage("Parallel_Plotting", plot_parallel_data)
                            })

                            Sys.sleep(.3)
                            incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
                        })
                    })
                    observeEvent(input[[paste0("searchButton_", x)]], {
                        iadhoreDir <- dirname(each_row$comparing_Path)
                        anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                        final_anchorpoints <- suppressMessages(
                            vroom(anchorpointout_file,
                                  col_names=TRUE,
                                  delim="\t")
                        )

                        searchGene <- input[[paste0("gene_", x)]]
                        searchMultiplicon <- final_anchorpoints[final_anchorpoints$geneX == searchGene | final_anchorpoints$geneY == searchGene, "multiplicon"]
                        if( searchGene %in% final_anchorpoints$geneX || searchGene %in% final_anchorpoints$geneY ){
                            withProgress(message='Searching Gene in progress', value=0, {
                                Sys.sleep(.8)
                                search_data <- list(
                                    "plot_id"=x,
                                    "geneId"=searchMultiplicon
                                )
                                session$sendCustomMessage("searchGene", search_data)
                                messageContent <- input[[paste0("foundItemsMessage_", x)]]
                                uiId <- paste0("foundItemsMessage_", x)
                                output[[uiId]] <- renderUI({
                                    if( !is.null(input[[paste0("foundMultiplicons_", x)]]) ){
                                        updatePickerInput(
                                            session,
                                            paste0("multiplicon_plot_", x),
                                            choices=input[[paste0("foundMultiplicons_", x)]],
                                            choicesOpt=list(
                                                content=lapply(input[[paste0("foundMultiplicons_", x)]], function(choice) {
                                                    HTML(paste0("<div style='color: orange; font-style: italic;'>Multiplicon: ", choice, "</div>"))
                                                })
                                            ),
                                        )
                                    }
                                    message <- paste("<div style='border: 1px solid #ccc; padding: 2px; margin-top: 20px; margin-left: -40px; border-radius: 10px; background-color: white; font-family: Times New Roman, Times, serif; white-space: pre-wrap;'>", input[[paste0("foundItemsMessage_", x)]], "</div>")
                                    HTML(message)
                                })
                                Sys.sleep(.9)
                                incProgress(amount=1, message="Searching Done")
                            })
                        }else{
                            shinyalert(
                                "Warning!",
                                "Please input the correct gene name ...",
                                type="warning",
                            )
                        }
                    })
                    observeEvent(input[[paste0("plotMicro_", x)]], {
                        withProgress(message='Drawing Micro Synteny in progress', value=0, {
                            Sys.sleep(.5)

                            if( is.null(input[[paste0("multiplicon_plot_", x)]]) ){
                                shinyalert(
                                    "Warning!",
                                    "No Multiplicon found! Please search the target gene or select multiplcon to plot first...",
                                    type="warning"
                                )
                            }
                            else{
                                iadhoreDir <- dirname(each_row$comparing_Path)
                                anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.txt")
                                final_anchorpoints <- suppressMessages(
                                    vroom(anchorpointout_file,
                                          col_names=TRUE,
                                          delim="\t")
                                )

                                renew_x <- x
                                query_chr_Input <- paste0("synteny_query_chr_", renew_x)
                                query_selected_chr_list <- input[[query_chr_Input]]

                                subject_selected_chr_list <- query_selected_chr_list

                                gff_file1 <- sp_gff_info_df[sp_gff_info_df$species==querySpecies, ]$gffPath
                                gff_df1 <- suppressMessages(
                                    vroom(gff_file1,
                                          delim="\t",
                                          comment="#",
                                          col_names=FALSE)
                                )
                                position_df1 <- gff_df1 %>%
                                    filter(gff_df1$X3=="mRNA") %>%
                                    select(X1, X9, X4, X5, X7) %>%
                                    mutate(X9=gsub("ID=([^;]+).*", "\\1", X9)) %>%
                                    filter(X1 %in% query_selected_chr_list)
                                colnames(position_df1) <- c("seqchr", "gene", "start", "end", "strand")

                                position_df2 <- position_df1
                                selectedQueryGenes <- data.frame()
                                selectedSubjectGenes <- data.frame()
                                selectedAnchorPoints <- data.frame()
                                chrListX <- data.frame()
                                chrListY <- data.frame()
                                for( multiplicon in input[[paste0("multiplicon_plot_", x)]] ){
                                    selectedAnchorPointsT <- final_anchorpoints[final_anchorpoints$multiplicon==multiplicon, ]
                                    selectedAnchorPoints <- rbind(selectedAnchorPoints, selectedAnchorPointsT)
                                    # print(selectedAnchorPoints)
                                    cutoffX <- selectedAnchorPoints %>%
                                        group_by(listX) %>%
                                        summarize(min=min(startX),
                                                  max=max(endX))
                                    cutoffX[["multiplicon"]] <- multiplicon
                                    chrListX <- rbind(chrListX, cutoffX)

                                    selectedQueryGenesT <- position_df1 %>%
                                        inner_join(cutoffX, by=c("seqchr"="listX")) %>%
                                        filter(start >= min, end <= max) %>%
                                        mutate(start=start - min,
                                               end=end - min)
                                    selectedQueryGenesT[["multiplicon"]] <- multiplicon
                                    selectedQueryGenes <- rbind(selectedQueryGenes, selectedQueryGenesT)

                                    cutoffY <- selectedAnchorPoints %>%
                                        group_by(listY) %>%
                                        summarize(min=min(startY),
                                                  max=max(endY))
                                    cutoffY[["multiplicon"]] <- multiplicon
                                    chrListY <- rbind(chrListY, cutoffY)

                                    selectedSubjectGenesT <- position_df2 %>%
                                        inner_join(cutoffY, by=c("seqchr"="listY")) %>%
                                        filter(start >= min, end <= max) %>%
                                        mutate(start=start - min,
                                               end=end - min)
                                    selectedSubjectGenesT[["multiplicon"]] <- multiplicon
                                    selectedSubjectGenes <- rbind(selectedSubjectGenes, selectedSubjectGenesT)
                                }
                                widthSpacingMicro <- reactiveValues(
                                    value=800
                                )
                                heightSpacingMicro <- reactiveValues(
                                    value=200
                                )
                                observeEvent(input[[paste0("svg_vertical_spacing_add_micro_", x)]], {
                                    heightSpacingMicro$value <- heightSpacingMicro$value + 20
                                })
                                observeEvent(input[[paste0("svg_vertical_spacing_sub_micro_", x)]], {
                                    heightSpacingMicro$value <- heightSpacingMicro$value - 20
                                })
                                observeEvent(input[[paste0("svg_horizontal_spacing_add_micro_", x)]], {
                                    widthSpacingMicro$value <- widthSpacingMicro$value + 20

                                })
                                observeEvent(input[[paste0("svg_horizontal_spacing_sub_micro_", x)]], {
                                    widthSpacingMicro$value <- widthSpacingMicro$value - 20
                                })

                                observe({
                                    microSynPlotData <- list(
                                        "plot_id"=renew_x,
                                        #"multiplicon"=multiplicon[1],
                                        "anchorpoints"=selectedAnchorPoints,
                                        "query_sp"=querySpecies,
                                        "query_chr_info"=chrListX,
                                        "query_chr_genes"=selectedQueryGenes,
                                        "subject_sp"=subjectSpecies,
                                        "subject_chr_info"=chrListY,
                                        "subject_chr_genes"=selectedSubjectGenes,
                                        "targe_gene"=input[[paste0("gene_", x)]],
                                        "width"=widthSpacingMicro$value,
                                        "height"=heightSpacingMicro$value
                                    )
                                    session$sendCustomMessage("microSynPlotting", microSynPlotData)
                                })
                            }
                            Sys.sleep(.9)
                            incProgress(amount=1, message="Drawing Micro Synteny Done")
                        })
                    })
                }
            })
        }
        incProgress(amount=1, message="Configuration Done")
        Sys.sleep(.4)
    })
})

observeEvent(input[["synplot_go_last"]], {
    withProgress(message='Analyzing Multiple Species Alignment in progress...', value=0, {
        Sys.sleep(.2)
        incProgress(amount=.3, message="Computing Multiple Species Alignment...")

        # display multiple species alignment
        order_list <- input[["order_of_display"]]
        if( is.null(order_list) ){
            shinyalert(
                "Oops!",
                "Please set the order of species first...",
                type="error"
            )
        }
        else{
            dirPath <- parseDirPath(roots=c(computer="/"), input$iadhoredir)
            load(paste0(dirPath, "/tmp.comparing.RData"))
            multiple_species_df <- path_df[path_df$comparing_ID == "Multiple", ]

            sp_gff_info_xls <- paste0(
                dirname(dirname(dirname(file.path(multiple_species_df$comparing_Path)))),
                "/Species.info.xls"
            )
            sp_gff_info_df <- suppressMessages(
                vroom(sp_gff_info_xls,
                      col_names=c("species", "cdsPath", "gffPath"),
                      delim="\t")
            ) %>%
                filter(species %in% gsub("_", " ", input$iadhore_multiple_species_list))
            cds_files <- gsub(".*/", "", sp_gff_info_df$cdsPath)
            gff_files <- gsub(".*/", "", sp_gff_info_df$gffPath)
            new_cds_files <- paste0(dirname(sp_gff_info_xls), "/", cds_files)
            new_gff_files <- paste0(dirname(sp_gff_info_xls), "/", gff_files)
            sp_gff_info_df$cdsPath <- new_cds_files
            sp_gff_info_df$gffPath <- new_gff_files
            # source(file="tools/obtain_chromosome_length.R", local=T, encoding="UTF-8")
            #print(sp_gff_info_df)
            chr_num_len_df <- obtain_chromosome_length_filter(
                sp_gff_info_df
            )

            multiplicon_file <- paste0(dirname(multiple_species_df$comparing_Path), "/multiplicons.txt")
            multiplicon_df <- suppressMessages(
                vroom(
                    multiplicon_file,
                    col_names=TRUE,
                    delim="\t"
                )
            ) %>%
                filter(genome_x != genome_y) %>%
                filter(number_of_anchorpoints >= input[["anchoredPointsCutoff_multiple"]])

            segments_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.txt")
            segs_df <- suppressMessages(
                vroom(
                    segments_file,
                    col_names=TRUE,
                    delim="\t"
                )
            )

            selected_multiplicon_df1 <- data.frame()
            selected_segs_df <- data.frame()
            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]

                filtered_df <- segs_df %>%
                    filter(genome == species) %>%
                    filter(list %in% selected_chrs)
                selected_segs_df <- rbind(selected_segs_df, filtered_df)

                filtered_df1 <- multiplicon_df %>%
                    filter(genome_x == species) %>%
                    filter(list_x %in% selected_chrs)
                selected_multiplicon_df1 <- rbind(selected_multiplicon_df1, filtered_df1)
            }
            selected_multiplicon_df <- data.frame()
            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]
                filtered_df <- selected_multiplicon_df1 %>%
                    filter(genome_y == species) %>%
                    filter(list_y %in% selected_chrs)
                selected_multiplicon_df <- rbind(selected_multiplicon_df, filtered_df)
            }
            selected_multiplicons <- selected_multiplicon_df %>% select(id)

            selected_segs_df <- selected_segs_df %>%
                filter(multiplicon %in% selected_multiplicons$id)

            rm(selected_multiplicon_df1, segs_df, multiplicon_df)

            for( species in input$iadhore_multiple_species_list ){
                selected_chrs <- input[[paste0("multiple_synteny_query_chr_", species)]]
                if( is.null(selected_chrs) ){
                    shinyalert(
                        "Oops!",
                        paste0("Please select the chromosome of ", species, " first..."),
                        type="error"
                    )
                }
            }

            segments_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.txt")
            segs_pos_file <- paste0(dirname(multiple_species_df$comparing_Path), "/segments.merged_pos.txt")
            # source("tools/obtain_coordinates_for_segments.multiple_species.R", local=T, encoding="UTF-8")
            obtain_coordinates_for_segments_multiple(
                seg_df=selected_segs_df,
                gff_df=sp_gff_info_df,
                input=input,
                out_file=segs_pos_file
            )

            segs_pos_df <- suppressMessages(
                vroom(
                    segs_pos_file,
                    delim="\t",
                    col_names=TRUE
                )
            )

            chr_len_df <- chr_num_len_df$len_df

            selected_chr_len_data <- data.frame()
            selected_chr_order_data <- data.frame()
            selected_segs_data <- data.frame()
            for( i in 1:(length(order_list) - 1) ){
                incProgress(
                    amount=0.5/length(order_list),
                    message=paste0(
                        "Computing synteny between ",
                        gsub("_", " ", order_list[[i]]),
                        " and ",
                        gsub("_", " ", order_list[[i+1]]),
                        "..."
                    )
                )

                order_list[[i]]=gsub(" ", "_", order_list[[i]]);
                order_list[[i+1]]=gsub(" ", "_", order_list[[i+1]])
                query_info <- paste0("multiple_synteny_query_chr_", order_list[[i]])
                subject_info <- paste0("multiple_synteny_query_chr_", order_list[[i+1]])
                query_selected_chr_list <- input[[query_info]]
                query_chr_len_df <- chr_len_df[chr_len_df$sp==gsub("_", " ", order_list[[i]]), ] %>%
                    filter(seqchr %in% query_selected_chr_list)
                subject_selected_chr_list <- input[[subject_info]]
                subject_chr_len_df <- chr_len_df[chr_len_df$sp==sub("_", " ", order_list[[i+1]]), ] %>%
                    filter(seqchr %in% subject_selected_chr_list)

                selected_chr_len_data <- rbind(selected_chr_len_data, query_chr_len_df)
                selected_chr_len_data <- rbind(selected_chr_len_data, subject_chr_len_df)
                tmp_query_chr_order <- data.frame(
                    "species"=order_list[[i]],
                    "chrOrder"=paste0(query_selected_chr_list, collapse=",")
                )
                tmp_subject_chr_order <- data.frame(
                    "species"=order_list[[i+1]],
                    "chrOrder"=paste0(subject_selected_chr_list, collapse=",")
                )
                selected_chr_order_data <- rbind(selected_chr_order_data, tmp_query_chr_order)
                selected_chr_order_data <- rbind(selected_chr_order_data, tmp_subject_chr_order)
                # deal segments data
                selected_segs <- segs_pos_df %>%
                    filter((genomeX == order_list[[i]] & genomeY == order_list[[i+1]])
                           | (genomeX == order_list[[i+1]] & genomeY == order_list[[i]]))

                selected_segs_re <- data.frame()
                if( length(unique(selected_segs$genomeX)) == 2 ){
                    for( i in 1:nrow(selected_segs) ){
                        each_row <- selected_segs[i, ]
                        if( each_row$genomeX != order_list[[i+1]] ){
                            tmp <- each_row[2:8]
                            each_row[2:8] <- each_row[9:15]
                            each_row[9:15] <- tmp
                        }
                        selected_segs_re <- rbind(selected_segs_re, each_row)
                    }
                    selected_segs_data <- rbind(selected_segs_data, selected_segs_re)
                }
                else{
                    selected_segs_data <- rbind(selected_segs_data, selected_segs)
                }
            }

            Sys.sleep(.2)
            incProgress(amount=.6, message="Computing Done")

            Sys.sleep(.2)
            incProgress(amount=.8, message="Drawing Parallel Syntenty Plot for Multiple Species Alignment...")
            selected_chr_len_data <- selected_chr_len_data[!duplicated(selected_chr_len_data), ]
            selected_chr_order_data <- selected_chr_order_data[!duplicated(selected_chr_order_data), ]

            widthSpacingMultiple <- reactiveValues(
                value=800
            )
            heightSpacingMultiple <- reactiveValues(
                value=100 * nrow(sp_gff_info_df)
            )
            observeEvent(input[["svg_vertical_spacing_add_multiple"]], {
                heightSpacingMultiple$value <- heightSpacingMultiple$value + 20
            })
            observeEvent(input[["svg_vertical_spacing_sub_multiple"]], {
                heightSpacingMultiple$value <- heightSpacingMultiple$value - 20
            })
            observeEvent(input[["svg_horizontal_spacing_add_multiple"]], {
                widthSpacingMultiple$value <- widthSpacingMultiple$value + 20
            })
            observeEvent(input[["svg_horizontal_spacing_sub_multiple"]], {
                widthSpacingMultiple$value <- widthSpacingMultiple$value - 20
            })

            observe({
                plot_parallel_multiple_data <- list(
                    "plot_id"="multiple",
                    "segs"=selected_segs_data,
                    "sp_order"=order_list,
                    "chr_order"=selected_chr_order_data,
                    "overlap_cutoff"=input[["overlapCutoff_multiple"]],
                    "chr_lens"=selected_chr_len_data,
                    "width"=widthSpacingMultiple$value,
                    "height"=heightSpacingMultiple$value
                )
                session$sendCustomMessage("Parallel_Multiple_Plotting", plot_parallel_multiple_data)
            })
        }
        Sys.sleep(.3)
        incProgress(amount=1, message="Drawing Parallel Syntenty Plot Done")
    })
})

observeEvent(input$cluster_go, {
    withProgress(message='Clustering Analysis in progress...', value=0, {
        Sys.sleep(.2)
        incProgress(amount=.1, message="Preparing data...")
        dirPath <- parseDirPath(roots=c(computer="/"), input$iadhoredir)
        load(paste0(dirPath, "/tmp.comparing.RData"))

        cluster_species_A <- input$cluster_species_A
        cluster_species_B <- input$cluster_species_B
        pattern1 <- paste0(cluster_species_A, "_vs_", cluster_species_B)
        pattern2 <- paste0(cluster_species_B, "_vs_", cluster_species_A)
        cluster_selected_df <- path_df[(path_df$comparing_ID %in% pattern1) | (path_df$comparing_ID %in% pattern2), ]

        sp_list_tmp <- unique(strsplit(cluster_selected_df$comparing_ID, split="_vs_")[[1]])
        querySpecies <- gsub("_", " ", sp_list_tmp[1])
        subjectSpecies <- gsub("_", " ", sp_list_tmp[2])

        iadhoreDir <- dirname(cluster_selected_df$comparing_Path)
        anchorpointFile <- paste0(iadhoreDir, "/anchorpoints.txt")
        ksFile <- paste0(iadhoreDir, "/anchorpoints.ks.txt")
        genesFile <- paste0(iadhoreDir, "/genes.txt")
        multiplicon_file <- paste0(iadhoreDir, "/multiplicons.txt")
        anchorpoint_merged_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos.cluster.txt")
        anchorpointout_file <- paste0(iadhoreDir, "/anchorpoints.merged_pos_ks.cluster.txt")

        if( file.exists(ksFile) ){
            if( !file.exists(anchorpointout_file) ){
                Sys.sleep(.2)
                incProgress(amount=.1, message="Mapping data...")
                # source(file="tools/obtain_coordinates_for_anchorpoints_ks.R", local=T, encoding="UTF-8")
                obtain_coordiantes_for_anchorpoints_ks(
                    anchorpoints=anchorpointFile,
                    anchorpoints_ks=ksFile,
                    genes_file=genesFile,
                    out_file=anchorpoint_merged_file,
                    out_ks_file=anchorpointout_file,
                    species=gsub(" ", "_", querySpecies)
                )
            }
        }
        else{
            shinyalert(
                "Opps!",
                paste0("Fail to access the ", ks_file, "! Please run i-ADHoRe mode of ShinyWGD first ..."),
                type="error",
            )
        }

        clusteringDir <- paste0(iadhoreDir, "/clusteringDir")
        if( !(dir.exists(clusteringDir)) ){
            dir.create(clusteringDir)
        }

        cutoffPoints <- input$interactPointsCutoff

        segmented_file <- paste0(clusteringDir, "/segmented.chr.", cutoffPoints, ".txt")
        segmented_anchopoints_file <- paste0(clusteringDir, "/segmented.anchorpoints.", cutoffPoints, ".txt")

        if( !(file.exists(segmented_anchopoints_file)) ){
            Sys.sleep(.2)
            incProgress(amount=.2, message="Segmenting...")
            # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
            get_segments(
                genes_file=genesFile,
                anchors_ks_file=anchorpointout_file,
                multiplicons_file=multiplicon_file,
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                num_anchors=cutoffPoints
            )
            Sys.sleep(.2)
            incProgress(amount=.1, message="Segmenting Done")
        }

        cluster_info_file <- paste0(clusteringDir, "/Clustering_info.", cutoffPoints, ".RData")
        if( !file.exists(cluster_info_file) ){
            Sys.sleep(.2)
            incProgress(amount=.1, message="Clustering...")
            # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
            cluster_synteny(
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                genes_file=genesFile,
                out_file=cluster_info_file
            )
            Sys.sleep(.2)
            incProgress(amount=.2, message="Clustering Done")
        }
        load(cluster_info_file)

        hcheightCutoff <- input$corRCutoff
        identified_cluster_file <- paste0(clusteringDir, "/Identified_Clusters.Num_", cutoffPoints, ".Hc_", hcheightCutoff, ".RData")
        # source(file="tools/clustering_synteny.R", local=TRUE, encoding="UTF-8")
        if( !(file.exists(identified_cluster_file)) ){
            Sys.sleep(.2)
            incProgress(amount=.2, message="Identifying Clusters...")
            analysisEachCluster(
                segmented_file=segmented_file,
                segmented_anchorpoints_file=segmented_anchopoints_file,
                genes_file=genesFile,
                cluster_info_file=cluster_info_file,
                identified_cluster_file=identified_cluster_file,
                hcheight=hcheightCutoff
            )
        }
        load(identified_cluster_file)

        subject_chr_order <- cluster_info[[1]]$order
        query_chr_order <- cluster_info[[2]]$order
        subject_chr_labels <- cluster_info[[1]]$labels[subject_chr_order]
        query_chr_lables <- cluster_info[[2]]$labels[query_chr_order]

        Sys.sleep(.2)
        incProgress(amount=.8, message="Plotting")

        plotSize <- reactiveValues(
            value=600
        )
        observeEvent(input[["svg_spacing_add_cluster"]], {
            plotSize$value <- plotSize$value + 50
        })
        observeEvent(input[["svg_spacing_sub_cluster"]], {
            plotSize$value <- plotSize$value - 50
        })
        observe({
            segmented_chr <- read.table(
                segmented_file,
                header=TRUE,
                sep="\t"
            )
            segmented_anchopoints <- read.table(
                segmented_anchopoints_file,
                header=TRUE,
                sep="\t"
            )
            PARs_info <- c()
            if( length(identified_cluster_list) > 0 ){
                for( i in 1:length(identified_cluster_list) ){
                    each_PAR <- identified_cluster_list[[i]]$cluster_chr
                    each_PAR[["par_id"]] <- paste0("PAR ", identified_cluster_list[[i]]$par_id)
                    PARs_info <- c(PARs_info, each_PAR)
                }
            }

            if( is.null(PARs_info) ){
                shinyalert(
                    "Opps!",
                    "Fail to identify the significant PAR regions ...",
                    type="error",
                )
            }

            tree_bycol <- readLines(
                gsub(".RData", ".bycol.newick", cluster_info_file)
            )
            tree_byrow <- readLines(
                gsub(".RData", ".byrow.newick", cluster_info_file)
            )

            plot_cluster_synteny_data <- list(
                "plot_id"="clusterView",
                "segmented_chr"=segmented_chr,
                "segmented_anchorpoints"=segmented_anchopoints,
                "query_chr_order"=query_chr_order,
                "subject_chr_order"=subject_chr_order,
                "query_sp"=querySpecies,
                "subject_sp"=subjectSpecies,
                "size"=plotSize$value,
                "pars"=PARs_info,
                "tree_bycol"=tree_bycol,
                "tree_byrow"=tree_byrow,
                "r_cutoff"=hcheightCutoff
            )
            session$sendCustomMessage("Cluster_Synteny_Plotting", plot_cluster_synteny_data)

            PARs_list <- c()
            if( length(identified_cluster_list) > 0 ){
                for( i in 1:length(identified_cluster_list) ){
                    PAR_id <- paste0("PAR ", identified_cluster_list[[i]]$par_id)
                    each_PAR <- identified_cluster_list[[i]]
                    each_PAR[["par_id"]] <- PAR_id
                    PARs_list <- c(PARs_list, PAR_id)
                }
                updatePickerInput(
                    session,
                    "pars_list",
                    choices=PARs_list,
                    choicesOpt=list(
                        content=lapply(PARs_list, function(choice) {
                            HTML(paste0("<div style='color: green;'>", choice, "</div>"))
                        })
                    )
                )
            }
        })

        observeEvent(input$zoomInPAR, {
            withProgress(message='Clustering Analysis in progress...', value=0, {
                Sys.sleep(.2)
                incProgress(amount=.8, message="Zoom in ...")

                plotSize <- reactiveValues(
                    value=400
                )
                observeEvent(input[["svg_vertical_spacing_add_par"]], {
                    plotSize$value <- plotSize$value + 50
                })
                observeEvent(input[["svg_vertical_spacing_sub_par"]], {
                    plotSize$value <- plotSize$value - 50
                })
                observe({
                    if( length(identified_cluster_list) > 0 ){
                        for( i in 1:length(identified_cluster_list) ){
                            PAR_id <- paste0("PAR ", i)
                            each_PAR <- identified_cluster_list[[i]]

                            if( PAR_id == input$pars_list ){
                                plot_zoom_in_data <- list(
                                    "plot_id"="ParZoomIn",
                                    "par_id"=PAR_id,
                                    "segmented_chr"=each_PAR$cluster_chr,
                                    "segmented_anchorpoints"=each_PAR$cluster_anchorpoints,
                                    "query_chr_labels"=query_chr_lables,
                                    "subject_chr_labels"=subject_chr_labels,
                                    "query_sp"=querySpecies,
                                    "subject_sp"=subjectSpecies,
                                    "size"=plotSize$value
                                )
                                session$sendCustomMessage("Cluster_Zoom_In_Plotting", plot_zoom_in_data)
                            }
                        }
                    }
                })
            })
        })
        Sys.sleep(.3)
        incProgress(amount=1, message="Done")
    })
})





