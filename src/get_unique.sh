#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Usage: get_unique.sh [options] BAM
# Input is BAM file 

# Options:
# -d : dry-run. Print commands but do not execute them
# -c CHR: Genomic region, e.g., "chr1".  Default is to process all chromosomes at once.  
# -f : Force overwrite if .seq files exist
# -o OUTFN: output filename.  Default is unique.seq if CHR is not specified, CHR.unique.seq if it is

## the path to the samtools getUnique helper script
SAMTOOLS_GU="/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"
SAMTOOLS="/usr/bin/samtools"
PERL="/usr/bin/perl"
source /BICSEQ2/src/utils.sh

SCRIPT=$(basename $0)


# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":d1c:fo:" opt; do
  case $opt in
    d)  # example of binary argument
      >&2 echo "Dry run" 
      DRYRUN=1
      ;;
    c) 
      CHR=$OPTARG
      ;;
    f) 
      FORCE_OVERWRITE=1
      ;;
    o) 
      OUTFN=$OPTARG
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

if [ -z $OUTFN ]; then
    if [ ! -z $CHR ]; then
        OUTFN="./$CHR.unique.seq"
    else
        OUTFN="./unique.seq"
    fi
fi

if [ "$#" -ne 1 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage: get_unique.sh BAM
    exit 1
fi

BAM=$1

if [ ! -e $BAM ]; then
    >&2 echo ERROR: Bam file $BAM does not exist
    exit 1
fi

function process_BAM {
    BAM=$1

    NOW=$(date)
    CMD="$SAMTOOLS view $BAM $CHR | $PERL $SAMTOOLS_GU unique - | cut -f 4 > $OUTFN"

    if [ -e $OUTFN ]; then
        if [ $FORCE_OVERWRITE ]; then
            >&2 echo NOTE: $OUTFN exists.  Forcing overwrite \(-f\) of existing .seq data
        else
            >&2 echo ERROR: $OUTFN exists.  Will not overwrite existing .seq data 
            exit 1
        fi
    fi
    >&2 echo [ $NOW ] Evaluating uniquely mapped reads, writing to $OUTFN 
    if [ $DRYRUN ]; then
    >&2 echo Dryrun: $CMD
    else
        >&2 echo $CMD 
        eval $CMD
        test_exit_status
    fi
}

process_BAM $BAM

>&2 echo SUCCESS
