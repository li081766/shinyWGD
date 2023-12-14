output$introductionPanel <- renderUI({
    div(
        style="max-width: 1200px;
               padding-left: 300px;
               padding-bottom: 50px;
               padding-top: 50px;
               color: black;",
        column(
            12,
            HTML(includeMarkdown("www/content/introduction.md")),
            tags$script("
              function switchToDataPreparationTab() {
                Shiny.setInputValue('switchTab', 'data_preparation', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToWhalePreparationTab() {
                Shiny.setInputValue('switchTab', 'whale_preparation', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToTreeExtractionTab() {
                Shiny.setInputValue('switchTab', 'extracting_tree', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToKsAnalysisTab() {
                Shiny.setInputValue('switchTab', 'ks_analysis', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToSyntenyAnalysisTab() {
                Shiny.setInputValue('switchTab', 'synteny_analysis', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToTreeBuildingTab() {
                Shiny.setInputValue('switchTab', 'jointTree', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToTreeReconTab() {
                Shiny.setInputValue('switchTab', 'tree_reconciliation', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToGalleryTab() {
                Shiny.setInputValue('switchTab', 'gallery_page', {priority: 'event'});
              }
            "),
            tags$script("
              function switchToHelpTab() {
                Shiny.setInputValue('switchTab', 'help', {priority: 'event'});
              }
            "),
        )
    )
})

observe({
    updateTabsetPanel(session, "shinywgd", selected=input$switchTab)
})

