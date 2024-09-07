################################################################################
#### PHYLOGENETIC INFERENCE ####
################################################################################
## Software:
# iqtree needs to be included in $PATH (v1.6.11; http://www.iqtree.org/)
amas=/global/homes/jg/t_vane02/software/AMAS-master/amas/AMAS.py # (https://github.com/marekborowiec/AMAS)
nwed=/global/homes/jg/t_vane02/software/newick-utils-1.6/src/nw_ed # (https://github.com/tjunier/newick_utils)

## Variables:
home=/global/homes/jg/t_vane02
scripts=$home/scripts
taxon_set=genus
wd=$home/uce-myrmecocystus/uce-extraction/$taxon_set/phylogenetic-inference

alignment=$home/uce-myrmecocystus/uce-extraction/$taxon_set/alignments/concat/mafft-trimal-spruceup-concat.fas-nex.out # Concatenated final alignment in NEXUS format
partition_scheme=$wd/partitions.nex # File with paragraph 'Nexus formatted character sets for IQtree' from best_scheme.txt of partitioning analysis

mkdir -p $wd/logs

#################################################################
#### 1 MAXIMUM LIKELIHOOD INFERENCE ####
#################################################################
## Submit four independent runs of IQ-TREE to increase probability to find global likelihood maximum
repeats=4
for i in $(seq 1 $repeats)
do	
	mkdir -p $wd/ML/run$i
	ln -s $alignment $wd/ML/run$i
	ln -s $partition_scheme $wd/ML/run$i
	qsub -N ML_inference_$i -o $wd/logs -e $wd/logs $scripts/ML_inference.sh $wd/ML/run$i/mafft-trimal-spruceup-concat.fasta $wd/ML/run$i/partitions.nex
done

## Estimate Robinson-Foulds distances
cat $wd/ML/run*/partitions.nex.treefile > $wd/ML/ml_trees.txt
iqtree -rf_all $wd/ML/ml_trees.txt

#################################################################
#### 2 SPECIES TREE INFERENCE UNDER THE MULTISPECIES COALESCENT ####
#################################################################

##################################################
### 2.1 GENE TREE INFERENCE ####
##################################################
locus_partitions=$home/uce-myrmecocystus/uce-extraction/$taxon_set/partitioning/locuspartitions.nex # Contains location of each UCE in concatenated alignment

## Split concatenated alignment into locus alignments
cd $(dirname $alignment)
python $amas split -i $alignment -u nexus -d dna -f fasta -l $locus_partitions

## Rename the alignment files to uceXXXX.fas
for i in $(dirname $alignment)/*-out.fas
do
	rename.ul uce- uce $i
	rename.ul -out.fas .fas $i
done

## Move alignment files to directory for phylogenetic inference
mkdir -p $wd/ML/single-locus
mv $(dirname $alignment)/UCE*.fas $wd/ML/single-locus

## Create alignment list
ls $wd/ML/single-locus/UCE*.fas > $wd/ML/single-locus/alignments.txt

## Maximum likelihood inference per locus
qsub -sync y -t 1-$(cat $wd/ML/single-locus/alignments.txt | wc -l) -N gene_tree_inference -o $wd/logs -e $wd/logs $scripts/gene_tree_inference.sh $wd/ML/single-locus/alignments.txt

##################################################
### 2.2 STATISTICAL BINNING ####
##################################################
mkdir -p $wd/statistical-binning

## Create directory for each alignment
cat $wd/ML/single-locus/alignments.txt | awk -v myvar=$wd/statistical-binning '{print("mkdir "$1" myvar")}' | sed 's/.fas//g' | /bin/bash

## Copy alignments and trees there
for i in $wd/ML/single-locus/UCE*.fas
do 
	cp $i $(dirname $i)/$(basename$i. fas)
	cp $i.treefile $(dirname $i)/$(basename$i. fas)
done

## Run statistical binning
support=95
qsub -sync y -N statistical_binning -o $wd/logs -e $wd/logs $scripts/statistical_binning.sh $wd/ML/single-locus/ $support $wd/ML/run1/partitions.nex.treefile

## Identify bins that are comprised of more than one locus (i.e., two or three loci) and run ML inference on them
find $wd/ML/single-locus/output/supergenes -type f -name "bin*" -print0 | xargs -0 wc -l | grep "2 .\|3 ." | sed -e 's/2 .\///g' | sed -e 's/3 .\///g' > $wd/ML/single-locus/output/supergenes/bin_multiple_loci.txt
qsub -sync y -t 1-$(cat $wd/ML/single-locus/output/supergenes/bin_multiple_loci.txt | wc -l) -N gene_tree_inference_supergenes -o $wd/logs -e $wd/logs $scripts/gene_tree_inference.sh $wd/ML/single-locus/output/supergenes/bin_multiple_loci.txt

##################################################
### 2.3 SPECIES TREE ESTIMATION WITH ASTRAL FOR BINNED AND UNBINNED LOCI ####
##################################################
MAPPING=$wd/astral/mapping.txt # Assigns specimens to species
mkdir -p $wd/astral/unbinned $wd/astral/binned

## Create input trees file for unbinned analysis in ASTRAL
cat $wd/ML/single-locus/UCE*/*.treefile > $wd/astral/unbinned/gene_trees.txt

