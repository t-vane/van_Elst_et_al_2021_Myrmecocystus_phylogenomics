################################################################################
#### ALIGNMENT AND TRIMMING ####
################################################################################
## Software:
# spruceup needs to be included in $PATH (https://github.com/marekborowiec/spruceup)
amas=/global/homes/jg/t_vane02/software/AMAS-master/amas/AMAS.py # (https://github.com/marekborowiec/AMAS)

home=/global/homes/jg/t_vane02
scripts=$home/scripts
taxon_set=genus
wd=$home/uce-myrmecocystus/uces/$taxon_set/alignments

mkdir -p $wd/logs

#################################################################
#### 1 ALIGN AND TRIM SINGLE LOCI ####
#################################################################
nt=12

## Create list of loci 
ls $home/uce-myrmecocystus/uces/$taxon_set/exploded-fastas-all > $wd/loci.txt
## Align and trim loci
qsub -sync y -pe smp $nt -t 1-$(cat $wd/loci.txt | wc -l) -N alignment_trimming -o $wd/logs -e $wd/logs $scripts/alignment_trimming.sh $nt $wd/loci.txt $wd

#################################################################
#### 2 CONCATENATE ALIGNMENTS AND TRIM ####
#################################################################
## Concatenate all alignments
mkdir -p $wd/concat
python $amas concat -i $wd/*-mafft-trimal -f fasta -d dna -t $wd/concat/mafft-trimal-concat.fas -p $wd/concat/mafft-trimal-concat.fas-part

## Trim with spruceup
spruceup_conf=$wd/concat/spruceup.conf # Manually created configuration file for spruceup
spruceup.py $spruceup_conf

## Convert final concatenated alignment to NEXUS and PHYLIP format
cd $wd/concat
python $amas convert -i $wd/concat/mafft-trimal-concat.fas -f fasta -d dna -u nexus
python $amas convert -i $wd/concat/mafft-trimal-concat.fas -f fasta -d dna -u phylip

