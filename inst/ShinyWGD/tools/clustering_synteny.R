#' Get the segments from multiplicons
#'
#' @param genes_file genes.txt created by i-ADHoRe
#' @param anchors_ks_file remapped anchored points saved in anchorpoints.merged_pos_ks.txt
#' @param multiplicons_file multiplicons.txt created by i-ADHoRe
#' @param segmented_file a file to save the segmented chromosomes info
#' @param segmented_anchorpoints_file a file to save the anchored points horboured in segmented chromosomes
#' @param num_anchors the threshold to filter out the small segments, default 5
#'
#' @return
#' @export
#'
#' @examples
#' get_segments(
#     genes_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/genes.txt",
#     anchors_ks_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.merged_pos_ks.txt",
#     multiplicons_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/multiplicons.txt",
#     segmented_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clustering/segmented.chr.txt",
#     segmented_anchorpoints_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clustering/segmented.anchorpoints.txt",
#     num_anchors=5
# )
get_segments <- function(
        genes_file,
        anchors_ks_file,
        multiplicons_file,
        segmented_file,
        segmented_anchorpoints_file,
        num_anchors=10){

    library(IRanges)
    library(dplyr)

    scaf_df <- read.table(
        genes_file,
        header=TRUE,
        sep="\t"
    ) %>%
        group_by(genome, list) %>%
        summarise(num_gene_remapped=max(remapped_coordinate), .groups="drop")

    anchors_ks_df <- read.table(
        anchors_ks_file,
        header=TRUE,
        sep="\t"
    ) %>%
        select(multiplicon,
               geneX, speciesX, listX, coordX,
               geneY, speciesY, listY, coordY, Ks)

    speciesX <- unique(anchors_ks_df$speciesX)[1]
    speciesY <- unique(anchors_ks_df$speciesY)[1]

    multiplicons_df <- read.table(
        multiplicons_file,
        header=TRUE,
        sep="\t"
    ) %>%
        select(id, level, number_of_anchorpoints)

    anchors_df <- merge(anchors_ks_df, multiplicons_df, by.x="multiplicon", by.y="id") %>%
        filter(number_of_anchorpoints >= num_anchors)

    df_A <- anchors_df[, c(1:5)]
    df_B <- anchors_df[, c(1, 6:9)]
    row.names(df_A) <- NULL
    colnames(df_A) <- c("multiplicon_id", "gene", "genome", "chr", "pos")
    row.names(df_B) <- NULL
    colnames(df_B) <- c("multiplicon_id", "gene", "genome", "chr", "pos")

    anchors <- rbind(df_A, df_B)
    anchors.arranged <- arrange(anchors)

    ap <- group_by(anchors.arranged, multiplicon_id, genome, chr)

    segs <- summarise(ap, pos_min=min(pos), pos_max=max(pos), .groups="drop")

    segments <- data.frame()
    for( chr in unique(segs$chr) ){
        seg.chr <- segs[segs$chr==chr, ]
        ir <- IRanges(seg.chr$pos_min, seg.chr$pos_max)
        seg.chr$group <- subjectHits(findOverlaps(ir, reduce(ir)))
        class(seg.chr)<-"data.frame"
        df <- summarise(group_by(arrange(seg.chr, pos_min), genome, chr, group),
                        pos_min=min(pos_min), pos_max=max(pos_max), .groups="drop")
        class(df) <- "data.frame"
        segments <- rbind(segments, df)
    }

    segments$min <- segments$pos_min
    segments$max <- segments$pos_max

    segments$name <- paste0(segments$chr, ":", segments$pos_min, "-", segments$pos_max)

    anchors.arranged$atomic_id <- vector("character", nrow(anchors.arranged))
    anchors.arranged$atomic_pos <- vector("integer", nrow(anchors.arranged))

    for( i in 1:nrow(anchors.arranged) ){
        genome <- anchors.arranged$genome[i]
        chr <- anchors.arranged$chr[i]
        pos <- anchors.arranged$pos[i]
        pos.ranges <- segments[segments$genome==genome & segments$chr==chr,
                               c("name","pos_min", "pos_max")]
        for( j in 1:nrow(pos.ranges) ){
            if( pos %in% seq(pos.ranges$pos_min[j], pos.ranges$pos_max[j]) ){
                anchors.arranged$atomic_id[i] <- pos.ranges$name[j]
                anchors.arranged$atomic_pos[i] <- pos - pos.ranges$pos_min[j]
                break
            }
        }
    }

    atomic.df <- data.frame()
    for( mid in unique(anchors.arranged$multiplicon_id) ){
        df_x <- anchors.arranged[anchors.arranged$multiplicon_id==mid & anchors.arranged$genome==speciesX,
                                 c("multiplicon_id", "gene", "genome","atomic_id", "atomic_pos")]
        df_y <- anchors.arranged[anchors.arranged$multiplicon_id==mid & anchors.arranged$genome==speciesY,
                                 c("gene", "genome","atomic_id", "atomic_pos")]
        double_check_len <- nrow(anchors_df[anchors_df$multiplicon==mid, ])
        if( nrow(df_x) == double_check_len & nrow(df_y) == double_check_len ){
            atomic.df <- rbind(atomic.df, cbind(df_x, df_y))
        }
    }


    atomic.df$level <- 10000
    atomic.df$num_anchors <- 10000
    atomic.df$is_real <- -1
    colnames(atomic.df) <- c("multiplicon",
                             "geneX", "speciesX", "listX", "coordX",
                             "geneY", "speciesY", "listY", "coordY",
                             "level", "num_anchors", "is_real")

    atomic.df <- atomic.df[!duplicated(atomic.df[, -1]), ]

    file_tmp <- gsub("txt", "no_ks.txt", segmented_anchorpoints_file)
    write.table(
        atomic.df,
        file=file_tmp,
        sep="\t",
        col.names=TRUE,
        row.names=FALSE,
        quote=FALSE
    )

    ks_df <- anchors_ks_df %>%
        select(multiplicon, geneX, geneY, Ks)

    final_table_ks_df <- merge(
        atomic.df,
        ks_df,
        by.x=c("multiplicon", "geneX", "geneY"),
        by.y=c("multiplicon", "geneX", "geneY"),
        all.x=TRUE
    ) %>%
        select(multiplicon,
               geneX, speciesX, listX, coordX,
               geneY, speciesY, listY, coordY,
               level, num_anchors, is_real,
               Ks) %>%
        arrange(multiplicon)

    atomic.df <- final_table_ks_df

    segs.df <- cbind(segments$genome, segments$name)
    segs.df <- cbind(
        segs.df,
        data.frame(num_gene_remapped=segments$pos_max - segments$pos_min + 1)
    )
    names(segs.df) <- names(scaf_df)

    write.table(
        segs.df,
        file=segmented_file,
        sep="\t",
        col.names=TRUE,
        row.names=FALSE,
        quote=FALSE
    )

    write.table(
        atomic.df,
        file=segmented_anchorpoints_file,
        sep="\t",
        col.names=TRUE,
        row.names=FALSE,
        quote=FALSE
    )
}

