#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 6 ] && [ $# -ne 7 ]; then
    echo "Usage: $0 <tree.newick> <aleDir> <wgdNodes> <outShellFile> <model> <chain> <number>"
    exit 1
fi

whale_configure() {
	local tree=$1
	local aleDir=$2
	local wgdNodes=$3
	local outFile=$4
	local whaleModel=$5
	local whaleChain=$6

	whaleDir=$(dirname "$outFile")

	cat >$outFile <<EOF
using Pkg; Pkg.activate(@__DIR__)
using Whale, NewickTree, Turing, DataFrames, CSV, JSON, Serialization, LinearAlgebra, Optim, Distributions, Logging, KernelDensity


function compute_average_q(df)
	qcols = filter(x -> occursin("q", x), names(df))
	avg_q = [mean(df[!, col]) for col in qcols]
    return avg_q
end


out = mkpath("${whaleDir}/output")
log_file = joinpath(out, "run.log")
logger = SimpleLogger(open(log_file, "w"), LogLevel(Info))
global_logger(logger)

tree = readnw(readline("${tree}"))
@info "Tree read from file" tree
for n in postwalk(tree)
	n.data.distance / 100
end

nn = length(postwalk(tree))
@info "Number of internal nodes: " nn
EOF

	row_count=0
	random_list=()
	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ -z "$line" ]]; then
			continue
		fi

		name=$(echo "$line" | sed 's/ //g' | awk -F '[:-]' '{print $1}')
    	value2=$(echo "$line" | sed 's/ //g' | awk -F '[:-]' '{print $2}')
    	value3=$(echo "$line" | sed 's/ //g' | awk -F '[:-]' '{print $3}')

	   	if [[ "$value2" == "$value3" ]]; then
		   	parts="insertnode!(getlca(tree, \"$value2\"), name=\"$name\")"
		else
			parts="insertnode!(getlca(tree, \"$value2\", \"$value3\"), name=\"$name\")"
		fi

		#parts=$(echo "$line" | sed 's/ //g' |awk -F '[:-]' '{print "insertnode!(getlca(tree, \""$2"\", \""$3"\"), name=\""$1"\")"}')
		echo ${parts} >> ${outFile}
		((row_count++))
		random_value=$(awk -v seed="${row_count}" 'BEGIN{srand(seed); r=rand(); printf "%.3f\n", r}')
		random_list+=($random_value)

	done < $wgdNodes

	qList="["
	#pList="["
	for ((i=0; i<${#random_list[@]}; i++)); do
		if ((i != 0)); then
			#pList+=", "
			qList+=", "
		fi
		qList+="0.1"
		#pList+="${random_list[i]}"
	done
	#pList+="]"
	qList+="]"

	if [ "$whaleModel" == "Constant_rates" ]; then
		echo "param = ConstantDLWGD(λ=1., μ=1., η=0.9, q=${qList})" >>$outFile
		echo "@info \"param\" param" >>$outFile
		echo "model = WhaleModel(param, tree, .1, condition=Whale.RootCondition(), minn=10, maxn=20)" >>$outFile
		echo "@info \"model\" model" >>$outFile
		echo "write(joinpath(out, \"model.txt\"), repr(model))" >>$outFile
		echo "data = read_ale(\"${aleDir}\", model)" >>$outFile
		echo "@info \"ccd data\" data" >>$outFile

		echo "@model constantrates(model, data) = begin" >>$outFile
		echo -e "\tλ  ~ Exponential()" >>$outFile
		echo -e "\tμ  ~ Exponential()" >>$outFile
		echo -e "\tη  ~ Beta(3,1)" >>$outFile

		qq="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qq+=", "
			fi
			j=$((i+1))
			echo -e "\tq$j ~ Beta()" >>$outFile
			qq+="q$j"
		done
		qq+="]"

		echo -e "\tdata ~ model((λ=λ, μ=μ, η=η, q=${qq}))" >>$outFile
		echo "end" >>$outFile

		echo "chain0 = sample(constantrates(model, data), NUTS(), ${whaleChain})" >>$outFile
		echo "summary_file = joinpath(out, \"MCMCchain.s\")" >>$outFile
		echo "summary_stream = open(summary_file, \"w\")" >>$outFile
		echo "redirect_stdout(summary_stream)" >>$outFile
		echo "show(summary_stream, \"text/plain\", chain0)" >>$outFile
		echo "close(summary_stream)" >>$outFile
		echo "CSV.write(joinpath(out, \"chainConstantRates.csv\"), chain0)" >>$outFile
		echo "serialize(joinpath(out, \"chainConstantRates.jls\"), chain0)" >>$outFile
		echo "df = DataFrame(CSV.File(joinpath(out, \"chainConstantRates.csv\")))" >>$outFile
		echo "qcols = [col for col in names(df) if startswith(string(col), \"q\")]" >>$outFile

		qqK="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qqK+=", "
			fi
			j=$((i+1))
			qqK+=":q$j"
		done
		qqK+="]"

		echo "Q = compute_average_q(df)" >>$outFile
		echo "Kdf = summarize(chain0[${qqK}], Whale.bayesfactor)" >>$outFile
		echo "K = DataFrame(Kdf)" >>$outFile
		echo "dfQK = DataFrame(q̅ = Q, K = K.bayesfactor)" >>$outFile

	elif [ "$whaleModel" == "Critical_branch" ]; then
		echo "param = DLWGD(λ=zeros(nn), μ=zeros(nn), η=0.9, q=${qList})" >>$outFile
		echo "@info \"param\" param" >>$outFile
		echo "model = WhaleModel(param, tree, .1)" >>$outFile
		echo "@info \"model\" model" >>$outFile
		echo "write(joinpath(out, \"model.txt\"), repr(model))" >>$outFile
		echo "data = read_ale(\"${aleDir}\", model)" >>$outFile
		echo "@info \"ccd data\" data" >>$outFile

		echo "@model critical(model, X, nn) = begin" >>$outFile
		echo -e "\tη ~ Beta(3,1)" >>$outFile
		echo -e "\tr ~ Turing.Flat()" >>$outFile
		echo -e "\tσ ~ Exponential(0.1)" >>$outFile
		echo -e "\tλ ~ MvNormal(repeat([r], nn-1), σ)" >>$outFile
		echo -e "\tl = [λ; r]" >>$outFile

		qq="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qq+=", "
			fi
			j=$((i+1))
			echo -e "\tq$j ~ Beta()" >>$outFile
			qq+="q$j"
		done
		qq+="]"

		echo -e "\tX ~ model((λ=l, μ=l, η=η, q=${qq}))" >>$outFile
		echo "end" >>$outFile

		echo "cmodel = critical(model, data, nn)" >>$outFile
		echo "@info \"critical branch model\" cmodel" >>$outFile
		echo "write(joinpath(out, \"cmodel.txt\"), repr(cmodel))" >>$outFile
		echo "chaincritical = sample(cmodel, NUTS(0.65), ${whaleChain})" >>$outFile
		echo "summary_file = joinpath(out, \"MCMCchain.s\")" >>$outFile
		echo "summary_stream = open(summary_file, \"w\")" >>$outFile
		echo "redirect_stdout(summary_stream)" >>$outFile
		echo "show(summary_stream, \"text/plain\", chaincritical)" >>$outFile
		echo "close(summary_stream)" >>$outFile
		echo "CSV.write(joinpath(out, \"chaincritical.csv\"), chaincritical)" >>$outFile
		echo "serialize(joinpath(out, \"chaincritical.jls\"), chaincritical)" >>$outFile
		echo "df = DataFrame(CSV.File(joinpath(out, \"chaincritical.csv\")))" >>$outFile

		qqK="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qqK+=", "
			fi
			j=$((i+1))
			qqK+=":q$j"
		done
		qqK+="]"

		echo "Q = compute_average_q(df)" >>$outFile
		echo "Kdf = summarize(chaincritical[${qqK}], Whale.bayesfactor)" >>$outFile
		echo "K = DataFrame(Kdf)" >>$outFile
		echo "dfQK = DataFrame(q̅ = Q, K = K.bayesfactor)" >>$outFile

    else
		echo "param = DLWGD(λ=zeros(nn), μ=zeros(nn), η=0.9, q=${qList})" >>$outFile
		echo "@info \"param\" param" >>$outFile
		echo "model = WhaleModel(param, tree, .1)" >>$outFile
		echo "@info \"model\" model" >>$outFile
		echo "write(joinpath(out, \"model.txt\"), repr(model))" >>$outFile
		echo "data = read_ale(\"${aleDir}\", model)" >>$outFile
		echo "@info \"ccd data\" data" >>$outFile

		echo "@model branchrates(model, X, n, τmean=1.) = begin" >>$outFile
		echo -e "\tη ~ Beta(3,1)" >>$outFile
		echo -e "\tρ ~ Uniform(-1, 1.)" >>$outFile
		echo -e "\tτ ~ Exponential(τmean)" >>$outFile
		echo -e "\tT = typeof(ρ)" >>$outFile
		echo -e "\tS = [τ 0. ; 0. τ]" >>$outFile
		echo -e "\tR = [1.  ρ; ρ 1.]" >>$outFile
		echo -e "\tΣ = S*R*S" >>$outFile
		echo -e "\t!isposdef(Σ) && return -Inf" >>$outFile
		echo -e "\tr = Matrix{T}(undef, 2, n)" >>$outFile
		echo -e "\to = id(getroot(model))" >>$outFile
		echo -e "\tr[:,o] ~ MvNormal(zeros(2), ones(2))" >>$outFile
		echo -e "\tfor i=1:n" >>$outFile
		echo -e "\t\ti == o && continue" >>$outFile
		echo -e "\t\tr[:,i] ~ MvNormal(r[:,o], Σ)" >>$outFile
		echo -e "\tend" >>$outFile

		qq="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qq+=", "
			fi
			j=$((i+1))
			echo -e "\tq$j ~ Beta()" >>$outFile
			qq+="q$j"
		done
		qq+="]"

		echo -e "\tX ~ model((λ=r[1,:], μ=r[2,:], η=η, q=${qq}))" >>$outFile
		echo "end" >>$outFile

		echo "bmodel = branchrates(model, data, nn)" >>$outFile
		echo "@info \"relaxed branch model\" bmodel" >>$outFile
		echo "write(joinpath(out, \"bmodel.txt\"), repr(bmodel))" >>$outFile
		echo "chainrelaxed = sample(bmodel, NUTS(0.65), ${whaleChain})" >>$outFile
		echo "summary_file = joinpath(out, \"MCMCchain.s\")" >>$outFile
		echo "summary_stream = open(summary_file, \"w\")" >>$outFile
		echo "redirect_stdout(summary_stream)" >>$outFile
		echo "show(summary_stream, \"text/plain\", chainrelaxed)" >>$outFile
		echo "close(summary_stream)" >>$outFile
		echo "CSV.write(joinpath(out, \"chainrelaxed.csv\"), chainrelaxed)" >>$outFile
		echo "serialize(joinpath(out, \"chainrelaxed.jls\"), chainrelaxed)" >>$outFile
		echo "df = DataFrame(CSV.File(joinpath(out, \"chainrelaxed.csv\")))" >>$outFile

		#echo "chain = deserialize("chainrelaxed.jls")" >>$outFile

		qqK="["
		for ((i=0; i<${#random_list[@]}; i++)); do
			if ((i != 0)); then
				qqK+=", "
			fi
			j=$((i+1))
			qqK+=":q$j"
		done
		qqK+="]"

		echo "Q = compute_average_q(df)" >>$outFile
		echo "Kdf = summarize(chainrelaxed[${qqK}], Whale.bayesfactor)" >>$outFile
		echo "K = DataFrame(Kdf)" >>$outFile
		echo "dfQK = DataFrame(q̅ = Q, K = K.bayesfactor)" >>$outFile
    fi

	echo "wgd_data = readlines(joinpath(out, \"../..\", \"wgdNodes.txt\"))" >>$outFile
	echo "wgd_names = String[]" >>$outFile
	echo "for line in wgd_data" >>$outFile
	echo -e "\tline = strip(line)" >>$outFile
	echo -e "\tisempty(line) && continue" >>$outFile
	echo -e "\tparts = split(line, \":\")" >>$outFile
    echo -e "\tname = strip(parts[1])" >>$outFile
	echo "push!(wgd_names, name)" >>$outFile
	echo "end" >>$outFile
	echo "dfQK_modified = hcat(DataFrame(Hypotheses = wgd_names), dfQK)" >>$outFile
	echo "dfQK_modified.q̅ = round.(dfQK_modified.q̅; digits = 5)" >>$outFile
	#echo "dfQK_modified.K = round.(dfQK_modified.K; digits = 3)" >>$outFile
	echo "@info dfQK_modified" >>$outFile
	echo "write(joinpath(out, \"posterior_mean_of_duplicate_retention_rate_Bayes_factor.txt\"), repr(dfQK_modified))" >>$outFile

}

randomly_selecting_gf() {
    local dirpath="$1"
    local num_files="$2"
    local random_seed="$3"

    if [ -n "$random_seed" ]; then
        RANDOM="$random_seed"
    fi

    local selected_dir="${dirpath}.selected"

    if [ -d "$selected_dir" ]; then
        rm -r "$selected_dir"
    fi

    mkdir "$selected_dir"

    shopt -s nullglob
    files=("$dirpath"/*)
    shopt -u nullglob

    for ((i = 0; i < num_files; i++)); do
        random_index=$((RANDOM % ${#files[@]}))
        selected_file="${files[random_index]}"

        cp "$selected_file" "$selected_dir"

        unset "files[random_index]"
        files=("${files[@]}")
    done
}

if [ $# -eq 6 ]; then
    whale_configure $1 $2 $3 $4 $5 $6
elif [ $# -eq 7 ]; then
    randomly_selecting_gf $2 $7 42
    newAleDir="$2.selected"
    whale_configure $1 $newAleDir $3 $4 $5 $6
else
    echo "Usage: $0 <tree.newick> <aleDir> <wgdNodes> <outShellFile> <model> <chain> <number>"
    exit 1
fi
