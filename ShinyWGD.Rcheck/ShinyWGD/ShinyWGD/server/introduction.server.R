output$introductionPanel <- renderUI({
    div(
        style="padding-left: 100px;
               padding-bottom: 10px;
               padding-right: 300px;
               padding-top: 10px;",
        column(
            12,
            HTML(includeMarkdown("www/content/introduction.md"))
        )
    )
})
