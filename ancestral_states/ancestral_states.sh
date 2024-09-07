#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
anc_states=/global/homes/jg/t_vane02/scripts/ancestral_states.R

## Command-line args:
tree=$1
chars=$2
out_dir=$3

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### ancestral_states.sh: Starting script."
echo -e "#### ancestral_states.sh: Tree file: $tree"
echo -e "#### ancestral_states.sh: Character mappings: $chars"
echo -e "#### ancestral_states.sh: Output directory: $out_dir \n\n"

################################################################################
#### Reconstruction of ancestral states####
################################################################################
mkdir -p $out_dir

echo -e "#### ancestral_states.sh: Reconstructing ancestral states ... \n"
Rscript $anc_states $tree $chars $out_dir

## Report:
echo -e "\n#### ancestral_states.sh: Done with script."
date
