#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# mcmctree of PAML needs to be included in $PATH (v4.8; http://abacus.gene.ucl.ac.uk/software/paml.html)

## Command-line args:
ctl_file=$1

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### mcmctree.sh: Starting script."
echo -e "#### mcmctree.sh: MCMCTree control file: $ctl_file \n\n"

################################################################################
#### MCMCTREE ANALYSIS####
################################################################################
echo -e "#### mcmctree.sh: Running MCMCTree ... \n"
mcmctree $ctl_file

## Report:
echo -e "\n#### mcmctree.sh: Done with script."
date
