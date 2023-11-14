output$whaleDataUploadPanel <- renderUI({
    fluidRow(
        div(class="boxLike",
            style="background-color: #FAF9F6;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
            column(
                12,
                h4(icon("upload"), "Uploading"),
                hr(class="setting"),
                HTML("Uploading the Analysis Directory:</br>"),
                fluidRow(
                    column(12, shinyDirButton("analysisDir", "Select a Folder", "Upload")),
                    column(12, uiOutput("selectedWhaleDirName"))
                )
            ),
            column(
                12,
                hr(class="setting"),
                fileInput(
                    inputId="uploadSpeciesTimeTree",
                    label=HTML("<font color='green'><b>Species Time Tree</b></font> in <font color='red'><b><i>Newick</b></i></font> format:")
                ),

            ),
            column(
                12,
                hr(class="setting"),
                h6(
                    HTML(
                        "If you don’t ensure the evolutionary relationships among the studied species, please use the ",
                    )
                ),
                actionLink(
                    "go_extracting_tree",
                    HTML(
                        paste0(
                            "<i class='fas fa-tree' style='color: #5151A2;'>&nbsp;</i>",
                            "<font color='#5151A2'>",
                            "<i><b>Tree Extraction</b></i></font>"
                        )
                    )
                ),
                h6(
                    HTML(
                        "module of shinyWGD to obtain a tree from <a href=\"http://www.timetree.org/\">TimeTree.org</a>."
                    )
                )
            )
        )
    )
})

observeEvent(input$go_extracting_tree, {
    updateNavbarPage(inputId="shinywgd", selected="extracting_tree")
    shinyjs::runjs(
        'setTimeout(function () {
            document.querySelector("#ObtainTreeFromTimeTreeSettingDisplay").scrollIntoView({
                behavior: "smooth",
                block: "start",
            });
        }, 100);
    ')
})

shinyDirChoose(input, "analysisDir", roots=c(computer="/"))
observeEvent(input$analysisDir, {
    output$selectedAnalysisDir <- renderText({
        if( !is.null(input$analysisDir) ){
             parseDirPath(roots=c(computer="/"), input$analysisDir)
        }
    })
})

observe({
    analysisDir <- parseDirPath(roots=c(computer="/"), input$analysisDir)
    if( length(analysisDir) > 0 ){
        dirName <- basename(analysisDir)
        output$selectedWhaleDirName <- renderUI({
            column(
                12,
                div(
                    style="background-color: #FAF0E6;
                           margin-top: 5px;
                           padding: 10px 10px 1px 10px;
                           border-radius: 10px;
                           text-align: center;",
                    HTML(paste("Selected Directory:<br><b><font color='#EE82EE'>", dirName, "</font></b>"))
                )
            )
        })
        orthoFinderOutputDir <- paste0(analysisDir, "/OrthoFinder_wd/", "orthofinderOutputDir")
        if( !dir.exists(orthoFinderOutputDir) ){
            shinyalert(
                "Oops",
                "No OrthoFinder output found. Please run the script to get the result of OrthoFinder, then switch this on",
                type="error"
            )
        }
    }
})

speciesTimeTreeRv <- reactiveValues(data=NULL, clear=FALSE)

observeEvent(input$uploadSpeciesTimeTree, {
    speciesTimeTreeRv$clear <- FALSE
}, priority=1000)

widthSpacing <- reactiveValues(value=500)
heightSpacing <- reactiveValues(value=NULL)

