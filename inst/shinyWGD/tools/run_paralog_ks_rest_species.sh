#!/bin/bash

#SBATCH -p all
#SBATCH -c 4
#SBATCH --mem 10G
#SBATCH -o run_paralog_ks_rest_species.sh.o%j
#SBATCH -e run_paralog_ks_rest_species.sh.e%j

export OPENBLAS_NUM_THREADS=4
export GOTO_NUM_THREADS=4
export OMP_NUM_THREADS=4

module load ksrates/x86_64/1.1.3


species_names=$(ls ../*fa | cut -d '/' -f 2 | sed 's/\.fa//')
focal_species=$(awk -F'=' '/focal_species/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' ksrates_conf.txt)

readarray -t species_array <<< "$species_names"

species_array=("${species_array[@]/$focal_species}")

for species in "${species_array[@]}"; do
	if [[ "$species" == "" ]]; then
		continue
	fi

	gff_file="../$species.gff"

	if [[ -f "$gff_file" ]]; then
		focal_species_renew="$species"
		awk -v focal_species="$focal_species_renew" -v gff_file="$gff_file" '/focal_species/ {$0 = "focal_species=" focal_species} /gff_filename/ {$0 = "gff_filename=" gff_file} 1' ksrates_conf.txt > ksrates_conf_$species.txt
	else
		focal_species_renew="$species"
		awk -v focal_species="$focal_species_renew" '/focal_species/ {$0 = "focal_species=" focal_species} 1' ksrates_conf.txt > ksrates_conf_$species.txt
		sed -i '/gff_filename/d' ksrates_conf_$species.txt
		sed -i 's/collinearity=yes/collinearity=no/' ksrates_conf_$species.txt
	fi

	ksrates init ksrates_conf_$species.txt
	ksrates paralogs-ks ksrates_conf_$species.txt --n-threads 4
	gzip paralog_distributions/wgd_$species/$species.blast.tsv
	rm ksrates_conf_$species.txt
	rm wgd_runs_$species.txt
done


echo Done at: `date`
