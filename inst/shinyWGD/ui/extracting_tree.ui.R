Extracting_Tree_ui <- tabPanel(
    "TimeTreeFetcher",
    value='extracting_tree',
    fluidRow(
        column(
            3,
            uiOutput("ObtainTreeFromTimeTreeSettingDisplay")
        ),
        column(
            9,
            uiOutput("timeTreeOrgPlot")
        )
    ),
    icon=icon("tree", verify_fa=FALSE)
)