#' Hierarchical clustering for segments
#'
#' @param segmented_file the file of segmented chromosome info
#' @param segmented_anchorpoints_file the file of anchored points in the segmented info
#' @param genes_file genes.txt created by i-ADHoRe
#' @param out_file save the hclust to the out_file
#'
#' @return
#' @export
#'
#' @examples 
#' cluster_synteny(
#     segmented_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/clusteringDir/segmented.chr.10.txt",
#     segmented_anchorpoints_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/clusteringDir/segmented.anchorpoints.10.txt",
#     genes_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/genes.txt",
#     out_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/clusteringDir/test.out"
# )
cluster_synteny <- function(
        segmented_file,
        segmented_anchorpoints_file,
        genes_file,
        out_file){

    segs.df <- read.table(
        segmented_file,
        header=TRUE,
        sep="\t"
    )
    atomic.df <- read.table(
        segmented_anchorpoints_file,
        header=TRUE,
        sep="\t"
    )

    genes_df <- read.table(
        genes_file,
        header=TRUE,
        sep="\t"
    ) %>%
        select(id, genome, list, remapped_coordinate)

    colnames(genes_df) <- c("gene", "genome", "list", "coord")

    SpeciesX <- unique(atomic.df$speciesX)
    SpeciesY <- unique(atomic.df$speciesY)
    p_value_matrix <- matrix(
        ncol=nrow(segs.df[segs.df$genome==SpeciesX, ]),
        nrow=nrow(segs.df[segs.df$genome==SpeciesY, ]),
        dimnames=list(segs.df[segs.df$genome==SpeciesY, "list"],
                      segs.df[segs.df$genome==SpeciesX, "list"])
    )


    p_value_matrix.bycol <- p_value_matrix
    p_value_matrix.byrow <- p_value_matrix

    m <- nrow(atomic.df)
    n <- nrow(genes_df[genes_df$genome==SpeciesX, ]) * nrow(genes_df[genes_df$genome==SpeciesY, ])

    for( i in 1:nrow(p_value_matrix) ){
        row.chr <- row.names(p_value_matrix)[i]
        for( j in 1:ncol(p_value_matrix) ){
            col.chr <- colnames(p_value_matrix)[j]
            q <- nrow(atomic.df[atomic.df$listX==col.chr & atomic.df$listY==row.chr,])
            col.k <- segs.df[segs.df$list==col.chr, "num_gene_remapped"]
            row.k <- segs.df[segs.df$list==row.chr, "num_gene_remapped"]
            k <- col.k * row.k
            ## using poisson distribution to get values
            p_value_matrix.bycol[i, j] <- CalHomoConcentration(m, n, q, k)
            p_value_matrix.byrow[i, j] <- CalHomoConcentration(m, n, q, k)
        }
    }

    
    d.bycol <- cor(p_value_matrix.bycol)
    d.byrow <- cor(t(p_value_matrix.byrow))
    # print(p_value_matrix.bycol)
    
    d.bycol[is.na(d.bycol)] <- 0
    d.byrow[is.na(d.byrow)] <- 0

    upgma.bycol <- hclust(as.dist(1 - d.bycol), method="average")
    upgma.byrow <- hclust(as.dist(1 - d.byrow), method="average")

    cluster_info <- list()
    upgma.bycol$height <- round(upgma.bycol$height, 10)
    upgma.byrow$height <- round(upgma.byrow$height, 10)
    cluster_info[["bycol"]] <- upgma.bycol
    cluster_info[["byrow"]] <- upgma.byrow

    newick_bycol_file <- gsub(".RData", ".bycol.newick", out_file)
    newick_byrow_file <- gsub(".RData", ".byrow.newick", out_file)
    
    suppressMessages(
        library(ape)
    )
    newick_tree_bycol <- as.phylo(cluster_info[['bycol']])
    write.tree(newick_tree_bycol, file=newick_bycol_file)
    
    newick_tree_byrow <- as.phylo(cluster_info[['byrow']])
    write.tree(newick_tree_byrow, file=newick_byrow_file)

    save(cluster_info, file=out_file)
}

