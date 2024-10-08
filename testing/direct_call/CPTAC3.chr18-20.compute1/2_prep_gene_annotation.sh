# Run prep_gene_annotation.sh from within docker.  

# Using same project_config as other katmai steps.  
#source project_config.run_sample.C3L-chr.katmai.sh

# previously, ../run_sample.C3L-chr.katmai/project_config.run_sample.C3L-chr.katmai.sh

GFF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz"

# Creates $GENE_BED defined in project_config
OUTD="/results/annotation"
GENE_BED="$OUTD/bed/gencode.v29.annotation.hg38.p12.bed"

#   prep_gene_annotation.sh [options] GFF_URL BED_OUT
bash /BICSEQ2/src/prep_gene_annotation.sh $@ $GFF_URL $GENE_BED

