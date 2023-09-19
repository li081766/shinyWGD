#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 7 ]; then
	echo "Usage: $0 <singleCopyOrthologuesID> <orthologuesGroups> <singleCopyOrthologues> <cdsFastaDir> <aliged.phylip> <tree.newick> <number_threads>"
	exit 1
fi


# Check if the files exist
if [ ! -f "$1" ] || [ ! -f "$2" ]; then
	echo "Error: the output of Orthofinder is not found. Please check the run log of Orthofinder."
	exit 1
fi



# Number of threads
num_threads=$7

start_time=$(date +%s) 

# Function to select singleCopyOrthologues from orthologuesGroups
select_items() {
	local first_file="$1"
	local second_file="$2"
	local output_file="$3"

	awk 'FNR == 1 {print}' "$second_file"
	awk 'FNR == NR { items[$0] = 1; next } $1 in items' "$first_file" "$second_file"
}

process_orthogroup() {
	local row=("$@")
	local orthogroup="${row[0]}"
	local sequence

	for ((i = 1; i < num_species; i++)); do
		species="${species_names[i]}"
		species_name="${species%%_*}"
		species_file="${species_files[$species_name]}"
		gene_id="${row[i]}"
		sequence=$(grep -A 1 -wF "$gene_id" "$species_file" | tail -n 1 | sed 's/TAA$//; s/TGA$//; s/TAG$//')

        # Check if the length is divisible by 3
		if (( ${#sequence} % 3 != 0 )); then
			continue
		fi
		echo -e ">${species}_${gene_id}" >> "singleCopyGeneDir/$orthogroup.fas"
		echo "$sequence" >> "singleCopyGeneDir/$orthogroup.fas"
	done

	if (( ${#sequence} % 3 != 0 )); then
		return
	fi

	module load gcc/x86_64/6.3
	/home/jiali/Software/Prank/170703/development/prank/bin/prank -codon -once -quiet -d="singleCopyGeneDir/$orthogroup.fas" -o="singleCopyGeneDir/$orthogroup"
	#/home/jiali/miniconda3/envs/Trimal/bin/trimal -in "singleCopyGeneDir/$orthogroup.best.fas" -out "singleCopyGeneDir/$orthogroup.best.gb.fas" -automated1
	/software/shared/apps/x86_64/Gblocks/0.91b/Gblocks "singleCopyGeneDir/$orthogroup.best.fas"  -t=c -b4=15 -b5=n

	#rm "singleCopyGeneDir/$orthogroup.fas"
}


# Function to extract sequences for selected items
extract_sequences() {
	local selected_file="$1"
	local sequence_dir="$2"

	temp_file=$(mktemp)
	tr -d '\r' < "$selected_file" > "$temp_file"

	IFS=$'\t' read -r -a species_names < "$temp_file"
	num_species="${#species_names[@]}"

	declare -A species_files

	for ((i = 1; i < num_species; i++)); do
		species="${species_names[i]}"
		species_name="${species%%_*}"
		species_file="${sequence_dir}/${species_name}*.fa"
		
		if ls $species_file >/dev/null 2>&1; then
			species_files["$species_name"]=$(ls $species_file)
		else
			echo "Species file not found: ${species_name}.fa"
		fi
	done
	
	if [ -d "singleCopyGeneDir" ]; then
	    rm -r "singleCopyGeneDir"
	fi
	mkdir "singleCopyGeneDir"
	
	max_jobs=${num_threads}
	current_jobs=0
	
	# Read the temp file line by line, process orthogroups in parallel
	tail -n +2 "$temp_file" | while IFS=$'\t' read -r -a row; do
	    process_orthogroup "${row[@]}" &
	    ((current_jobs++))
	
	    if (( current_jobs >= max_jobs )); then
	        wait
	        current_jobs=0
	    fi
	done
	wait
	rm "$temp_file"
}

merge_aligned_files_into_phylip() {
    local selected_file="$1"
    local aligned_dir="$2"
    local output_file="$3"

    local aligned_files=("$aligned_dir"/*.fas-gb)

    temp_file=$(mktemp)
    tr -d '\r' < "$selected_file" > "$temp_file"
    IFS=$'\t' read -r -a species_names <<< "$(head -n 1 "$temp_file" | cut -f 2-)"

    # Declare the associative array to store concatenated sequences
	#local concatenated_seqs=()
	declare -A concatenated_seqs

    # Iterate over the aligned sequence files
    for aligned_file in "${aligned_files[@]}"; do
        local orthogroup=$(basename "$aligned_file" | cut -d'.' -f1)

        # Read the aligned sequences from the file
        while IFS= read -r line; do
            if [[ $line == '>'* ]]; then
                IFS='_' read -r -a name_parts <<< "${line:1}"
                local species="${name_parts[0]}_${name_parts[1]}"
            else
				concatenated_seqs["$species"]+="${line//[[:space:]]/}"
            fi
        done < "$aligned_file"
    done

    # Write the concatenated sequences to the output phylip file
    echo "${#species_names[@]} ${#concatenated_seqs[${species_names[0]}]}" > "$output_file"
    for species in "${species_names[@]}"; do
        printf "%-20s    %s\n" "$species" "${concatenated_seqs[$species]}" >> "$output_file"
    done

    rm "$temp_file"
}


# Function to compute ks value using PAML
compute_ks() {
	local phylip="$1"
	local tree="$2"
	sed 's/, /,/g' "$tree" | sed 's/ /_/g' >tree.newick 

    # Create PAML control file
    control_file="singleCopyGene.paml.ctrl"
    cat > "$control_file" <<EOF
      seqfile = ${phylip}
	  treefile = tree.newick 
      outfile = singleCopyGene.paml.out
      noisy = 9
      verbose = 1
      runmode = 0
      seqtype = 1
      CodonFreq = 2
      clock = 0
      model = 1
      NSsites = 0
       icode = 0
      Mgene = 0
      fix_kappa = 0
      kappa = 2
      fix_omega = 0
      omega = 2
      fix_alpha = 1
      alpha = .0
      Malpha = 0
      ncatG = 4
      getSE = 0
      RateAncestor = 0
      method = 0
EOF

    # Run PAML to compute ks value
	module load paml
    codeml "$control_file" >/dev/null
	
	# Extract ds Tree from PAML output
	grep -A 1 "dS tree:" singleCopyGene.paml.out  | tail -n 1 >singleCopyGene.ds_tree.newick
}


declare -a pids
waitPids() {
	while [ ${#pids[@]} -ne 0 ]; do
		#echo "Waiting for pids: ${pids[@]}"
		local range=$(eval echo {0..$((${#pids[@]}-1))})
		local i
		for i in $range; do
			if ! kill -0 ${pids[$i]} 2> /dev/null; then
				echo "Done -- ${pids[$i]}"
				unset pids[$i]
			fi
		done
		pids=("${pids[@]}") # Expunge nulls created by unset.
		sleep 1
	done
	#echo "Done!"
}

addPid() {
	local desc=$1
	local pid=$2
	echo "$desc -- $pid"
	pids=(${pids[@]} $pid)
}

select_items "$1" "$2" > "$3"
#extract_sequences "$3" "$4" 
selected_file="$3"
sequence_dir="$4"
temp_file=$(mktemp)
tr -d '\r' < "$selected_file" > "$temp_file"

IFS=$'\t' read -r -a species_names < "$temp_file"
num_species="${#species_names[@]}"

declare -A species_files

for ((i = 1; i < num_species; i++)); do
	species="${species_names[i]}"
	species_name="${species%%_*}"	
	species_file="${sequence_dir}/${species_name}*.fa"

	if ls $species_file >/dev/null 2>&1; then
		species_files["$species_name"]=$(ls $species_file)
	else
		echo "Species file not found: ${species_name}.fa"
	fi
done

if [ -d "singleCopyGeneDir" ]; then
	rm -r "singleCopyGeneDir"
fi
mkdir "singleCopyGeneDir"

tmp_rows_file=$(mktemp)
tail -n +2 "$temp_file" > "$tmp_rows_file"

max_jobs="${num_threads}"
current_jobs=0

while IFS=$'\t' read -r -a row; do

	if [ "$current_jobs" -ge "$max_jobs" ]; then
		waitPids
		current_jobs=0
	fi

	process_orthogroup "${row[@]}" &
	addPid "Sleep for ${row[0]}" $!
	((current_jobs++))

done < "$tmp_rows_file"

waitPids

merge_aligned_files_into_phylip "$3" "singleCopyGeneDir" "$5"
compute_ks "$5" "$6"

# Get the end time of the script
end_time=$(date +%s)
runtime=$((end_time - start_time))

echo "Script execution time: $runtime seconds"