#' Compute the -log10 of Poisson distribution
#'
#' @param m the total number of all anchored points 
#' @param n the product of the remapped gene number of query species and subject species
#' @param q the product of the anchored points in the cluster constructed by two segments
#' @param k the product of the remapped gene number of the segmented chromosomes of query species and subject species
#'
#' @return
#' @export
#'
#' @examples
CalHomoConcentration <- function(m, n, q, k) {
    p <- m / n
    mean <- k * p
    return(-log10(ppois(q, mean, lower.tail=F)))
}

#' Analyze each cluster and get the significantly enriched clusters
#'
#' @param segmented_file the file of segmented chromosome info
#' @param segmented_anchorpoints_file the file of anchored points in the segmented info
#' @param genes_file genes.txt created by i-ADHoRe
#' @param cluster_info_file Clustering_info.10.RData includes the hclust output
#' @param identified_cluster_file the file used to save the significantly enriched clusters
#' @param hcheight the cutoff for cuttree, default 0.3
#'
#' @return
#' @export
#'
#' @examples analysisEachCluster(
#     segmented_file="/Users/jiali/Desktop/Projects/ShinyWGD/example/data/Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clusteringDir/segmented.chr.10.txt",
#     segmented_anchorpoints_file="/Users/jiali/Desktop/Projects/ShinyWGD/example/data/Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clusteringDir/segmented.anchorpoints.10.txt",
#     genes_file="/Users/jiali/Desktop/Projects/ShinyWGD/example/data/Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/genes.txt",
#     cluster_info_file="/Users/jiali/Desktop/Projects/ShinyWGD/example/data/Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clusteringDir/Clustering_info.10.RData",
#     identified_cluster_file="/Users/jiali/Desktop/Projects/ShinyWGD/example/data/Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/clusteringDir/Identified_Clusters.10.RData",
#     hclength=0.3
# )
analysisEachCluster <- function(
        segmented_file,
        segmented_anchorpoints_file,
        genes_file,
        cluster_info_file,
        identified_cluster_file,
        hcheight=0.3){
    
    library(grid)
    library(dplyr)
    library(gridBase)
    library(gridExtra)
    source(file="tools/CountOrthologs.R", local=TRUE, encoding="UTF-8")

    segs.df <- read.table(
        segmented_file,
        header=TRUE,
        sep="\t"
    )
    
    atomic.df <- read.table(
        segmented_anchorpoints_file,
        header=TRUE,
        sep="\t"
    )
    SpeciesX <- unique(atomic.df$speciesX)
    SpeciesY <- unique(atomic.df$speciesY)

    genes.df <- read.table(
        genes_file,
        header=TRUE,
        sep="\t"
    ) %>%
        select(id, genome, list, remapped_coordinate)

    load(cluster_info_file)
    hc <- cluster_info
    hc.bycol <- hc$bycol
    hc.byrow <- hc$byrow

    cl.bycol <- cutree(hc$bycol, h=hcheight)
    cl.byrow <- cutree(hc$byrow, h=hcheight)
    
    cl.bycol.num <- max(cl.bycol)
    cl.byrow.num <- max(cl.byrow)
    
    identified_cluster_list <- list()
    par_num <- 0
    for( i in 1:cl.bycol.num  ){
        scaf.bycol <- names(cl.bycol[which(cl.bycol == i)])
        for( j in 1:cl.byrow.num ){ 
            scaf.byrow <- names(cl.byrow[which(cl.byrow == j)])
            clust <- ExtractCluster(
                segs.df,
                atomic.df,
                scaf.bycol,
                scaf.byrow
            )
            if( length(clust) > 0 ){
                m <- nrow(atomic.df)
                n <- nrow(genes.df[genes.df$genome==SpeciesX, ]) * nrow(genes.df[genes.df$genome==SpeciesY, ])
                col.k <- sum(clust[[1]][clust[[1]]$genome==SpeciesX, "num_gene_remapped"])
                row.k <- sum(clust[[1]][clust[[1]]$genome==SpeciesY, "num_gene_remapped"])
                k <- col.k * row.k
                q <- nrow(clust[[2]])
                p.value <- p.adjust(CalPvalue(m, n, q, k), method="bonferroni",
                                    n=cl.bycol.num * cl.byrow.num)

                if( p.value >= 1E-10 ){ #1E-100
                    next
                }

                p.value <- prettyNum(p.value, digits=4)
                
                par_num <- par_num + 1
                iteration_results <- list(
                    cluster_chr=clust[[1]],
                    cluster_anchorpoints=clust[[2]],
                    p_value=p.value,
                    par_id=par_num
                )
                identified_cluster_list <- c(identified_cluster_list, list(iteration_results))
            } else {
                next
            }
        }
    }
    
    save(identified_cluster_list, file=identified_cluster_file)
}

