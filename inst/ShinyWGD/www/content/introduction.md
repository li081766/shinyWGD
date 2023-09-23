<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

### <span style="color:red; background:linear-gradient(to right, red, yellow, green, cyan, yellow, red); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">ShinyWGD</span>

<span style="color:red; background:linear-gradient(to right, red, yellow, green, cyan, yellow, red); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">ShinyWGD</span>
 can prepare the input and command lines for [`wgd`](https://github.com/arzwa/wgd), [`ksrates`](https://github.com/VIB-PSB/ksrates), [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30), [`OrthoFinder`](https://github.com/davidemms/OrthoFinder) and [`Whale`](https://github.com/arzwa/Whale.jl/tree/master) and then study the whole genome duplication events (WGDs) of the interesting species.


This page gives users a brief introduction to this software. Please go to the <font color='#6650C9'><b>? Help</b></font> Page to see more details. 


---


#### The structure of <span style="color:red; background:linear-gradient(to right, red, yellow, green, cyan, yellow, red); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">ShinyWGD</span>


- ##### <font color="#6650C9"><i class="fa-solid fa-home"></i> Home</font>
- ##### <font color="#6650C9"><i aria-label="terminal icon" class="fa fa-terminal fa-fw fa-fade" role="presentation"></i>Scripts</font>
  - <font color="orange"><i aria-label="microscope icon" class="fa fa-microscope fa-fw fa-fade" role="presentation"></i> Data Preparation</font>
  - <font color="orange"><i aria-label="code icon" class="fa fa-code fa-fw fa-fade" role="presentation"></i> Codes</font>
- ##### <font color="#6650C9"><i class="fa-solid fa-pencil" role="presentation"></i> Analysis</font>
  - <font color="orange"><img src="images/ksIcon.svg" alt="Icon" width="20" height="20"> Age Distribution Analysis</font>
  - <font color="orange"><img src="images/syntenyIcon.svg" alt="Icon" width="20" height="20"> Synteny Analysis</font>
  - <font color="orange"><img src="images/ksTreeIcon.svg" alt="Icon" width="20" height="20"> Tree Building</font>
  - <font color="orange"><img src="images/treeReconciliationIcon.svg" alt="Icon" width="20" height="20"> Gene Tree – Species Tree Reconciliation Analysis</font>
- ##### <font color="#6650C9"><i class="fa-solid fa-question"></i> Help</font>

---

##### Dependencies

- ###### <font color="#6650C9">External software</font>

  - [`wgd`](https://github.com/arzwa/wgd))
  - [`ksrates`](https://github.com/VIB-PSB/ksrates)
  - [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30)
  - [`Whale`](https://github.com/arzwa/Whale.jl/tree/master)
  - [`OrthoFinder`](https://github.com/davidemms/OrthoFinder)

- ###### <font color="#6650C9">R packages</font>
  - `{shiny}`
  - `{shinyjs}`
  - `{shinyFiles}`
  - `{shinyBS}`
  - `{shinyWidgets}`
  - `{shinyalert}`
  - `{bslib}`
  - `{bsplus}`
  - `{htmltools}`
  - `{stringi}`
  - `{tidyverse}`
  - `{vroom}`
  - `{english}`
  - `{data.table}`
  - `{argparse}`
  - `{dplyr}`
  - `{tools}`
  - `{seqinr}`
  - `{DT}`