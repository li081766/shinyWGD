Tree_Reconciliation_ui <- tabPanel(
    "TreeRecon",
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
                HTML("TreeRecon: Gene Tree – Species Tree Reconciliation Analysis")
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
                       padding-left: 10px;",
                h4(icon("upload"), "Uploading"),
                hr(class="setting"),
                h5(HTML("<font color='green'><b><i>shinyWGD</i> Whale Analysis</b></font> Data")),
                style="background-color: #FAF9F6;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
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
                                'whale_data_zip_file',
                                label=h6(icon("file-zipper"), "Upload the Zipped File"),
                                multiple=FALSE,
                                accept=c(
                                    ".zip",
                                    ".gz"
                                ),
                                width="80%"
                            ),
                            actionButton(
                                inputId="whale_TreeRecon_example",
                                "",
                                icon=icon("question"),
                                status="secondary",
                                class="my-start-button-class",
                                title="Click to use the example data to demo run the TreeRecon Analysis",
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
                        uiOutput("selectedTreeReconDirName")
                    )
                )
                # fluidRow(
                #     column(
                #         12,
                #         hr(class="setting")
                #     ),
                #     column(
                #         12,
                #         uiOutput("selectedSubAnalysisDir")
                #     )
                # )
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
            # div(class="boxLike",
            #     style="background-color: #FBFEEC;
            #            margin: 5px 5px 5px 5px;
            #            padding: 5px 10px 10px 10px;",
            #     column(
            #         12,
            #         uiOutput("whaleOutputPanel")
            #     )
            # )
        ),
        column(
            # id="speciesTreeOutputPanel",
            width=9,
            div(class="boxLike",
                style="background-color: white;",
                column(
                    12,
                    uiOutput("whaleOutputPanel")
                ),
                column(
                    12,
                    hr(class="setting")
                ),
                column(
                    12,
                    h5(HTML("The species cladograms with the putative WGD events in the <b>Whale</b> analysis"))
                ),
                # column(
                #     12,
                #     hr(class="setting")
                # ),
                column(
                    12,
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
                                "TreeRecon_svg_vertical_spacing_add_species",
                                "",
                                icon("arrows-alt-v"),
                                title="Expand vertical spacing",
                                style="border-color: #fff;"
                            ),
                            actionButton(
                                "TreeRecon_svg_vertical_spacing_sub_species",
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
                                "TreeRecon_svg_horizontal_spacing_add_species",
                                "",
                                icon("arrows-alt-h"),
                                title="Expand horizontal spacing",
                                style="border-color: #fff;"
                            ),
                            actionButton(
                                "TreeRecon_svg_horizontal_spacing_sub_species",
                                "",
                                icon(
                                    "down-left-and-up-right-to-center",
                                    verify_fa=FALSE,
                                    class="rotate-45"
                                ),
                                title="Compress horizontal spacing",
                                style="border-color: #fff; "
                            ),
                            downloadButton_custom(
                                "speciesWhaleTreeReconPlotDownload",
                                status="secondary",
                                icon=icon("download"),
                                label=HTML(""),
                                title="Download svg figure",
                                class="my-download-button-class",
                                style="color: #fff;
                                   background-color: #6B8E23;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;"
                            )
                        ),
                        column(
                            9,
                            div(
                                id="speciesWhaleTreeRecon_plot",
                            ),
                            uiOutput("whaleReconTreeDesPanel")
                        )
                    )
                ),
                column(
                    12,
                    hr(class="setting")
                ),
                column(
                    12,
                    uiOutput("posteriorPanelTitle"),
                    fluidRow(
                        column(
                            9,
                            # tags$style(
                            #     HTML(".rotate-135 {
                            #     transform: rotate(135deg);
                            # }"),
                            #     HTML(".rotate-45{
                            #     transform: rotate(45deg);
                            # }")
                            # ),
                            # actionButton(
                            #     "posterior_svg_vertical_spacing_add_species",
                            #     "",
                            #     icon("arrows-alt-v"),
                            #     title="Expand vertical spacing",
                            #     style="border-color: #fff;"
                            # ),
                            # actionButton(
                            #     "posterior_svg_vertical_spacing_sub_species",
                            #     "",
                            #     icon(
                            #         "down-left-and-up-right-to-center",
                            #         verify_fa=FALSE,
                            #         class="rotate-135"
                            #     ),
                            #     title="Compress vertical spacing",
                            #     style="border-color: #fff;"
                            # ),
                            # actionButton(
                            #     "posterior_svg_horizontal_spacing_add_species",
                            #     "",
                            #     icon("arrows-alt-h"),
                            #     title="Expand horizontal spacing",
                            #     style="border-color: #fff;"
                            # ),
                            # actionButton(
                            #     "posterior_svg_horizontal_spacing_sub_species",
                            #     "",
                            #     icon(
                            #         "down-left-and-up-right-to-center",
                            #         verify_fa=FALSE,
                            #         class="rotate-45"
                            #     ),
                            #     title="Compress horizontal spacing",
                            #     style="border-color: #fff; "
                            # ),
                            downloadButton_custom(
                                "posteriorDistPlotDownload",
                                status="secondary",
                                icon=icon("download"),
                                label=HTML(""),
                                title="Download svg figure",
                                class="my-download-button-class",
                                style="color: #fff;
                                       background-color: #6B8E23;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;"
                            )
                        ),
                        column(
                            8,
                            div(
                                id="posterior_Dist_plot_div",
                            ),
                            # uiOutput("whaleReconTreeDesPanel")
                        )
                    )
                ),
                column(
                    12,
                    uiOutput("whaleTextOutputPanel")
                )
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
