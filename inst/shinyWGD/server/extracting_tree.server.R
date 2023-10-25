output$ObtainTreeFromTimeTreeSettingDisplay <- renderUI({
    div(class="boxLike",
        style="background-color: #F5FFE8;",
        fluidRow(
            column(
                12,
                h4(
                    icon("tree", style="color: #64A600;"),
                    HTML("<font color='#64A600'>Extracting Tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a></font>")
                )
            )
        ),
        hr(class="setting"),
        fluidRow(
            div(
                style="padding-left: 20px;",
                column(
                    12,
                    h6(
                        HTML(
                            "If you don’t ensure the evolutionary relationships among the studied species,
        <br>Click the button below to obtain a tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a>."
                        )
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
                actionButton(
                    inputId="extract_tree_go",
                    "Extract Tree",
                    width="200px",
                    icon=icon("tree"),
                    status="secondary",
                    style="color: #fff;
                              background-color: #019858;
                              border-color: #fff;
                              padding: 5px 14px 5px 14px;
                              margin: 5px 5px 5px 5px;
                              animation: glowing 5300ms infinite;"
                    # )
                ),
                fluidRow(
                    column(
                        12,
                        HTML(paste0("<br>The Newick Tree Extracted from TimeTree.org:")),
                        div(
                            style="width: 500px;",
                            verbatimTextOutput(
                                "TimetreeNewick",
                                placeholder=TRUE
                            )
                        )
                    )
                ),
                h6(
                    HTML("<font color='red'><b>Note</b></font> TimeTree database does not include all the species.
             <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the species are not included in the TimeTree database,
             <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;you should ensure the relationship in other ways.")
                )
            )
        )
    )
})

observeEvent(input$extract_tree_go, {
    analysis_dir <- paste0(tempdir(), "/Analysis_", Sys.Date())
    if( !file.exists(analysis_dir) ){
        dir.create(paste0(tempdir(), "/Analysis_", Sys.Date()))
    }
    species_names_file <- paste0(analysis_dir, "/species_names_list.xls")
    from_file <- get_species_from_file()
    from_input <- get_species_from_input()

    if( length(from_file) > 0 | length(from_input[nzchar(from_input)]) > 0 ){
        if( length(from_file) > 0 ){
            writeLines(get_species_from_file(), species_names_file)
        }else{
            writeLines(get_species_from_input(), species_names_file)
        }
        species_name_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/species_names_list.xls")
        timetree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/timetree.newick")
        newick_tree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/species_tree.newick")
        withProgress(message='Extracting in progress', value=0, {
            system(
                paste(
                    "Rscript tools/obtain_newick_tree_from_timetree.R ",
                    species_name_file,
                    timetree_file,
                    newick_tree_file
                )
            )
            if( file.exists(newick_tree_file) ){
                output$TimetreeNewick <- renderText({
                    CommandText <- readChar(newick_tree_file, file.info(newick_tree_file)$size)
                })
            }else{
                shinyalert(
                    "Oops",
                    "Fail to extract tree from Timetree.org. Please try other ways!",
                    type="error"
                )
            }
            incProgress(amount=1)
        })
    }
    else{
        shinyalert(
            "Oops",
            "Please upload data first, then switch on this",
            type="error"
        )
    }
})

widthSpacing <- reactiveValues(value=500)
heightSpacing <- reactiveValues(value=NULL)

observe({
    timetree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/timetree.newick")
    if( file.exists(timetree_file) ){
        speciesTree <- readLines(textConnection(readChar(timetree_file, file.info(timetree_file)$size)))
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
    timetree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/timetree.newick")
    if( file.exists(timetree_file) ){
        species_tree_data <- list(
            "width"=widthSpacing$value
        )
        speciesTree <- readLines(textConnection(readChar(timetree_file, file.info(timetree_file)$size)))
        closeAllConnections()

        species_tree_data[["speciesTree"]] <- speciesTree

        species_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("speciesTreePlot", species_tree_data)
    }
})

observe({
    timetree_file <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/timetree.newick")
    if( file.exists(timetree_file) ){
        output$timeTreeOrgPlot <- renderUI({
            div(class="boxLike",
                style="background-color: #F5FFE8;",
                fluidRow(
                    column(
                        12,
                        HTML("<font color='#64A600'>Time Tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a></font>"),
                        div(
                            id="timeTree_plot",
                        )
                    )
                )
            )
        })
    }
})