#' Computing the P value of the cluster
#'
#' @param m the total number of all anchored points 
#' @param n the product of the remapped gene number of query species and subject species
#' @param q the number of anchored points in the cluster
#' @param k the product of the remapped gene number of the segmented chromosomes of query species and subject species
#'
#' @return
#' @export
#'
#' @examples
CalPvalue <- function(m, n, q, k) {
    p <- m / n
    mean <- p * k
    return(ppois(q, mean, lower.tail=F))
}

#' Extract segments and anchored points based on the given scaf.bycol and scaf.byrow
#'
#' @param segs.df the data frame of segmented chromosome info
#' @param atomic.df the data frame of anchored points 
#' @param scaf.bycol the chromosome ids of the query species
#' @param scaf.byrow the chromosome ids of the subject species
#'
#' @return
#' @export
#'
#' @examples
extractCluster <- function(
        segs.df,
        atomic.df,
        scaf.bycol,
        scaf.byrow){
    
    atomic.df1 <- atomic.df[atomic.df$listX %in% scaf.bycol, ]
    atomic.df2 <- atomic.df1[atomic.df1$listY %in% scaf.byrow, ]
    
    SpeciesX <- unique(atomic.df$speciesX)
    SpeciesY <- unique(atomic.df$speciesY)
    
    if( nrow(atomic.df2) == 0 ){
        return(NULL)
    }else{
        segs.df1 <- segs.df[segs.df$genome == SpeciesX & segs.df$list %in% scaf.bycol, ]
        segs.df2 <- segs.df[segs.df$genome == SpeciesY & segs.df$list %in% scaf.byrow, ]
        cluster <- list()
        cluster[["segs"]] <- rbind(segs.df1, segs.df2)
        cluster[["atomtic"]] <- atomic.df2
        return(cluster)
    }
}
