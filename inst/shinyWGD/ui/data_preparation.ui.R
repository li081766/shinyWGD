Data_preparation_ui <- tabPanel(
    HTML("Data Preparation"),
    value="data_preparation",
    fluidRow(
        column(
            id="SettingPanel",
            width=6,
            div(class="boxLike",
                style="background-color: #FAF9F6;",
                h4(icon("upload"), "Data Uploading"),
                hr(class="setting"),
                column(
                    12,
                    numericInput(
                        inputId="number_of_study_species",
                        label="Select Number of Species to Analyze:",
                        min=1,
                        value=1
                    )
                ),
                hr(class="setting"),
                h5(
                    tags$i(
                        class="fa fa-star",
                        style="color: #e17f00"
                    ),
                    HTML(paste0("If the analysis contains more than <font color='red'><b>three species</font></b>, ",
                        "we recommend using <font color='green'><b>a tab-separated file</b></font> to upload data. ")
                        )
                ),
                h5(
                    tags$i(
                        class="fa fa-star",
                        style="color: #e17f00"
                    ),
                    #HTML("Please switch to the <font color='green'><b>&#63; Help</font></b> page to see detail...")
                    HTML("Please switch to the <font color='green'><b><a href='#' onclick='switchToHelpTab()'>?Help</a></font> </b> page to see detail..."),

                    # JavaScript code to switch to the Help tab
                    tags$script("
                          function switchToHelpTab() {
                            Shiny.setInputValue('switchTab', 'help', {priority: 'event'});
                          }
                        ")
                ),
                hr(class="setting"),
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
                #h4(HTML("<b>WGD</b> Result")),
                fluidRow(
                    column(
                        12,
                        uiOutput("WgdksratesSettingDisplay")
                    )
                )
            ),
            fluidRow(
                column(
                    12,
                    uiOutput("ObtainTreeFromTimeTreeSettingDisplay")
                )
            )
        ),
        column(
            id="refs",
            width=12,
            div(
                class="boxLike",
                style="background-color: #f0f0f0",
                h5(icon("book"), "References"),
                hr(class="setting"),
                #fluidRow(
                    column(
                        12,
                        h6("Please refer to the documentation of the packages for details:"),
                        p(tags$a(href="https://github.com/arzwa/wgd",
                            "https://github.com/arzwa/wgd")),
                        p(tags$a(href="https://github.com/VIB-PSB/ksrates",
                            "https://github.com/VIB-PSB/ksrates")),
                        p(tags$a(href="https://www.vandepeerlab.org/?q=tools/i-adhore30",
                            "https://www.vandepeerlab.org/?q=tools/i-adhore30")),
                        h6("If you use the packages, please also cite their original papers:"),
                        p(HTML("Zwaenepoel, A., and Van de Peer, Y., (2019) <i>wgd - simple command line tools for the analysis of ancient whole genome duplications</i>. <b>Bioinformatics</b>, bty915")),
                        p(HTML("Sensalari, C., Maere, S., and Lohaus R., (2021) <i>ksrates: positioning whole-genome duplications relative to speciation events in KS distributions</i>. <b>Bioinformatics</b>, btab602")),
                        p(HTML("Proost, S., Fostier, J., De Witte, D., Dhoedt, B., Demeester, P., Van de Peer, Y. and Vandepoele, K., (2012) <i>i-ADHoRe 3.0—fast and sensitive detection of genomic homology in extremely large data sets</i>. <b>Nucleic acids research</b>, 40(2), pp.e11-e11."))
                    )
                #)
            )
        )
    ),
    icon=icon("microscope")
)
