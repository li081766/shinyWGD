Synteny_Analysis_ui <- tabPanel(
    "Collinearity",
    value="synteny_analysis",
    fluidRow(
        column(
            id="syntenyPageTitle",
            width=12,
            h3(icon(
                name=NULL,
                style="
                    background: url('images/syntenyIcon.svg');
                    background-size: contain;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 50px;
                    width: 50px;
                    display: inline-block;
                    vertical-align: middle;"
                ),
                "Collinearity Analysis"
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="iadhoreOutputsSettingPanel",
            width=3,
            div(class="boxLike",
                style="background-color: #FAF9F6;",
                h4(icon("upload"), "Uploading"),
                hr(class="setting"),
                h5(HTML("<font color='green'><i>shinyWGD</i> <b>Collinearity Analysis</b></font> Data")),
                fluidRow(
                    class="justify-content-left",
                    style="padding-bottom: 15px;
                           padding-top: 5px",
                    column(
                        12,
                        div(
                            style="padding-left: 10px;
                                   position: relative;",
                            fileInput(
                                'collinear_data_zip_file',
                                label=h6(icon("file-zipper"), HTML("Upload the <b>zipped</b> File")),
                                multiple=FALSE,
                                accept=c(
                                    ".zip",
                                    ".gz"
                                ),
                                width="80%"
                            ),
                            actionButton(
                                inputId="collinear_data_example",
                                "",
                                icon=icon("question"),
                                status="secondary",
                                class="my-start-button-class",
                                title="Click to use the example data to demo run the Collinearity Analysis",
                                style="color: #fff;
                                       background-color: #87CEEB;
                                       border-color: #fff;
                                       position: absolute;
                                       top: 63%;
                                       left: 90%;
                                       margin-top: -15px;
                                       margin-left: -15px;
                                       padding: 5px 14px 5px 10px;
                                       width: 30px; height: 30px; border-radius: 50%;"
                            )
                        )
                    ),
                    column(
                        12,
                        uiOutput("selectedSyntenyDirName")
                    )
                )
            ),
            fluidRow(
                column(
                    12,
                    uiOutput("iadhoreAnalysisPanel")
                )
            )
        ),
        column(
            id="iadhoreOutputPanel",
            width=9,
            fluidRow(
                column(
                    12,
                    uiOutput("iadhore_output"),
                )
            )
        )
    ),
    icon=icon(
        name=NULL,
        style="
            background: url('images/syntenyIcon.svg');
            background-size: contain;
            background-position: center;
            background-repeat: no-repeat;
            height: 21px;
            width: 21px;
            display: inline-block;
            vertical-align: middle;
        "
    )
)
