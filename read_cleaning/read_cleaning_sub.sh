################################################################################
#### READ CLEANING ####
################################################################################
home=/global/homes/jg/t_vane02
scripts=$home/scripts
wd=$home/uce-myrmecocystus/reads

mkdir -p $wd/logs

nt=16
conf=$wd/illumiprocessor.conf # Configuration/adapter file for newly generated reads
conf_sra=$wd/illumiprocessor_SRA.conf # Configuration/adapter file for reads downloaded from SRA
r1_pattern=_1
r2_pattern=_2

## Read cleaning for newly generated reads
qsub -pe smp $nt -N read_cleaning -o $wd/logs -e $wd/logs  $scripts/read_cleaning.sh $nt $wd/raw-fastq $wd/clean-fastq $conf $r1_pattern $r2_pattern
## Read cleaning for SRA reads
qsub -pe smp $nt -N read_cleaning_SRA -o $wd/logs -e $wd/logs $scripts/read_cleaning.sh $nt $wd/raw-fastq-SRA $wd/clean-fastq $conf_SRA $r1_pattern $r2_pattern


