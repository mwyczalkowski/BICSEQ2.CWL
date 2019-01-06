# Configuration file for testing normalization on katmai
# using past run as input : /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq
# All paths are container-based
# Assuming the following mapping:
#   data1:/diskmnt/Datasets/BICSEQ2-dev.tmp (output)
#   data2:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  (chrom reference (./hg38) and mappability)
#   data3:/diskmnt/Projects/cptac_downloads_3/GDC_import/data (BAM files)
#	This is if want to use external SEQ files
#   data4:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq  (.seq files)

# if $IMPORT_SEQ is 1, use external (preprocessed) SEQ file, otherwise
# use directory as defined by workflow.  This is to simplify testing and restarts
# Be careful about inadvertant overwriting of data
IMPORT_SEQ=0

PROJECT="run_sample.C3L-chr.katmai"

# REF defined below is used for two purposes: to get path to all-chrom reference used in prep_mappability step, 
# and for getting the basename of the mappability files ("MER").  For this project, we are not mapping the 
# directory but respecting the reference base name
REF="/foo/GRCh38.d1.vd1.fa"
R=$(basename -- "$REF")
#REF_BASE="${R%.*}"	# this takes trailing .fa off
REF_BASE="${R}"

# This is the root directory of per-chrom reference.  Filename is e.g. chr20.fa
REF_CHR="/data2/hg38"

# All output directories are rooted in $OUTD
OUTD="/data1/$PROJECT"

READ_LENGTH=150

CHRLIST="/BICSEQ2/testing/test_data/chromosomes.18-20.dat"

# This is used in prep_gene_annotation.sh and run_annotation.sh
# Version generated by Yige: /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs/gencode.v29.annotation.hg38.p12.protein_coding.bed
GENE_BED="$OUTD/bed/gencode.v29.annotation.hg38.p12.bed"

SRCD="/BICSEQ2/src"	# scripts directory

# Create output directories
mkdir -p $OUTD
# MAPD is passed to make_mappability.sh as OUTD, is mappability file directory
MAPD="/data2"


## the path to the .seq file, 
if [ "$IMPORT_SEQ" == 1 ]; then
    SEQD="/data4"
    >&2 echo "IMPORT_SEQ: will read .seq from $SEQD"
else
    SEQD="$OUTD/unique_reads"
    >&2 echo "IMPORT_SEQ: will read .seq from workflow $SEQD"
fi

# Output of normalization step
NORMD="$OUTD/norm"
# Output of segmentation step
SEGD="$OUTD/segmentation"
# Output of annotation step
ANND="$OUTD/annotation"

# MER is a convenience string defined in make_mappability.sh
MER=${REF_BASE}.${READ_LENGTH}mer     # common name used for output

# Output filename specifications

# Assumed per-chrom FASTA installed in same directory as $REF
FA_CHR="${REF_CHR}/%s.fa"
# MAPD is identical to OUTD in make_mappability.sh
# v1 defined in main.sh as /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/
MAP_CHR="$MAPD/$MER/$MER.%s.txt"

# get_unique.sh parameters
# SEQ_CHR is used when multiple chrom exist, otherwise SEQ_OUT is used
# SEQ_CHR="$SEQD/$SAMPLE_NAME.%s.seq"
# SEQ_OUT="$SEQD/$SAMPLE_NAME.seq"
# NORM_CHR="$OUTD/${SAMPLE_NAME}.%s.norm.bin" 
# NORM_PDF="$OUTD/${SAMPLE_NAME}.GC.pdf"

# NOte that config file does not know about sequence names
SEQ_CHR="$SEQD/%s_%s.seq"
SEQ_OUT="$SEQD/%s.seq"
NORM_CHR="$NORMD/%s.%s.norm.bin" 
NORM_PDF="$NORMD/%s.GC.pdf"

# PARALLEL_JOBS: if parallel run, number of jobs to run at any one time 
PARALLEL_JOBS=4

# See http://compbio.med.harvard.edu/BIC-seq/ for details
BICSEQ_NORM="/NBICseq-norm_v0.2.4/NBICseq-norm.pl"

# Parameters used by BICSEQ_NORM
FRAG_SIZE=350
BIN_SIZE=100

# parameters for segmentation
# LAMBDA is a smoothing parameter
LAMBDA=3
BICSEQ_SEG="/NBICseq-seg_v0.7.2/NBICseq-seg.pl"
SEG_PDF="$SEGD/%s_seg.pdf"  # add to project_config
SEG_CNV="$SEGD/%s.cnv"

# Parameters for annotation step
GL_CASE="$ANND/%s.gene_level.log2.seg"

