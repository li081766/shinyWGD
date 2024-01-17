#' Remove directories older than a specified day
#'
#' This function removes directories in the specified base directory that are
#' older than a specified maximum age in days. It logs the removed directories
#' and any errors encountered during removal.
#'
#' @param base_dir The base directory to search for old directories.
#' @param max_age_in_days The maximum age (in days) for directories to be considered old.
#' @param log_file The name of the log file to store information about removed directories and errors.
#'
#' @return The function does not return anything. It logs information about removed directories and errors.
#'
#' @examples
#' \dontrun{
#' # Remove directories older than 3 days in the specified directory
#' remove_old_dirs("~/path/to/base/directory", max_age_in_days=3)
#' }
#'
remove_old_dirs <- function(base_dir, max_age_in_days=3, log_file="remove_old_dirs.log") {
    current_time <- Sys.time()

    dirs <- list.dirs(base_dir, full.names=TRUE, recursive=FALSE)
    dirs <- dirs[grep("Analysis_", dirs)]

    con <- file(log_file, open="a")

    for( dir_path in dirs ){
        dir_creation_time <- file.info(dir_path)$ctime

        time_difference_days <- as.numeric(
            difftime(current_time, dir_creation_time, units="days")
        )

        if( time_difference_days >= max_age_in_days ){
            tryCatch({
                print(dir_path)
                unlink(dir_path, recursive=TRUE)
                cat(paste("Removed:", dir_path, "\n"), file=log_file, append=TRUE)
            }, error=function(e) {
                cat(paste("Error removing:", dir_path, "\n", "Error message:", e$message, "\n"), file=log_file, append=TRUE)
            })
        }
    }
    close(con)
}
