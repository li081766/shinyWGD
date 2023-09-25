ksTreeRv <- reactiveValues(data=NULL, clear=FALSE)
timeTreeRv <- reactiveValues(data=NULL, clear=FALSE)

observeEvent(input$uploadKsTree, {
    ksTreeRv$clear <- FALSE
}, priority=1000)

observeEvent(input$uploadTimeTree, {
    timeTreeRv$clear <- FALSE
}, priority=1000)

widthSpacing <- reactiveValues(value=500)
heightSpacing <- reactiveValues(value=NULL)

observe({
    if( isTruthy(input$uploadKsTree) || isTruthy(input$uploadTimeTree) ){
        if( isTruthy(input$uploadKsTree) ){
            ksTreeFile <- input$uploadKsTree$datapath
            ksTree <- readLines(textConnection(readChar(ksTreeFile, file.info(ksTreeFile)$size)))
            closeAllConnections()
            sp_count <- str_count(ksTree[1], ":")
        }
        if( isTruthy(input$uploadTimeTree) ){
            timeTreeFile <- input$uploadTimeTree$datapath
            timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
            closeAllConnections()
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            sp_count <- str_count(timeTree, ":")
        }
        trunc_val <- as.numeric(sp_count) * 20
        heightSpacing$value <- trunc_val
    }
})

observeEvent(input$svg_vertical_spacing_add, {
    heightSpacing$value <- heightSpacing$value + 50    
})
observeEvent(input$svg_vertical_spacing_sub, {
    heightSpacing$value <- heightSpacing$value - 50  
})
observeEvent(input$svg_horizontal_spacing_add, {
    widthSpacing$value <- widthSpacing$value + 50    
})
observeEvent(input$svg_horizontal_spacing_sub, {
    widthSpacing$value <- widthSpacing$value - 50  
})
observeEvent(input$reset, {
    if( isTruthy(input$uploadKsTree) || isTruthy(input$uploadTimeTree) ){
        joint_tree_data <- list(
            "width"=500
        )
        if( isTruthy(input$uploadKsTree) ){
            ksTreeFile <- input$uploadKsTree$datapath
            ksTree <- readLines(textConnection(readChar(ksTreeFile, file.info(ksTreeFile)$size)))
            closeAllConnections()
            joint_tree_data[["ksTree"]] <- ksTree
            sp_count <- str_count(ksTree, ":")
        }
        if( isTruthy(input$uploadTimeTree) ){
            timeTreeFile <- input$uploadTimeTree$datapath
            timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
            closeAllConnections()
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            joint_tree_data[["timeTree"]] <- timeTree
            sp_count <- str_count(timeTree, ":")
        }
        if( isTruthy(input$uploadKsPeakTable) ){
            ksPeakTableFile <- input$uploadKsPeakTable$datapath
            ksPeak <- suppressMessages(
                vroom(ksPeakTableFile,
                      col_names=c("species", "peak", "confidence_interval", "color"),
                      delim="\t",
                      skip=1)
            )
            if( ncol(ksPeak) == 3 ){
                color_list <- c(
                    "#ff7f00", "#FFA750", "#0064A7", "#008DEC", 
                    "#088A00", "#0CD300", "#e31a1c", "#fb9a99", "#cab2d6"
                )
                ksPeak$color <- color_list[match(ksPeak$species, unique(ksPeak$species))]
            }
            joint_tree_data[["ksPeak"]] <- ksPeak
        }
        if( isTruthy(input$uploadTimeTable) ){
            timeTableFile <- input$uploadTimeTable$datapath
            timeTable <- suppressMessages(
                vroom(
                    timeTableFile,
                    col_names=c("species", "wgds"),
                    delim="\t"
                )
            )
            joint_tree_data[["wgdtable"]] <- timeTable
        }
        trunc_val <- as.numeric(sp_count) * 20
        heightSpacing$value <- trunc_val
        joint_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("jointTreePlot", joint_tree_data)
    }
})

observe({
    if( isTruthy(input$uploadKsTree) || isTruthy(input$uploadTimeTree) ){
        joint_tree_data <- list(
            "width"=widthSpacing$value
        )
        if( isTruthy(input$uploadKsTree) ){
            ksTreeFile <- input$uploadKsTree$datapath
            ksTree <- readLines(textConnection(readChar(ksTreeFile, file.info(ksTreeFile)$size)))
            closeAllConnections()
            joint_tree_data[["ksTree"]] <- ksTree[1]
        }
        if( isTruthy(input$uploadTimeTree) ){
            timeTreeFile <- input$uploadTimeTree$datapath
            timeTreeInfo <- readLines(textConnection(readChar(timeTreeFile, file.info(timeTreeFile)$size)))
            closeAllConnections()
            timeTree <- timeTreeInfo[grep("=", timeTreeInfo)]
            joint_tree_data[["timeTree"]] <- timeTree
        }
        if( isTruthy(input$uploadKsPeakTable) ){
            ksPeakTableFile <- input$uploadKsPeakTable$datapath
            ksPeak <- suppressMessages(
                vroom(ksPeakTableFile,
                      col_names=c("species", "peak", "confidence_interval", "color"),
                      delim="\t",
                      skip=1)
            )
            if( ncol(ksPeak) == 3 ){
                color_list <- c(
                    "#ff7f00", "#FFA750", "#0064A7", "#008DEC", 
                    "#088A00", "#0CD300", "#e31a1c", "#fb9a99", "#cab2d6"
                )
                ksPeak$color <- color_list[match(ksPeak$species, unique(ksPeak$species))]
            }
            joint_tree_data[["ksPeak"]] <- ksPeak
        }
        if( isTruthy(input$uploadTimeTable) ){
            timeTableFile <- input$uploadTimeTable$datapath
            timeTable <- suppressMessages(
                vroom(
                    timeTableFile,
                    col_names=c("species", "wgds", "color"),
                    delim="\t"
                )
            )
            joint_tree_data[["wgdtable"]] <- timeTable
        }
        joint_tree_data[["height"]] <- heightSpacing$value
        session$sendCustomMessage("jointTreePlot", joint_tree_data)
    }
})