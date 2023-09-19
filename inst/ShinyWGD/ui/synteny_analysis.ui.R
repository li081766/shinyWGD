Synteny_Analysis_ui <- tabPanel(
    "Synteny Analysis",
    value="synteny_analysis",
    fluidRow(
        column(
            id="syntenyPageTitle",
            width=12,
            h3(icon(
                name=NULL,
                style="
                    background: url('../images/syntenyIcon.svg');
                    background-size: contain;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 50px;
                    width: 50px;
                    display: inline-block;
                    vertical-align: middle;"
                ),
                "Synteny Analysis"
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
                h5(HTML("Upload <font color='green'><br><b>i-ADHoRe</b></font><br>Output Folder")),
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
                        shinyDirButton("iadhoredir", "Select a Folder", "Upload"),
                    )
                )
            ),
            div(class="boxLike",
                style="background-color: #FBFEEC;
                       padding-bottom: 10px;
                       padding-top: 10px",
                fluidRow(
                    column(
                        12,
                        uiOutput("iadhoreanalysisPanel")
                    )
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
                ),
                column(
                    12,
                    uiOutput("iadhore_multiple_species_output")
                )
            )
        )
    ),
    #icon=icon("water")
    icon=icon(
        name=NULL,
        style="
            background: url('../images/syntenyIcon.svg');
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
