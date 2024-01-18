observeEvent(input$upload_data_file_example, {
    species_data_file <- "www/content/4sp_data_file_example.xls"
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>Tab-Separated</b></font> File"),
            size="xl",
            uiOutput("upload_data_file_example_panel")
        )
    )

    output$uploadSpeciesDataExampleTable <- renderTable({
        species_info_example <- read.delim(
            species_data_file,
            header=FALSE,
            col.names=c("species name", "cds file", "gff file"),
            sep="\t",
            quote=""
        )
    })

    output$upload_data_file_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    h5(
                        HTML(
                            paste0(
                                "Each row of this file contains the data information of a species"
                            )
                        )
                    ),
                    tableOutput("uploadSpeciesDataExampleTable"),
                    HTML(
                        paste0(
                            "<sup>a</sup> <b>cds</b> is the coding region of a gene or the portion of a gene's DNA or RNA that codes for protein. This file can be <b>fasta</b> or <b>gzipped-fasta</b>.<br>",
                            "This column is <strong>mandatory</strong>.<br>",
                            "<font color='green'><i aria-label='warning icon' class='fa fa-warning fa-fw' role='presentation'></i></font> Do not contain the <a href='https://en.wikipedia.org/wiki/Alternative_splicing' target='_blank'>alternative isoforms</a> of each gene.<br>",
                            "<sup>b</sup> <b>gff</b> is the format consists of one line per feature, each containing nine columns of data, plus optional track definition lines, see more <a href='https://www.ensembl.org/info/website/upload/gff.html' target='_blank'>click here</a>.<br>",
                            "The file can be <b>gff</b>, <b>gff3</b>, <b>gzipped-gff</b>, or <b>gzipped-gff3</b>.<br>",
                            "This column is <strong>mandatory</strong> for the <strong>focal species</strong> and is <strong>optional</strong> for the <strong>other species</strong>.</br>",
                            "<b>Make sure you upload fasta and gff files with the same name in this table field.</b>",
                            "<p><br></br></p>",
                            "<p>To download the demo data, <a href='https://github.com/li081766/shinyWGD_Demo_Data/blob/main/4sp_orchids.CDS_GFF_Example_Data.tar.gz' target='_blank'>click here</a>.</p>"
                        )
                    )
                )
            )
        )
    })
})

output$UploadDisplay <- renderUI({
    sp_range <- 1:input$number_of_study_species
    ui_parts <- c()
    scientific_names <- readLines("www/content/scientific_names.xls")
    scientific_names_selected <- rep(scientific_names, length.out=input$number_of_study_species)
    for( i in sp_range ){
        if( i == 1 ){
            ui_parts[[i]] <- fluidRow(
                tags$style(
                    HTML(
                        "input::placeholder {
                      font-style: italic;
                    }"
                    )
                ),
                column(
                    4,
                    textInput(
                        paste0("latin_name_", i),
                        paste("Species ", i, " Latin Name:"),
                        value="",
                        width="100%",
                        placeholder=scientific_names_selected[[i]]
                    )
                ),
                column(
                    3,
                    fileInput(
                        paste0("proteome_", i),
                        HTML("Upload <font color='green'><b>Fasta</b></font> File:"),
                        multiple=FALSE,
                        width="100%",
                        accept=c(
                            ".fasta",
                            ".fas",
                            ".fa",
                            ".fasta.gz",
                            ".fa.gz",
                            ".fas.gz",
                            ".gz"
                        )
                    )
                ),
                column(
                    1,
                    actionButton(
                        inputId="fasta_file_example",
                        "",
                        icon=icon("question"),
                        title="Click to see the example of the CDS Fasta File",
                        status="secondary",
                        class="my-start-button-class",
                        style="text-align: left;
                               color: #fff;
                               background-color: #87CEEB;
                               border-color: #fff;
                               padding: 5px 14px 5px 10px;
                               margin: 33px 5px 5px -15px;
                               width: 30px; height: 30px; border-radius: 50%;"
                    )
                ),
                column(
                    3,
                    fileInput(
                        paste0("gff_", i),
                        HTML("Upload <font color='green'><b>GFF</b></font> File:"),
                        multiple=FALSE,
                        width="100%",
                        accept=c(
                            ".gff",
                            ".gff.gz",
                            ".gff3",
                            ".gff3.gz",
                            ".gtf",
                            ".gtf.gz",
                            ".gz"
                        )
                    )
                ),
                column(
                    1,
                    actionButton(
                        inputId="gff_file_example",
                        "",
                        icon=icon("question"),
                        title="Click to see the example of the Annotation GFF File",
                        status="secondary",
                        class="my-start-button-class",
                        style="text-align: left;
                               color: #fff;
                               background-color: #87CEEB;
                               border-color: #fff;
                               padding: 5px 14px 5px 10px;
                               margin: 33px 5px 5px -15px;
                               width: 30px; height: 30px; border-radius: 50%;"
                    )
                )
            )
        }else{
            ui_parts[[i]] <- fluidRow(
                tags$style(
                    HTML(
                        "input::placeholder {
                      font-style: italic;
                    }"
                    )
                ),
                column(
                    4,
                    textInput(
                        paste0("latin_name_", i),
                        paste("Species ", i, " Latin Name:"),
                        value="",
                        width="100%",
                        placeholder=scientific_names_selected[[i]]
                    )
                ),
                column(
                    4,
                    fileInput(
                        paste0("proteome_", i),
                        HTML("Upload <font color='green'><b>CDS Fasta</b></font> File:"),
                        multiple=FALSE,
                        width="100%",
                        accept=c(
                            ".fasta",
                            ".fas",
                            ".fa",
                            ".fasta.gz",
                            ".fa.gz",
                            ".fas.gz",
                            ".gz"
                        )
                    )
                ),
                column(
                    4,
                    fileInput(
                        paste0("gff_", i),
                        HTML("Upload <font color='green'><b>GFF</b></font> File:"),
                        multiple=FALSE,
                        width="100%",
                        accept=c(
                            ".gff",
                            ".gff.gz",
                            ".gff3",
                            ".gff3.gz",
                            ".gtf",
                            ".gtf.gz",
                            ".gz"
                        )
                    )
                )
            )
        }
    }
    ui_parts
})

observeEvent(input$fasta_file_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>CDS Fasta</b></font> file"),
            size="xl",
            uiOutput("fasta_file_example_panel")
        )
    )

    output$fasta_file_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("cdsFastaExample"),
                    HTML(
                        paste0(
                            "<b>cds</b> is the coding region of a gene or the portion of a gene's DNA or RNA that codes for protein. This file can be <b>fasta</b> or <b>gzipped-fasta</b>.<br>",
                            "<font color='green'><i aria-label='warning icon' class='fa fa-warning fa-fw' role='presentation'></i></font> Do not contain the <a href='https://en.wikipedia.org/wiki/Alternative_splicing' target='_blank'>alternative isoforms</a> of each gene.<br>",
                            "The two sequences are from <i>Oryza sativa</i>."
                        )
                    )
                )
            )
        )
    })

    output$cdsFastaExample <- renderText({
    ">Os01t0100466-00 | Os01g0100466
ATGCCGCAGTTTGTGCCGCCCACGCCGTCCTGCCAGGGGCTCTTGCGCTGCTGCACCCCGTGCCACGTCAGCAG
CAGCGGCTCGTCCAGGCCGTTCCTCACGTTCACCACCAGGTTCCAGTTGGTCGTCACGTTCAGCGCCGGCCCCG
GCAGCTGCCCGTTGATGCCAATCGCCTCCTGCTTCTTCACTCCGCCCAGCGGCGCACCCCACACGTACGATACC
TCCCACTCGTAG
>Os01t0100200-01 | Os01g0100200
ATGGAGGAGGCTGGCGAGCGGGACGCTGACGAGACGCACGCGTGGAGCGGAACAGCATCGCCTGCAGCTTTGTG
GAAGACCGTGGCGTCGTCGGCGGCGATGCTGAAGCTGGCCTTGGCGATGATCTCGGCGGCGTTCCGGACAACGC
CCTTCTCGATGTCGATGCAGCTGTGTCCCAACGCCACTATGTCGCTCCACTCGCCGAGCATCTTCGACGTCGTC
TCCTCCATCACGCCGATCATGTCCTGCATCATCAACAACAGGTTGGTGGCGGAGAAGGCAGGGGCGACGATGCA
GCGGTGGCGAGCCCACTCGTCGCCCTCGGCCATGACGCGGCCTCTCCCGAACATGGGCATGCGGTTGAGCAGTT
ACGATATAGTGTGCCAATTGGCACACCTACATTTTAGTCATGTATGTTGTTTAGTTTAA
"
    })
})

