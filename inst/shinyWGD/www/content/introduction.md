<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

### **`shinyWGD`**

---

Welcome to **`shinyWGD`** Server – **`a freely accessible and inclusive platform`**, providing an open space for users to explore and analyze Whole Genome Duplication (WGD) events.

Designed with a user-friendly interface, **`shinyWGD`** empowers users with an intuitive, interactive platform that eliminates the need for programming skills. Whether you're a experienced researcher or new to WGD analysis, **`shinyWGD`** offers a comprehensive solution.

Our server comprises two key components. First, we've streamlined the process of preparing essential inputs for existing packages, providing an interactive experience for users. Second, **`shinyWGD`** offers a meticulously crafted environment for exploring and visualizing WGD events, ensuring a smooth and insightful analysis.

Dive into the world of WGD analysis with **`shinyWGD`** Server – freely distributed and tailored to meet your genomic exploration needs.

---

#### The structure of **`shinyWGD`**

- ##### <font color="#6650C9"><i class="fa-solid fa-home"></i> Home</font>
- ##### <font color="#6650C9"><i aria-label="terminal icon" class="fa fa-terminal fa-fw fa-fade" role="presentation"></i> Scripts</font>
  - <a href="javascript:void(0);" onclick="switchToDataPreparationTab()"><font color="orange"><i aria-label="microscope icon" class="fa fa-microscope fa-fw fa-fade" role="presentation"></i> Data Preparation</font></a>
    - This module effortlessly readies inputs for a selection of integrated packages, including [`wgd`](https://github.com/arzwa/wgd), [`ksrates`](https://github.com/VIB-PSB/ksrates), [`i-ADHoRe`](https://www.vandepeerlab.org/?q=tools/i-adhore30) and [`OrthoFinder`](https://github.com/davidemms/OrthoFinder). With a fixed number of studied species, this module automatically generates the necessary inputs for each package, simplifying your workflow and enhancing the efficiency of your genomic analyses.
  - <a href="javascript:void(0);" onclick="switchToWhalePreparationTab()"><font color="orange"><img src="images/treeReconciliationIcon.svg" alt="Icon" width="20" height="20"> Whale Preparation</font></a>
    - This module seamlessly integrates the powerful capabilities of the [`Whale`](https://github.com/arzwa/Whale.jl/tree/master) package, enabling the inference of reconciled gene trees and model parameters for gene family evolution. This module leverages outputs from [`OrthoFinder`](https://github.com/davidemms/OrthoFinder), selecting optimal gene families to create the [`ALE`](https://github.com/ssolo/ALE) file for each gene family. Users can conveniently upload a time divergence tree, interactively specify WGD events for testing directly on the tree, and effortlessly generate [`Whale`](https://github.com/arzwa/Whale.jl/tree/master) code. This streamlined process eliminates the need for users to delve into Julia scripting, ensuring a user-friendly experience.
  - <a href="javascript:void(0);" onclick="switchToTreeExtractionTab()"><font color="orange"><i aria-label="tree icon" class="fa fa-tree fa-fw fa-fade" role="presentation"></i> TimeTreeFetcher</font></a>
    - This module simplifies the process of obtaining a species tree from [TimeTree.org](http://www.timetree.org/), especially when users are uncertain about the evolutionary relationships among studied species. By simply uploading a file containing species names, this module seamlessly communicates with [TimeTree.org](http://www.timetree.org/), providing users with two types of trees. The first type mirrors the sample tree structure found on [TimeTree.org](http://www.timetree.org/), while the second represents a tree constructed based on the median divergence time among studied species. This module offers a straightforward solution for users seeking clarity in their species relationships.
- ##### <font color="#6650C9"><i class="fa-solid fa-pencil" role="presentation"></i> Analysis</font>
  - <a href="javascript:void(0);" onclick="switchToKsAnalysisTab()"><font color="orange"><img src="images/ksIcon.svg" alt="Icon" width="20" height="20"> <i>K</i><sub>s</sub>Dist</font></a>
    - This module simplifies the identification of WGD events using <i>K</i><sub>s</sub> age distribution. Leveraging Data Preparation outputs, users customize selections in the configuration settings for tailored results. The module corrects paralog <i>K</i><sub>s</sub> distribution peaks with two methods: normal mixture model fitting and SiZer. It also utilizes relative rate tests to quantify substitution rate differences. Ideal for users exploring WGD events through <i>K</i><sub>s</sub> age distribution analysis.
  - <a href="javascript:void(0);" onclick="switchToSyntenyAnalysisTab()"><font color="orange"><img src="images/syntenyIcon.svg" alt="Icon" width="20" height="20"> Collinearity</font></a>
    - This module broadens the investigation of collinear relationships across all studied species, surpassing the capabilities of [`ksrates`](https://github.com/VIB-PSB/ksrates). It provides visualizations of collinear blocks. Additionally, users can delve into the exploration of putative ancestral regions (PARs) through clustering analysis, offering a more detailed and interactive exploration of the genomic architecture.
  - <a href="javascript:void(0);" onclick="switchToTreeReconTab()"><font color="orange"><img src="images/treeReconciliationIcon.svg" alt="Icon" width="20" height="20"> TreeRecon</font></a>
    - This module visualizes [`Whale`](https://github.com/arzwa/Whale.jl/tree/master) output and posterior distributions of WGD retention rates (q) for potential WGDs under selected models.
  - <a href="javascript:void(0);" onclick="switchToTreeBuildingTab()"><font color="orange"><img src="images/ksTreeIcon.svg" alt="Icon" width="20" height="20"> VizWGD </font></a>
    - This module lets users customize the MCMCtree's time tree, or a ultrametic tree. Upload a tree file, click branches to add WGD events, and adjust colors and symbols. Highlight geological time regions with ease.
- ##### <a href="javascript:void(0);" onclick="switchToGalleryTab()"><font color="#6650C9"><i class="fa-solid fa-image"></i> Gallery</font></a>
- ##### <a href="javascript:void(0);" onclick="switchToHelpTab()"><font color="#6650C9"><i class="fa-solid fa-question"></i> Help</font></a>
