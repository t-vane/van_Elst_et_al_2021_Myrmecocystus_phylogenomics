#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# phyluce needs to be included in $PATH (v1.6.7; https://phyluce.readthedocs.io/en/latest/)

## Command-line args:
contig_dir=$1
probes=$2
out_dir=$3

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### UCE_match_contigs.sh: Starting script."
echo -e "#### UCE_match_contigs.sh: Contig directory: $contig_dir"
echo -e "#### UCE_match_contigs.sh: Probes: $probes"
echo -e "#### UCE_match_contigs.sh: Output directory: $out_dir \n\n"

################################################################################
#### MATCH CONTIGS TO PROBES####
################################################################################
echo -e "#### UCE_match_contigs.sh: Matching contigs to probes ... \n"
phyluce_assembly_match_contigs_to_probes --contigs $contig_dir --probes $probes --output $out_dir

## Report:
echo -e "\n#### UCE_match_contigs.sh: Done with script."
date
