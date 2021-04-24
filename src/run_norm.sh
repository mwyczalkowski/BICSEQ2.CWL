#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Create normalization configuration file and run BICSeq normalization on all chromsomes
# Usage:
#   bash run_norm.sh [options] SEQ1 [SEQ2 ...]
#   SEQ (SEQLIST) is list of results of get_unique.sh output. Chromosome is obtained from input filenames
#      with the assumption they are named `CHR.unique.seq`. 
#
# Options:
#   -v: verbose
#   -s SAMPLE_NAME: Unique name for this run.  Default: sample
#   -d: dry run. Make normalization configuration file but do not execute BICSeq-norm script
#   -c CHRLIST: define chrom list, which will define CHR for a given result.  List must be same length
#      as SEQLIST
#   -C norm_config: Use given normalization config file, rather than creating it
#   -w: issue warnings instead of fatal errors if files do not exist
#   -o OUTD: set output directory.  Defalt is ./norm
#   -R REFD: path to reference files, or compressed file which contains these.  Required
#   -M MAPD: path to mappability files, or compressed file which contains these.  Required
#   -m MER: Base name for mappability files.  Default: GRCh38.d1.vd1.150mer

# * Input
#   * Reads per-chrom reference, mapping, and seq files
#   * Iterates over CHRLIST - or 
# * All output of this step written to $OUTD:
#   * normalization configuration file {SAMPLE_NAME}.norm-config.txt
#   * PDF written as {SAMPLE_NAME}.GC.pdf
#   * parameter estimate output in {SAMPLE_NAME}.out.txt
#   * Normalized data, per chrom, written to {SAMPLE_NAME}.{CHR}.norm.bin
#     * Note that this is written to config file used by NBICseq-norm.pl
#   * Tmp directory $OUTD/tmp created and passed as argument to NBICseq-norm.pl

REFNAM="GRCh38.d1.vd1"
READ_LENGTH="150"
MER=${REFNAM}.${READ_LENGTH}mer

source /BICSEQ2/src/utils.sh
PERL="/usr/bin/perl"

SCRIPT=$(basename $0)

OUTD="./norm"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":vwdc:R:M:C:o:m:" opt; do
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
    c) 
      CHRLIST="$OPTARG"
      ;;
    R) 
      REF_ARG="$OPTARG"
      ;;
    M) 
      MAP_ARG="$OPTARG"
      ;;
    C) # define a normalization configuration file instead of writing it
      NORM_CONFIG=$OPTARG
      >&2 echo Norm config file passed: $NORM_CONFIG
      ;;
    o) 
      OUTD=$OPTARG
      ;;
    m) 
      MER=$OPTARG
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

