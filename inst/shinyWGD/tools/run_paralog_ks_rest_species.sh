#!/bin/bash

#SBATCH -p all
#SBATCH -c 4
#SBATCH --mem 10G
#SBATCH -o run_paralog_ks_rest_species.sh.o%j
#SBATCH -e run_paralog_ks_rest_species.sh.e%j

export OPENBLAS_NUM_THREADS=2
export GOTO_NUM_THREADS=2
export OMP_NUM_THREADS=2

module load ksrates/x86_64/1.1.3


species_names=$(awk -F'[:, ]+' '/fasta_filenames/ {for (i=3; i<=NF; i+=2) print $i}' ksrates_conf.txt)
focal_species=$(awk -F'=' '/focal_species/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' ksrates_conf.txt)

readarray -t species_array <<< "$species_names"

species_array=("${species_array[@]/$focal_species}")

for species in "${species_array[@]}"; do
	echo $species
	gff_file="../$species.gff"
	if [[ -f "$gff_file" ]]; then
		focal_species="$species"
		echo "Found $gff_file"
		awk -v focal_species="$focal_species" -v gff_file="$gff_file" '/focal_species/ {$0 = "focal_species = " focal_species} /gff_filename/ {$0 = "gff_filename = " gff_file} 1' ksrates_conf.txt > ksrates_conf_$species.txt
		ksrates init ksrates_conf_$species.txt
		ksrates paralogs-ks ksrates_conf_$species.txt --n-threads 4
		rm ksrates_conf_$species.txt
		if [ -f "rate_adjustment/$species.txt" ]; then
			rm "rate_adjustment/$species.txt" 
		fi
	fi
done


echo Done at: `date`
