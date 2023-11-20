Data_preparation_ui <- tabPanel(
    "Data Preparation",
    value="data_preparation",
    fluidRow(
        column(
            id="SettingPanel",
            width=6,
            div(class="boxLike",
                style="background-color: #FAF9F6;",
                h4(icon("upload"), "Data Uploading"),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        numericInput(
                            inputId="number_of_study_species",
                            label="Select Number of Species to Analyze:",
                            min=1,
                            value=1
                        )
                    )
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        h5(
                            tags$i(
                                class="fa fa-star",
                                style="color: #e17f00"
                            ),
                            HTML(paste0("If the analysis contains more than <font color='#e17f00'><b>three species</font></b>, ",
                                        "we recommend using <font color='green'><b>a tab-separated file</b></font> to manage data. ")
                            )
                        ),
                        h5(
                            tags$i(
                                class="fa fa-star",
                                style="color: #e17f00"
                            ),
                            HTML("Please switch to the <font color='green'><b><a href='#' onclick='switchToHelpTab()'>?Help</a></font> </b> page to see detail..."),

                            tags$script("
                              function switchToHelpTab() {
                                Shiny.setInputValue('switchTab', 'help', {priority: 'event'});
                              }
                            ")
                        )
                    )
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        5,
                        fileInput(
                            'upload_data_file',
                            HTML("Upload <font color='green'><b>a Tab-Separated</b></font> File:"),
                            multiple=FALSE,
                            width="100%",
                            accept=c(
                                ".txt",
                                ".xls",
                                ".txt.gz",
                                ".xls.gz",
                                ".gz"
                            )
                        )
                    ),
                    column(
                        1,
                        actionButton(
                            inputId="upload_data_file_example",
                            "",
                            icon=icon("question"),
                            status="secondary",
                            style="text-align: left;
                                   color: #fff;
                                   background-color: #87CEEB;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 10px;
                                   margin: 33px 5px 5px -15px;
                                   width: 30px; height: 30px; border-radius: 50%;"
                        ) %>%
                            bs_embed_tooltip(
                                title="Click to see the example of the Tab-Separated File",
                                placement="right",
                                trigger="hover",
                                options=list(container="body")
                            )
                    ),
                    column(
                        6,
                        fileInput(
                            'selected_data_files',
                            HTML("Upload <font color='green'><b>CDS / Annotation </b></font> Files:"),
                            multiple=TRUE,
                            accept=c(
                                ".gff",
                                ".gff3",
                                ".gff.gz",
                                ".gff3.gz",
                                ".fa",
                                ".fas",
                                ".fasta",
                                ".fa.gz",
                                ".fas.gz",
                                ".fasta.gz",
                                ".gz"
                            )
                        )
                    )
                ),
                hr(class="setting"),
                column(
                    12,
                    h4(HTML("<font color='#e17f00'><b><i>OR</i></b></font>"))
                ),
                column(
                    12,
                    uiOutput("UploadDisplay")
                )
            )
        ),
        column(
            id="WgdksratesSettingPanel",
            width=6,
            div(class="boxLike",
                style="background-color: #FFFFF4;",
                h4(icon("cog"), "Setting"),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        uiOutput("WgdksratesSettingDisplay")
                    )
                )
            ),
            # This div container only works for a remote server mode
            # div(class="boxLike",
            #     style="background-color: #FFFFF4;",
            #     h4(icon("play"), "Script Executing"),
            #     hr(class="setting"),
            #     fluidRow(
            #         column(
            #             12,
            #             div(
            #                 style="padding-left: 5px;",
            #                 HTML("The scripts will be executed in the <b><font color='#9F5000'>PSB computing cluster</b></font>. Please provide your email address below. A confirmation email will be sent to the provided email address when the job is finished."),
            #                 column(
            #                     12,
            #                     div(
            #                         style="padding-top:25px;",
            #                         textInput(
            #                             inputId="users_email_address",
            #                             label=HTML("<b>Your email</b>:"),
            #                             value="",
            #                             width="100%",
            #                             placeholder="your_name@mail.com"
            #                         )
            #                     )
            #                 )
            #             )
            #         ),
            #         column(
            #             12,
            #             hr(class="setting"),
            #             div(
            #                 style="padding-top: 5px;
            #                        padding-bottom: 15px;
            #                        padding-left: 5px",
            #                 HTML("Choose a script to submit to the <b><font color='#9F5000'>PSB computing cluster</b></font>"),
            #             ),
            #             uiOutput("WgdKsratesIadhoreScriptRun")
            #         )
            #     )
            # ),
            div(class="boxLike",
                style="background-color: #FFFFF4;",
                h4(icon("download"), "Data Downloading"),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        uiOutput("WgdKsratesIadhoreDataDownload")
                    )
                )
            )
        )
    ),
    icon=icon("microscope")
)
