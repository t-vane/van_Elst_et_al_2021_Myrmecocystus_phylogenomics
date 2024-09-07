#!/bin/bash

set -euo pipefail

################################################################################
#### SET-UP ####
################################################################################
## Software:
# ucsc-fatotwobit needs to be included in $PATH (https://genome.ucsc.edu/index.html)
# ucsc-twoBitInfo needs to be included in $PATH (https://genome.ucsc.edu/index.html)
# phyluce needs to be included in $PATH (v1.6.7; https://phyluce.readthedocs.io/en/latest/)

## Command-line args:
nt=$1
in_dir=$2
genomes=$3
probes=$4
contig_dir=$5

## Report:
echo -e "\n\n###################################################################"
date
echo -e "#### UCE_harvesting.sh: Starting script."
echo -e "#### UCE_harvesting.sh: Number of threads: $nt"
echo -e "#### UCE_harvesting.sh: Input directory: $in_dir"
echo -e "#### UCE_harvesting.sh: File with list of genomes: $genomes"
echo -e "#### UCE_harvesting.sh: Probe file: $probes"
echo -e "#### UCE_harvesting.sh: Contig directory: $contig_dir \n\n"

################################################################################
#### CONVERT AND CALCULATE SUMMARY STATISTICS####
################################################################################
echo -e "#### UCE_harvesting.sh: Unzipping, converting to 2bit format and calculating summary statistics ... \n"
for i in $(cat $genomes)
do
	gunzip $in_dir/$i/${i}_genomic.fna.gz
	faToTwoBit $in_dir/$i/${i}_genomic.fna. $in_dir/$i/$i.2bit
	twoBitInfo $in_dir/$i/$i.2bit $in_dir/$i/$i.sizes.tab
done

################################################################################
#### HARVEST UCES FROM GENOMES####
################################################################################
cd $in_dir

echo -e "#### UCE_harvesting.sh: Creating database ... \n"
genomes_string=$(awk '$1=$1' ORS=' ' $genomes)
phyluce_probe_run_multiple_lastzs_sqlite --cores $nt --identity 75 --coverage 77.5 --db harvesting.sqlite --output harvesting-lastz --scaffoldlist $genomes_string --genome-base-path ./ --probefile $probes

echo -e "#### UCE_harvesting.sh: Slice sequences from genomes ... \n"
for i in $(cat $genomes)
do
	echo -e "## UCE_harvesting.sh: Processing genome $i... \n"
	printf "[scaffolds]\n$i:$in_dir/$i/$i.2bit" > $i.conf
	phyluce_probe_slice_sequence_from_genomes --lastz outgroups-lastz --conf $i.conf --flank 400 --name-pattern $(basename $probes)_v_{}.lastz.clean --output $i-genome-fasta
	ln -s $i-genome-fasta/$i.fasta $contig_dir/$i.contigs.fasta
done

## Report:
echo -e "\n#### UCE_harvesting.sh: Done with script."
date
