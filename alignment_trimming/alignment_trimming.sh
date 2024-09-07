#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
mafft=/global/homes/jg/t_vane02/software/mafft-7.429/bin/mafft # (v7.429; https://mafft.cbrc.jp/alignment/software/)
# trimal needs to be included in $PATH (v1.4.rev15; http://trimal.cgenomics.org/trimal)

## Command-line args:
nt=$1
locus_file=$2
out_dir=$3
locus=$(sed -n "$SGE_TASK_ID"p $locus_file)

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### alignment_trimming.sh: Starting script."
echo -e "#### alignment_trimming.sh: Number of threads: $nt"
echo -e "#### alignment_trimming.sh: File with loci: $locus_file"
echo -e "#### alignment_trimming.sh: Output directory: $out_dir \n\n"

################################################################################
#### ALIGNMENT####
################################################################################
echo -e "#### alignment_trimming.sh: Aligning sequences in $locus with MAFFT ... \n"
$mafft --thread $nt $locus > $out_dir/$(basename $locus)-mafft

################################################################################
#### TRIMMING####
################################################################################
echo -e "#### alignment_trimming.sh: Trimming alignment with trimAl ... \n"
trimal -in $out_dir/$(basename $locus)-mafft -out $out_dir/$(basename $locus)-mafft-trimal -gappyout

## Report:
echo -e "\n#### alignment_trimming.sh: Done with script."
date
