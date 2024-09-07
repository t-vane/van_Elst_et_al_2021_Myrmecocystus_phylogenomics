################################################################################
#### ANCESTRAL STATE ESTIMATION ####
################################################################################
home=/global/homes/jg/t_vane02
scripts=$home/scripts
wd=/global/homes/jg/t_vane02/uce-myrmecocystus/ancestral-states

mkdir -p $wd/logs

## Estimate ancestral states for two alternative topologies (based on concatenated ML inference and ASTRAL species tree inference) 
tree_concat=$home/uce-myrmecocystus/uce-extraction/genus/phylogenetic-inference/ML/run1/partitions.nex.treefile
tree_astral=$home/uce-myrmecocystus/uce-extraction/genus/phylogenetic-inference//astral/unbinned/speciestree_unbinned.tre
chars=$wd/characters.csv # CSV formatted file with two columns named 'species' and 'char'

# Concatenated topology
qsub -N ancestral_states_concat -o $wd/logs -e $wd/logs $scripts/ancestral_states.sh $tree_concat $chars $wd/concat
# ASTRAL species tree topology
qsub -N ancestral_states_astral -o $wd/logs -e $wd/logs $scripts/ancestral_states.sh $tree_astral $chars $wd/astral
