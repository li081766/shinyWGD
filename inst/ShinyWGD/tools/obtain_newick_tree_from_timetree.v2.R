library(httr)
library(jsonlite)
library(phangorn)

args <- commandArgs(trailingOnly = TRUE)

# Define the base URL for the TimeTree API
base_url <- "https://timetree.org/api"

# Get the scientific name from a file
taxon_names <- readLines(args[1])

# Function to get the taxon ID for a given scientific name
get_taxon_id <- function(name_t){
    name <- gsub(" ", "+", name_t)
    endpoint <- paste0(base_url, "/taxon/", name)
    response <- GET(endpoint)
    response_content <- content(response, as = "text")
    json <- fromJSON(response_content)
    taxon_id <- json$taxon_id
    if( is.null(taxon_id) ){
        # only try genus if the scientific name is not available 
        name <- strsplit(name_t, " ")[[1]][1]
        endpoint <- paste0(base_url, "/taxon/", name)
        response <- GET(endpoint)
        response_content <- content(response, as = "text")
        json <- fromJSON(response_content)
        taxon_id <- json$taxon_id
    }
    return(taxon_id)
}

# Initialize an empty distance matrix
dist_matrix <- matrix(
    0, 
    nrow=length(taxon_names), 
    ncol=length(taxon_names)
)
rownames(dist_matrix) <- taxon_names
colnames(dist_matrix) <- taxon_names

# Loop through the list of taxa and get their pairwise divergence times
for( i in 1:length(taxon_names) ){
    for( j in i:length(taxon_names) ){
        if( i == j ){
            dist_matrix[i, j] <- 0
        } 
        else{
            # Get the taxon IDs for the two taxa
            taxon_id1 <- get_taxon_id(taxon_names[i])
            taxon_id2 <- get_taxon_id(taxon_names[j])
            
            if( is.null(taxon_id1) | is.null(taxon_id2) ){
                stop("Some species are not in the Timetree Database")
            }
            
            # Define the pairwise API endpoint
            endpoint <- paste0(base_url, "/pairwise/", taxon_id1, "/", taxon_id2)
            
            # Send a GET request to the API endpoint
            response <- GET(endpoint)
            
            # Extract the response content as a JSON object
            response_content <- content(response, as="text")
            json <- fromJSON(response_content)
            
            # Update the distance matrix with the pairwise divergence time
            dist_matrix[i,j] <- json$sum_median_time
            dist_matrix[j,i] <- json$sum_median_time
        }
    }
}

# Build a tree from the distance object using nj algorithm
tree <- nj(dist_matrix)

# Root the tree by the midpoint method
tree_rooted <- midpoint(tree)

# Save the rooted tree to Newick format
newick_tree <- write.tree(
    tree_rooted,
    file=args[2])

# Save the rooted tree without branch length
newick_tree <- gsub(":\\d+\\.\\d+", "", write.tree(tree_rooted))
newick_tree <- gsub("_", " ", newick_tree)
writeLines(newick_tree, args[3])

