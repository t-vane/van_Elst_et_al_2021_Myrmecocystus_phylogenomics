#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# iqtree needs to be included in $PATH (v1.6.11; http://www.iqtree.org/)

## Command-line args:
alignment=$1
partitions=$2

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### ML_inference.sh: Starting script."
echo -e "#### ML_inference.sh: Alignment: $alignment"
echo -e "#### ML_inference.sh: Partitioning scheme: $partitions \n\n"

################################################################################
#### CREATE PARTITIONS####
################################################################################
cd $(dirname $alignment)

echo -e "#### ML_inference.sh: Maximum likelihood inference ... \n"
iqtree -s $alignment -nt AUTO -ntmax 10 -bb 1000 -wbt -spp $partitions -nstop 200

## Report:
echo -e "\n#### ML_inference.sh: Done with script."
date


