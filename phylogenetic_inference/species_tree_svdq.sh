#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# paup needs to be included in $PATH (v4.0a; https://paup.phylosolutions.com/)

## Command-line args:
in_file=$1
log_file=$2

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### species_tree_svdq.sh: Starting script."
echo -e "#### species_tree_svdq.sh: PAUP input file: $in_file"
echo -e "#### species_tree_svdq.sh: Log file: $log_file \n\n"

################################################################################
#### SPECIES TREE INFERENCE WITH SVDquartets####
################################################################################
cd $(dirname $in_file)

echo -e "#### species_tree_svdq.sh: Species tree inference with SVDquartets... \n"
paup4a168_ubuntu64 -n $in_file $log_file

## Report:
echo -e "\n#### species_tree_svdq.sh: Done with script."
date