observeEvent(input$gff_file_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>Anntation GFF</b></font> file"),
            size="xl",
            uiOutput("gff_file_example_panel")
        )
    )

    output$gff_file_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("gffExample"),
                    HTML(
                        paste0(
                            "<b>gff</b> is the format consists of one line per feature, each containing nine columns of data, plus optional track definition lines, see more <a href='https://www.ensembl.org/info/website/upload/gff.html' target='_blank'>click here</a>.<br>",
                            "The file can be <b>gff</b>, <b>gff3</b>, <b>gzipped-gff</b>, or <b>gzipped-gff3</b>.<br>",
                            "The example items are from <i>Oryza sativa</i>."
                        )
                    )
                )
            )
        )
    })

    output$gffExample <- renderText({
        "chr01	IRGSP-1.0-2021-05-10	gene	12808	13978	.	-	.	ID=Os01g0100466;tid=Os01t0100466-00;uniprot=A0A0P0UXH5;Name=Os01g0100466;gene_id=Os01g0100466
chr01	IRGSP-1.0-2021-05-10	mRNA	12808	13978	.	-	.	ID=Os01t0100466-00;Parent=Os01g0100466;Name=Os01g0100466;gene_id=Os01g0100466
chr01	IRGSP-1.0-2021-05-10	exon	12808	13782	.	-	.	ID=Os01t0100466-00:exon:1;Parent=Os01t0100466-00;Name=Os01g0100466;gene_id=Os01g0100466
chr01	IRGSP-1.0-2021-05-10	exon	13880	13978	.	-	.	ID=Os01t0100466-00:exon:2;Parent=Os01t0100466-00;Name=Os01g0100466;gene_id=Os01g0100466
chr01	IRGSP-1.0-2021-05-10	gene	11218	12435	.	+	.	ID=Os01g0100200;uniprot=B9EYQ4;MSU-ID=LOC_Os01g01019.1;tid=Os01t0100200-01;Name=Os01g0100200;gene_id=Os01g0100200
chr01	IRGSP-1.0-2021-05-10	mRNA	11218	12435	.	+	.	ID=Os01t0100200-01;Parent=Os01g0100200;Name=Os01g0100200;gene_id=Os01g0100200
chr01	IRGSP-1.0-2021-05-10	exon	11218	12060	.	+	.	ID=Os01t0100200-01:exon:1;Parent=Os01t0100200-01;Name=Os01g0100200;gene_id=Os01g0100200
chr01	IRGSP-1.0-2021-05-10	exon	12152	12435	.	+	.	ID=Os01t0100200-01:exon:2;Parent=Os01t0100200-01;Name=Os01g0100200;gene_id=Os01g0100200
"
    })
})

