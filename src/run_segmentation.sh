#!/bin/bash

# Create segmentation configuration file and detect CNVs based on the normalized data 
# generated by BICseq2-norm
# Usage:
#   bash run_segmentation.sh [options] SAMPLE_NAME.CASE SAMPLE_NAME.CONTROL PROJECT_CONFIG 
#
# SAMPLE_NAME.*:  Case and control sample names, same as passed to BICseq2-norm
#       Case and control are typically tumor and normal, respectively
# PROJECT_CONFIG: Project configuration file
#
# Options:
#   -v: verbose
#   -d: dry run. Make segmentation configuration file but do not execute BICSeq-seg script
#   -c CHRLIST: define chrom list, overriding value in PROJECT_CONFIG
#   -C seg_config: Use given segmentation config file, rather than creating it
#   -w: issue warnings instead of fatal errors if files do not exist
#   -s CASE_NAME: define name of case (patient) corresponding to both case and control samples. 
#       Default is longest common prefix of SAMPLE_NAME.CASE and SAMPLE_NAME.CONTROL

# * Input
#   * Reads per-chrom normalized data files
#   * Iterates over CHRLIST
# * All output of this step written to $OUTD:
#   * segmentation configuration file {CASE_NAME}.seg-config.txt
#   * PDF output (CASE-seg.pdf)
#   * CNV file  (CASE.cnv)
#   * tmp directory $OUTD/tmp

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":vdc:C:ws:" opt; do
  case $opt in
    v)  
      VERBOSE=1
      ;;
    w)  
      WARN=1
      ;;
    d)  
      DRYRUN=1
      ;;
    c) # Define CHRLIST
      CHRLIST_ARG=$OPTARG
      ;;
    C) # define a segmentation configuration file instead of writing it
      SEG_CONFIG=$OPTARG
      >&2 echo Segmentation config file passed: $SEG_CONFIG
      ;;
    s) # Define CASE_NAME explicitly
      CASE_NAME_ARG=$OPTARG
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


if [ "$#" -ne 3 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage:
    >&2 echo bash run_segmentation.sh \[options\] SAMPLE_NAME.CASE SAMPLE_NAME.CONTROL PROJECT_CONFIG
    exit 1
fi

SAMPLE_NAME_CASE=$1
SAMPLE_NAME_CONTROL=$2
PROJECT_CONFIG=$3

if [ ! -e $PROJECT_CONFIG ]; then
    >&2 echo Error: Project configuration file $PROJECT_CONFIG not found
    exit 1
fi

>&2 echo Reading $PROJECT_CONFIG
source $PROJECT_CONFIG

if [ $CHRLIST_ARG ]; then
    CHRLIST=$CHRLIST_ARG
fi

if [ ! -e $CHRLIST ]; then
    >&2 echo Error: File $CHRLIST does not exist
    exit 1
fi

# If its not otherwise specified, CASE_NAME (corresponding to source of common samples when case and control are tumor and normal, respectively)
if [ ! $CASE_NAME_ARG ]; then
    # from https://stackoverflow.com/questions/6973088/longest-common-prefix-of-two-strings-in-bash
    CASE_NAME=$(printf "%s\n%s\n" "$SAMPLE_NAME_CASE" "$SAMPLE_NAME_CONTROL" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')
else
    CASE_NAME=$CASE_NAME_ARG
fi

# LAMBDA is a smoothing parameter
if [ ! $LAMBDA ]; then
    >&2 echo Error: parameter LAMBDA not defined
    exit 1
fi

OUTD=$SEGD

## create tmp directory
# be able to specify with -t
TMPD="$OUTD/tmp"
mkdir -p $TMPD

function confirm {
    FN=$1
    if [ ! -e $FN ]; then
        if [ $WARN ]; then
            >&2 echo Warning: $FN does not exist
        else
            >&2 echo Error: $FN does not exist
            exit 1
        fi
    fi
}

function write_seg_config {
    # Segmentation configuration is distinct from project parameter configuration file
    SEG_CONFIG="$OUTD/${CASE_NAME}.seg-config.txt"

    # Create configuration file by iterating over all chrom in CHRLIST
    ## Config file format defined here: http://compbio.med.harvard.edu/BIC-seq/ (using control)

    >&2 echo Writing segmentation configuration $SEG_CONFIG
    printf "chromName\tbinFileNorm.Case\tbinFileNorm.Control\n" > $SEG_CONFIG
    while read CHR; do
        binCase=$(printf $NORM_CHR $SAMPLE_NAME_CASE $CHR)
        confirm $binCase   
        binControl=$(printf $NORM_CHR $SAMPLE_NAME_CONTROL $CHR)
        confirm $binControl   
        printf "$CHR\t$binCase\t$binControl\n" >> $SEG_CONFIG
    done<$CHRLIST
    >&2 echo Segmentation configuration $SEG_CONFIG written successfully
}

# Skip writing configutation file if it has already been defined with -C
if [ ! $SEG_CONFIG ]; then
    write_seg_config
else
    confirm $SEG_CONFIG
fi

PDF=$(printf $SEG_PDF $CASE_NAME)
CNV=$(printf $SEG_CNV $CASE_NAME)

CMD="perl $BICSEQ_SEG --detail --control --noscale --lambda=$LAMBDA --tmp=$TMPD --fig $PDF $SEG_CONFIG $CNV"

if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
fi

# Evaluate return value see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

