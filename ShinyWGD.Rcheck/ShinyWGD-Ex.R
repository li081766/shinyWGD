pkgname <- "ShinyWGD"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('ShinyWGD')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("CalHomoConcentration")
### * CalHomoConcentration

flush(stderr()); flush(stdout())

### Name: CalHomoConcentration
### Title: Compute the -log10 of Poisson Distribution
### Aliases: CalHomoConcentration

### ** Examples

# Example usage:
p_value <- CalHomoConcentration(m=100, n=1000, q=10, k=1)



cleanEx()
nameEx("CalPvalue")
### * CalPvalue

flush(stderr()); flush(stdout())

### Name: CalPvalue
### Title: Compute the P-value of a Cluster using the Poisson Distribution
### Aliases: CalPvalue

### ** Examples

# Example usage:
p_value <- CalPvalue(m=100, n=10000, q=5, k=250)
cat("P-value:", p_value, "\n")



cleanEx()
nameEx("CountOrthologs")
### * CountOrthologs

flush(stderr()); flush(stdout())

### Name: CountOrthologs
### Title: Count Ortholog Genes in a Species
### Aliases: CountOrthologs

### ** Examples

# Example usage:
ortholog_counts <- CountOrthologs(atomic.df, species="SpeciesA")
print(ortholog_counts)



cleanEx()
nameEx("PeaksInKsDistributionValues")
### * PeaksInKsDistributionValues

flush(stderr()); flush(stdout())

### Name: PeaksInKsDistributionValues
### Title: Find Peaks in the Ks Distribution
### Aliases: PeaksInKsDistributionValues

### ** Examples

# Generate a vector of Ks values (replace with your data)
ks_values <- c(0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 1.2, 1.5, 2.0, 2.5)

# Find peaks in the Ks distribution
peaks <- PeaksInKsDistributionValues(ks=ks_values, binWidth=0.1, maxK=2.5, m=3, peak.maxK=2.0, spar=0.25)

# Print the identified peaks
print(peaks)



cleanEx()
nameEx("SiZer")
### * SiZer

flush(stderr()); flush(stdout())

### Name: SiZer
### Title: SiZer (Significant Zero Crossings)
### Aliases: SiZer

### ** Examples

df_sizer <- SiZer(
    ks_value_tmp,
    gridsize=c(500, 50),
    bw=c(0.01, 5)
)



cleanEx()
nameEx("SignifFeatureRegion")
### * SignifFeatureRegion

flush(stderr()); flush(stdout())

### Name: SignifFeatureRegion
### Title: SignifFeatureRegion
### Aliases: SignifFeatureRegion

### ** Examples

SignifFeatureRegion(n, d, gcounts, gridsizegs, est.dens, h, signifLevel, range.x, grad=TRUE, curv=FALSE)



cleanEx()
nameEx("analysisEachCluster")
### * analysisEachCluster

flush(stderr()); flush(stdout())

### Name: analysisEachCluster
### Title: Perform synteny analysis for identified clusters
### Aliases: analysisEachCluster

### ** Examples

