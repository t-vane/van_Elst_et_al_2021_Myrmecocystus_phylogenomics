#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# phyluce needs to be included in $PATH (v1.6.7; https://phyluce.readthedocs.io/en/latest/)

## Command-line args:
contig_dir=$1
out_dir=$2
locus_db=$3
taxon_set=$4

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### UCE_extractions.sh: Starting script."
echo -e "#### UCE_extractions.sh: Contig directory: $contig_dir"
echo -e "#### UCE_extractions.sh: Output directory: $out_dir"
echo -e "#### UCE_extractions.sh: Locus database: $locus_db"
echo -e "#### UCE_extractions.sh: Taxon set: $taxon_set \n\n"

################################################################################
#### EXTRACT UCES FROM CONTIGS####
################################################################################
mkdir -p $out_dir/$taxon_set
cd $out_dir/$taxon_set

echo -e "#### UCE_extractions.sh: Creating monolithic FASTA file with all loci from all taxa ... \n"
phyluce_assembly_get_match_counts --locus-db $locus_db --taxon-list-config $out_dir/taxon-set-$taxon_set.conf --taxon-group $taxon_set --incomplete-matrix --output $out_dir/$taxon_set/$taxon_set-taxa-incomplete.conf
phyluce_assembly_get_fastas_from_match_counts --contigs $contig_dir --locus-db $locus_db --match-count-output $out_dir/$taxon_set/$taxon_set-taxa-incomplete.conf --output $out_dir/$taxon_set/$taxon_set-taxa-incomplete.fasta --incomplete-matrix $out_dir/$taxon_set/$taxon_set-taxa-incomplete.incomplete

echo -e "#### UCE_extractions.sh: Exploding monolithic FASTA file into one file per taxon ... \n"
phyluce_assembly_explode_get_fastas_file --input $out_dir/$taxon_set/$taxon_set-taxa-incomplete.fasta --output $out_dir/$taxon_set/exploded-fastas-all
cd $out_dir/$taxon_set/exploded-fasta-all
for i in $out_dir/$taxon_set/exploded-fastas-all/*
do 
	sed -r -i 's/>uce-[0-9]+_/>/g;s/ \|uce-[0-9]+//g' $i
done

## Report:
echo -e "\n#### UCE_extractions.sh: Done with script."
date
