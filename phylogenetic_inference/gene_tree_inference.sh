#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
seqkit=/global/homes/jg/t_vane02/software/seqkit # (https://github.com/shenwei356/seqkit)
# iqtree needs to be included in $PATH (v1.6.11; http://www.iqtree.org/)

## Command-line args:
alignment_file=$1
alignment=$(sed -n "$SGE_TASK_ID"p $alignment_file)

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### gene_tree_inference.sh: Starting script."
echo -e "#### gene_tree_inference.sh: File with input alignments: $alignment_file \n\n"

################################################################################
#### ALIGNMENT CLEANING AND GENE TREE INFERENCE####
################################################################################
cd $(dirname $alignment)

echo -e "#### gene_tree_inference.sh: Removing taxa with gaps or missing data only ... \n"
$seqkit fx2tab $alignment | awk '{if ($2 !~ "^?+$") print $0}' | $seqkit tab2fx > $(dirname $alignment)/$(basename $alignment .fas)_clean.fas

echo -e "#### gene_tree_inference.sh: Infering gene tree ... \n"
iqtree -s $(dirname $alignment)/$(basename $alignment .fas)_clean.fas -nt 2 -bb 1000 -wbt -nstop 200 -mset GTR+G+I,GTR+G,GTR -merit AICc

## Report:
echo -e "\n#### gene_tree_inference.sh: Done with script."
date

