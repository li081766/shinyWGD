#' Extracts a timetree from TimeTree.org based on species names.
#'
#' This function takes a file with species names as input and a prefix to define the output.
#'
#' @param input_file A character string specifying the path to the file containing species names.
#' @param prefix A character string providing the prefix for the output file.
#'
#' @return A timetree object representing the estimated divergence times between species.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET content
#' @importFrom stringr str_trim
#' @importFrom shiny incProgress
#' @importFrom ape write.nexus
#'
#' @export
#'
TimeTreeFecher <- function(input_file, prefix){
    base_url <- "https://timetree.org/api"

    taxon_names <- readLines(input_file)
    taxon_names <- str_trim(taxon_names, side="right")
    message(taxon_names)

    get_taxon_id <- function(name_t){
        name <- gsub(" ", "+", name_t)
        endpoint <- paste0(base_url, "/taxon/", name)
        response <- GET(endpoint)
        response_content <- content(response, as="text")
        json <- fromJSON(response_content)
        taxon_id <- json$taxon_id
        miss_name <- 0
        if( is.null(taxon_id) ){
            # only try genus if the scientific name is not available
            name <- strsplit(name_t, " ")[[1]][1]
            endpoint <- paste0(base_url, "/taxon/", name)
            response <- GET(endpoint)
            response_content <- content(response, as="text")
            json <- fromJSON(response_content)
            taxon_id <- json$taxon_id
            miss_name <- 1
        }
        return(c(taxon_id, miss_name))
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

    # species_df <- data.frame(
    #     stringsAsFactors=FALSE
    # )
    x <- 0
    total_iterations <- length(taxon_names) * (length(taxon_names) + 1) / 2
    shiny::withProgress(message='Searching in progress', value=0, {
        for( i in 1:length(taxon_names) ){
            for( j in i:length(taxon_names) ){
                x <- x + 1
                incProgress(
                    amount=1/total_iterations,
                    message=paste(
                        x,
                        "/",
                        total_iterations,
                        "..."
                    )
                )

                if( i == j ){
                    dist_matrix_as_timetree[i, j] <- 0
                    dist_matrix_as_median[i, j] <- 0
                }
                else{
                    taxon_id_i <- get_taxon_id(taxon_names[i])
                    taxon_id1 <- taxon_id_i[1]

                    taxon_id_j <- get_taxon_id(taxon_names[j])
                    taxon_id2 <- taxon_id_j[1]

                    # if( taxon_id_i[2] > 0 ){
                    #     temp_df1 <- data.frame(
                    #         species=taxon_names[i],
                    #         miss_type=taxon_id_i[2],
                    #         genus=strsplit(taxon_names[i], " ")[[1]][1],
                    #         stringsAsFactors=FALSE
                    #     )
                    #     species_df <- rbind(species_df, temp_df1)
                    # }
                    #
                    # if( taxon_id_j[2] > 0 ){
                    #     temp_df2 <- data.frame(
                    #         species=taxon_names[j],
                    #         miss_type=taxon_id_j[2],
                    #         genus=strsplit(taxon_names[j], " ")[[1]][1],
                    #         stringsAsFactors=FALSE
                    #     )
                    #     species_df <- rbind(species_df, temp_df2)
                    # }

                    if( is.null(taxon_id1) | is.null(taxon_id2) ){
                        if( is.null(taxon_id1) ){
                            #return(species_df)
                            stop(
                                paste(
                                    "Both",
                                    taxon_names[i],
                                    "and",
                                    strsplit(taxon_names[i], " ")[[1]][1],
                                    "are not in the Timetree Database"
                                )
                            )
                        }
                        if( is.null(taxon_id2) ){
                            #return(species_df)
                            stop(
                                paste(
                                    "Both",
                                    taxon_names[j],
                                    "and",
                                    strsplit(taxon_names[j], " ")[[1]][1],
                                    "are not in the Timetree Database"
                                )
                            )
                        }
                    }

                    endpoint <- paste0(base_url, "/pairwise/", taxon_id1, "/", taxon_id2)

                    response <- GET(endpoint)


                    response_content <- content(response, as="text")
                    json <- fromJSON(response_content)

                    if( !is.null(json$studies$adjusted_age) && !is.null(json$sum_median_time) ){
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
        }
    })

    tree_as_timetree <- as.phylo(
        hclust(as.dist(dist_matrix_as_timetree)*2, method="average")
    )
    tree_as_median <- as.phylo(
        hclust(as.dist(dist_matrix_as_median)*2, method="average")
    )

    write.tree(tree_as_timetree, file=paste0(prefix, ".as_timetree.nwk"))
    write.nexus(
        tree_as_timetree,
        file=paste0(prefix, ".as_timetree.nexus"),
        translate=FALSE
    )
    write.tree(tree_as_median, file=paste0(prefix, ".sum_median_time.nwk"))
    write.nexus(
        tree_as_median,
        file=paste0(prefix, ".sum_median_time.nexus"),
        translate=FALSE
    )

    duplicated_rows <- duplicated(dist_matrix_as_timetree) | duplicated(dist_matrix_as_timetree, fromLast=TRUE)
    unique_rows_with_same_values <- rownames(dist_matrix_as_timetree)[duplicated_rows]

    row_groups <- list()
    for( unique_row in unique_rows_with_same_values ){
        group <- rownames(dist_matrix_as_timetree)[dist_matrix_as_timetree[unique_row, ] == dist_matrix_as_timetree[unique_row, unique_row]]
        row_groups[[unique_row]] <- group
    }

    species_result_df <- data.frame(
        group_id=integer(),
        species_list=character(),
        stringsAsFactors=FALSE
    )

    group_id_counter <- 1

    for( group_name in names(row_groups) ){
        species_list <- paste(row_groups[[group_name]], collapse=", ")
        existing_row <- species_result_df[species_result_df$species_list == species_list, ]

        if (nrow(existing_row) == 0) {
            species_result_df <- rbind(
                species_result_df,
                data.frame(
                    group_id=group_id_counter,
                    species_list=species_list
                )
            )
            group_id_counter <- group_id_counter + 1
        } else {
            species_result_df[species_result_df$species_list == species_list, "group_id"] <- existing_row$group_id
        }
    }

    return(species_result_df)
}
