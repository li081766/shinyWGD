Gallery_ui <- tabPanel(
    HTML("Gallery"),
    value='gallery_page',
    fluidRow(
        column(
            12,
            uiOutput("galleryPanel")
        )
    ),
    icon=icon("image")
)
