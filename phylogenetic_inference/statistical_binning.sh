#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
binning_scripts=/global/homes/jg/t_vane02/software/binning-master/ # Pipeline by S. Mirarab is used (https://github.com/smirarab/binning)

## Command-line args:
genes_dir=$1
support=$2
tree=$4

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### statistical_binning.sh: Starting script."
echo -e "#### statistical_binning.sh: Directory containing the gene folders with alignments and trees: $genes_dir"
echo -e "#### statistical_binning.sh: Support value: $support"
echo -e "#### statistical_binning.sh: Name of tree file: $tree \n\n"

################################################################################
#### RUN BINNING PIPELINE####
################################################################################
mkdir -p $genes_dir/output
cd $genes_dir/

echo -e "#### statistical_binning.sh.sh: Preparing ... \n"
$binning_scripts/makecommands.compatibility.sh $genes_dir $support $genes_dir/output $tree
parallel < commands*

echo -e "#### statistical_binning.sh.sh: Building bin definitions ... \n"
ls | grep -v ge | sed -e "s/.95$//g" > genes   
python $binning_scripts/cluster_genetrees.py genes $support

echo -e "#### statistical_binning.sh.sh: Concatenating gene alignments for each bin to create supergenes ... \n"
mkdir -p $genes_dir/output/supergenes
$binning_scripts/build.supergene.alignments.sh $genes_dir/output $genes_dir $genes_dir/output/supergenes

## Report:
echo -e "\n#### statistical_binning.sh.sh: Done with script."
date