# In general, we iterate over list of provided results (SEQLIST) and extract chromosome name from it
# with the assumption that filename is CHR.unique.seq.  Alternatively, if CHRLIST is provided, we will
# obtain chromsome names from it; this requires that SEQLIST and CHRLIST are the same lengths
SEQLIST="$@"
if [ ! -z $CHRLIST ]; then
    if [ ${#SEQLIST[@]} != ${#CHRLIST[@]} ]; then
        >&2 echo ERROR: Require SEQLIST length to be same as CHRLIST length
        >&2 echo SEQLIST = $SEQLIST
        >&2 echo CHRLIST = $CHRLIST
        exit 1
    else
        >&2 echo Obtaining CHR from CHRLIST
    fi
else
    >&2 echo Obtaining CHR from SEQLIST
fi

# Not clear if we're checking this
#if [ "$#" -ne 2 ]; then
#    >&2 echo ERROR: Wrong number of arguments
#    >&2 echo Usage:
#    >&2 echo bash run_norm.sh \[options\] SAMPLE_NAME 
#    exit 1
#fi

## create tmp directory
TMPD="$OUTD/tmp"
mkdir -p $TMPD


# Given an input file or directory,
# If this is a directory, return that as output directory
# If this is a .tar.gz file, extract it to the given directory
function extract_tarball {
    IN_ARG=$1
    DEFAULT_OUTD=$2

    # If IN_ARG is a directory, OUTPUT_D=IN_ARG
    # else if it is a file which ends in .tar.gz extract it to ./reference
    if [ -d $IN_ARG ]; then
        OUTPUT_D="$IN_ARG"
    elif [ -e $IN_ARG ]; then
        if [[ $IN_ARG == *".tar.gz" ]]; then
            OUTPUT_D="$DEFAULT_OUTD"
            >&2 echo "Extracting reference tarball $IN_ARG into $OUTPUT_D\n";
            CMD="tar -zxf $IN_ARG --directory $OUTPUT_D"
            run_cmd $CMD $DRYRUN
        else
            >&2 echo ERROR: File $IN_ARG is not a .tar.gz file
        fi
    else
        >&2 echo ERROR: Reference $IN_ARG does not exist
        exit 1
    fi
    echo $OUTPUT_D
}

if [ -z $REF_ARG ];
    >&2 echo ERROR: -R REF_ARG not passed
    exit 1
fi
REFD=$(extract_tarball $REF_ARG)

if [ -z $MAP_ARG ];
    >&2 echo ERROR: -M MAP_ARG not passed
    exit 1
fi
MAPD=$(extract_tarball $MAP_ARG)

# Output:
# NORM_PDF - per sample
#   #NORM_PDF="$OUTD/%s.GC.pdf"
# OUTPARS - not generally used
# NORM_OUT - per chrom
# NORM_CONFIG="$OUTD/${SAMPLE_NAME}.norm-config.txt"

# Assumed per-chrom FASTA installed in same directory as $REF
FA_CHR="${REFD}/%s.fa"

MAP_CHR="$MAPD/$MER/$MER.%s.txt"

OUTPARS="$OUTD/${SAMPLE_NAME}.out.txt"
PDF="$OUTD/${SAMPLE_NAME}.GC.pdf"
NORM_BIN="$OUTD/${SAMPLE_NAME}.${CHR}.norm.bin" 

function write_norm_config {
    # Normalizaton configuration is distinct from project parameter configuration file
    NORM_CONFIG="$OUTD/${SAMPLE_NAME}.norm-config.txt"

    # Create configuration file by iterating over all chrom in CHRLIST
    ## Config file format defined here: https://www.math.pku.edu.cn/teachers/xirb/downloads/software/BICseq2/BICseq2.html
        # The first row of this file is assumed to be the header of the file and will be omitted by BICseq2-norm.
        # The 1st column (chromName) is the chromosome name
        # The 2nd column (faFile) is the reference sequence of this chromosome (human hg18 and hg19 are available for download)
        # The 3rd column (MapFile) is the mappability file of this chromosome (human hg18 (50bp) and hg19 (50bp and 75bp) are available for download)
        # The 4th column (readPosFile) is the file that stores all the mapping positions of all reads that uniquely mapped to this chromosome
        # The 5th column (binFile) is the file that stores the normalized data. The data will be binned with the bin size as specified by the option -b
    >&2 echo Writing normalization configuration $NORM_CONFIG
    printf "chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm\n" > $NORM_CONFIG


#https://stackoverflow.com/questions/17403498/iterate-over-two-arrays-simultaneously-in-bash
    for i in "${!SEQLIST[@]}"; do
        SEQ="${SEQLIST[i]}"
        if [ ! -z $CHRLIST ]; then
            CHR="${CHRLIST[i]}"
        else
            CHR=$($(basename $SEQ) | sed 's/\(.*\)\.unique.seq/\1/p' )
        fi

        faFile=$(printf $FA_CHR $CHR)
        confirm $faFile   
        MapFile=$(printf $MAP_CHR $CHR)
        confirm $MapFile
        readPosFile="$SEQ"
        confirm $readPosFile   
        binFile="$OUTD/${SAMPLE_NAME}.${CHR}.norm.bin" 
        printf "$CHR\t$faFile\t$MapFile\t$readPosFile\t$binFile\n" >> $NORM_CONFIG
    done
    >&2 echo Normalization configuration $NORM_CONFIG written successfully
}

# Skip writing configutation file if it has already been defined with -C
if [ ! $NORM_CONFIG ]; then
    write_norm_config
else
    confirm $NORM_CONFIG
fi

CMD="$PERL $BICSEQ_NORM --tmp=$TMPD -l $READ_LENGTH -s $FRAG_SIZE -b $BIN_SIZE --fig $PDF $NORM_CONFIG $OUTPARS"
if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
fi
test_exit_status

>&2 echo SUCCESS
