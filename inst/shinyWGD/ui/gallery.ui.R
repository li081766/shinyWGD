Gallery_ui <- tabPanel(
    HTML("Gallery"),
    value='gallery_page',
    fluidRow(
        column(
            12,
            #uiOutput("galleryPanel")
			HTML('<iframe src="https://li081766.github.io/shinyWGD_Demo_Data/gallery.html" style="width:100%; height:800px; border:none;"></iframe>')
        )
    ),
    icon=icon("image")
)
