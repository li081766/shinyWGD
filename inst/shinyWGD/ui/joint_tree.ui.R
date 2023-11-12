Joint_Tree_ui <- tabPanel(
    HTML("Tree Building"),
    value="jointTree",
    fluidRow(
        column(
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
            id="jointTreeTitle",
            width=12,
            h3(icon(
                name=NULL,
                style="
                    background: url('images/ksTreeIcon.svg');
                    background-size: contain;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 50px;
                    width: 50px;
                    display: inline-block;
                    vertical-align: middle;
                "
                ),
                HTML("Tree Building")
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="jointTreeSettingPanel",
            width=3,
            div(class="boxLike",
                style="background-color: #FAF9F6;",
                h5(icon("upload"), HTML("Uploading <font color='green'><i>K</i><sub>s</sub> Tree</font>")),
                hr(class="setting"),
                column(
                    12,
                    fileInput(
                        inputId="uploadKsTree",
                        label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Tree</b></font> File:"),
                        accept=c(".newick", ".tre", ".tree")
                    )
                ),
                column(
                    12,
                    fileInput(
                        inputId="uploadKsPeakTable",
                        label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Peak</b></font> File (Optional):"),
                        accept=c(".csv", ".txt", ".xls")
                    )
                )
            ),
            div(class="boxLike",
                style="background-color: #FBFEEC;",
                h5(icon("upload"), HTML("Uploading <font color='orange'><i>MCMCTREE</i></font>")),
                hr(class="setting"),
                column(
                    12,
                    fileInput(
                        inputId="uploadTimeTree",
                        label=HTML("<font color='orange'><b><i>MCMCTREE</i> Tree</b></font> File:"),
                        accept=c(".nexus", ".tre", ".tree")
                    )
                ),
                column(
                    12,
                    fileInput(
                        inputId="uploadTimeTable",
                        label=HTML("<font color='orange'><b>WGDs Time </b></font> File (Optional):"),
                        accept=c(".csv", ".txt", ".xls")
                    )
                )
            ),
            # div(class="boxLike",
            #     style="background-color: #F0FFF0;
            #         border: 0px solid grey; ",
            #     fluidRow(
            #         # column(
            #         #     6,
            #         #     #h5(icon("pencil-alt"), HTML("Construct Tree")),
            #         #     actionButton(
            #         #         inputId="jointTreeGo",
            #         #         "Construct Tree",
            #         #         #width="200px",
            #         #         icon=icon("pencil-alt"),
            #         #         status="secondary",
            #         #         style="color: #fff;
            #         #            background-color: #27ae60;
            #         #            border-color: #fff;
            #         #            padding: 5px 14px 5px 14px;
            #         #            margin: 5px 5px 5px 5px;
            #         #            animation: glowing 5000ms infinite; "
            #         #     )
            #         # ),
            #         column(
            #             6,
            #             #h5(icon("download"), HTML("Download")),
            #             downloadButton_custom(
            #                 "jointTreePlotDownload",
            #                 status="secondary",
            #                 icon=icon("download"),
            #                 label=HTML("Save Tree SVG"),
            #                 style="color: #fff;
            #                   background-color: #019858;
            #                   border-color: #fff;
            #                   padding: 5px 14px 5px 14px;
            #                   margin: 5px 5px 5px 5px;
            #                   animation: glowingD 5000ms infinite;"
            #             )
            #         )
            #     )
            # )
        ),
        column(
            id="TreePanel",
            width=9,
            div(class="boxLike",
                style="background-color: white;
                       padding-bottom: 10px;
                       padding-top: 10px",
                fluidRow(
                    column(
                        9,
                        tags$style(
                            HTML(".rotate-135 {
                                    transform: rotate(135deg);
                                }"),
                            HTML(".rotate-45{
                                    transform: rotate(45deg);
                                }")
                        ),
                        actionButton(
                            "svg_vertical_spacing_add",
                            "",
                            icon("arrows-alt-v"),
                            title="Expand vertical spacing"
                        ),
                        actionButton(
                            "svg_vertical_spacing_sub",
                            "",
                            icon("compress", class="rotate-135"),
                            title="Compress vertical spacing"
                        ),
                        actionButton(
                            "svg_horizontal_spacing_add",
                            "",
                            icon("arrows-alt-h"),
                            title="Expand horizontal spacing"
                        ),
                        actionButton(
                            "svg_horizontal_spacing_sub",
                            "",
                            icon("compress", class="rotate-45"),
                            title="Compress horizontal spacing"
                        ),
                        # actionButton(
                        #     "reset",
                        #     "",
                        #     icon("sync"),
                        #     title="Restore spacing"
                        # ),
                        downloadButton_custom(
                            "jointTreePlotDownload",
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
                        12,
                        div(
                            id="jointtree_plot",
                        )
                    )
                )
            )
        )
    ),
    #icon=icon("chart-line")
    icon=icon(
        name=NULL,
        style="
            background: url('../../images/ksTreeIcon.svg');
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
