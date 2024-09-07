#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# illumiprocessor needs to be included in $PATH (https://illumiprocessor.readthedocs.io/en/latest/)
# phyluce needs to be included in $PATH (v1.6.7; https://phyluce.readthedocs.io/en/latest/)

## Command-line args:
nt=$1
in_dir=$2
out_dir=$3
config=$4
r1_pattern=$5
r2_pattern=$6

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### clean_reads.sh: Starting script."
echo -e "#### clean_reads.sh: Number of threads: $nt"
echo -e "#### clean_reads.sh: Input directory: $in_dir"
echo -e "#### clean_reads.sh: Output directory: $out_dir"
echo -e "#### clean_reads.sh: Configuration file: $config"
echo -e "#### clean_reads.sh: Forward read pattern: $r1_pattern"
echo -e "#### clean_reads.sh: Reverse read pattern: $r2_pattern \n\n"

################################################################################
#### CLEAN READS AND CHECK FOR INTEGRITY OF OUTPUT####
################################################################################
mkdir -p $out_dir

echo -e "#### clean_reads.sh: Cleaning reads in $in_dir ... \n"
illumiprocessor --cores $nt --input $in_dir --output $out_dir --config $in_dir/$config --r1-pattern $r1_pattern --r2-pattern $r2_pattern

echo -e "#### clean_reads.sh: Checking for integrity of output... \n"
gunzip -t -r $out_dir

echo -e "#### clean_reads.sh: Calculate clean read statistics... \n"
for i in $out_dir/*
do 
	phyluce_assembly_get_fastq_lengths --input $i/split-adapter-quality-trimmed/ --csv
done > $out_dir/clean_read_statistics.txt

## Report:
echo -e "\n#### clean_reads.sh: Done with script."
date
