# ShinyWGD <img src="man/figures/stanlogo.png" align="right" width="120" />

<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/ShinyWGD?color=blue)](https://cran.r-project.org/web/packages/ShinyWGD)
[![Downloads](https://cranlogs.r-pkg.org/badges/ShinyWGD?color=blue)](https://cran.rstudio.com/package=ShinyWGD)
<!-- badges: end -->

### Overview

`ShinyWGD` can prepare the input and command lines for [`wgd`](https://github.com/arzwa/wgd), [`ksrates`](https://github.com/VIB-PSB/ksrates), [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30), and [`OrthoFinder`](https://github.com/davidemms/OrthoFinder). 

`ShinyWGD` can also assist users in using [`Whale`](https://github.com/arzwa/whaleprep/tree/master) to infer reconciled gene trees and parameters of a model of gene family evolution given a known species tree.

After directly uploading the output of `wgd`, `ksrates`, `i-ADHoRe`, or `OrthoFinder`, `ShinyWGD` can study the whole genome duplication events (WGDs).

### Installation

* Install from CRAN:

```r
install.packages("ShinyWGD")
```

* Install the latest development version from GitHub (requires [devtools](https://github.com/hadley/devtools) package):

```r
if (!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("li081766/ShinyWGD", dependencies = TRUE, build_vignettes = FALSE)
```

### Examples

Please refer to the [ShinyWGD server](https://bioinformatics.psb.ugent.be/webtools/ShinyWGD) to see the detailed usage. 


### The structure of`ShinyWGD`

- ##### <img src="inst/ShinyWGD/www/images/house-solid.svg" alt="Icon" width="15" height="15"> Home
- ##### <img src="inst/ShinyWGD/www/images/terminal-solid.svg" alt="Icon" width="15" height="15"> Scripts
  - <img src="inst/ShinyWGD/www/images/microscope-solid.svg" alt="Icon" width="15" height="15"> Data Preparation
  - <img src="inst/ShinyWGD/www/images/code-solid.svg" alt="Icon" width="15" height="15"> Codes
- ##### <img src="inst/ShinyWGD/www/images/pencil-solid.svg" alt="Icon" width="15" height="15"> Analysis
  - <img src="inst/ShinyWGD/www/images/ksIcon.svg" alt="Icon" width="20" height="20"> Age Distribution Analysis
  - <img src="inst/ShinyWGD/www/images/syntenyIcon.svg" alt="Icon" width="20" height="20"> Synteny Analysis
  - <img src="inst/ShinyWGD/www/images/ksTreeIcon.svg" alt="Icon" width="20" height="20"> Tree Building
  - <img src="inst/ShinyWGD/www/images/treeReconciliationIcon.svg" alt="Icon" width="20" height="20"> Gene Tree – Species Tree Reconciliation Analysis
- ##### <img src="inst/ShinyWGD/www/images/question-solid.svg" alt="Icon" width="15" height="15"> Help

### Dependencies

- ##### External software
  - [`wgd`](https://github.com/arzwa/wgd)
  - [`ksrates`](https://github.com/VIB-PSB/ksrates)
  - [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30)
  - [`Whale`](https://github.com/arzwa/Whale.jl/tree/master)
  - [`OrthoFinder`](https://github.com/davidemms/OrthoFinder)

- ##### R packages
  - `{shiny}`
  - `{shinyjs}`
  - `{shinyFiles}`
  - `{shinyBS}`
  - `{shinyWidgets}`
  - `{shinyalert}`
  - `{bslib}`
  - `{bsplus}`
  - `{htmltools}`
  - `{tidyverse}`
  - `{vroom}`
  - `{english}`
  - `{data.table}`
  - `{argparse}`
  - `{dplyr}`
  - `{tools}`
  - `{seqinr}`
  - `{DT}`
  - `{stringr}`
  - `{fs}`
  - `{tidyr}`
  - `{ape}`
  - `{ks}`
  - `{mclust}`
