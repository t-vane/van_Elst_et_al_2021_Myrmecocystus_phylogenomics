#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
iqtree2=/global/homes/jg/t_vane02/software/iqtree-2.0.4-Linux/bin/iqtree # (v2.0.5; http://www.iqtree.org/)
concord=/global/homes/jg/t_vane02/scripts/concordance.R

## Command-line args:
nt=$1
tree=$2
gene_trees=$3
alignment=$4
out_dir=$5

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### concordance_factors.sh: Starting script."
echo -e "#### concordance_factors.sh: Number of threads: $nt"
echo -e "#### concordance_factors.sh: Tree file: $tree"
echo -e "#### concordance_factors.sh: File with gene trees: $gene_trees"
echo -e "#### concordance_factors.sh: Alignment file: $alignment"
echo -e "#### concordance_factors.sh: Output directory: $out_dir \n\n"

################################################################################
#### CONCORDANCE FACTOR ANALYSIS####
################################################################################
echo -e "#### concordance_factors.sh: Calculating site and gene concordance ... \n"
$iqtree2 -nt $nt -t $tree --gcf $gene_trees -s $alignment --scf 100 --prefix $out_dir/concord

echo -e "#### concordance_factors.sh: Testing incomplete lineage sorting and calculating internode certainty ... \n"
Rscript $concord $out_dir

## Report:
echo -e "\n#### concordance_factors.sh: Done with script."
date
