################################################################################
#### 5 PARTITIONING ####
################################################################################
home=/global/homes/jg/t_vane02
scripts=$home/scripts
taxon_set=genus
wd=$home/uce-myrmecocystus/uces/$taxon_set/partitioning

mkdir -p $wd/logs

#################################################################
#### 1 CREATE TRIPLET PARTITIONS FOR EACH LOCUS ####
#################################################################
alignment=$home/uce-myrmecocystus/uces/$taxon_set/alignments/concat/mafft-trimal-concat.fas-nex.out # NEXUS-formatted alignment
locus_info=$wd/locuspartitions.nex # NEXUS file with UCE locus information; can be taken from mafft-trimal-concat.fas-part (see alignment section)

cat $alignment $locus_info > $wd/alignment-concatenated-partitions.nex

## Run SWSC-EN
qsub sync -y -N SWSC-EN -o $wd/logs -e $wd/logs $scripts/swscen.sh $wd/alignment-concatenated-partitions.nex

#################################################################
#### 2 RUN PARTITIONFINDER ####
#################################################################
mkdir -p $wd/locus $wd/triplet

## Two partitioning schemes are run (per triplet and per locus)
locus_conf=$wd/partitionfinder_locus.cfg # Configuration file for PartitionFinder2 considering loci as partitions
triplet_conf=$wd/partitionfinder_triplet.cfg #Configuration file for PartitionFinder2 considering triplets as partitions

qsub -N partitionfinder_locus -o $wd/logs -e $wd/logs $scripts/partitionfinder.sh $locus_conf
qsub -N partitionfinder_triplet -o $wd/logs -e $wd/logs $scripts/partitionfinder.sh $triplet_conf
