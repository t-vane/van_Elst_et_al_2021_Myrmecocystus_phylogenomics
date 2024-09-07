#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
pfinder=/global/homes/jg/t_vane02/software/partitionfinder-2.1.1/PartitionFinder.py # (v2.1.1; https://www.robertlanfear.com/partitionfinder/)

## Command-line args:
conf_file=$1

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### partitionfinder.sh: Starting script."
echo -e "#### partitionfinder.sh: Configuration file: $conf_file \n\n"

################################################################################
#### CREATE PARTITIONS####
################################################################################
echo -e "#### partitionfinder.sh: Running ParitionFinder for file $conf_file ... \n"
python2.7 $pfinder -r $conf_file

## Report:
echo -e "\n#### partitionfinder.sh: Done with script."
date
