suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinyFiles)
    library(bslib)
    library(shinyBS)
    library(bsplus)
    library(htmltools)
    library(igraph)
    library(shinyWidgets)
    library(shinyalert)
    library(stringi)
    library(tidyverse)
    library(vroom)
    library(fs)
    library(english)
    library(data.table)
    library(argparse)
    library(dplyr)
    library(tools)
    library(seqinr)
    library(DT)
    library(ape)
})

## clean r session and temporary folder first
rm(list=ls())
## change upload file size limit to 5GB
options(shiny.maxRequestSize=5000*1024^2)

## source the necessary R script before deploying shinyWGD to the PSB server
# R_files <- list.files(path="R", pattern="\\.R$", full.names=TRUE)
# for( file in R_files ){
#     source(file)
# }

### load ui pages
source(file="ui/introduction.ui.R", local=T, encoding="UTF-8")
source(file="ui/data_preparation.ui.R", local=T, encoding="UTF-8")
source(file="ui/whale_preparation.ui.R", local=T, encoding="UTF-8")
source(file="ui/extracting_tree.ui.R", local=T, encoding="UTF-8")
source(file="ui/ks_age_distribution.ui.R", local=T, encoding="UTF-8")
source(file="ui/joint_tree.ui.R", local=T, encoding="UTF-8")
source(file="ui/synteny_analysis.ui.R", local=T, encoding="UTF-8")
source(file="ui/tree_reconciliation.ui.R", local=T, encoding="UTF-8")
source(file="ui/gallery.ui.R", local=T, encoding="UTF-8")
source(file="ui/help.ui.R", local=T, encoding="UTF-8")

ui <- tagList(
    includeScript("www/js/d3.min.js"),
    includeScript("www/js/iadhore.synteny.js"),
    includeScript("www/js/clustering.js"),
    includeScript("www/js/Ksdistribution.js"),
    includeScript("www/js/figtree.js"),
    includeScript("www/js/findOutgroup.js"),
    includeScript("https://unpkg.com/@popperjs/core@2"),
    includeScript("www/js/tippy-bundle.umd.v6.3.7.min.js"),
    includeScript("www/js/progress_bar.js"),
    includeScript("https://cdnjs.cloudflare.com/ajax/libs/seedrandom/3.0.5/seedrandom.min.js"),
    includeScript("https://cdn.jsdelivr.net/npm/sweetalert2@11"),
    includeScript("https://cdn.jsdelivr.net/npm/progressbar.js@1.1.0/dist/progressbar.min.js"),
    shinyjs::useShinyjs(),
    tags$head(
        tags$link(
            rel="stylesheet",
            href="custom.css"
        )
    ),
    navbarPage(
        id="shinywgd",
        theme=bs_theme(
            version=4,
            bootswatch="flatly",
            bg="#fffff4",
            fg="#336666",
            "input-border-color"="#feb24c"
        ),
        title=tags$img(
            src="images/sticker_server.png",
            width="80",
        ),
        windowTitle="shinyWGD",
        Introduction_ui,
        navbarMenu(
            "Setup",
            icon=icon("terminal"),
            Data_preparation_ui,
            Whale_Preparation_ui,
            # Codes_checking_ui,
            Extracting_Tree_ui,
        ),
        navbarMenu(
            "Analysis",
            icon=icon("pencil-alt"),
            Ks_Age_Distribution_ui,
            Synteny_Analysis_ui,
            Tree_Reconciliation_ui,
            Joint_Tree_ui
        ),
        Gallery_ui,
        Help_ui,
        #tabPanel(
        #    "Downlaod",
        #    icon=icon("download"),
        #    fluidRow(
        #        column(
        #            6,
        #            uiOutput("search_download_page")
        #        )
        #    )
        #)
    ),
    tags$head(
        tags$style(HTML("
            .my-start-button-class:hover {
                background-color: #2E8B57 !important;
            }
            .my-confirm-button-class:hover {
                background-color: #808080 !important;
            }
            .my-download-button-class:hover {
                background-color: #556B2F !important;
            }
        "))
    ),
    # add website for lab and UGent
    tags$a(href="https://www.vandepeerlab.org/", id="mylink1", target="_blank", rel="noopener",
           tags$img(
               src="images/logo_lab.png",
               width="222.50",
               height="41.95"
               )
    ),
    tags$head(
        tags$style(HTML("
            #mylink1 {
                position: absolute;
                top: 30px;
                right: 110px;
                z-index: 1;
            }
            .modal {
                z-index: 1050 !important;
            }
            .modal-backdrop {
                z-index: 1040 !important;
            }
        "))
    ),
    tags$a(href="https://www.ugent.be/en", id="mylink2", target="_blank", rel="noopener",
           tags$img(
               src="images/logo_ugent.png",
               width="100.65",
               height="81.64"
           )
    ),
    tags$head(
        tags$style(HTML("
            #mylink2 {
                position: absolute;
                top: 10px;
                right: 10px;
                z-index: 1;
            }
            .modal {
                z-index: 1050 !important;
            }
            .modal-backdrop {
                z-index: 1040 !important;
            }
        "))
    ),
    tags$script(HTML(
            'function openTab(tabClass) {
        Shiny.setInputValue("openTab", tabClass);
      }'
    ))
)

server <- function(input, output, session){
    observe({
        jsCode <- '
                  $(window).bind("beforeunload", function() {
                    Shiny.onInputChange("refreshClicked", new Date().getTime());
                  });
                '
        session$sendCustomMessage("jsCode", jsCode)
    })

    # Reload the app when the refresh button is clicked
    observeEvent(input$refreshClicked, {
        session$reload()
    })

    source(file="server/introduction.server.R", local=T, encoding="UTF-8")
    source(file="server/data_preparation.server.R", local=T, encoding="UTF-8")
    source(file="server/whale_preparation.server.R", local=T, encoding="UTF-8")
    source(file="server/extracting_tree.server.R", local=T, encoding="UTF-8")
    source(file="server/ks_age_distribution.server.R", local=T, encoding="UTF-8")
    source(file="server/joint_tree.server.R", local=T, encoding="UTF-8")
    source(file="server/synteny_analysis.server.R", local=T, encoding="UTF-8")
    source(file="server/tree_reconciliation.server.R", local=T, encoding="UTF-8")
    source(file="server/gallery.server.R", local=T, encoding="UTF-8")
    source(file="server/help.server.R", local=T, encoding="UTF-8")
}

shinyApp(ui, server, options=list(markdownTemplate="html_document"))