output$WgdksratesSettingDisplay <- renderUI({
    num <- toupper(as.english(input$number_of_study_species))
    if( input$number_of_study_species < 2 ){
        mode <- "Whole-Paranome"
        fluidRow(
            class="justify-content-end",
            style="padding-bottom: 5px;",
            column(
                12,
                div(HTML("Species number is set to <b><font color='#9F5000'>",
                        num,
                        "</b></font>, less than <b><font color='red'>TWO</font></b>. ",
                        "Following <b>WGD ",
                        "<font color='green'>",
                        mode,
                        "</font>",
                        "</b> pipeline ...<br></br>"),
                    div(class="d-flex justify-content-between",
                        div(class="float-left",
                            actionButton(
                                inputId="wgd_go",
                                HTML("Create <b><i>wgd</i></b> Codes"),
                                icon=icon("screwdriver-wrench"),
                                title="Click to create wgd codes",
                                status="secondary",
                                class="my-start-button-class",
                                style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px; "
                            ),
                            div(
                                id="wgd_progress_container_js"
                            )
                        ),
                        div(class="float-right",
                            style="padding-top: 15px; ",
                            actionLink(
                                "go_codes_wgd",
                                HTML(
                                    paste0(
                                        "<font color='#5151A2'>",
                                        icon("share"),
                                        " Go to <i><b>wgd</b></i> Scripts</font>"
                                    )
                                )
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to see detail wgd codes",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                )
                        )
                    )
                )
            )
        )
    }
    else{
        fluidRow(
            div(
                style="padding-left: 20px;
                       padding-right: 20px;",
                fluidRow(
                    column(
                        12,
                        h6(
                            HTML(
                                "Species number is set to <b><font color='#9F5000'>",
                                num,
                                "</b></font>, larger than <b><font color='red'>ONE</font></b>.",
                                " Following <b><font color='green'>ksrates</font></b> pipeline...<br></br>"
                            )
                        )
                    ),
                    column(
                        6,
                        pickerInput(
                            inputId="select_focal_species",
                            label=HTML("Set <b>Focal Species</b> for <b><font color='green'>ksrates</font></b>:"),
                            options=list(
                                title='Please select focal species below'
                            ),
                            choices=NULL,
                            multiple=FALSE
                        )
                    ),
                    column(
                        5,
                        fileInput(
                            "newick_tree",
                            HTML("Upload <b>a Newick Tree</b> for <b><font color='green'>ksrates</font></b>:"),
                            multiple=FALSE,
                            width="100%"
                        )
                    ),
                    column(
                        1,
                        actionButton(
                            inputId="newick_file_example",
                            "",
                            icon=icon("question"),
                            title="Click to see the example of the Newick Tree File",
                            status="secondary",
                            class="my-start-button-class",
                            style="text-align: left;
                                   color: #fff;
                                   background-color: #87CEEB;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 10px;
                                   margin: 33px 5px 5px -15px;
                                   width: 30px; height: 30px; border-radius: 50%;"
                        )
                    ),
                    column(
                        12,
                        uiOutput("multipleSpeciesPanel")
                    ),
                ),
                hr(class="setting"),
                fluidRow(
                    column(
                        6,
                        actionButton(
                            inputId="ksrates_go",
                            HTML("Create <b><i>ksrates</b></i> Codes"),
                            width="230px",
                            icon=icon("screwdriver-wrench"),
                            title="Click to create ksrates codes",
                            status="secondary",
                            class="my-start-button-class",
                            style="color: #fff;
                                   background-color: #27ae60;
                                   border-color: #fff;
                                   padding: 5px 14px 5px 14px;
                                   margin: 5px 5px 5px 5px;"
                        ),
                        div(
                            id="ksrates_progress_container_js"
                        )
                    ),
                    column(
                        6,
                        div(class="float-right",
                            style="padding-top: 15px; ",
                            actionLink(
                                "go_codes_ksrates",
                                HTML(
                                    paste0(
                                        "<font color='#5151A2'>",
                                        icon("share"),
                                        " Go to <i><b>ksrates</b></i> Scripts</font>"
                                    )
                                )
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to review ksrates codes",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                )
                        )
                    )
                ),
                fluidRow(
                    column(
                        6,
                        div(class="float-left",
                            actionButton(
                                inputId="iadhore_go",
                                HTML("Create <b><i>i-ADHoRe</b></i> Codes"),
                                width="245px",
                                icon=icon("screwdriver-wrench"),
                                title="Click to create i-ADHoRe codes",
                                status="secondary",
                                class="my-start-button-class",
                                style="color: #fff;
                                       background-color: #27ae60;
                                       border-color: #fff;
                                       padding: 5px 14px 5px 14px;
                                       margin: 5px 5px 5px 5px;"
                            ),
                            div(
                                id="iadhore_progress_container_js"
                            )
                        )
                    ),
                    column(
                        6,
                        div(class="float-right",
                            style="padding-top: 15px;",
                            actionLink(
                                "go_codes_iadhore",
                                HTML(
                                    paste0(
                                        "<font color='#5151A2'>",
                                        icon("share"),
                                        " Go to <i><b>i-ADHoRe</b></i> Scripts</font>"
                                    )
                                )
                            ) %>%
                                bs_embed_tooltip(
                                    title="Click to review i-ADHoRe codes",
                                    placement="right",
                                    trigger="hover",
                                    options=list(container="body")
                                )
                        )
                    )
                ),
                if( input$number_of_study_species > 2 ){
                    fluidRow(
                        column(
                            6,
                            div(
                                style="padding-bottom: 15px;",
                                actionButton(
                                    inputId="orthofinder_go",
                                    HTML("Create <i><b>OrthoFinder</b></i> Codes"),
                                    width="265px",
                                    icon=icon("screwdriver-wrench"),
                                    title="Click to create OrthoFinder codes",
                                    status="secondary",
                                    class="my-start-button-class",
                                    style="color: #fff;
                                           background-color: #27ae60;
                                           border-color: #fff;
                                           padding: 5px 14px 5px 14px;
                                           margin: 5px 5px 5px 5px;"
                                ),
                                div(
                                    id="orthofinder_progress_container_js"
                                )
                            )
                        ),
                        column(
                            6,
                            div(class="float-right",
                                style="padding-top: 15px;",
                                actionLink(
                                    "go_codes_orthofinder",
                                    HTML(
                                        paste0(
                                            "<font color='#5151A2'>",
                                            icon("share"),
                                            " Go to <i><b>OrthoFinder</b></i> Scripts</font>"
                                        )
                                    )
                                ) %>%
                                    bs_embed_tooltip(
                                        title="Click to review OrthoFinder codes",
                                        placement="right",
                                        trigger="hover",
                                        options=list(container="body")
                                    )
                            )
                        )
                    )
                }
            )
        )
    }
})

observeEvent(input$newick_file_example, {
    showModal(
        modalDialog(
            title=HTML("The example of the <font color='green'><b>Newick Tree</b></font> file"),
            size="xl",
            uiOutput("newick_file_example_panel")
        )
    )

    output$newick_file_example_panel <- renderUI({
        fluidRow(
            div(
                style="padding-bottom: 10px;
                       padding-left: 20px;
                       padding-right: 20px;
                       max-width: 100%;
                       overflow-x: auto;",
                column(
                    12,
                    verbatimTextOutput("newickExample"),
                    HTML(
                        paste0(
                            "see more <a href='https://en.wikipedia.org/wiki/Newick_format#:~:text=In%20mathematics%2C%20Newick%20tree%20format,Maddison%2C%20Christopher%20Meacham%2C%20F.' target='_blank'>click here</a>."
                        )
                    )
                )
            )
        )
    })

    output$newickExample <- renderText({
        "(Vitis_vinifera,(Asparagus_officinalis,(Elaeis_guineensis,Oryza_sativa)));"
    })
})

output$multipleSpeciesPanel <- renderUI({
    if( input$number_of_study_species > 2 ){
        div(
            column(
                12,
                HTML(
                    paste(
                        "If the below mode is enabled, <font color='green'><b>i-ADHoRe</b></font> will analyze all the species within a single run.",
                        "The corresponding code will be added to the main script of <font color='green'><i><b>run_diamond_iadhore.sh</b></i></font>.",
                        "For more details, refer to the <font color='green'><b>i-ADHoRe</b></font> manual."
                    )
                )
            ),
            column(
                12,
                style="margin-top: 5px;",
                prettyToggle(
                    inputId="multiple_iadhore",
                    label_on="Yes!",
                    icon_on=icon("check"),
                    status_on="info",
                    status_off="warning",
                    label_off="No..",
                    bigger=TRUE,
                    icon_off=icon("remove"),
                    animation="rotate"
                ) %>%
                    bs_embed_tooltip(
                        title="Switch On to activate the multiple speices model",
                        placement="right",
                        trigger="hover",
                        options=list(container="body")
                    )
            )
        )
    }
})

output$WgdKsratesIadhoreScriptRun <- renderUI({
    fluidRow(
        class="justify-content-end",
        style="padding-bottom: 5px;",
        column(
            12,
            actionButton(
                inputId="job_run_server",
                "Submit Jobs",
                icon=icon("paper-plane"),
                title="Click to submit the job to the PSB computing server",
                status="secondary",
                class="my-start-button-class",
                style="text-align: left;
                       color: #fff;
                       background-color: #27ae60;
                       border-color: #fff;
                       padding: 5px 14px 5px 14px;
                       margin: 5px 5px 5px 5px; "
            )
        ),
        column(
            12,
            uiOutput("job_unique_id")
        )
    )
})

output$WgdKsratesIadhoreDataDownload <- renderUI({
    fluidRow(
        column(
            12,
            div(class="float-left",
                downloadButton_custom(
                    outputId="wgd_ksrates_data_download",
                    label="Download Data and Scripts",
                    icon=icon("download"),
                    title="Click to download the analysis data and the scripts",
                    status="secondary",
                    class="my-download-button-class",
                    style="color: #fff;
                           background-color: #6B8E23;
                           border-color: #fff;
                           padding: 5px 14px 5px 14px;
                           margin: 5px 5px 5px 5px;"
                )
            ),
            # div(class="float-right",
            #     downloadButton(
            #         outputId="wgd_ksrates_ouput_download",
            #         label="Download Output Data",
            #         icon=icon("download"),
            #         status="secondary",
            #         style="background-color: #5151A2;
            #                padding: 5px 10px 5px 10px;
            #                margin: 5px 5px 5px 5px;
            #                animation: glowingD 5000ms infinite; "
            #     )
            # )
        )
    )
})

updateProgress <- function(container, width, type) {
    session$sendCustomMessage(
        "UpdateProgressBar",
        list(container=container, width=width, type=type)
    )
}

observeEvent(input$switchTab, {
    if( input$switchTab=="help" ){
        updateTabsetPanel(session, "shinywgd", selected="help")
    }
})

data_preparation_dir_Val <- reactiveVal(NULL)
original_data_wd_Val <- reactiveVal(NULL)

observe({
    if(
        isTruthy(input$upload_data_file) ||
        isTruthy(input$selected_data_files) ||
        isTruthy(input$proteome_1)
    ){
        observeEvent(input$upload_data_file, {
            if( !is.null(input$upload_data_file) ){
                shinyalert(
                    "Success",
                    "You use a file file to upload the data. See more details in Help page",
                    type="success"
                )
                data_table <- read_data_file(input$upload_data_file)
                ncols <- ncol(data_table)
                nrows <- nrow(data_table)

                if( input$number_of_study_species != nrows ){
                    shinyalert(
                        "Oops!",
                        paste0("The species number in the file (", nrows, " species) is not equal to the number you chose (", input$number_of_study_species, " species). Please set the right species number to analyze!"),
                        type="error",
                    )
                }else{
                    # for server
                    # base_dir <- "/www/bioinformatics01_rw/ShinyWGD"
                    # timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
                    # working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))

                    base_dir <- tempdir()
                    timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
                    working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))

                    while( dir.exists(working_wd) ){
                        Sys.sleep(1)
                        timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
                        working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))
                    }

                    dir.create(working_wd)
                    original_data_wd <- file.path(working_wd, "original_data")
                    dir.create(original_data_wd)

                    data_preparation_dir_Val(working_wd)
                    # system(paste("chmod -R 777", working_wd))
                    original_data_wd_Val(original_data_wd)
                    # system(paste("chmod -R 777", original_data_wd))

                    system(
                        paste0(
                            "cp ",
                            input$upload_data_file$datapath,
                            " ",
                            original_data_wd,
                            "/data.original.xls"
                        )
                    )
                }
            }
        })

        observeEvent(input$selected_data_files, {
            working_wd <- data_preparation_dir_Val()
            original_data_wd <- original_data_wd_Val()
            if( isTruthy(input$selected_data_files) ){
                for( i in 1:nrow(input$selected_data_files) ){
                    system(
                        paste0(
                            "cp ",
                            input$selected_data_files[i, "datapath"],
                            " ",
                            original_data_wd,
                            "/",
                            input$selected_data_files[i, "name"]
                        )
                    )
                }

                # check file existence
                withProgress(message='Checking the path of input files', value=0, {
                    original_data_df <- read.delim(
                        paste0(original_data_wd, "/data.original.xls"),
                        sep="\t",
                        header=FALSE,
                        fill=T,
                        na.strings=""
                    )
                    checkFileExistence(original_data_df, original_data_wd)
                    incProgress(amount=1)
                })
            }
        })

        if( !is.null(input$proteome_1) ){
            # for server
            # base_dir <- "/www/bioinformatics01_rw/ShinyWGD"
            # timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
            # working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))

            base_dir <- tempdir()
            timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
            working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))

            while( dir.exists(working_wd) ){
                Sys.sleep(1)
                timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
                working_wd <- file.path(base_dir, paste0("Analysis_", gsub("[ :\\-]", "_", timestamp)))
            }

            dir.create(working_wd)

            data_preparation_dir_Val(working_wd)
            # system(paste("chmod -R 777", working_wd))
        }
    }
})

# update the focal species panel
get_species_from_input <- reactive({
    sp_range <- 1:input$number_of_study_species
    latin_names_list <- c()
    for( i in sp_range ){
        latin_name <- paste0("latin_name_", i)
        if( !is.null(input[[latin_name]]) ){
            latin_names_list <- c(latin_names_list, trimws(input[[latin_name]]))
        }
    }
    return(latin_names_list)
})
observeEvent(get_species_from_input(), {
    updatePickerInput(
        session,
        "select_focal_species",
        choices=get_species_from_input(),
        choicesOpt=list(
            content=lapply(get_species_from_input(), function(choice) {
                choice <- gsub("_", " ", choice)
                HTML(paste0("<div style='color: #5667E5; font-style: italic;'>", choice, "</div>"))
            })
        )
    )
})

