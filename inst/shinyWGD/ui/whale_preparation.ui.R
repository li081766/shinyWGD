Whale_Preparation_ui <- tabPanel(
    "Whale Preparation",
    value="whale_preparation",
    fluidRow(
        column(
            id="whalePreparationTitle",
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
                "Whale Preparation for Gene Tree – Species Tree Reconciliation Analysis"
            ),
            style="padding-bottom: 5px;
                   padding-top: 5px;
                   padding-left: 30px;",
        ),
        column(
            id="whalePreparationSettingPanel",
            width=3,
            column(
                12,
                uiOutput("whaleDataUploadPanel")
            )
        ),
        column(
            id="speciesTreeOutputPanel",
            width=9,
            div(class="boxLike",
                style="background-color: white;
                       margin: 5px 5px 5px 5px;
                       padding: 5px 10px 10px 10px;",
                fluidRow(
                    column(
                        9,
                        tags$style(
                            HTML(".rotate-135 {
                                    transform: rotate(135deg);
                                }"),
                            HTML(
                                ".rotate+45 {
                                    transform: rotate(-45deg);
                                }"
                            ),
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
                        # actionButton(
                        #     "update_output",
                        #     "",
                        #     icon("sync"),
                        #     title="Update plot",
                        #     style="color: #fff;
                        #            background-color: #019858;
                        #            border-color: #fff;
                        #            padding: 5px 14px 5px 14px;
                        #            margin: 5px 5px 5px 200px;
                        #            animation: glowing 5000ms infinite;"
                        # ),
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
            ),
            column(
                12,
                uiOutput("whaleCommandPanel")
            )
        )
    ),
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
