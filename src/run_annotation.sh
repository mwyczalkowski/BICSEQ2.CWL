#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

## get gene-level copy number values for given case
#
# Usage:
#   bash run_annotation.sh [options] CNV
#
# Options:
# -d: dry run: print command but do not execute
# -s CASE_NAME: Name for this case (patient)  Default: case
# -o OUTD: output directory.  Defalt is ./annotation
# -G GENE_BED: gene annotation bed file, created by prep_gene_annotation step (specific to ensembl build)
#    Required
# -C: process data for case-only segmentation mode.  Default is case-control.
#
# Input:
#  * .cnv file output by run_segmentation step
# 
# Output:
#  * Gene level CNV file like CASE.gene_level.log2.seg, written to annotation directory

SCRIPT=$(basename $0)
source /BICSEQ2/src/utils.sh

OUTD="./annotation"
CASE_NAME="case"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":do:G:s:C" opt; do
  case $opt in
    d)  
      DRYRUN=1
      ;;
    o) 
      OUTD=$OPTARG
      ;;
    G) 
      GENE_BED=$OPTARG
      ;;
    s) 
      CASE_NAME=$OPTARG
      ;;
    C)  
      CASE_ONLY=1
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR: Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR: Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

CNV=$1

if [ -z $GENE_BED ]; then
    >&2 echo ERROR: Gene annotation file \[-g\] not defined
    exit 1
fi
if [ ! -e $GENE_BED ]; then
    >&2 echo ERROR: Gene annotation file $GENE_BED not found
    exit 1
fi

# Output, tmp, and log files go here
mkdir -p $OUTD

if [ ! -e $CNV ]; then
    >&2 echo ERROR: CNV input file $CNV not found
    exit 1
fi

GL_OUT="$OUTD/${CASE_NAME}.gene_level.log2.seg"

# The data format for CASE_ONLY and case/control is different
if [ $CASE_ONLY ]; then
    CUT="cut -f1,2,3,7"
else
    CUT="cut -f1,2,3,9"
fi

# -S prevents site packages from loading, important at MGI
# PYTHONPATH defines additional library paths.  MGI doesn't seem to respect environment variables from Dockerfile ?
PYTHON="/usr/bin/python -S"
export PYTHONPATH="/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/dist-packages:$PYTHONPATH"
CMD="sed '1d' $CNV | $CUT | /usr/bin/bedtools intersect -loj -a $GENE_BED -b - | $PYTHON /BICSEQ2/src/gene_segment_overlap.py > $GL_OUT"

#>&2 echo testing python...
#CMD="python -S -c \"import sys;print(sys.path)\" "

run_cmd "$CMD" $DRYRUN

>&2 echo SUCCESS

# Note, not merging across all samples into final result named e.g. gene_level_CNV.BICSEQ2.UCEC.hg38.121.v1.2.tsv
# Code below from https://github.com/ding-lab/BICSEQ2/blob/master/get_gene_level_cnv.sh

# ls *.CNV | cut -f1 -d'.' > ${outputPath}samples.txt
# genelevelFile="gene_level_CNV"
# version=1.2
# batchName="BICSEQ2.UCEC.hg38.121"
# genelevelOut=${genelevelFile}"."${batchName}".v"${version}".tsv"
# echo gene > ${genelevelOut}
# cut -f1 $(head -1 samples.txt).gene_level.log2.seg >> ${genelevelOut}
# cat samples.txt | while read sample; do
# 	echo ${sample}
# 	echo $sample > smp
# 	cut -f5 $sample.gene_level.log2.seg >> smp
# 	paste ${genelevelOut} smp > tmp2
# 	mv -f tmp2 ${genelevelOut}
# 	rm -f smp
# done