analysisEachCluster(



cleanEx()
nameEx("bootStrapPeaks")
### * bootStrapPeaks

flush(stderr()); flush(stdout())

### Name: bootStrapPeaks
### Title: Bootstrap Peaks in the Ks Distribution
### Aliases: bootStrapPeaks

### ** Examples

# Load or obtain a Ks distribution (replace with your data)
ks_distribution <- c(0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 1.2, 1.5, 2.0, 2.5)

# Bootstrap peak estimation
bootstrap_peaks <- bootStrapPeaks(
    ksRaw=ks_distribution,
    peak.index=1,
    rep=1000,
    peak.maxK=2.5
)

# Print the bootstrapped peak estimates
print(bootstrap_peaks)



cleanEx()
nameEx("calculateKsDistribution4wgd_multiple")
### * calculateKsDistribution4wgd_multiple

flush(stderr()); flush(stdout())

### Name: calculateKsDistribution4wgd_multiple
### Title: Calculate the Ks Distribution for Multiple Speices
### Aliases: calculateKsDistribution4wgd_multiple

### ** Examples

# Example usage:
result <- calculateKsDistribution4wgd_multiple(
    files_list = files_list_new,
    binWidth = 0.1,
    maxK = 5,
    plot.mode = "weighted",
    include.outliers = FALSE,
    minK = 0,
    minAlnLen = 0,
    minIdn = 0,
    minCov = 0
)



cleanEx()
nameEx("check_gff_from_file")
### * check_gff_from_file

flush(stderr()); flush(stdout())

### Name: check_gff_from_file
### Title: Check and Process GFF Input File from a Specific Path
### Aliases: check_gff_from_file

### ** Examples

gff_temp <- check_gff_from_file("MyGFF", "/path/to/my_gff.gff")



cleanEx()
nameEx("check_gff_input")
### * check_gff_input

flush(stderr()); flush(stdout())

### Name: check_gff_input
### Title: Check and Prepare GFF/GTF Input File
### Aliases: check_gff_input

### ** Examples

check_gff_input("Sample GFF", input[[paste0("gff_", 1)]])



cleanEx()
nameEx("check_proteome_from_file")
### * check_proteome_from_file

flush(stderr()); flush(stdout())

### Name: check_proteome_from_file
### Title: Check and Process Proteome Input File From a Special Path
### Aliases: check_proteome_from_file

### ** Examples

proteome_temp <- check_proteome_input("MyProteome", my_proteome_data)



cleanEx()
nameEx("check_proteome_input")
### * check_proteome_input

flush(stderr()); flush(stdout())

### Name: check_proteome_input
### Title: Check and Process Proteome Input File
### Aliases: check_proteome_input

### ** Examples

proteome_temp <- check_proteome_input("MyProteome", my_proteome_data)



cleanEx()
nameEx("cluster_synteny")
### * cluster_synteny

flush(stderr()); flush(stdout())

### Name: cluster_synteny
### Title: Cluster Synteny Data and Generate Trees
### Aliases: cluster_synteny

### ** Examples

# Example usage:
cluster_synteny(
    segmented_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/clusteringDir/segmented.chr.10.txt",
    segmented_anchorpoints_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/clusteringDir/segmented.anchorpoints.10.txt",
    genes_file="Analysis_2023-09-06/i-ADHoRe_wd/i-adhore.AMK_vs_Zostera_marina/genes.txt",
    out_file="output_cluster_info.RData"
)



cleanEx()
nameEx("computing_depth")
### * computing_depth

flush(stderr()); flush(stdout())

### Name: computing_depth
### Title: Compute the Depth of Anchored Points
### Aliases: computing_depth

### ** Examples

# Example usage:
depth_list <- computing_depth(
    anchorpoint_ks_file = anchorpointout_file,
    multiplicon_id = selected_multiplicons_Id,
    selected_query_chr = query_selected_chr_list,
    selected_subject_chr = subject_selected_chr_list
)



cleanEx()
nameEx("computing_depth_paranome")
### * computing_depth_paranome

flush(stderr()); flush(stdout())

### Name: computing_depth_paranome
### Title: Compute the Depth of Anchored Points in a Paranome Comparison
### Aliases: computing_depth_paranome

### ** Examples

# Example usage:
depth_list <- computing_depth_paranome(
    anchorpoint_ks_file = anchorpointout_file,
    multiplicon_id = selected_multiplicons_Id,
    selected_query_chr = query_selected_chr_list
)




cleanEx()
nameEx("convert_wgd2kevins")
### * convert_wgd2kevins

flush(stderr()); flush(stdout())

### Name: convert_wgd2kevins
### Title: Convert
### Aliases: convert_wgd2kevins

### ** Examples

convert_wgd2kevins(file, "rice")



cleanEx()
nameEx("create_ksrates_cmd")
### * create_ksrates_cmd

flush(stderr()); flush(stdout())

### Name: create_ksrates_cmd
### Title: Create Ksrates Command Files from Shiny Input
### Aliases: create_ksrates_cmd

### ** Examples

create_ksrates_cmd(input, "ksrates_conf.txt", ksrates_cmd_sh_file)



cleanEx()
nameEx("create_ksrates_cmd_from_table")
### * create_ksrates_cmd_from_table

flush(stderr()); flush(stdout())

### Name: create_ksrates_cmd_from_table
### Title: Create Ksrates Command Files from Data Table
### Aliases: create_ksrates_cmd_from_table

### ** Examples

create_ksrates_cmd_from_table(
  my_data_table,
  "ksrates_config.txt",
  "ksrates_cmd.sh",
  "wgd_cmd.sh",
  "FocalSpecies"
)



cleanEx()
nameEx("create_ksrates_configure_file_based_on_table")
### * create_ksrates_configure_file_based_on_table

flush(stderr()); flush(stdout())

### Name: create_ksrates_configure_file_based_on_table
### Title: Create Ksrates Configuration File Based on Data Table
### Aliases: create_ksrates_configure_file_based_on_table

### ** Examples

create_ksrates_configure_file_based_on_table(
  my_data_table,
  "FocalSpecies",
  "my_newick_tree.newick",
  "ksrates_config.txt",
  "species_info.txt"
)



cleanEx()
nameEx("create_ksrates_configure_file_v2")
### * create_ksrates_configure_file_v2

flush(stderr()); flush(stdout())

### Name: create_ksrates_configure_file_v2
### Title: Create Ksrates Configuration File
### Aliases: create_ksrates_configure_file_v2

### ** Examples

create_ksrates_configure_file_v2(input, "ksrates_config.txt", "species_info.txt")



cleanEx()
nameEx("create_ksrates_expert_parameter_file")
### * create_ksrates_expert_parameter_file

flush(stderr()); flush(stdout())

### Name: create_ksrates_expert_parameter_file
### Title: Create ksrates Expert Parameter File
### Aliases: create_ksrates_expert_parameter_file

### ** Examples

ksratesexpert <- paste0(ksratesDir, "/ksrates_expert_parameter.txt")
create_ksrates_expert_parameter_file(ksratesexpert)



cleanEx()
nameEx("dfltBWrange")
### * dfltBWrange

flush(stderr()); flush(stdout())

### Name: dfltBWrange
### Title: dfltBWrange
### Aliases: dfltBWrange

### ** Examples

dfltBWrange(x, tau)



cleanEx()
nameEx("dfltCounts")
### * dfltCounts

flush(stderr()); flush(stdout())

### Name: dfltCounts
### Title: dfltCounts
### Aliases: dfltCounts

### ** Examples

dfltCounts(x, gridsize, h, supp, range.x, w)



cleanEx()
nameEx("downloadButton_custom")
### * downloadButton_custom

flush(stderr()); flush(stdout())

### Name: downloadButton_custom
### Title: Creating a Custom Download Button
### Aliases: downloadButton_custom

### ** Examples

downloadButton_custom(
    outputId="wgd_ksrates_data_download",
    label="Download Analysis Data",
    width="215px",
    icon=icon("download"),
    status="secondary",
    style="background-color: #5151A2;
             padding: 5px 10px 5px 10px;
             margin: 5px 5px 5px 5px;
             animation: glowingD 5000ms infinite; "
)



cleanEx()
nameEx("drvkde")
### * drvkde

flush(stderr()); flush(stdout())

### Name: drvkde
### Title: drvkde
### Aliases: drvkde

### ** Examples

est.dens <- drvkde(x, drv0, bandwidthh, gridsizegridsize, range.xrange.x, binnedTRUE, seFALSE)



cleanEx()
nameEx("extractCluster")
### * extractCluster

flush(stderr()); flush(stdout())

### Name: extractCluster
### Title: Extract clusters based on specified scaffolds
### Aliases: extractCluster

### ** Examples

# Example usage:
query_scaffolds <- c("scaffold1", "scaffold2")
subject_scaffolds <- c("chromosomeA", "chromosomeB")
cluster <- extractCluster(segs.df, atomic.df, query_scaffolds, subject_scaffolds)
if (!is.null(cluster)) {
  cat("Cluster extracted successfully!\n")
} else {
  cat("No cluster found for the specified scaffolds.\n")
}



cleanEx()
nameEx("find_peaks")
### * find_peaks

flush(stderr()); flush(stdout())

### Name: find_peaks
### Title: Find Peaks in a Numeric Vector
### Aliases: find_peaks

### ** Examples

# Generate some example data
x <- c(1, 3, 7, 2, 6, 8, 5, 4, 9, 3, 2, 1)

# Find peaks in the data with a half-width of 2
peaks <- find_peaks(x, m=2)

# Print the indices of the identified peaks
print(peaks)



cleanEx()
nameEx("generateKsDistribution")
### * generateKsDistribution

flush(stderr()); flush(stdout())

### Name: generateKsDistribution
### Title: Generate the Ks Distribution
### Aliases: generateKsDistribution

### ** Examples

# Load or obtain raw Ks values (replace with your data)
raw_ks_values <- c(0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 1.2, 1.5, 2.0, 2.5)

# Generate the Ks distribution
ks_distribution <- generateKsDistribution(ksraw=raw_ks_values, maxK=2.5)

# Print the binned Ks distribution
print(ks_distribution)



cleanEx()
nameEx("generate_ksd")
### * generate_ksd

flush(stderr()); flush(stdout())

### Name: generate_ksd
### Title: Convert
### Aliases: generate_ksd

### ** Examples

generate_ksd(ks_df, bin_width=0.01)



cleanEx()
nameEx("get_segments")
### * get_segments

flush(stderr()); flush(stdout())

### Name: get_segments
### Title: Get Segmented Data from Anchorpoints and Ks Values
### Aliases: get_segments

### ** Examples

# Example usage:
get_segments(
    genes_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/genes.txt",
    anchors_ks_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.merged_pos_ks.txt",
    multiplicons_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/multiplicons.txt",
    segmented_file="output_segmented_data.txt",
    segmented_anchorpoints_file="output_segmented_anchorpoints.txt",
    num_anchors=5
)



cleanEx()
nameEx("is.ksv")
### * is.ksv

flush(stderr()); flush(stdout())

### Name: is.ksv
### Title: ksv class
### Aliases: is.ksv

### ** Examples

is.ksv(x)
is.ksv(x)



cleanEx()
nameEx("is.not.null")
### * is.not.null

flush(stderr()); flush(stdout())

### Name: is.not.null
### Title: Check if an Object is Not NULL
### Aliases: is.not.null

### ** Examples

is.not.null(5)
is.not.null(NULL)



cleanEx()
nameEx("ks_mclust_v2")
### * ks_mclust_v2

flush(stderr()); flush(stdout())

### Name: ks_mclust_v2
### Title: ks_mclust_v2
### Aliases: ks_mclust_v2

### ** Examples

ks_mclust_v2(ks_value)



cleanEx()
nameEx("map_informal_name_to_latin_name")
### * map_informal_name_to_latin_name

flush(stderr()); flush(stdout())

### Name: map_informal_name_to_latin_name
### Title: Map Informal Names to Latin Names
### Aliases: map_informal_name_to_latin_name

### ** Examples

names_df <- map_informal_name_to_latin_name("species_info.xls")



cleanEx()
nameEx("mix_logNormal_Ks")
### * mix_logNormal_Ks

flush(stderr()); flush(stdout())

### Name: mix_logNormal_Ks
### Title: Log-Normal mixturing analyses of a Ks distributions for the
###   whole paranome
### Aliases: mix_logNormal_Ks

### ** Examples

mix_logNormal_Ks <- function(ksv)




cleanEx()
nameEx("modeFinder")
### * modeFinder

flush(stderr()); flush(stdout())

### Name: modeFinder
### Title: modeFinder
### Aliases: modeFinder

### ** Examples

modeFinder(x)



cleanEx()
nameEx("obtain_chromosome_length")
### * obtain_chromosome_length

flush(stderr()); flush(stdout())

### Name: obtain_chromosome_length
### Title: obtain_chromosome_length
### Aliases: obtain_chromosome_length

### ** Examples

# Load the species information into a data frame (replace 'species_info_df' with your actual data frame)
species_info_df <- read.table("path/to/your/species_info_file.txt", sep="\t", header=TRUE)

# Call the obtain_chromosome_length_filter function
result <- obtain_chromosome_length_filter(species_info_df)

# Access the chromosome length and mRNA count data frames from the result
len_df <- result$len_df
num_df <- result$num_df

# Print the first few rows of the data frames
head(len_df)
head(num_df)



cleanEx()
nameEx("obtain_chromosome_length_filter")
### * obtain_chromosome_length_filter

flush(stderr()); flush(stdout())

### Name: obtain_chromosome_length_filter
### Title: obtain_chromosome_length_filter
### Aliases: obtain_chromosome_length_filter

### ** Examples

Create a sample data frame
species_info_df <- data.frame(
  sp=c("SpeciesA", "SpeciesB"),
  cds=c("cds_file_A.gff", "cds_file_B.gff"),
  gff=c("gff_file_A.gff", "gff_file_B.gff")
)

# Obtain chromosome lengths and mRNA counts
result <- obtain_chromosome_length_filter(species_info_df)



cleanEx()
nameEx("obtain_coordiantes_for_anchorpoints")
### * obtain_coordiantes_for_anchorpoints

flush(stderr()); flush(stdout())

### Name: obtain_coordiantes_for_anchorpoints
### Title: Obtain coordinates for anchorpoints from GFF files
### Aliases: obtain_coordiantes_for_anchorpoints

### ** Examples

# Example usage with one species:
obtain_coordiantes_for_anchorpoints(
  anchorpoints="anchorpoints.txt",
  species1="SpeciesA",
  gff_file1="speciesA.gff",
  out_file="results.txt"
)

# Example usage with two species:
obtain_coordiantes_for_anchorpoints(
  anchorpoints="anchorpoints.txt",
  species1="SpeciesA",
  gff_file1="speciesA.gff",
  species2="SpeciesB",
  gff_file2="speciesB.gff",
  out_file="results.txt"
)



cleanEx()
nameEx("obtain_coordiantes_for_anchorpoints_ks")
### * obtain_coordiantes_for_anchorpoints_ks

flush(stderr()); flush(stdout())

### Name: obtain_coordiantes_for_anchorpoints_ks
### Title: Obtain Coordinates and Ks Values for Anchorpoints
### Aliases: obtain_coordiantes_for_anchorpoints_ks

### ** Examples

# Example usage:
obtain_coordiantes_for_anchorpoints_ks(
    anchorpoints="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.txt",
    anchorpoints_ks="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/anchorpoints.ks.txt",
    genes_file="Analysis_2023-07-04/i-ADHoRe_wd/i-adhore.Vitis_vinifera_vs_Oryza_sativa/genes.txt",
    out_file="output_coordinates.txt",
    out_ks_file="output_ks_values.txt",
    species="Vitis_vinifera"
)



cleanEx()
nameEx("obtain_coordiantes_for_segments")
### * obtain_coordiantes_for_segments

flush(stderr()); flush(stdout())

### Name: obtain_coordiantes_for_segments
### Title: Obtain coordinates for segments in a comparison
### Aliases: obtain_coordiantes_for_segments

### ** Examples

obtain_coordiantes_for_segments(



cleanEx()
nameEx("obtain_coordinates_for_segments_multiple")
### * obtain_coordinates_for_segments_multiple

flush(stderr()); flush(stdout())

### Name: obtain_coordinates_for_segments_multiple
### Title: Obtain Coordinates for Segments in Multiple Synteny Blocks
### Aliases: obtain_coordinates_for_segments_multiple

### ** Examples

# Example usage:
# Define dataframes for segments and GFF information
seg_df <- read.table("segments.csv", header=TRUE, sep=",")
gff_df <- read.table("genomic_data.gff", header=TRUE, sep="\t")

# Define input data
input_data <- list(
    multiple_synteny_query_chr_SpeciesA=c("Chr1", "Chr2"),
    multiple_synteny_query_chr_SpeciesB=c("ChrX", "ChrY")
)

# Obtain coordinates for segments within multiple synteny blocks
obtain_coordinates_for_segments_multiple(seg_df, gff_df, input_data, "output_coordinates.txt")




cleanEx()
nameEx("obtain_mean_ks_for_each_multiplicon")
### * obtain_mean_ks_for_each_multiplicon

flush(stderr()); flush(stdout())

### Name: obtain_mean_ks_for_each_multiplicon
### Title: Compute the Mean of Ks values for Each Multiplicon
### Aliases: obtain_mean_ks_for_each_multiplicon

### ** Examples

# Example usage with one species:
obtain_mean_ks_for_each_multiplicon(
    multiplicon_file="multiplicons.txt",
    anchorpoint_file="anchorpoints.txt",
    ks_file="ks_values.txt",
    species1="SpeciesA",
    outfile="mean_ks_for_multiplicons.txt",
    anchorpointout_file="anchorpoint_with_ks.txt"
)

# Example usage with two species:
obtain_mean_ks_for_each_multiplicon(
    multiplicon_file="multiplicons.txt",
    anchorpoint_file="anchorpoints.txt",
    ks_file="ks_values.txt",
    species1="SpeciesA",
    species2="SpeciesB",
    outfile="mean_ks_for_multiplicons.txt",
    anchorpointout_file="anchorpoint_with_ks.txt"
)



cleanEx()
nameEx("parse_EMMIX")
### * parse_EMMIX

flush(stderr()); flush(stdout())

### Name: parse_EMMIX
### Title: Read the EMMIX output for a range of components
### Aliases: parse_EMMIX

### ** Examples

parse_EMMIX(emmix.out)



cleanEx()
nameEx("parse_one_EMMIX")
### * parse_one_EMMIX

flush(stderr()); flush(stdout())

### Name: parse_one_EMMIX
### Title: Read the EMMIX output for a specify number of components
### Aliases: parse_one_EMMIX

### ** Examples

parseEMMIX("data/WelMiLog.out")



cleanEx()
nameEx("plot.ksv")
### * plot.ksv

flush(stderr()); flush(stdout())

### Name: plot.ksv
### Title: Draw Ks distribution using output from 'wgd'
### Aliases: plot.ksv

### ** Examples

ksv <- read.wgd_ksd(file)
plot.ksv(ksv)



cleanEx()
nameEx("plot_Ks_mix")
### * plot_Ks_mix

flush(stderr()); flush(stdout())

### Name: plot_Ks_mix
### Title: Draw a Ks distribution with fitted Gaussian
### Aliases: plot_Ks_mix

### ** Examples

plot_Ks_mix(ksv)



cleanEx()
nameEx("plot_ksv_density")
### * plot_ksv_density

flush(stderr()); flush(stdout())

### Name: plot_ksv_density
### Title: Draw a density plot of ksv
### Aliases: plot_ksv_density

### ** Examples

plot_ksv_density(mids, count, 5)



cleanEx()
nameEx("read.dating_anchors")
### * read.dating_anchors

flush(stderr()); flush(stdout())

### Name: read.dating_anchors
### Title: Read the output of Ks values for anchor pairs from the dating
###   pipeline
### Aliases: read.dating_anchors

### ** Examples

ksv <- read.dating_anchors(file)



cleanEx()
nameEx("read.wgd_ksd")
### * read.wgd_ksd

flush(stderr()); flush(stdout())

### Name: read.wgd_ksd
### Title: Read the output file of wgd ksd
### Aliases: read.wgd_ksd

### ** Examples

ksv <- read.wgd_ksd(file)



cleanEx()
nameEx("read_KTpipeline")
### * read_KTpipeline

flush(stderr()); flush(stdout())

### Name: read_KTpipeline
### Title: Read file from KT pipeline
### Aliases: read_KTpipeline

### ** Examples

read_KTpipeline(file)



cleanEx()
nameEx("read_data_file")
### * read_data_file

flush(stderr()); flush(stdout())

### Name: read_data_file
### Title: Read Data from Uploaded File
### Aliases: read_data_file

### ** Examples

data <- read_data_file(input$upload_data_file)
column1 <- data[["V1"]]



cleanEx()
nameEx("relativeRate")
### * relativeRate

flush(stderr()); flush(stdout())

### Name: relativeRate
### Title: relativeRate
### Aliases: relativeRate

### ** Examples

relativeRate(ksv2out_1_file, ksv2out_2_file, ksv_between_file, KsMax)



cleanEx()
nameEx("replace_informal_name_to_latin_name")
### * replace_informal_name_to_latin_name

flush(stderr()); flush(stdout())

### Name: replace_informal_name_to_latin_name
### Title: Replace Informal Names with Latin Names
### Aliases: replace_informal_name_to_latin_name

### ** Examples

replaced_name <- replace_informal_name_to_latin_name(names_df, "species1_species2")



cleanEx()
nameEx("resampleKsDistribution")
### * resampleKsDistribution

flush(stderr()); flush(stdout())

### Name: resampleKsDistribution
### Title: Resample a Ks Distribution
### Aliases: resampleKsDistribution

### ** Examples

# Load or obtain a Ks distribution (replace with your data)
ks_distribution <- c(0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 1.2, 1.5, 2.0, 2.5)

# Resample the Ks distribution
resampled_ks <- resampleKsDistribution(ks=ks_distribution, maxK=2.5)

# Print the resampled Ks distribution
print(resampled_ks)



cleanEx()
nameEx("symconv.ks")
### * symconv.ks

flush(stderr()); flush(stdout())

### Name: symconv.ks
### Title: symconv.ks
### Aliases: symconv.ks

### ** Examples

est <- symconv.ks(kappam, gcounts, skewflag(-1)^drv)



cleanEx()
nameEx("symconv2D.ks")
### * symconv2D.ks

flush(stderr()); flush(stdout())

### Name: symconv2D.ks
### Title: symconv2D.ks
### Aliases: symconv2D.ks

### ** Examples

est.var <- ((symconv2D.ks((n*kappam)^2, gcounts)/n) - est^2)/(n-1)



cleanEx()
nameEx("symconv3D.ks")
### * symconv3D.ks

flush(stderr()); flush(stdout())

### Name: symconv3D.ks
### Title: symconv3D.ks
### Aliases: symconv3D.ks

### ** Examples

est <- symconv3D.ks(kappam, gcounts, skewflag(-1)^drv)



cleanEx()
nameEx("symconv4D.ks")
### * symconv4D.ks

flush(stderr()); flush(stdout())

### Name: symconv4D.ks
### Title: symconv4D.ks
### Aliases: symconv4D.ks

### ** Examples

est <- symconv4D.ks(kappam, gcounts, skewflag(-1)^drv)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
