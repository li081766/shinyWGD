Extracting_Tree_ui <- tabPanel(
    "Extracting Tree",
    value='extracting_tree',
    fluidRow(
        column(
            4,
            uiOutput("ObtainTreeFromTimeTreeSettingDisplay")
        ),
        column(
            8,
            uiOutput("timeTreeOrgPlot")
        )
    ),
    icon=icon("tree", verify_fa=FALSE)
)
