#' Extracts a timetree from TimeTree.org based on species names.
#'
#' This function takes a file with species names as input and a prefix to define the output.
#'
#' @param input_file A character string specifying the path to the file containing species names.
#' @param prefix A character string providing the prefix for the output file.
#'
#' @return A timetree object representing the estimated divergence times between species.
#'
#' @import httr jsonlite phangorn
#'
#' @export
#'
#' @seealso \code{\link{httr}}, \code{\link{jsonlite}}, \code{\link{phangorn}}
extract_tree <- function(input_file, prefix){
    suppressPackageStartupMessages({
        library(httr)
        library(jsonlite)
        library(phangorn)
    })
    base_url <- "https://timetree.org/api"

    taxon_names <- readLines(input_file)

    get_taxon_id <- function(name_t){
        name <- gsub(" ", "+", name_t)
        endpoint <- paste0(base_url, "/taxon/", name)
        response <- GET(endpoint)
        response_content <- content(response, as="text")
        json <- fromJSON(response_content)
        taxon_id <- json$taxon_id
        # if( is.null(taxon_id) ){
        #     # only try genus if the scientific name is not available
        #     name <- strsplit(name_t, " ")[[1]][1]
        #     endpoint <- paste0(base_url, "/taxon/", name)
        #     response <- GET(endpoint)
        #     response_content <- content(response, as="text")
        #     json <- fromJSON(response_content)
        #     taxon_id <- json$taxon_id
        # }
        return(taxon_id)
    }

    dist_matrix_as_timetree <- matrix(
        0,
        nrow=length(taxon_names),
        ncol=length(taxon_names)
    )
    rownames(dist_matrix_as_timetree) <- taxon_names
    colnames(dist_matrix_as_timetree) <- taxon_names

    dist_matrix_as_median <- matrix(
        0,
        nrow=length(taxon_names),
        ncol=length(taxon_names)
    )
    rownames(dist_matrix_as_median) <- taxon_names
    colnames(dist_matrix_as_median) <- taxon_names

    for( i in 1:length(taxon_names) ){
        for( j in i:length(taxon_names) ){
            if( i == j ){
                dist_matrix_as_timetree[i, j] <- 0
                dist_matrix_as_median[i, j] <- 0
            }
            else{
                taxon_id1 <- get_taxon_id(taxon_names[i])
                taxon_id2 <- get_taxon_id(taxon_names[j])

                if( is.null(taxon_id1) | is.null(taxon_id2) ){
                    if( is.null(taxon_id1) ){
                        stop(paste(taxon_names[i], "is not in the Timetree Database"))
                    }
                    if( is.null(taxon_id2) ){
                        stop(paste(taxon_names[j], "is not in the Timetree Database"))
                    }
                }

                endpoint <- paste0(base_url, "/pairwise/", taxon_id1, "/", taxon_id2)

                response <- GET(endpoint)

                response_content <- content(response, as="text")
                json <- fromJSON(response_content)

                if( as.numeric(json$studies$adjusted_age) != 0 ){
                    dist_matrix_as_timetree[i, j] <- round(as.numeric(json$studies$adjusted_age), 2)
                    dist_matrix_as_timetree[j, i] <- round(as.numeric(json$studies$adjusted_age), 2)
                }else{
                    dist_matrix_as_timetree[i, j] <- round(as.numeric(json$sum_median_time), 2)
                    dist_matrix_as_timetree[j, i] <- round(as.numeric(json$sum_median_time), 2)
                }

                dist_matrix_as_median[i, j] <- round(as.numeric(json$sum_median_time), 2)
                dist_matrix_as_median[j, i] <- round(as.numeric(json$sum_median_time), 2)

            }
        }
    }

    tree_as_timetree <- as.phylo(
        hclust(as.dist(dist_matrix_as_timetree)*2, method="average")
    )
    tree_as_median <- as.phylo(
        hclust(as.dist(dist_matrix_as_median)*2, method="average")
    )

    write.tree(tree_as_timetree, file=paste0(args$prefix, ".as_timetree.nwk"))
    write.nexus(
        tree_as_timetree,
        file=paste0(prefix, ".as_timetree.nexus"),
        translate=FALSE
    )
    write.tree(tree_as_median, file=paste0(args$prefix, ".sum_median_time.nwk"))
    write.nexus(
        tree_as_median,
        file=paste0(prefix, ".sum_median_time.nexus"),
        translate=FALSE
    )
}