get_species_from_file <- reactive({
    if( !is.null(input$upload_data_file)) {
        read_data_file(input$upload_data_file)[["V1"]]
    }
})
observeEvent(get_species_from_file(), {
    updatePickerInput(
        session,
        "select_focal_species",
        choices=get_species_from_file(),
        choicesOpt=list(
            content=lapply(get_species_from_file(), function(choice) {
                choice <- gsub("_", " ", choice)
                HTML(paste0("<div style='color: #5667E5; font-style: italic;'>", choice, "</div>"))
            })
        )
    )
})

observeEvent(input$wgd_go, {
    working_wd <- data_preparation_dir_Val()
    original_data_wd <- original_data_wd_Val()
    if( is.null(input$upload_data_file) ){
        if( is.null(input[[paste0("proteome_", 1)]]) ){
            shinyalert(
                "Oops!",
                "Please upload the data from at least one species, then switch this on ...",
                type="error"
            )
        }
        else{
            shinyjs::runjs('$("#progress_modal").modal("show");')
            progress_data <- list(
                "actionbutton"="wgd_go",
                "container"="wgd_progress_container_js"
            )
            session$sendCustomMessage(
                "Progress_Bar_Complete",
                progress_data
            )
            withProgress(message='Creating in progress', value=0, {
                incProgress(amount=.2, message="Processing files ...")
                updateProgress("wgd_progress_container_js", 20, "Create wgd code")
                Sys.sleep(.5)

                species_info_list <- c()

                latin_name <- gsub(" $", "", input[[paste0("latin_name_", 1)]])
                informal_name <- gsub(" ", "_", latin_name)

                species_info_list <- c(species_info_list, informal_name)

                query_proteome_t <- check_proteome_input(
                    informal_name,
                    input[[paste0("proteome_", 1)]],
                    working_wd
                )
                species_info_list <- c(species_info_list, paste0(informal_name, ".fa"))

                incProgress(amount=.6, message="Creating WGD Runing Script ...")
                updateProgress("wgd_progress_container_js", 60, "Create wgd code")
                Sys.sleep(.5)

                wgd_working_dir <- paste0(working_wd, "/wgd_wd")
                if( !dir.exists(wgd_working_dir) ){
                    dir.create(wgd_working_dir)
                    # system(paste("chmod -R 777", wgd_working_dir))
                }
                wgd_cmd_sh_file <- paste0(wgd_working_dir, "/run_wgd.sh")
                wgd_cmd_con <- file(wgd_cmd_sh_file, open="w")
                # create wgd runing script
                writeLines(
                    c(
                        "#!/bin/bash",
                        "",
                        "#SBATCH -p all",
                        "#SBATCH -c 4",
                        "#SBATCH --mem 8G",
                        paste0("#SBATCH -o ", basename(wgd_cmd_sh_file), ".o%j"),
                        paste0("#SBATCH -e ", basename(wgd_cmd_sh_file), ".e%j"),
                        ""
                    ),
                    wgd_cmd_con
                )

                writeLines(
                    "module load wgd mcl diamond mafft fasttree",
                    wgd_cmd_con
                )

                writeLines(
                    paste0("wgd dmd -I 3 ../", informal_name, ".fa -o 01.wgd_dmd --nostrictcds"),
                    wgd_cmd_con
                )

                writeLines(
                    paste0(
                        "wgd ksd 01.wgd_dmd/", informal_name, ".fa.mcl ../",
                        informal_name, ".fa -o 02.wgd_ksd"
                    ),
                    wgd_cmd_con
                )

                if( is.null(input[[paste0("gff_", 1)]]) ){
                    shinyalert(
                        "Warning",
                        "No annotation file uploaded. Skip the synteny analysis in WGD pipeline",
                        type="warning",
                    )
                }
                else{
                    query_gff_t <- check_gff_input(
                        informal_name,
                        input[[paste0("gff_", 1)]],
                        working_wd
                    )

                    species_info_list <- c(species_info_list, paste0(informal_name, ".gff"))

                    writeLines(
                        paste0(
                            "wgd syn -f mRNA -a ID -ks 02.wgd_ksd/", informal_name, ".fa.ks.tsv ../",
                            informal_name, ".gff 01.wgd_dmd/", informal_name, ".fa.mcl ",
                            "-o 03.wgd_syn"
                        ),
                        wgd_cmd_con
                    )
                }

                writeLines(
                    paste0(
                        "wgd mix -ni 100 --method bgmm 02.wgd_ksd/", informal_name, ".fa.ks.tsv",
                        " -o 04.wgd_mix"
                    ),
                    wgd_cmd_con
                )
                close(wgd_cmd_con)

                species_info_file <- paste0(working_wd, "/Species.info.xls")
                write.table(
                    paste(species_info_list, collapse="\t"),
                    file=species_info_file,
                    sep="\t",
                    col.names=FALSE,
                    row.names=FALSE,
                    quote=FALSE
                )

                incProgress(amount=1)
                updateProgress("wgd_progress_container_js", 100, "Create wgd code")
                Sys.sleep(2)
            })
            shinyjs::runjs('$("#progress_modal").modal("hide");');
        }
    }
    else{
        if( !is.null(input$selected_data_files) ){
            data_table <- read_data_file(input$upload_data_file)
            data_table <- read.delim(
                paste0(original_data_wd, "/data.original.xls"),
                sep="\t",
                header=FALSE,
                fill=T,
                na.strings=""
            )
            ncols <- ncol(data_table)
            nrows <- nrow(data_table)
            if( nrows == 1 ){
                shinyjs::runjs('$("#progress_modal").modal("show");')
                progress_data <- list(
                    "actionbutton"="wgd_go",
                    "container"="wgd_progress_container_js"
                )
                session$sendCustomMessage(
                    "Progress_Bar_Complete",
                    progress_data
                )
                withProgress(message='Creating in progress', value=0, {
                    incProgress(amount=.2, message="Processing files ...")
                    updateProgress("wgd_progress_container_js", 20, "Create wgd code")
                    Sys.sleep(.5)

                    species_info_list <- c()

                    latin_name <- gsub(" ", "_", data_table[1, "V1"])
                    proteome <- paste0(original_data_wd, "/", data_table[1, "V2"])
                    proteome_checked <- check_proteome_from_file(
                        latin_name,
                        proteome,
                        working_wd
                    )

                    species_info_list <- c(species_info_list, latin_name)
                    species_info_list <- c(species_info_list, paste0(latin_name, ".fa"))

                    incProgress(amount=.6, message="Creating WGD Runing Script ...")
                    updateProgress("wgd_progress_container_js", 60, "Create wgd code")
                    Sys.sleep(.5)

                    wgd_working_dir <- paste0(working_wd, "/wgd_wd")
                    if( !dir.exists(wgd_working_dir) ){
                        dir.create(wgd_working_dir)
                        # system(paste("chmod -R 777", wgd_working_dir))
                    }
                    wgd_cmd_sh_file <- paste0(wgd_working_dir, "/run_wgd.sh")
                    wgd_cmd_con <- file(wgd_cmd_sh_file, open="w")
                    writeLines(
                        c(
                            "#!/bin/bash",
                            "",
                            "#SBATCH -p all",
                            "#SBATCH -c 4",
                            "#SBATCH --mem 8G",
                            paste0("#SBATCH -o ", basename(wgd_cmd_sh_file), ".o%j"),
                            paste0("#SBATCH -o ", basename(wgd_cmd_sh_file), ".e%j"),
                            ""
                        ),
                        wgd_cmd_con
                    )

                    writeLines(
                        "module load wgd mcl diamond mafft fasttree",
                        wgd_cmd_con
                    )

                    writeLines(
                        paste0("wgd dmd -I 3 ../", latin_name, ".fa -o 01.wgd_dmd"),
                        wgd_cmd_con
                    )

                    writeLines(
                        paste0(
                            "wgd ksd 01.wgd_dmd/",
                            latin_name, ".fa.mcl ../",
                            latin_name, ".fa ",
                            "-o 02.wgd_ksd"
                        ),
                        wgd_cmd_con
                    )
                    if( ncols > 2 ){
                        gff <- paste0(original_data_wd, "/", data_table[1, "V3"])
                        gff_checked <- check_gff_from_file(
                            latin_name,
                            gff,
                            working_wd
                        )
                        writeLines(
                            paste0(
                                "wgd syn -f mRNA -a ID -ks ",
                                "02.wgd_ksd/", latin_name, ".fa.ks.tsv ../",
                                latin_name, ".gff 01.wgd_dmd/", latin_name, ".fa.mcl ",
                                "-o 03.wgd_syn"
                            ),
                            wgd_cmd_con
                        )

                        species_info_list <- c(species_info_list, paste0(latin_name, ".gff"))
                    }
                    else if( ncols == 2 ){
                        shinyalert(
                            "Warning",
                            "No annotation file found. Skip the synteny analysis in WGD pipeline",
                            type="warning",
                        )
                    }
                    writeLines(
                        paste0(
                            "wgd mix -ni 100 --method bgmm 02.wgd_ksd/", latin_name, ".fa.ks.tsv",
                            " -o 04.wgd_mix"
                        ),
                        wgd_cmd_con
                    )
                    close(wgd_cmd_con)

                    species_info_file <- paste0(working_wd, "/Species.info.xls")
                    write.table(
                        paste(species_info_list, collapse="\t"),
                        file=species_info_file,
                        sep="\t",
                        col.names=FALSE,
                        row.names=FALSE,
                        quote=FALSE
                    )

                    incProgress(amount=1)
                    updateProgress("wgd_progress_container_js", 100, "Create wgd code")
                    Sys.sleep(2)
                })
                shinyjs::runjs('$("#progress_modal").modal("hide");');
            }
        }else{
            shinyalert(
                "Oops",
                "No cds or annotation file found. Please upload the data first",
                type="error",
            )
        }
    }

    wgdcommmandFile <- paste0(working_wd, "/wgd_wd/run_wgd.sh")
    if( file.exists(wgdcommmandFile) ){
        output$WgdCommandTxt <- renderText({
            command_info <- readChar(
                wgdcommmandFile,
                file.info(wgdcommmandFile)$size
            )
        })
        output$wgdParameterPanel <- renderUI({
            fluidRow(
                div(
                    style="padding-bottom: 10px;
                           padding-left: 20px;
                           padding-right: 20px;
                           max-width: 100%;
                           overflow-x: auto;",
                    column(
                        12,
                        h5(HTML(paste0("The command line for <font color='green'><b><i>wgd</i></b></font>:"))),
                        verbatimTextOutput(
                            "WgdCommandTxt",
                            placeholder=TRUE
                        )
                    )
                )
            )
        })
    }
})

