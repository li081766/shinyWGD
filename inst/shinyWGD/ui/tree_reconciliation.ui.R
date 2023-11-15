Tree_Reconciliation_ui <- tabPanel(
    "Gene Tree – Species Tree Reconciliation Analysis",
    value="tree_reconciliation",
    fluidRow(
        column(
            id="treeReconciliationTitle",
            width=12,
            h4(icon(
                name=NULL,
                style="
                    background: url('images/treeReconciliationIcon.svg');
                    background-size: contain;
                    background-position: center;
                    background-repeat: no-repeat;
                    height: 50px;
                    width: 50px;
                    display: inline-block;
                    vertical-align: middle;
                "
                ),
                HTML("Gene Tree – Species Tree Reconciliation Analysis")
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="treeReconciliationSettingPanel",
            width=3,
            div(class="boxLike",
                style="background-color: #FAF9F6;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
                column(
                    12,
                    h4(icon("upload"), "Uploading"),
                    hr(class="setting"),
                    fileInput(
                        inputId="uploadSpeciesTree",
                        label=HTML("<font color='green'><b>Species Time Tree</b></font> in <font color='red'><b><i>Newick</b></i></font> format:")
                    )
                ),
                column(
                    12,
                    HTML("<font color='orange'><b>ALE files</b></font> directory:<br>"),
                    shinyDirButton("aleDir", "Select a Folder", "Upload"),
                    uiOutput("numberAleFiles")
                )
            ),
            # div(class="boxLike",
            #     style="background-color: #FAF9F6;
            #            padding-bottom: 10px;
            #            padding-top: 10px",
            #     h4(icon("cog"), "Setting"),
            #     fluidRow(
            #         column(
            #             12,
            #             textInput(
            #                 inputId="wgdNodes",
            #                 label=HTML("Add <font color='#977C00'><b>WGD Nodes</b></font> to the Tree:"),
            #                 value="",
            #                 width="100%",
            #                 placeholder="wgd_1: PPAT, PPAT; wgd_2: ATHA, ATRI"
            #             )
            #         ),
            #         h6(HTML("Use <font color='orange'><b>\";\"</b></font> to separate."))
            #     )
            # )
            # column(
            #     12,
            #     uiOutput("wgdCommnadPanel")
            # ),
            div(class="boxLike",
                style="background-color: #FBFEEC;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
                column(
                    12,
                    uiOutput("whaleCommandPanel")
                )
            )
        ),
        column(
            id="speciesTreeOutputPanel",
            width=9,
            div(class="boxLike",
                style="background-color: white;",
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
                            "svg_vertical_spacing_add_species",
                            "",
                            icon("arrows-alt-v"),
                            title="Expand vertical spacing",
                            style="border-color: #fff;"
                        ),
                        actionButton(
                            "svg_vertical_spacing_sub_species",
                            "",
                            icon(
                                "down-left-and-up-right-to-center",
                                verify_fa=FALSE,
                                class="rotate-135"
                            ),
                            title="Compress vertical spacing",
                            style="border-color: #fff;"
                        ),
                        actionButton(
                            "svg_horizontal_spacing_add_species",
                            "",
                            icon("arrows-alt-h"),
                            title="Expand horizontal spacing",
                            style="border-color: #fff;"
                        ),
                        actionButton(
                            "svg_horizontal_spacing_sub_species",
                            "",
                            icon(
                                "down-left-and-up-right-to-center",
                                verify_fa=FALSE,
                                class="rotate-45"
                            ),
                            title="Compress horizontal spacing",
                            style="border-color: #fff; "
                        ),
                        actionButton(
                            "update_output",
                            "",
                            icon("sync"),
                            title="Update plot",
                            style="color: #fff;
                                   background-color: #019858;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 200px;
                                   animation: glowing 5000ms infinite;"
                        ),
                        downloadButton_custom(
                            "speciesTreePlotDownload",
                            status="secondary",
                            icon=icon("download"),
                            label=HTML(""),
                            title="Download svg figure",
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
                            id="speciesTree_plot",
                        )
                    )
                )
            ),
            column(
                12,
                uiOutput("whaleConfigurePanel")
            )
        )
    ),
    #icon=icon("chart-line")
    icon=icon(
        name=NULL,
        style="
            background: url('images/treeReconciliationIcon.svg');
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
