################################################################################
#### DIVERGENCE DATING ####
################################################################################
## Software:
# spruceup needs to be included in $PATH (https://github.com/marekborowiec/spruceup)
amas=/global/homes/jg/t_vane02/software/AMAS-master/amas/AMAS.py # (https://github.com/marekborowiec/AMAS)

home=/global/homes/jg/t_vane02
scripts=$home/scripts
wd=$home/uce-myrmecocystus
taxon_set=dating # A configuration file called taxon-set-$taxon_set.conf with a list of samples needs to be present in $wd; a reduced taxon set was used for dating compared to phylogenetic inference

#################################################################
#### 1 SETUP ####
#################################################################

##################################################
### 1.1 EXTRACT UCES ####
##################################################
locus_db=uces.sqlite # Name for the database created in UCE_extraction.sh
assembly_dir=$wd/metaspades

## Extract UCEs for desired taxon set
qsub -sync y -N UCE_extraction_$taxon_set -o $wd/uces/logs -e $wd/uces/logs $scripts/UCE_extraction.sh $assembly_dir $wd/uces $locus_db $taxon_set

## Copy loci with 90% taxon-completeness (more than 37 samples) to separate directory
mkdir -p $wd/uces/$taxon_set/exploded-fastas-90
grep -c ">" $wd/uces/$taxon_set/exploded-fastas-all/* | awk -v myvar=$wd/uces/$taxon_set/exploded-fastas-90 -F : '$2 > 37 {print ("cp "$1" myvar/"$1)}' | /bin/bash

##################################################
### 7.1.2 ALIGNMENT ####
##################################################
mkdir -p $wd/uces/$taxon_set/mafft-aligned-90

nt=12

## Create list of loci 
ls $wd/uces/$taxon_set/exploded-fastas-90 > $wd/uces/$taxon_set/loci_$taxon_set.txt

## Align and trim loci
qsub -sync y -pe smp $nt -t 1-$(cat $wd/$taxon_set/loci_$taxon_set.txt | wc -l) -N alignment_trimming_$taxon_set -o $wd/uces/logs -e $wd/uces/logs $scripts/alignment_trimming.sh $nt $wd/uces/$taxon_set/loci_$taxon_set.txt $wd/uces/$taxon_set/mafft-aligned-90

## Concatenate alignments
mkdir -p $wd/uces/$taxon_set/mafft-aligned-90/concat
python $amas concat -i $wd/uces/$taxon_set/mafft-aligned-90/*-mafft-trimal -f fasta -d dna -t $wd/uces/$taxon_set/mafft-aligned-90/concat/mafft-trimal-concat.fas -p $wd/uces/$taxon_set/mafft-aligned-90/concat/mafft-trimal-concat.fas-part

## Trim with spruceup
spruceup_conf=$wd/uces/concat/spruceup.conf # Manually created configuration file
spruceup.py $spruceup_conf

## Convert final concatenated alignment to PHYLIP format
cd $wd/uces/$taxon_set/mafft-aligned-90/concat
python $amas convert -i $wd/uces/$taxon_set/mafft-aligned-90/concat/mafft-trimal-concat.fas -f fasta -d dna -u phylip

## Calculate summary statistics 
#Calculate summary statistics on the final alignment using AMAS
python $amas summary -i $wd/uces/$taxon_set/mafft-aligned-90/concat/mafft-trimal-spruceup-concat.fas -f fasta -d dna -o $wd/uces/$taxon_set/mafft-aligned-90/concat/mafft-trimal-spruceup-concat-summary.txt

#################################################################
#### 7 DIVERGENCE TIME ESTIMATION ####
#################################################################
mkdir -p $wd/divergence_dating/logs

## Create directory structure
for topology in concat astral
do
	for calibration in lasius paratrechinanylanderia
	do
		mkdir -p $wd/divergence_dating/$topology/$calibration/usedata0
		mkdir -p $wd/divergence_dating/$topology/$calibration/usedata3
		for i in 1 2
		do
			mkdir -p $wd/divergence_dating/$topology/$calibration/usedata2_run$i
		done
	done
done

##################################################
### 7.2.1 RUN BASEML ####
##################################################
mkdir -p $wd/divergence_dating/concatenated $wd/divergence_dating/astral

concat_ctl=$wd/divergence_dating/concat_baseml.ctl # Manually created control file with instructions for baseml
astral_ctl=$wd/divergence_dating/astral_baseml.ctl # Manually created control file with instructions for baseml

## Submit baseml with topology of ML inference of concatenated alignment
qsub -N baseml_concat -o $wd/divergence_dating/logs -e $wd/divergence_dating/logs $scripts/baseml.sh $concat_ctl
## Submit baseml with topology of ASTRAL analysis
qsub -N baseml_astral -o $wd/divergence_dating/logs -e $wd/divergence_dating/logs $scripts/baseml.sh $astral_ctl

##################################################
### 7.2.2 RUN MCMCTREE ####
##################################################

## Run MCMCTree with usedata=3 to get estimate of Gradient and Hessian
## Create control files manually following the pattern ${topology}_${calibration}_usedata3.ctl
for topology in concat astral
do
	for calibration in lasius paratrechinanylanderia
	do	
		qsub -N mcmctree_${topology}_${calibration}_usedata3 -o $wd/divergence_dating/logs -e $wd/divergence_dating/logs $scripts/mcmctree.sh ${topology}_${calibration}_usedata3.ctl
	done
done

## Run MCMCTREE with usedata=0 to get prior estimates
for topology in concat astral
do
	for calibration in lasius paratrechinanylanderia
	do
		qsub -N mcmctree_${topology}_${calibration}_usedata0 -o $wd/divergence_dating/logs -e $wd/divergence_dating/logs $scripts/mcmctree.sh ${topology}_${calibration}_usedata0.ctl
	done
done

## Copy file with Gradient and Hessian to usedata2 directories and run MCMCTree with usedata=2
for topology in concat astral
do
	for calibration in lasius paratrechinanylanderia
	do 
		for i in 1 2
		do
			cp $wd/divergence_dating/$topology/$calibration/usedata3/out.BV $wd/divergence_dating/$topology/$calibration/usedata2_run$i/in.BV
			qsub -N mcmctree_${topology}_${calibration}_usedata2 -o $wd/divergence_dating/logs -e $wd/divergence_dating/logs $scripts/mcmctree.sh ${topology}_${calibration}_usedata2.ctl
		done
	done
done
