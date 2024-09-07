################################################################################
#### ASSEMBLY ####
################################################################################
## Software:
# phyluce needs to be included in $PATH (v1.6.7; https://phyluce.readthedocs.io/en/latest/)

home=/global/homes/jg/t_vane02
scripts=$home/scripts
wd=$home/uce-myrmecocystus/metaspades

mkdir -p $wd/logs

nt=8
mem=30
inds=$wd/individuals.txt # List of individuals for assembly
inds_downsample=$wd/individuals_downsample.txt # List of individuals for which reads need to be downsampled before assembly

## Assembly for individuals for which downsampling has to be done
qsub -pe smp $nt -l h_vmem=${mem}G -t 1-$(cat $inds_downsample | wc -l) -N assembly_downsample -o $wd/logs -e $wd/logs $scripts/assembly.sh $nt $mem $inds $home/uce-myrmecocystus/reads/clean-fastq $wd TRUE 1500000
## Assembly for individuals without downsampling
qsub -sync y -pe smp $nt -l h_vmem=${mem}G -t 1-$(cat $inds | wc -l) -N assembly -o $wd/logs -e $wd/logs $scripts/assembly.sh $nt $mem $inds $home/uce-myrmecocystus/reads/clean-fastq $wd FALSE

## Calculate basic summary statistics
for file in $wd/*.fasta
do
	echo -e "#### processing file $file ... \n"
	phyluce_assembly_get_fasta_lengths --input $file --csv
done > $wd/fasta-lengths-metaspades.txt
