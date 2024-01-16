Joint_Tree_ui <- tabPanel(
    "VizWGD",
    value="jointTree",
    fluidRow(
        column(
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
                "VizWGD: WGD Events Visualization in Tree"
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="jointTreeSettingPanel",
            width=3,
            # div(class="boxLike",
            #     style="background-color: #FAF9F6;",
            #     h5(icon("upload"), HTML("Uploading <font color='green'><i>K</i><sub>s</sub> Tree</font>")),
            #     hr(class="setting"),
            #     fluidRow(
            #         column(
            #             12,
            #             div(
            #                 style="padding-left: 10px;
            #                        position: relative;",
            #                 fileInput(
            #                     inputId="uploadKsTree",
            #                     label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Tree</b></font> File:"),
            #                     width="80%",
            #                     accept=c(".newick", ".tre", ".tree")
            #                 ),
            #                 actionButton(
            #                     inputId="ks_tree_example",
            #                     "",
            #                     icon=icon("question"),
            #                     status="secondary",
            #                     title="Click to see the example of Ks Unit Tree file",
            #                     class="my-start-button-class",
            #                     style="color: #fff;
            #                            background-color: #87CEEB;
            #                            border-color: #fff;
            #                            position: absolute;
            #                            top: 53%;
            #                            left: 90%;
            #                            margin-top: -15px;
            #                            margin-left: -15px;
            #                            padding: 5px 14px 5px 10px;
            #                            width: 30px; height: 30px; border-radius: 50%;"
            #                 )
            #             )
            #         )
            #     ),
            #     fluidRow(
            #         column(
            #             12,
            #             div(
            #                 style="padding-left: 10px;
            #                        position: relative;",
            #                 fileInput(
            #                     inputId="uploadKsPeakTable",
            #                     label=HTML("<font color='green'><b><i>K</i><sub>s</sub> Peak</b></font> File (Optional):"),
            #                     width="80%",
            #                     accept=c(".csv", ".txt", ".xls")
            #                 ),
            #                 actionButton(
            #                     inputId="ks_peaks_example",
            #                     "",
            #                     icon=icon("question"),
            #                     title="Click to see the example of Ks Peak file",
            #                     status="secondary",
            #                     class="my-start-button-class",
            #                     style="color: #fff;
            #                            background-color: #87CEEB;
            #                            border-color: #fff;
            #                            position: absolute;
            #                            top: 53%;
            #                            left: 90%;
            #                            margin-top: -15px;
            #                            margin-left: -15px;
            #                            padding: 5px 14px 5px 10px;
            #                            width: 30px; height: 30px; border-radius: 50%;"
            #                 )
            #             )
            #         )
            #     )
            # ),
            div(class="boxLike",
                style="background-color: #FBFEEC;",
                h5(icon("upload"), HTML("Uploading Phylogenetic Tree")),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        div(
                            style="padding-left: 10px;
                                   position: relative;",
                            fileInput(
                                inputId="uploadTimeTree",
                                label=HTML("<b>Phylogenetic Tree</b> file:"),
                                width="80%",
                                accept=c(".nexus", ".tre", ".tree", ".newick", ".nwk")
                            ),
                            actionButton(
                                inputId="MCMC_tree_example",
                                "",
                                icon=icon("question"),
                                title="Click to see the example of the Phylogenetic Tree file",
                                class="my-start-button-class",
                                status="secondary",
                                style="color: #fff;
                                       background-color: #87CEEB;
                                       border-color: #fff;
                                       position: absolute;
                                       top: 53%;
                                       left: 90%;
                                       margin-top: -15px;
                                       margin-left: -15px;
                                       padding: 5px 14px 5px 10px;
                                       width: 30px; height: 30px; border-radius: 50%;"
                            )
                        )
                    )
                ),
                # fluidRow(
                #     column(
                #         12,
                #         div(
                #             style="padding-left: 10px;
                #                    position: relative;",
                #             fileInput(
                #                 inputId="uploadTimeTable",
                #                 label=HTML("<b>WGDs Time </b> File (Optional but only for <i><b>Time Tree</i></b>):"),
                #                 width="80%",
                #                 accept=c(".csv", ".txt", ".xls")
                #             ),
                #             actionButton(
                #                 inputId="wgd_time_table_example",
                #                 "",
                #                 icon=icon("question"),
                #                 status="secondary",
                #                 title="Click to see the example of WGD time file",
                #                 class="my-start-button-class",
                #                 style="color: #fff;
                #                        background-color: #87CEEB;
                #                        border-color: #fff;
                #                        position: absolute;
                #                        top: 53%;
                #                        left: 90%;
                #                        margin-top: -15px;
                #                        margin-left: -15px;
                #                        padding: 5px 14px 5px 10px;
                #                        width: 30px; height: 30px; border-radius: 50%;"
                #             )
                #         )
                #     )
                # )
            ),
            fluidRow(
                column(
                    12,
                    uiOutput("timeTreeSettingPanel")
                )
            ),
            fluidRow(
                column(
                    12,
                    uiOutput("preDatedWGDsSettingPanel")
                )
            )
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
                            icon(
                                "down-left-and-up-right-to-center",
                                verify_fa=FALSE,
                                class="rotate-135"
                            ),
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
                            icon(
                                "down-left-and-up-right-to-center",
                                verify_fa=FALSE,
                                class="rotate-45"
                            ),
                            title="Compress horizontal spacing"
                        ),
                        downloadButton_custom(
                            "jointTreePlotDownload",
                            status="secondary",
                            icon=icon("download"),
                            title="Download the plot",
                            class="my-donwload-button-class",
                            label=HTML(""),
                            style="color: #fff;
                                  background-color: #6B8E23;
                                  border-color: #fff;
                                  padding: 5px 14px 5px 14px;
                                  margin: 5px 5px 5px 5px;"
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
    icon=icon(
        name=NULL,
        style="
            background: url('images/ksTreeIcon.svg');
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
