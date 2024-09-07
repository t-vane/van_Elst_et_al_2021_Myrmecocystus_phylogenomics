#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
metaspades=/global/homes/jg/t_vane02/software/SPAdes-3.13.1-Linux/bin/metaspades.py # (v3.13.1; https://github.com/ablab/spades)
# seqtk needs to be included in $PATH (https://github.com/lh3/seqtk)

## Command-line args:
nt=$1
mem=$2
inds=$3
clean_reads=$4
out_dir=$5
downsample=$6
read_number=$7
ind=$(sed -n "$SGE_TASK_ID"p $inds)

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### assembly.sh: Starting script."
echo -e "#### assembly.sh: Number of threads: $nt"
echo -e "#### assembly.sh: Maximum memory in GB: $mem"
echo -e "#### assembly.sh: File with individuals: $inds"
echo -e "#### assembly.sh: Directory with clean reads: $clean_reads"
echo -e "#### assembly.sh: Output directory: $out_dir"
echo -e "#### assembly.sh: Downsampling: $downsample"
echo -e "#### assembly.sh: Number of reads to retain if downsampling: $read_number \n\n"

################################################################################
#### UNZIP CLEAN READ FILES####
################################################################################
echo -e "#### assembly.sh: Unzipping clean read files for individual $ind \n"
gunzip $clean_reads/$ind/split-adapter-quality-trimmed/$ind-*.fastq.gz

################################################################################
#### DOWNSAMPLE####
################################################################################
if [ $downsample == TRUE ]
then
	echo -e "#### assembly.sh: Downsampling reads for individual $ind to $read_number ...\n"
	rnum=$RANDOM
	reads=$read_number
	for i in 1 2
	do
		cp $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.fastq $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.full.fastq
		seqtk sample -s $rnum $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.fastq $reads > $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.tmp.fastq
		mv $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.tmp.fastq $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ$i.fastq
	done
fi

################################################################################
#### RUN ASSEMBLY FOR SPECIFIC SAMPLE####
################################################################################
echo -e "#### assembly.sh: Running assembly for sample $ind \n"
python3 $metaspades -t $nt -m $mem -1 $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ1.fastq -2 $clean_reads/$ind/split-adapter-quality-trimmed/$ind-READ2.fastq -s $clean_reads/$ind/split-adapter-quality-trimmed/$ind-singleton.fastq -o $out_dir 

## Report:
echo -e "\n#### assembly.sh: Done with script."
date
