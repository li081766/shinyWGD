observeEvent(input$ksrates_go, {
    output$ksratesConfigureFileTxt <- renderText({
        ksratesconf <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd/ksrates_conf.txt")
        if( file.exists(ksratesconf) ){
            rawText <- readChar(ksratesconf, file.info(ksratesconf)$size)
        }
    })
    output$ksratesCommandTxt <- renderText({
        ksratescommad <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/ksrates_wd/run_ksrates.sh")
        if( file.exists(ksratescommad) ){
            CommandText <- readChar(ksratescommad, file.info(ksratescommad)$size)
        }
    })
    output$ksratesParameterPanel <- renderUI({
        fluidRow(
            column(
                id="KsrateCommandSettingPanel",
                width=12,
                div(class="boxLike",
                    style="background-color: #faf9f6;",
                    h4(icon("cog"), "ksrates parameter"),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The configure file for ", "<span style=\"color:green\"><b><i>ksrates</i></b></span>", ":"))),
                            verbatimTextOutput(
                                "ksratesConfigureFileTxt",
                                placeholder=TRUE)
                        )
                    ),
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The command line for <font color='green'><b><i>ksrates</i></b></font>:"))),
                            verbatimTextOutput(
                                "ksratesCommandTxt",
                                placeholder=TRUE)
                        ),
                        column(
                            12,
                            actionLink(
                                "back_datapreparation_2",
                                h5(HTML(paste0("<font color='#5151A2'>",
                                            icon("share"),
                                            " Back to <i><b>Data Preparation</b></i> Page")
                                ))
                            )
                        )
                    )
                )
            )
        )
    })
})

observeEvent(input$wgd_go, {
    output$WgdCommandTxt <- renderText({
        wgdcommmandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/run_wgd.sh")
        if( file.exists(wgdcommmandFile) ){
            command_info <- readChar(
                wgdcommmandFile,
                file.info(wgdcommmandFile)$size
            )
        }
    })
    output$wgdParameterPanel <- renderUI({
        fluidRow(
            column(
                id="WgdCommandSettingPanel",
                width=12,
                div(class="boxLike",
                    style="background-color: #e6f5c9;",
                    h4(icon("cog"), "WGD parameter"),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The command line for <font color='green'><b><i>wgd</i></b></font>:"))),
                            verbatimTextOutput(
                                "WgdCommandTxt",
                                placeholder=TRUE)
                        ),
                        column(
                            12,
                            actionLink(
                                "back_datapreparation_1",
                                h5(HTML(paste0("<font color='#5151A2'>",
                                               icon("share"),
                                               " Back to <i><b>Data Preparation</b></i> Page")
                                ))
                            )
                        )
                    )
                )
            )
        )
    })
})

observeEvent(input$iadhore_go, {
    output$IadhoreCommandTxt <- renderText({
        iadhorecommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/i-ADHoRe_wd/run_diamond_iadhore.sh")
        if( file.exists(iadhorecommandFile) ){
            command_info <- readChar(
                iadhorecommandFile,
                file.info(iadhorecommandFile)$size
            )
        }
    })
    output$iadhoreParameterPanel <- renderUI({
        fluidRow(
            column(
                id="IadhoreCommandSettingPanel",
                width=12,
                div(class="boxLike",
                    style="background-color: #e6f5c9;",
                    h4(icon("cog"), "i-ADHoRe parameter"),
                    hr(class="setting"),
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The command line for <font color='green'><b><i>i-ADHoRe</i></b></font>:"))),
                            verbatimTextOutput(
                                "IadhoreCommandTxt",
                                placeholder=TRUE)
                        ),
                        column(
                            12,
                            actionLink(
                                "back_datapreparation_3",
                                h5(HTML(paste0("<font color='#5151A2'>",
                                               icon("share"),
                                               " Back to <i><b>Data Preparation</b></i> Page")
                                ))
                            )
                        )
                    )
                )
            )
        )
    })
})

