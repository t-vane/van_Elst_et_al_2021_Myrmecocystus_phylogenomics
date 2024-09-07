################################################################################
#### UCE EXTRACTION ####
################################################################################
home=/global/homes/jg/t_vane02
scripts=$home/scripts
wd=$home/uce-myrmecocystus/uces
assembly_dir=$home/uce-myrmecocystus/metaspades
probes=$wd/uces/hymenoptera-v2-ANT-SPECIFIC-uce-baits.fasta # UCE probe sequences

mkdir -p $wd/logs

#################################################################
#### 1 HARVEST UCES FROM PUBLISHED GENOMES ####
#################################################################
nt=16
genomes=$wd/uce-harvesting/genomes.txt # List of genome names without file extension

qsub -sync y -pe smp $nt -N uce_harvesting -o $wd/logs -e $wd/logs $scripts/uce_harvesting.sh $nt $wd/uce-harvesting $genomes $probes $assembly_dir

#################################################################
#### 2 EXTRACT UCES ####
#################################################################
locus_db=uces.sqlite # Name for the database created in UCE_extraction.sh
taxon_set=genus # A configuration file called taxon-set-$taxon_set.conf with a list of samples needs to be present in $wd/uce-extraction

## Match contigs to probes for all samples
id=$(qsub -N uce_match_contigs -o $wd/logs -e $wd/logs $scripts/uce_match_contigs.sh $assembly_dir $probes $wd)
## Extract UCEs for desired taxon set
qsub -N uce_extraction_$taxon_set -o $wd/logs -e $wd/logs -W depend=afterok:$id $scripts/uce_extraction.sh $assembly_dir $wd $locus_db $taxon_set