observeEvent(input$ksrates_go, {
    working_wd <- data_preparation_dir_Val()
    original_data_wd <- original_data_wd_Val()
    if( is.null(input$select_focal_species) ){
        shinyalert(
            "Oops!",
            "Please define focal species first, then switch this on ...",
            type="error"
        )
    }
    else if( is.null(input$newick_tree) ){
        shinyalert(
            "Oops!",
            "Please upload the newick tree first, then switch this on ...",
            type="error"
        )
    }else{
        if( is.null(input$upload_data_file) ){
            if( is.null(input[[paste0("proteome_", 2)]]) ){
                shinyalert(
                    "Oops!",
                    "Please upload the data from at least two species to trigger the ksrates pipeline, then switch this on ...",
                    type="error"
                )
            }
            else{
                shinyjs::runjs('$("#progress_modal").modal("show");')
                progress_data <- list(
                    "actionbutton"="ksrates_go",
                    "container"="ksrates_progress_container_js"
                )
                session$sendCustomMessage(
                    "Progress_Bar_Complete",
                    progress_data
                )
                withProgress(message='Creating in progress', value=0, {
                    incProgress(amount=.15, message="Preparing ksrates configure file...")
                    updateProgress(
                        container="ksrates_progress_container_js",
                        width=15,
                        type="Create ksrates code"
                    )
                    Sys.sleep(1)

                    ksratesDir <- paste0(working_wd, "/ksrates_wd")
                    if( !file.exists(ksratesDir) ){
                        dir.create(ksratesDir)
                        # system(paste("chmod -R 777", ksratesDir))
                    }
                    ksratesconf <- paste0(ksratesDir, "/ksrates_conf.txt")
                    speciesinfoconf <- paste0(working_wd, "/Species.info.xls")

                    create_ksrates_configure_file_v2(input, ksratesconf, speciesinfoconf)

                    incProgress(amount=.6, message="Preparing ksrates expert parameters...")
                    updateProgress(
                        container="ksrates_progress_container_js",
                        width=60,
                        type="Create ksrates code"
                    )
                    Sys.sleep(1)

                    # create Ksrate expert parameters file
                    ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                    create_ksrates_expert_parameter_file(ksratesexpert)

                    updateProgress("ksrates_progress_container_js", 80, "Create ksrates code")
                    incProgress(amount=.8, message="Creating ksrates Runing Script ...")
                    Sys.sleep(1)

                    ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                    ksrates_cmd <- create_ksrates_cmd(input, "ksrates_conf.txt", ksrates_cmd_sh_file)

                    system(
                        paste(
                            "cp",
                            paste0(getwd()[1], "/tools/run_paralog_ks_rest_species.sh"),
                            ksratesDir
                        )
                    )

                    updateProgress("ksrates_progress_container_js", 100, "Create ksrates code")
                    incProgress(amount=1)
                    Sys.sleep(1)
                })
                shinyjs::runjs('$("#progress_modal").modal("hide");');
            }
        }
        else{
            if( !is.null(input$selected_data_files) ){
                shinyjs::runjs('$("#progress_modal").modal("show");')
                progress_data <- list("actionbutton"="ksrates_go",
                                      "container"="ksrates_progress_container_js")
                session$sendCustomMessage(
                    "Progress_Bar_Complete",
                    progress_data
                )

                data_table <- read_data_file(input$upload_data_file)
                ncols <- ncol(data_table)
                nrows <- nrow(data_table)
                if( nrows > 1 ){
                    if( is.null(input$select_focal_species) || input$select_focal_species == ""){
                        shinyalert(
                            "Oops!",
                            "Please define focal species first, then switch this on ...",
                            type="error"
                        )
                    }
                    else if( is.null(input$newick_tree) ){
                        shinyalert(
                            "Oops!",
                            "Please upload the newick tree first, then switch this on ...",
                            type="error"
                        )
                    }
                    else{
                        withProgress(message='Creating in progress', value=0, {
                            incProgress(amount=.35, message="Processing CDS / Annotation Files ...")
                            updateProgress("ksrates_progress_container_js", 35, "Create ksrates code")
                            Sys.sleep(1)

                            ksratesDir <- paste0(working_wd, "/ksrates_wd")
                            if( !file.exists(ksratesDir) ){
                                dir.create(ksratesDir)
                                # system(paste("chmod -R 777", ksratesDir))
                            }
                            ksratesconf <- paste0(ksratesDir, "/ksrates_conf.txt")
                            speciesinfoconf <- paste0(working_wd, "/Species.info.xls")
                            create_ksrates_configure_file_based_on_table(
                                data_table,
                                input$select_focal_species,
                                input$newick_tree,
                                ksratesconf,
                                speciesinfoconf,
                                working_wd
                            )

                            incProgress(amount=.6, message="Preparing ksrates Expert Parameters ...")
                            updateProgress("ksrates_progress_container_js", 60, "Create ksrates code")
                            Sys.sleep(1)

                            ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
                            create_ksrates_expert_parameter_file(ksratesexpert)

                            incProgress(amount=.8, message="Create ksrates Running Script ...")
                            updateProgress("ksrates_progress_container_js", 80, "Create ksrates code")
                            Sys.sleep(1)

                            ksrates_cmd_sh_file <- paste0(ksratesDir, "/run_ksrates.sh")
                            ksrates_cmd <- create_ksrates_cmd_from_table(data_table, "ksrates_conf.txt", ksrates_cmd_sh_file, input$select_focal_species)

                            system(
                                paste(
                                    "cp",
                                    paste0(getwd()[1], "/tools/run_paralog_ks_rest_species.sh"),
                                    ksratesDir
                                )
                            )

                            incProgress(amount=1)
                            updateProgress("ksrates_progress_container_js", 100, "Create ksrates code")
                            Sys.sleep(1)
                        })
                        shinyjs::runjs('$("#progress_modal").modal("hide");');
                    }
                }
            }else{
                shinyalert(
                    "Oops",
                    "No cds or annotation file found. Please upload the data first",
                    type="error",
                )
            }
        }
    }

    ksratesconf <- paste0(working_wd, "/ksrates_wd/ksrates_conf.txt")
    ksratescommad <- paste0(working_wd, "/ksrates_wd/run_ksrates.sh")
    if( file.exists(ksratescommad) && file.exists(ksratesconf)){
        output$ksratesConfigureFileTxt <- renderText({
            rawText <- readChar(ksratesconf, file.info(ksratesconf)$size)
        })
        output$ksratesCommandTxt <- renderText({
            CommandText <- readChar(ksratescommad, file.info(ksratescommad)$size)
        })
        output$ksratesParameterPanel <- renderUI({
            fluidRow(
                div(
                    style="padding-bottom: 10px;
                           padding-left: 20px;
                           padding-right: 20px;
                           max-width: 100%;
                           overflow-x: auto;",
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The configure file for ", "<span style=\"color:green\"><b><i>ksrates</i></b></span>", ":"))),
                            verbatimTextOutput(
                                "ksratesConfigureFileTxt",
                                placeholder=TRUE
                            )
                        )
                    ),
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The command line for <font color='green'><b><i>ksrates</i></b></font>:"))),
                            verbatimTextOutput(
                                "ksratesCommandTxt",
                                placeholder=TRUE
                            )
                        )
                    )
                )
            )
        })
    }
})