observeEvent(input$orthofinder_go, {
    output$OrthoFinderCommandTxt <- renderText({
        orthofinderCommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/OrthoFinder_wd/run_orthofinder.sh")
        if( file.exists(orthofinderCommandFile) ){
            command_info <- readChar(
                orthofinderCommandFile,
                file.info(orthofinderCommandFile)$size
            )
        }
    })
    output$orthofinderParameterPanel <- renderUI({
        fluidRow(
            tabPanel(
                title="TEST",
                id="TEST",
                value="TEST",
                column(
                    id="OrthoFinderSetting",
                    width=12,
                    div(class="boxLike",
                        style="background-color: #faf9f6;",
                        h4(icon("cog"), "OrthoFinder parameter"),
                        hr(class="setting"),
                        h5(HTML(paste0("The command line for <font color='#5A5AAD'><i><b>OrthoFinder</b></i></font>:"))),
                        fluidRow(
                            column(
                                12,
                                verbatimTextOutput(
                                    "OrthoFinderCommandTxt",
                                    placeholder=TRUE)
                            ),
                            column(
                                12,
                                actionLink(
                                    "back_datapreparation_5",
                                    h5(HTML(paste0("<font color='#5151A2'>",
                                                   icon("share"),
                                                   " Back to <i><b>Data Preparation</b></i> Page")
                                    ))
                                )
                            )
                        )
                    )
                )
            )
        )
    })
})

observeEvent(input$whale_go, {
    output$whaleCommandTxt <- renderText({
        whaleCommandFile <- paste0(tempdir(), "/Analysis_", Sys.Date(), "/whale_wd/run_whale.sh")
        if( file.exists(whaleCommandFile) ){
            command_info <- readChar(
                whaleCommandFile,
                file.info(whaleCommandFile)$size
            )
        }
    })
    output$whaleParameterPanel <- renderUI({
        fluidRow(
            column(
                id="WhaleSetting",
                width=12,
                div(class="boxLike",
                    style="background-color: #e6f5c9;",
                    h4(icon("cog"), "Whale parameter"),
                    hr(class="setting"),
                    h5(HTML(paste0("The command line for <font color='#a23400'><i></b>whale</b></i></font>:"))),
                    fluidRow(
                        column(
                            12,
                            verbatimTextOutput(
                                "WhaleCommandTxt",
                                placeholder=TRUE)
                        ),
                        column(
                            12,
                            actionLink(
                                "back_datapreparation_4",
                                h5(HTML(paste0("<font color='#5151A2'>",
                                               icon("share"),
                                               " Back to <i><b>Data Preparation</b></i> Page")
                                ))
                            )
                        )
                    )
                )
            )
        )
    })
})

# Link to Data Preparation page
observeEvent(input$back_datapreparation_1, {
    updateTabsetPanel(inputId="shinywgd", selected="data_preparation")
    # Sys.sleep(1)
    # session$sendCustomMessage(
    #     type="toggleDropdown",
    #     message=list(msg="hide dropdown"))
})
observeEvent(input$back_datapreparation_2, {
    updateTabsetPanel(inputId="shinywgd", selected="data_preparation")
    # Sys.sleep(1)
    # session$sendCustomMessage(
    #     type="toggleDropdown",
    #     message=list(msg="hide dropdown"))
})
observeEvent(input$back_datapreparation_3, {
    updateTabsetPanel(inputId="shinywgd", selected="data_preparation")
    # Sys.sleep(1)
    # session$sendCustomMessage(
    #     type="toggleDropdown",
    #     message=list(msg="hide dropdown"))
})
observeEvent(input$back_datapreparation_4, {
    updateTabsetPanel(inputId="shinywgd", selected="data_preparation")
    # Sys.sleep(1)
    # session$sendCustomMessage(
    #     type="toggleDropdown",
    #     message=list(msg="hide dropdown"))
})
observeEvent(input$back_datapreparation_5, {
    updateTabsetPanel(inputId="shinywgd", selected="data_preparation")
    # Sys.sleep(1)
    # session$sendCustomMessage(
    #     type="toggleDropdown",
    #     message=list(msg="hide dropdown"))
})
