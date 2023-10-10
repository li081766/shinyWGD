Ks_Age_Distribution_ui <- tabPanel(
    HTML("<i>K</i><sub>s</sub> Age Distribution Analysis"),
    value="ks_analysis",
    fluidRow(
        column(
            id="ksAnalysisPageTitle",
            width=12,
            h3(icon(
                name=NULL,
                style="
                    background: url('images/ksIcon.svg');
                    background-size: contain;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 50px;
                    width: 50px;
                    display: inline-block;
                    vertical-align: middle;
                "
                ),
                HTML("<i>K</i><sub>s</sub> Age Distribution Analysis"),
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="WgdKsratesOutputsSettingPanel",
            width=3,
            div(class="boxLike",
                style="background-color: #FAF9F6;",
                h4(icon("upload"), "Uploading"),
                hr(class="setting"),
                h5(HTML("Upload <font color='green'><br><b>wgd</b> / <b>ksrates</b></font><br>Output Folder")),
                fluidRow(
                    class="justify-content-left",
                    style="padding-bottom: 5px;
                           padding-top: 5px",
                    column(
                        12,
                        h6(icon("folder"), "Select Output Folder")
                    )
                ),
                fluidRow(
                    class="justify-content-left",
                    style="padding-bottom: 5px;
                           padding-top: 5px",
                    column(
                        12,
                        shinyDirButton("dir", "Select a Folder", "Upload"),
                    )
                )
            ),
            fluidRow(
                column(
                    12,
                    uiOutput("ksanalysisPanel")
                )
            )
        ),
        column(
            id="WgdOutputPanel",
            width=9,
            fluidRow(
                column(
                    12,
                    uiOutput("ks_analysis_output")
                )
            )
        )
    ),
    #icon=icon("search")
    icon=icon(
        name=NULL,
        style="
            background: url('images/ksIcon.svg');
            background-size: contain;
            background-position: center;
            background-repeat: no-repeat;
            height: 21px;
            width: 21px;
            display: inline-block;
            vertical-align: middle;
        "
    )
    #icon=icon("chart-line")
)


# fluidRow(
#     class="justify-content-left",
#     style="padding-bottom: 5px;
#            padding-top: 5px",
#     column(
#         12,
#         radioButtons(
#             "analysis_mode_option",
#             label="Select the Mode",
#             choices=c("WGD Inference", "Synteny Analysis"),
#             selected="WGD Inference"
#         )
#     )
# )
