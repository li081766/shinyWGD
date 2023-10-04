Codes_checking_ui <- tabPanel(
    HTML("Codes"),
    value='codes_page',
    fluidRow(
        column(
            12,
            uiOutput("wgdParameterPanel")
        ),
        column(
            12,
            uiOutput("ksratesParameterPanel")
        ),
        column(
            12,
            uiOutput("iadhoreParameterPanel")
        ),
        column(
            12,
            uiOutput("orthofinderParameterPanel")
        ),
        column(
            12,
            uiOutput("whaleParameterPanel")
        ),
        column(
            id="refs",
            width=12,
            div(class="boxLike",
                style="background-color: #f0f0f0",
                h5(icon("book"), "References"),
                hr(class="setting"),
                fluidRow(
                    column(
                        12,
                        h6("Please refer to the documentations of packages for details:"),
                        p(tags$a(href="https://github.com/arzwa/wgd", "https://github.com/arzwa/wgd")),
                        p(tags$a(href="https://github.com/VIB-PSB/ksrates", "https://github.com/VIB-PSB/ksrates")),
                        p(tags$a(href="https://www.vandepeerlab.org/?q=tools/i-adhore30", "https://www.vandepeerlab.org/?q=tools/i-adhore30")),
                        p(tags$a(href="https://github.com/arzwa/Whale.j", "https://github.com/arzwa/Whale.jl")),
                        h6("If you use the packages, please also cite their original papers:"),
                        p(HTML("Zwaenepoel, A., and Van de Peer, Y., (2019) <i>wgd - simple command line tools for the analysis of ancient whole genome duplications</i>. <b>Bioinformatics</b>, bty915")),
                        p(HTML("Sensalari, C., Maere, S., and Lohaus, R., (2021) <i>ksrates: positioning whole-genome duplications relative to speciation events in KS distributions</i>. <b>Bioinformatics</b>, btab602")),
                        p(HTML("Proost, S., Fostier, J., De Witte, D., Dhoedt, B., Demeester, P., Van de Peer, Y. and Vandepoele, K., (2012) <i>i-ADHoRe 3.0—fast and sensitive detection of genomic homology in extremely large data sets</i>. <b>Nucleic acids research</b>, 40(2), pp.e11-e11.")),
                        p(HTML("Zwaenepoel, A., and Van de Peer, Y., (2019) <i>Inference of Ancient Whole-Genome Duplications and the Evolution of Gene Duplication and Loss Rates</i>. <b>Molecular biology and evolution</b>, 36(7), pp.1384-1404."))
                    )
                )
            )
        )
    ),
    icon=icon("code")
)