observeEvent(input$iadhore_go, {
    working_wd <- data_preparation_dir_Val()
    original_data_wd <- original_data_wd_Val()
    species_info <- paste0(working_wd, "/Species.info.xls")
    if( is.null(input$upload_data_file) & is.null(input[[paste0("gff_", 1)]]) ){
        shinyalert(
            "Oops!",
            "Please upload the annotation file (gff) for at least one species to trigger the i-ADHoRe pipeline, then switch this on ...",
            type="error"
        )
    }
    else if ( !file.exists(species_info) ){
        shinyalert(
            "Oops",
            "Please click the Create-ksrates-Codes button first, then switch this on ...",
            type="error"
        )
    }
    else{
        shinyjs::runjs('$("#progress_modal").modal("show");')
        progress_data <- list(
            "actionbutton"="iadhore_go",
            "container"="iadhore_progress_container_js"
        )
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.2, message="Preparing i-ADHoRe configure file...")
            updateProgress("iadhore_progress_container_js", 20, "Creat i-ADHoRe code")
            Sys.sleep(1)

            syn_dir <- paste0(working_wd, "/i-ADHoRe_wd")
            if( !file.exists(syn_dir) ){
                dir.create(syn_dir)
                # system(paste("chmod -R 777", syn_dir))
            }
            cmd_file <- paste0(syn_dir, "/run_diamond_iadhore.sh")
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/running_diamond.shell"),
                    syn_dir
                )
            )
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/computing_anchorpoint_ks.MultiThreads.shell"),
                    syn_dir
                )
            )

            incProgress(amount=.3, message="Dealing with gff files ...")
            updateProgress("iadhore_progress_container_js", 30, "Creat i-ADHoRe code")
            Sys.sleep(1)

            system(
                paste(
                    "sh tools/preparing_iadhore_inputs.shell",
                    species_info,
                    syn_dir
                )
            )
            incProgress(amount=.7, message="Generating the codes for diamond and i-ADHoRe")
            updateProgress("iadhore_progress_container_js", 70, "Creat i-ADHoRe code")
            Sys.sleep(1)

            if( isTruthy(input$multiple_iadhore) ){
                system(
                    paste(
                        "sh tools/generating_iadhore_codes.local.shell",
                        species_info,
                        syn_dir,
                        cmd_file,
                        getwd()[1],
                        "running_diamond.shell",
                        4,
                        "mode"
                    )
                )
            }else{
                system(
                    paste(
                        "sh tools/generating_iadhore_codes.local.shell",
                        species_info,
                        syn_dir,
                        cmd_file,
                        getwd()[1],
                        "running_diamond.shell",
                        4
                    )
                )
            }
            incProgress(amount=1, message="Done")
            updateProgress("iadhore_progress_container_js", 100, "Creat i-ADHoRe code")
            Sys.sleep(1)
        })
        shinyjs::runjs('$("#progress_modal").modal("hide");');
    }

    iadhorecommandFile <- paste0(working_wd, "/i-ADHoRe_wd/run_diamond_iadhore.sh")
    if( file.exists(iadhorecommandFile) ){
        output$IadhoreCommandTxt <- renderText({
            command_info <- readChar(
                iadhorecommandFile,
                file.info(iadhorecommandFile)$size
            )
        })
        output$iadhoreParameterPanel <- renderUI({
            fluidRow(
                div(
                    style="padding-bottom: 10px;
                           padding-left: 20px;
                           padding-right: 20px;
                           max-width: 100%;
                           overflow-x: auto;",
                    fluidRow(
                        column(
                            12,
                            h5(HTML(paste0("The command line for <font color='green'><b><i>i-ADHoRe</i></b></font>:"))),
                            verbatimTextOutput(
                                "IadhoreCommandTxt",
                                placeholder=TRUE
                            )
                        )
                    )
                )
            )
        })
    }
})

observeEvent(input$orthofinder_go, {
    working_wd <- data_preparation_dir_Val()
    original_data_wd <- original_data_wd_Val()
    species_info <- paste0(working_wd, "/Species.info.xls")
    if( file.exists(species_info) ){
        shinyjs::runjs('$("#progress_modal").modal("show");')
        progress_data <- list(
            "actionbutton"="orthofinder_go",
            "container"="orthofinder_progress_container_js"
        )
        session$sendCustomMessage(
            "Progress_Bar_Complete",
            progress_data
        )
        withProgress(message='Creating in progress', value=0, {
            incProgress(amount=.1, message="Preparing OrthoFinder input file ...")
            updateProgress("orthofinder_progress_container_js", 10, "Create OrthoFinder code")
            Sys.sleep(1)

            orthofinder_dir <- paste0(working_wd, "/OrthoFinder_wd")
            if( !dir.exists(orthofinder_dir) ){
                dir.create(orthofinder_dir)
                # system(paste("chmod -R 777", orthofinder_dir))
            }
            ds_tree_dir <- paste0(orthofinder_dir, "/ds_tree_wd")
            if( !dir.exists(ds_tree_dir) ){
                dir.create(ds_tree_dir)
                # system(paste("chmod -R 777", ds_tree_dir))
            }
            cmd_file <- paste0(orthofinder_dir, "/run_orthofinder.sh")
            incProgress(amount=.1, message="Create inputs file for OrthoFinder ...")
            system(
                paste(
                    "cp",
                    paste0(getwd()[1], "/tools/computing_Ks_tree_of_SingleCopyOrthologues.shell"),
                    ds_tree_dir
                )
            )
            incProgress(amount=.3, message="Translate CDS into proteins ...")
            updateProgress("orthofinder_progress_container_js", 30, "Create OrthoFinder code")
            Sys.sleep(1)

            system(
                paste(
                    "Rscript tools/prepare_orthofinder.R",
                    "-i", species_info,
                    "-o", orthofinder_dir,
                    "-s", gsub(" ", "_", input$select_focal_species),
                    "-c", cmd_file
                )
            )

            incProgress(amount=1, message="Done")
            updateProgress("orthofinder_progress_container_js", 100, "Create OrthoFinder code")
            Sys.sleep(1)
        })
        shinyjs::runjs('$("#progress_modal").modal("hide");');
    }
    else{
        shinyalert(
            "Oops",
            "Please click the Create-Ksrate-Codes button first, then switch this on ...",
            type="error"
        )
    }

    orthofinderCommandFile <- paste0(working_wd, "/OrthoFinder_wd/run_orthofinder.sh")
    if( file.exists(orthofinderCommandFile) ){
        output$OrthoFinderCommandTxt <- renderText({
            command_info <- readChar(
                orthofinderCommandFile,
                file.info(orthofinderCommandFile)$size
            )
        })
        output$orthofinderParameterPanel <- renderUI({
            fluidRow(
                div(
                    style="padding-bottom: 10px;
                           padding-left: 20px;
                           padding-right: 20px;
                           max-width: 100%;
                           overflow-x: auto;",
                    fluidRow(
                        h5(HTML(paste0("The command line for <font color='#5A5AAD'><i><b>OrthoFinder</b></i></font>:"))),
                        column(
                            12,
                            verbatimTextOutput(
                                "OrthoFinderCommandTxt",
                                placeholder=TRUE
                            )
                        )
                    )
                )
            )
        })
    }
})

observeEvent(input$go_codes_wgd, {
    working_wd <- data_preparation_dir_Val()
    wgdcommmandFile <- paste0(working_wd, "/wgd_wd/run_wgd.sh")
    if( file.exists(wgdcommmandFile) ){
        showModal(
            modalDialog(
                title="",
                size="xl",
                uiOutput("wgdParameterPanel")
            )
        )
    }else{
        shinyalert(
            "Oops",
            "Please click the Create-wgd-Codes button first, then switch this on ...",
            type="error"
        )
    }
})

observeEvent(input$go_codes_ksrates, {
    working_wd <- data_preparation_dir_Val()
    ksratescommadFile <- paste0(working_wd, "/ksrates_wd/run_ksrates.sh")
    if( !file.exists(ksratescommadFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-ksrates-Codes button first, then switch this on ...",
            type="error"
        )
    }
    else{
        showModal(
            modalDialog(
                title="",
                size="xl",
                uiOutput("ksratesParameterPanel")
            )
        )
    }
})

