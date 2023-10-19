suppressPackageStartupMessages(
    library(shiny)
)
suppressPackageStartupMessages(library(shinyjs))
library(shinyFiles)
library(bslib)
library(shinyBS)
suppressPackageStartupMessages(library(bsplus))
suppressPackageStartupMessages(library(htmltools))
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
source(file="ui/codes_checking.ui.R", local=T, encoding="UTF-8")
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
        # position="fixed-top",
        Introduction_ui,
        navbarMenu(
            "Scripts",
            icon=icon("terminal"),
            Data_preparation_ui,
            Codes_checking_ui
        ),
        navbarMenu(
            "Analysis",
            icon=icon("pencil-alt"),
            Ks_Age_Distribution_ui,
            Synteny_Analysis_ui,
            Joint_Tree_ui,
            Tree_Reconciliation_ui
        ),
        Gallery_ui,
        Help_ui
    ),

    # add website for lab and UGent
    tags$a(href="https://www.vandepeerlab.org/", id="mylink1",
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
            z-index: 9999;
            }"
        ))
    ),
    tags$a(href="https://www.ugent.be/en", id="mylink2",
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
            z-index: 9999;
            }"
        ))
    ),
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
    source(file="server/codes_checking.server.R", local=T, encoding="UTF-8")
    source(file="server/ks_age_distribution.server.R", local=T, encoding="UTF-8")
    source(file="server/joint_tree.server.R", local=T, encoding="UTF-8")
    source(file="server/synteny_analysis.server.R", local=T, encoding="UTF-8")
    source(file="server/tree_reconciliation.server.R", local=T, encoding="UTF-8")
    source(file="server/gallery.server.R", local=T, encoding="UTF-8")
    source(file="server/help.server.R", local=T, encoding="UTF-8")
}

shinyApp(ui, server, options=list(markdownTemplate="html_document"))
