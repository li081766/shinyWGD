#' The main code to run shinyWGD
#'
#'
#' @export
runshinyWGD <- function() {
    appDir <- system.file("shinyWGD", package="shinyWGD")
    if (appDir == "") {
        stop("Could not find shinyWGD Try re-installing `shinyWGD`.", call.=FALSE)
    }

    shiny::runApp(appDir)
}
