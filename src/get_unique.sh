#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Usage: get_unique.sh [options] BAM
# Input is BAM file 

# Options:
# -d : dry-run. Print commands but do not execute them
# -1 : stop after one.  If CHRLIST defined, launch only one job and proceed
# -c CHR: Genomic region, e.g., "chr1".  Default is to process all chromosomes at once.  
# -f : Force overwrite if .seq files exist
# -o OUTFN: output filename.  Default is unique.seq

## the path to the samtools getUnique helper script
SAMTOOLS_GU="/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"

SCRIPT=$(basename $0)

OUTFN="./unique.seq"

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
    1) 
      >&2 echo "Will stop after one element of CHRLIST" 
      JUSTONE=1
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

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo $SCRIPT Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}

function process_BAM {
    BAM=$1

    NOW=$(date)
    CMD="samtools view $BAM $CHR | perl $SAMTOOLS_GU unique - | cut -f 4 > $OUTFN"

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

>&2 echo Processing BAM singly
process_BAM $BAM

>&2 echo SUCCESS