observeEvent(input$go_codes_iadhore, {
    working_wd <- data_preparation_dir_Val()
    iadhorecommandFile <- paste0(working_wd, "/i-ADHoRe_wd/run_diamond_iadhore.sh")
    if( !file.exists(iadhorecommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-i-ADHoRe-Codes button first, then switch this on ...",
            type="error"
        )
    }
    else{
        showModal(
            modalDialog(
                title="",
                size="xl",
                uiOutput("iadhoreParameterPanel")
            )
        )
    }
})

observeEvent(input$go_codes_orthofinder, {
    working_wd <- data_preparation_dir_Val()
    orthofinderCommandFile <- paste0(working_wd, "/OrthoFinder_wd/run_orthofinder.sh")
    if( !file.exists(orthofinderCommandFile) ){
        shinyalert(
            "Oops",
            "Please click the Create-OrthoFinder-Codes button first, then switch this on ...",
            type="error"
        )
    }
    else{
        showModal(
            modalDialog(
                title="",
                size="xl",
                uiOutput("orthofinderParameterPanel")
            )
        )
    }
})

observeEvent(input$job_run_server, {
    if( input$number_of_study_species > 5 ){
        shinyalert(
            "Oops!",
            "To control resource usage, the PSB computing cluster restricts studies to a maximum of five species. Please execute the generated scripts locally.",
            type="error"
        )
    }else{
        working_wd <- data_preparation_dir_Val()
        unique_id <- gsub("Analysis_", "", basename(working_wd))

        output$job_unique_id <- renderUI({
            column(
                12,
                "Job id:",
                verbatimTextOutput("job_id_text"),
                HTML("Make sure to take note of this <b>ID</b> as you will need it for downloading the results from our server.")
            )
        })
        output$job_id_text <- renderText({
            unique_id
        })

        # submit the job to psb computing cluster
        sh_files <- list.files(working_wd, pattern="\\.sh$", full.names=TRUE, recursive=TRUE)

        ksrates_sh_file <- sh_files[grepl("run_ksrates.sh", sh_files)]

        ksrates_rest_sh_file <- sh_files[grepl("run_paralog_ks_rest_species.sh", sh_files)]

        iadhore_sh_file <- sh_files[grepl("run_diamond_iadhore.sh", sh_files)]

        sh_files <- sh_files[!(sh_files %in% c(ksrates_sh_file[1], ksrates_rest_sh_file[1]))]

        system(
            paste(
                "cat",
                ksrates_sh_file[1],
                ksrates_rest_sh_file[1],
                "| grep -v '#SBATCH'",
                "| sed 's/--n-threads 1/--n-threads 2/'",
                ">",
                paste0(dirname(ksrates_sh_file[1]), "/ksrates_qsub.sh")
            )
        )

        system(
            paste(
                "echo 'cd ..'",
                ">>",
                paste0(dirname(ksrates_sh_file[1]), "/ksrates_qsub.sh")
            )
        )

        system(
            paste(
                "head -n 2",
                paste0(getwd()[1], "/tools/archive_compress_files_for_visualization.shell"),
                ">>",
                paste0(dirname(ksrates_sh_file[1]), "/ksrates_qsub.sh")
            )
        )

        system(
            paste(
                "echo 'cd ..'",
                ">>",
                iadhore_sh_file[1]
            )
        )

        system(
            paste(
                "sed -n '4,13p'",
                paste0(getwd()[1], "/tools/archive_compress_files_for_visualization.shell"),
                ">>",
                iadhore_sh_file[1]
            )
        )

        sh_files <- c(
            paste0(dirname(ksrates_sh_file[1]), "/ksrates_qsub.sh"),
            sh_files
        )

        shinyjs::runjs('$("#progress_modal").modal("show");')
        shiny::withProgress(message='Submit job in progress', value=0, {

            total_jobs <- length(sh_files)
            progress_increment <- 0.8 / total_jobs

            submit_job <- function(script_file) {
                shiny::incProgress(
                    amount=progress_increment,
                    message=paste0("Dealing with ", basename(script_file), " ...")
                )

                qsub_wd <- dirname(script_file)
                setwd(qsub_wd)

                if (length(grepl("ksrates_qsub.sh", script_file)) > 0) {
                    # system(paste("qsub -cwd -l h_vmem=8g", script_file))
                    Sys.sleep(10)
                } else if (length(grepl("run_diamond_iadhore.sh", script_file)) > 0) {
                    # system(paste("qsub -cwd -l h_vmem=8g", script_file))
                    Sys.sleep(10)
                } else if (length(grepl("run_wgd.sh", script_file)) > 0) {
                    # system(paste("qsub -cwd -l h_vmem=8g", script_file))
                    Sys.sleep(10)
                } else if (length(grepl("run_orthofinder.sh", script_file)) > 0) {
                    # system(paste("qsub -cwd -l h_vmem=8g -pe serial 4", script_file))
                    Sys.sleep(10)
                }
            }
            lapply(sh_files, submit_job)

            incProgress(amount=1, message="Done")
        })
        setwd(working_wd)
        shinyjs::runjs('$("#progress_modal").modal("hide");');
    }
})

observeEvent(input$comfirm_email, {
    working_wd <- data_preparation_dir_Val()
    if( is.null(working_wd) ){
        shinyalert(
            "Oops",
            "Please upload the data first, then switch this on ...",
            type="error"
        )
    }else{
        if( isTruthy(input$users_email_address) ){
            email_file_path <- paste0(working_wd, "/user_email.txt")

            writeLines(input$users_email_address, email_file_path)
            shinyalert(
                "Your email",
                input$users_email_address,
                type="info"
            )
        }else{
            shinyalert(
                "Oops",
                "Please input the email address first, then switch this on ...",
                type="error"
            )
        }
    }
})

output$search_download_page <- renderUI({
    div(class="boxLike",
        style="background-color: #FFFFF4;",
        h4(icon("download"), "Downlaod Result for the PSB server"),
        hr(class="setting"),
        fluidRow(
            column(
                12,
                HTML("Please enter the <b>identifier</b> generated by <b>shinyWGD</b> after submitting your job to the <b>PSB computing cluster</b> below."),
            ),
            column(
                12,
                fluidRow(
                    column(
                        4,
                        textInput(
                            inputId="job_search_identifier",
                            label="",
                            value="",
                            width="100%",
                            placeholder="identifier"
                        )
                    ),
                    column(
                        1,
                        actionButton(
                            inputId="comfirm_job_search",
                            "",
                            width="40px",
                            icon=icon("search"),
                            status="secondary",
                            class="my-start-button-class",
                            style="color: #fff;
                                   background-color: #8080C0;
                                   border-color: #fff;
                                   margin: 22px 0px 0px 0px;"
                        )
                    )
                ),
                fluidRow(
                    column(
                        12,
                        div(
                            style="padding-bottom: 10px;
                                   padding-top:30px;",
                            id="job_search_progress_container_js"
                        )
                    )
                )
            ),
            column(
                12,
                div(
                    style="background-color: #F8F8FF;
                           padding: 10px 10px 10px 10px;
                           border-radius: 10px;
                           width: 450px;",
                    uiOutput("unfinished_job_panel")
                )
            ),
            column(
                12,
                uiOutput("download_output_panel")
            )
        )
    )
})

updateProgressDownload <- function(container, width, type) {
    session$sendCustomMessage(
        "UpdateProgressBarDownload",
        list(container=container, width=width, type=type)
    )
}

