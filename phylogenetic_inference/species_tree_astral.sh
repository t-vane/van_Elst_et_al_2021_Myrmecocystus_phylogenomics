#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
astral=/global/homes/jg/t_vane02/software/Astral/astral.5.6.3.jar # (v5.6.3; https://github.com/smirarab/ASTRAL)

## Command-line args:
gene_trees=$1
mapping=$2
out_file=$3

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### species_tree_astral.sh: Starting script."
echo -e "#### species_tree_astral.sh: File with gene trees: $gene_trees"
echo -e "#### species_tree_astral.sh: Mapping of specimens to species: $mapping"
echo -e "#### species_tree_astral.sh: Output file: $out_file \n\n"

################################################################################
#### SPECIES TREE INFERENCE WITH ASTRAL####
################################################################################
echo -e "#### species_tree_astral.sh: Species tree inference with ASTRAL ... \n"
java -jar $astral -i $gene_trees -a $mapping -o $out_file

## Report:
echo -e "\n#### species_tree_astral.sh: Done with script."
date
