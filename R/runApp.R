#' The main code to run ShinyWGD
#'
#'
#' @export
runApp <- function() {
    appDir <- system.file("ShinyWGD", package="ShinyWGD")
    if (appDir == "") {
        stop("Could not find ShinyWGD Try re-installing `ShinyWGD`.", call.=FALSE)
    }

    shiny::runApp(appDir)
}
