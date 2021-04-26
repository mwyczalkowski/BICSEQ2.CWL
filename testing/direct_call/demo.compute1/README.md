Create mappiblity files for demo dataset

Reference: /storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/demo_data/Homo_sapiens_assembly19.COST16011_region.fa
This is mapped to /data

Mapping data in /data/map

Annotation file - generated here:
    /gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/a_prep_gene_annotation.sh
Source:
    GFF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz"

Note that this test dataset is useful for preliminary testing since it is small and runs quickly, but seems to fail
on step 3, normalization.  This necessitates a move to real data for further testing, like that described here:
../old/run_sample.C3L-chr.katmai

Note that the following scripts are place-holders:
  *  5_run_segmentation.sh
  *  6_run_gene_anotation.sh