observeEvent(input$comfirm_job_search, {
    # data_wd <- "/www/bioinformatics01_rw/ShinyWGD"
    data_wd <- "/var/folders/dm/nv89839s3dngv7d76s59n0rr0000gn/T/Rtmpg0qnEU/"
    dirs_list <- list.dirs(path=data_wd, full.names=TRUE, recursive=FALSE)
    dirs_list <- dirs_list[grep("Analysis_", dirs_list)]
    if( isTruthy(input$job_search_identifier) ){
        if( paste0("Analysis_", input$job_search_identifier) %in% basename(dirs_list) ){
            progress_data <- list(
                "actionbutton"="job_search_identifier",
                "container"="job_search_progress_container_js"
            )
            session$sendCustomMessage(
                "Progress_Bar_Complete",
                progress_data
            )
            updateProgressDownload("job_search_progress_container_js", 10, "Searching database")

            job_wd <- dirs_list[grep(input$job_search_identifier, dirs_list)]
            Sys.sleep(2)
            updateProgressDownload("job_search_progress_container_js", 20, "Checking job status")
            compressed_job_files_list <- list.files(
                path=job_wd,
                pattern="\\.tar\\.gz$",
                full.names=TRUE
            )

            if( file.exists(paste0(job_wd, "/OrthoFinder_wd/OrthoFinderOutput_for_Whale.tar.gz")) ){
                compressed_job_files_list <- c(
                    compressed_job_files_list,
                    paste0(job_wd, "/OrthoFinder_wd/OrthoFinderOutput_for_Whale.tar.gz")
                )
            }

            if( file.exists(paste0(job_wd, "/OrthoFinder_wd/ds_tree_wd.tar.gz")) ){
                compressed_job_files_list <- c(
                    compressed_job_files_list,
                    paste0(job_wd, "/OrthoFinder_wd/ds_tree_wd.tar.gz")
                )
            }

            output_compressed_files_name <- c(
                "Ks_Data_for_Visualization.tar.gz",
                "Collinear_Data_for_Visualization.tar.gz",
                "OrthoFinderOutput_for_Whale.tar.gz",
                "ds_tree_wd.tar.gz"
            )

            not_existed_names_list <- setdiff(output_compressed_files_name, basename(compressed_job_files_list))

            job_status_list <- c()
            if( length(not_existed_names_list) > 0 ){
                for( i in 1:length(not_existed_names_list) ){
                    if( not_existed_names_list[i] == "Ks_Data_for_Visualization.tar.gz" ){
                        job_status_list <- c(
                            job_status_list,
                            "<b>ksrates</b> is still running. Please wait ..."
                        )
                    }else if( not_existed_names_list[i] == "Collinear_Data_for_Visualization.tar.gz" ){
                        job_status_list <- c(
                            job_status_list,
                            "<b>i-ADHoRe</b> is still running. Please wait ..."
                        )
                    }else if( not_existed_names_list[i] == "ds_tree_wd.tar.gz" ){
                        job_status_list <- c(
                            job_status_list,
                            "<b><i>K</i><sub>s</sub> unit tree</b> is still computing. Please wait ..."
                        )
                    }else if( not_existed_names_list[i] == "OrthoFinderOutput_for_Whale.tar.gz" ){
                        job_status_list <- c(
                            job_status_list,
                            "<b>OrthoFinder</b> is still running. Please wait ..."
                        )
                    }

                    updateProgressDownload(
                        "job_search_progress_container_js",
                        20 + 10 * i,
                        "Checking job status"
                    )
                }
                output$download_output_panel <- renderUI({
                    ""
                })
            }else{
                updateProgressDownload(
                    "job_search_progress_container_js",
                    60,
                    "Checking job status"
                )

                job_status_list <- c(
                    job_status_list,
                    "<b>All jobs</b> are done.<br>You can click the download button to download results now ..."
                )

                output$download_output_panel <- renderUI({
                    column(
                        12,
                        hr(class="setting"),
                        downloadButton(
                            outputId="wgd_ksrates_ouput_download",
                            label="Download Output Data",
                            icon=icon("download"),
                            title="Click to download the output",
                            status="secondary",
                            class="my-download-button-class",
                            style="color: #fff;
                               background-color: #6B8E23;
                               border-color: #fff;
                               padding: 5px 14px 5px 14px;
                               margin: 10px 5px 5px 5px;"
                        )
                    )
                })

                output$wgd_ksrates_ouput_download <- downloadHandler(
                    filename=function(){
                        paste0(input$job_search_identifier, ".output.tgz")
                    },
                    content=function(file){
                        withProgress(message='Downloading in progress', value=0, {
                            setwd(job_wd)
                            incProgress(amount=.1, message="Compressing files...")

                            shinyalert(
                                "Note",
                                "Pleae wait for compressing the files. Do not close the page.",
                                type="info"
                            )

                            files_to_compress <- gsub("^.*?Analysis_2023_12_16_01_55_31/", "", compress_job_files_list)

                            system(
                                paste(
                                    "tar czf",
                                    file,
                                    paste(shQuote(files_to_compress), collapse=' ')
                                )
                            )

                            incProgress(amount=.9, message="Downloading file ...")
                            incProgress(amount=1)
                            Sys.sleep(.1)
                        })
                    }
                )
            }


            output$unfinished_job_panel <- renderUI({
                HTML(paste0(job_status_list, collapse="<br>"))
            })

            Sys.sleep(2)
            updateProgressDownload("job_search_progress_container_js", 100, "Done")
        }else{
            shinyalert(
                "Oops",
                "The job identifier you provided is not found in the database. Please enter the correct one.",
                type="error"
            )
        }
    }
    else{
        shinyalert(
            "Oops",
            "Please enter the job identifier first, then switch this on ...",
            type="error"
        )
    }
})

# Create analysis data to download
output$wgd_ksrates_data_download <- downloadHandler(
    filename=function(){
        working_wd <- data_preparation_dir_Val()
        paste0(basename(working_wd), ".tgz")
    },
    content=function(file){
        working_wd <- data_preparation_dir_Val()
        original_data_wd <- original_data_wd_Val()
        if( !is.null(original_data_wd) ){
            unlink(original_data_wd)
        }
        ksratescommadFile <- paste0(working_wd, "/ksrates_wd/run_ksrates.sh")
        wgdcommmandFile <- paste0(working_wd, "/wgd_wd/run_wgd.sh")
        if( !file.exists(wgdcommmandFile) & !file.exists(ksratescommadFile) ){
            shinyalert(
                "Oops",
                "Please click the Create-wgd-Codes or Create-ksrates-Codes button first, then switch this on ...",
                type="error"
            )
            return(NULL)
        }
        else{
            withProgress(message='Downloading in progress', value=0, {
                species_info <- paste0(working_wd, "/Species.info.xls")
                species_data <- read.delim(
                    species_info,
                    header=FALSE,
                    sep="\t",
                    stringsAsFactors=FALSE
                )

                species_data$V1 <- gsub("_", " ", species_data$V1)
                species_data$V2 <- gsub("^.*/", "", species_data$V2)
                species_data$V3 <- gsub("^.*/", "", species_data$V3)

                write.table(
                    species_data,
                    file=species_info,
                    sep="\t",
                    quote=FALSE,
                    col.names=FALSE,
                    row.names=FALSE
                )

                system(
                    paste("rm -rf", original_data_wd)
                )

                incProgress(amount=.1, message="Compressing files...")
                shinyalert(
                    "Note",
                    "Pleae wait for compressing the files. Do not close the page.",
                    type="info"
                )
                run_dir <- getwd()
                setwd(dirname(working_wd))
                system(
                    paste(
                        "tar czf",
                        file,
                        basename(working_wd)
                    )
                )

                incProgress(amount=.9, message="Downloading file ...")
                incProgress(amount=1)
                Sys.sleep(.1)
                setwd(run_dir)
            })
        }
    }
)

# remove the folder created two weeks ago
# find_folders_two_weeks_ago <- function(base_dir) {
#     folders <- list.files(base_dir, full.names=TRUE)
#
#     pattern <- "\\d{4}_\\d{2}_\\d{2}_\\d{2}_\\d{2}_\\d{2}"
#     matching_folders <- grep(pattern, folders, value=TRUE)
#
#     folder_dates <- as.Date(
#         sub(".*_(\\d{4}_\\d{2}_\\d{2}_\\d{2}_\\d{2}_\\d{2}).*", "\\1", matching_folders),
#         format="%Y_%m_%d_%H_%M_%S"
#     )
#
#     two_weeks_ago <- Sys.Date() - 14
#
#     two_weeks_ago_folders <- matching_folders[folder_dates <= two_weeks_ago]
#
#     sapply(two_weeks_ago_folders, function(folder) system(paste("rm -rf", shQuote(folder))))
#
#     return(two_weeks_ago_folders)
# }
#
# timer <- reactiveTimer(60 * 1000)
#
# observe({
#     timer()
#
#     data_dir <- "/var/folders/dm/nv89839s3dngv7d76s59n0rr0000gn/T/RtmpmsMCLT"
#     removed_projects_log <- paste0(data_dir, "/removed_projects.xls")
#     if( format(Sys.time(), "%H:%M") == "17:22"){
#         folders_needed_to_be_removed <- find_folders_two_weeks_ago(data_dir)
#         if( file.exists(removed_projects_log)) {
#             write.table(
#                 folders_needed_to_be_removed,
#                 removed_projects_log,
#                 append=TRUE,
#                 col.names=FALSE,
#                 row.names=FALSE,
#                 quote=FALSE
#             )
#         }else{
#             write.table(
#                 folders_needed_to_be_removed,
#                 removed_projects_log,
#                 col.names=FALSE,
#                 row.names=FALSE,
#                 quote=FALSE
#             )
#         }
#     }
# })

