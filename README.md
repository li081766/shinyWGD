# ShinyWGD <img src="man/figures/stanlogo.png" align="right" width="120" />

<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/ShinyWGD?color=blue)](https://cran.r-project.org/web/packages/ShinyWGD)
[![Downloads](https://cranlogs.r-pkg.org/badges/ShinyWGD?color=blue)](https://cran.rstudio.com/package=ShinyWGD)
<!-- badges: end -->

### Overview

`ShinyWGD` can prepare the input and command lines for [`wgd`](https://github.com/arzwa/wgd), [`ksrates`](https://github.com/VIB-PSB/ksrates), [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30), and [`OrthoFinder`](https://github.com/davidemms/OrthoFinder). 

`ShinyWGD` can also assist users in using [`Whale`](https://github.com/arzwa/whaleprep/tree/master) to infer reconciled gene trees and parameters of a model of gene family evolution given a known species tree.

After directly uploading the output of `wgd`, `ksrates`, `i-ADHoRe`, or `OrthoFinder`, `ShinyWGD` can study the whole genome duplication events (WGDs).


This page gives users a brief introduction to this software. Please go to the <font color='#6650C9'><b>? Help</b></font> Page to see more details.



### The structure of`ShinyWGD`


- ##### <font color="#6650C9"><i class="fa-solid fa-info"></i> Introduction</font>
- ##### <font color="#6650C9"><i aria-label="terminal icon" class="fa fa-terminal fa-fw fa-fade" role="presentation"></i>Scripts</font>
  - <font color="orange"><i aria-label="microscope icon" class="fa fa-microscope fa-fw fa-fade" role="presentation"></i> Data Preparation</font>
  - <font color="orange"><i aria-label="code icon" class="fa fa-code fa-fw fa-fade" role="presentation"></i> Codes</font>
- ##### <font color="#6650C9"><i class="fa-solid fa-pencil" role="presentation"></i> Analysis</font>
  - <font color="orange"><img src="images/ksIcon.svg" alt="Icon" width="20" height="20"> Age Distribution Analysis</font>
  - <font color="orange"><img src="images/syntenyIcon.svg" alt="Icon" width="20" height="20"> Synteny Analysis</font>
  - <font color="orange"><img src="images/ksTreeIcon.svg" alt="Icon" width="20" height="20"> Tree Building</font>
  - <font color="orange"><img src="images/treeReconciliationIcon.svg" alt="Icon" width="20" height="20"> Gene Tree – Species Tree Reconciliation Analysis</font>
- ##### <font color="#6650C9"><i class="fa-solid fa-question"></i> Help</font>