## Create weighted input trees file for binned analysis in ASTRAL
# Single-locus bins
find $wd/ML/single-locus/output/ -type f -name "bin*" -print0 | xargs -0 wc -l | grep "1 ." | sed -e 's/1 .\///g' | xargs grep "uce" | sed -e 's/bin.\{1,9\}\+.txt://g' | while read line
do 
	cat $wd/ML/single-locus/$line/$line.treefile > $wd/astral/binned/gene_trees.txt
done 
# Dual-locus bins
find $wd/ML/single-locus/output/ -type f -name "bin*" -print0 | xargs -0 wc -l | grep "2 ." | sed -e 's/2 .\///g' | while read line
do 
	for i in {1..2}
	do
		cat $wd/ML/single-locus/output/supergenes/$line.treefile >> $wd/astral/binned/gene_trees.txt
	done
done 
# Triple-locus bins
find $wd/ML/single-locus/output/ -type f -name "bin*" -print0 | xargs -0 wc -l | grep "3 ." | sed -e 's/3 .\///g' | while read line
do 
	for i in {1..3}
	do
		cat $wd/ML/single-locus/output/supergenes/$line.treefile >> $wd/astral/binned/gene_trees.txt
	done
done

## Collapse branches in input trees files with bootstrap support below 20 and submit analysis
for i in binnend unbinned
do
	$nwed $wd/astral/$i/gene_trees.txt 'i & b <=20' o > $wd/astral/$i/gene_trees_bs20.txt
	qsub -N species_tree_astral_$i -o $wd/logs -e $wd/logs $scripts/species_tree_astral.sh $wd/astral/$i/gene_trees_bs20.txt $MAPPING $wd/astral/$i/speciestree_$i.tre

done

##################################################
### 2.3 SPECIES TREE ESTIMATION WITH SVDquartets ####
##################################################
mkdir -p $wd/svdq

## Create PAUP block file
echo "BEGIN PAUP;" > $wd/svdq/blockfile.txt
echo -e "\toutgroup SPECIES.Nylanderia_terricola SPECIES.Paratrechina_longicornis;" >> $wd/svdq/blockfile.txt
echo -e "\tset root=outgroup outroot=monophyl;" >> $wd/svdq/blockfile.txt
echo -e "\tsvdq nthreads=8 evalQuartets=all taxpartition=SPECIES loci=LOCI bootstrap=multilocus treeFile=svdq_bootstrap.tre;" >> $wd/svdq/blockfile.txt
echo "END;" >> $wd/svdq/blockfile.txt

## Create NEXUS file to run SVDQ in PAUP
char_partitions=$wd/svdq/char_partitions.txt # Character partitions
tax_partitions=$wd/svdq/tax_partitions.txt # Taxon partitions

cat $alignment $char_partitions $tax_partitions $wd/svdq/blockfile.txt > $wd/svdq/concat_alignment_paup.nex

## Run SVDQuartets
qsub -N species_tree_svdq -o $wd/logs -e $wd/logs $scripts/species_tree_svdq.sh $wd/svdq/concat_alignment_paup.nex $wd/svdq/concat_alignment_paup.log

##################################################
### 2.4 CONCORDANCE FACTOR ANALYSIS ####
##################################################
mkdir -p $wd/concordance-factors
nt=16

qsub -N concordance_factors -o $wd/logs -e $wd/logs $scripts/concordance_factors.sh $nt $wd/ML/run1/partitions.nex.treefile $wd/astral/unbinned/gene_trees.txt $alignment $wd/concordance-factors/concord