observe({
    if( isTruthy(input$uploadSpeciesTimeTree) ){
        speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
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
    if( isTruthy(input$uploadSpeciesTimeTree) ){
        species_tree_data <- list(
            "width"=widthSpacing$value
        )
        speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
        speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
        closeAllConnections()

        species_tree_data[["speciesTree"]] <- speciesTree

        species_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("speciesTreePlot", species_tree_data)
    }
})

observe({
    analysisDir <- parseDirPath(roots=c(computer="/"), input$analysisDir)
    if( length(analysisDir) > 0 ){
        wgdNum <- toupper(as.english(length(input$wgdInput)))
        if( length(input$wgdInput) > 0 ){
            note <- HTML(paste0("<font color='#AD1F1F'><b>", wgdNum, "</b></font> WGD events will be examinated."))
        }else{
            note <- HTML(paste0("<font color='#C0C0C0'><b>", wgdNum, "</b></font> WGD event will be examinated."))
        }

        output$whaleCommandPanel <- renderUI({
            fluidRow(
                div(class="boxLike",
                    style="background-color: #FBFEEC;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
                    column(
                        id="WhaleSetting",
                        width=12,
                        h4(icon("cog"), HTML("<b><i>Whale</b></i> Setting")),
                        hr(class="setting"),
                        fluidRow(
                            column(
                                12,
                                "Please insert the Hypothetical WGD events to test in the right tree panel. Click the branch and then follow the rule to insert.",
                                h5(HTML("<font color='#AD1F1F'>Hypothetical WGDs</font> to test:")),
                                verbatimTextOutput(
                                    "wgdNeededTestedID",
                                    placeholder=TRUE
                                ),
                                note
                            ),
                            column(
                                12,
                                hr(class="setting"),
                                selectInput(
                                    inputId="select_whale_model",
                                    label=HTML("<b>Base Model</b> for <b><i>Whale</b></i>:"),
                                    choices=c(
                                        "Constant-rates model",
                                        "Relaxed branch-specific DL+WGD model",
                                        "Critical branch-specific DL+WGD model"
                                    ),
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
                                )
                            ),
                            column(
                                12,
                                fluidRow(
                                    column(
                                        12,
                                        #gf_num_note,
                                        HTML("Choose a small portion of gene families to quickly check the running of <b><i>Whale</b></i>:<br>recommended: 50 / 100, < 1000"),
                                    ),
                                    column(
                                        8,
                                        textInput(
                                            inputId="input_gf_num",
                                            value="",
                                            label="",
                                            width="100%",
                                            placeholder="number"
                                        )
                                    ),
                                    column(
                                        4,
                                        actionButton(
                                            inputId="confirm_gf_num",
                                            "",
                                            width="40px",
                                            icon=icon("check"),
                                            status="secondary",
                                            style="color: #fff;
                                                   background-color: #C0C0C0;
                                                   border-color: #fff;
                                                   margin: 22px 0px 0px 0px; ",
                                            onclick="$('#confirm_gf_num').css('background-color', 'green');"
                                        )
                                    )
                                )
                            ),
                            column(
                                12,
                                hr(class="setting"),
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
                                        HTML("Create <b><i>Whale</i></b> Codes"),
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
                                div(class="float-left",
                                    style="padding: 5px 14px 5px 14px; margin: 5px 5px 5px 5px; ",
                                    actionLink(
                                        "go_whale_codes",
                                        HTML(
                                            paste0(
                                                "<font color='#5151A2'>",
                                                icon("share"),
                                                " Go to <i><b>Whale</b></i> Codes</font>"
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

        observeEvent(input$confirm_gf_num, {
            if( is.null(input$uploadSpeciesTimeTree) ){
                shinyalert(
                    "Oops",
                    "Please upload a time tree with the studied species first...",
                    type="error"
                )
            }else{
                if( input$input_gf_num != "" && as.integer(input$input_gf_num) > 1000 ){
                    shinyalert(
                        "Oops",
                        "Please choose a smaller number (< 1000)",
                        type="error"
                    )
                }
            }
            observe({
                runjs('$("#confirm_gf_num").css("background-color", "#C0C0C0");')
            })
        })
    }
})

output$wgdNeededTestedID <- renderText({
    text <- input$wgdInput
    text
})


observeEvent(input$whale_configure_go, {
    analysisDir <- parseDirPath(roots=c(computer="/"), input$analysisDir)
    whale_dir <- paste0(analysisDir, "/OrthoFinder_wd/Whale_wd")
    if( !dir.exists(whale_dir) ){
        dir.create(whale_dir)
    }

    # Output the wgd Nodes to a file
    if( is.null(input$wgdInput) ){
        shinyalert(
            "Opps",
            "Please add the Hypothetical WGD events to the tree first...",
            type="error"
        )
    }
    wgdNodeFile <- paste0(whale_dir, "/wgdNodes.txt")
    writeLines(input$wgdInput, wgdNodeFile)

    speciesTreeFile <- input$uploadSpeciesTimeTree$datapath
    uploaded_tree_file <- paste0(whale_dir, "/species_timetree.nwk")
    if( !file.exists(uploaded_tree_file) ){
        system(
            paste(
                "cp",
                speciesTreeFile,
                uploaded_tree_file
            )
        )
    }

    speciesTree <- readLines(textConnection(readChar(speciesTreeFile, file.info(speciesTreeFile)$size)))
    contains_underscore <- any(sapply(speciesTree, function(line) grepl("_", line)))

    aleDirPath <- paste0(whale_dir, "/selected_tree_ALE_files")
    if( !dir.exists(aleDirPath) ){
        withProgress(message='Creating the codes to prepare ALE files...', value=0, {
            if( !file.exists(paste0(whale_dir, "/preparing_Whale_inputs.shell")) ){
                system(
                    paste(
                        "cp",
                        paste0(getwd()[1], "/tools/preparing_Whale_inputs.shell"),
                        whale_dir
                    )
                )
            }

            whale_prepare_cmd_file <- paste0(whale_dir, "/run_ale_preparing.sh")
            cmd_con <- file(whale_prepare_cmd_file, open="w")
            writeLines(
                c(
                    "#!/bin/bash",
                    "",
                    "#SBATCH -p all",
                    "#SBATCH -c 4",
                    "#SBATCH --mem 2G",
                    paste0("#SBATCH -o ", basename(whale_prepare_cmd_file), ".os%j"),
                    paste0("#SBATCH -o ", basename(whale_prepare_cmd_file), ".es%j"),
                    ""
                ),
                cmd_con
            )

            writeLines(paste0("cd ", whale_dir), cmd_con)
            writeLines("orthogroupFile=$(ls ../orthofinderOutputDir/Results*/Orthogroups/Orthogroups.tsv)", cmd_con)
            focal_species_w <- gsub(" ", "_", input$select_focal_species)
            writeLines(
                paste0(
                    "sh ",
                    "./preparing_Whale_inputs.shell \\\n",
                    "\t$orthogroupFile \\\n",
                    "\t../../tree.newick \\\n",
                    "\t", focal_species_w, " \\\n",
                    "\t", getwd()[1], "/tools \\\n",
                    "\t4"
                ),
                cmd_con
            )
            if( contains_underscore ){
                aleUpdatedDirPath <- paste0(aleDirPath, ".updated")
                if( !dir.exists(aleUpdatedDirPath) ){
                    incProgress(amount=.5, message="Change species names...")
                    Sys.sleep(.2)
                    if( !file.exists(paste0(whale_dir, "/rename_species.py")) ){
                        system(
                            paste(
                                "cp",
                                paste0(getwd()[1], "/tools/rename_species.py"),
                                whale_dir
                            )
                        )
                    }
                    writeLines(
                        paste(
                            "python",
                            "./rename_species.py",
                            uploaded_tree_file,
                            aleDirPath,
                            wgdNodeFile
                        ),
                        cmd_con
                    )
                }
                speciesTreeFile <- paste0(gsub(".nwk", "", uploaded_tree_file), ".updated.nwk")
                aleDirPath <- paste0(aleDirPath, ".updated")
                wgdNodeFile <- paste0(gsub(".txt", "", wgdNodeFile), ".updated.txt")
            }

            writeLines("cd ..", cmd_con)
            writeLines("tar czf orthofinderOutputDir.tar.gz orthofinderOutputDir && rm -r orthofinderOutputDir", cmd_con)
            close(cmd_con)
        })
    }

    withProgress(message='preparing in progress', value=0, {
        incProgress(amount=.1, message="Creating Whale command file...")
        Sys.sleep(.1)

        # Preparing Whale command lines
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
        whaleCommandFile <- paste0(running_dir, "/whale.jl")
        whale_cmd_file <- paste0(running_dir, "/run_Whale_", whaleModel, ".sh")
        whale_cmd_con <- file(whale_cmd_file, open="w")

        writeLines(
            c(
                "#!/bin/bash",
                "",
                "#SBATCH -p all",
                "#SBATCH -c 4",
                "#SBATCH --mem 8G",
                paste0("#SBATCH -o ", basename(whale_cmd_file), ".so%j"),
                paste0("#SBATCH -o ", basename(whale_cmd_file), ".se%j"),
                ""
            ),
            whale_cmd_con
        )
        writeLines(
            "module load julia",
            whale_cmd_con
        )

        writeLines(
            paste0("cd ", running_dir),
            whale_cmd_con
        )


        incProgress(amount=.5, message="Write whale command lines into file...")
        Sys.sleep(.4)

        if( !file.exists(paste0(whale_dir, "/prepare_Whale_command.v2.sh")) ){
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/prepare_Whale_command.v2.sh"),
                    whale_dir
                )
            )
        }

        if( input$input_gf_num != "" ){
            writeLines(
                paste(
                    "sh",
                    "../prepare_Whale_command.v2.sh",
                    speciesTreeFile,
                    aleDirPath,
                    wgdNodeFile,
                    whaleCommandFile,
                    whaleModel,
                    input$select_chain_num,
                    input$input_gf_num
                ),
                whale_cmd_con
            )
        }else{
            writeLines(
                paste(
                    "sh",
                    "../prepare_Whale_command.v2.sh",
                    speciesTreeFile,
                    aleDirPath,
                    wgdNodeFile,
                    whaleCommandFile,
                    whaleModel,
                    input$select_chain_num
                ),
                whale_cmd_con
            )
        }

        writeLines(
            paste("julia", whaleCommandFile),
            whale_cmd_con
        )

        close(whale_cmd_con)
        closeAllConnections()
    })
})

observeEvent(input$go_whale_codes, {
    analysisDir <- parseDirPath(roots=c(computer="/"), input$analysisDir)
    whale_dir <- paste0(analysisDir, "/OrthoFinder_wd/Whale_wd")
    alePreparingCommadFile <- paste0(whale_dir, "/run_ale_preparing.sh")

    whaleModel <- ""
    if( input$select_whale_model == "Constant-rates model" ){
        whaleModel <- "Constant_rates"
    }else if( input$select_whale_model == "Relaxed branch-specific DL+WGD model" ){
        whaleModel <- "Relaxed_branch"
    }else{
        whaleModel <- "Critical_branch"
    }

    running_dir <- paste0(whale_dir, "/run_", whaleModel, "_model_", input$select_chain_num)

    whaleCommandFile <- paste0(running_dir, "/run_Whale_", whaleModel, ".sh")

    if( !file.exists(alePreparingCommadFile) & !file.exists(whaleCommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-Whale-Codes button first, then switch this on",
            type="error"
        )
    }
    else{
        updateNavbarPage(inputId="shinywgd", selected="codes_page")
        shinyjs::runjs(
            'setTimeout(function () {
                document.querySelector("#whaleParameterPanel").scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }, 100);
            '
        )
    }
})
