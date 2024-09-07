#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
swscen=/global/homes/jg/t_vane02/software/PFinderUCE-SWSC-EN-master/py_script/SWSCEN.py # (https://github.com/Tagliacollo/PFinderUCE-SWSC-EN)

## Command-line args:
in_file=$1

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### swscen.sh: Starting script."
echo -e "#### swscen.sh: Input file: $in_file \n\n"

################################################################################
#### CREATE TRIPLET PARTITIONS WITH SWSC-EN####
################################################################################
echo -e "#### swscen.sh: Running SWSC-EN ... \n"
python3 $swscen $in_file

## Report:
echo -e "\n#### swscen.sh: Done with script."
date

