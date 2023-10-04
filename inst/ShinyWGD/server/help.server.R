output$myMarkdown <- renderUI({
    div(
        # style="padding-left: 100px;
        #        padding-bottom: 10px;
        #        padding-right: 200px;
        #        padding-top: 10px;",
        column(
            12,
            #HTML(includeMarkdown("www/content/help.md"))
            #HTML(includeMarkdown("../../../vignettes/intro_to_shinywgd.Rmd"))
            htmltools::tags$iframe(
                src="intro_to_shinywgd.html",
                width='100%',
                height=1000,
                style="border:none;"
            )
        )
    )
})
