#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Create normalization configuration file and run BICSeq normalization on all chromosomes
Usage:
  bash run_norm.sh [options] SEQ1 [SEQ2 ...]
  SEQ (SEQLIST) is list of results of get_unique.sh output. Chromosome is obtained from input filenames
     with the assumption they are named `CHR.unique.seq`. 

Options:
  -v: verbose
  -s SAMPLE_NAME: Unique name for this run.  Default: sample
  -d: dry run. Make normalization configuration file but do not execute BICSeq-norm script
  -c CHRLIST: define chrom list, which will define CHR for a given result.  List must be same length
     as SEQLIST
  -C norm_config: Use given normalization config file, rather than creating it
  -w: issue warnings instead of fatal errors if `perl NBICseq-norm.pl` fails
  -o OUTD: set output directory.  Defalt is ./norm
  -R REFD: path to reference files, or compressed file which contains these.  
      Assume per-chrom reference filenames are named CHR.fa.  Required
  -m MER: Base name for mappability files.  Example: GRCh38.d1.vd1.150mer  Required
      Traditionally, MER=${REFNAM}.${READ_LENGTH}mer
  -M MAPD: path to mappability files, or compressed file which contains these.  
      Assume per-chrom mappability files are in directory MAPD/MER.CHR.txt. Required
  -F: Remove $OUTD/mappability and $OUTD/reference directories if they were created
  -X XARGS: arguments to be passed directly to NBICseq-norm.pl
  -x X0_POLICY: how to test for "excess zeros": allowed values = ignore, warning (default), error

Parameters used by BICSEQ_NORM
  -r READ_LENGTH.  Default 150
  -f FRAG_SIZE.  Default 350
  -b BIN_SIZE.  Default 100

"excess zero" testing is a heuristic error diagnostic where column 3 of NBICseq-norm.pl output
  has 0 as the most frequently observed value, which is associated with spurious results. X0_policy has 3 permitted values: 
  "ignore" - do not test
  "warning" - test results.  File results/excess_zeros/{SAMPLE_NAME}.{CHR}.norm.bin.dist.dat is written with column 3 counts
      If a "excess zero" situation is detected, file results/excess_zeros/{SAMPLE_NAME}.{CHR}.norm.bin.excess_zeros_observed.dat is also written
      Also, the file results/excess_zeros/excess_zeros_observed.dat is also written (work-around cromwell bug)
      However, no error is returned and processing continues.  
  "error" - same processing as "warning", but an error is generated and processing stops

* Input
  * Reads per-chrom reference, mapping, and seq files
  * Iterates over SEQLIST
  * If REFD and MAPD given as .tar.gz files, they are extracted into $OUTD/reference and $OUTD/mappability
    directories.  These directories can be deleted at the conclusion of the run with -F flag
* All output of this step written to $OUTD:
  * normalization configuration file results/{SAMPLE_NAME}.norm-config.txt
  * PDF written as {SAMPLE_NAME}.GC.pdf
  * parameter estimate output in {SAMPLE_NAME}.out.txt
  * Normalized data, per chrom, written to results/{SAMPLE_NAME}.{CHR}.norm.bin
    * Note that this is written to config file used by NBICseq-norm.pl
  * Tmp directory $OUTD/tmp created and passed as argument to NBICseq-norm.pl
  * If passed as .tar.gz, mappability and reference files uncompressed to $OUTD/reference and $OUTD/mappability
    * these can be deleted after conclusion of script with -F
EOF

SAMPLE_NAME="sample"

source /BICSEQ2/src/utils.sh
PERL="/usr/bin/perl"
BICSEQ_NORM="/NBICseq-norm_v0.2.4/NBICseq-norm.pl"
TEST_X0="/BICSEQ2/src/test_excess_zero.sh"

# Parameters used by BICSEQ_NORM
READ_LENGTH=150
FRAG_SIZE=350
BIN_SIZE=100

SCRIPT=$(basename $0)

X0_POLICY="warning"
OUTD="./norm"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hvwdc:R:M:C:o:m:s:Fr:f:b:X:x:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
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
      CHRLIST=($OPTARG)
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
    s) 
      SAMPLE_NAME=$OPTARG
      ;;
    F)  
      FINALIZE=1
      ;;
    r) 
      READ_LENGTH=$OPTARG
      ;;
    f) 
      FRAG_SIZE=$OPTARG
      ;;
    b) 
      BIN_SIZE=$OPTARG
      ;;
    X) 
      XARGS="$OPTARG"
      ;;
    x) 
      if [ $OPTARG != "ignore" ] && [ $OPTARG != "warning" ] && [ $OPTARG != "error" ]; then
          >&2 echo "$SCRIPT: ERROR: Invalid X0_POLICY: $OPTARG"
          >&2 echo "$USAGE"
          exit 1
      fi  
      X0_POLICY="$OPTARG"
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR: Invalid option: -$OPTARG"
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR: Option -$OPTARG requires an argument."
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# In general, we iterate over list of provided results (SEQLIST) and extract chromosome name from it
# with the assumption that filename is CHR.unique.seq.  Alternatively, if CHRLIST is provided, we will
# obtain chromsome names from it; this requires that SEQLIST and CHRLIST are the same lengths
SEQLIST=("$@")

if [ ! -z $CHRLIST ]; then
    if [ ${#SEQLIST[@]} != ${#CHRLIST[@]} ]; then
        >&2 echo ERROR: Require SEQLIST length to be same as CHRLIST length
        >&2 echo SEQLIST length = ${#SEQLIST[@]}
        >&2 echo CHRLIST length = ${#CHRLIST[@]}
        exit 1
    else
        >&2 echo Obtaining CHR from CHRLIST
    fi
else
    >&2 echo Obtaining CHR from SEQLIST
fi

## create tmp and result directory
TMPD="$OUTD/bicseq-tmp"
RESULTSD="$OUTD/results"
mkdir -p $TMPD
mkdir -p $RESULTSD


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
            mkdir -p $OUTPUT_D
            >&2 echo "Extracting reference tarball $IN_ARG into $OUTPUT_D";
            CMD="tar -zxf $IN_ARG --directory $OUTPUT_D"
            run_cmd "$CMD" $DRYRUN
        else
            >&2 echo ERROR: File $IN_ARG is not a .tar.gz file
        fi
    else
        >&2 echo ERROR: Reference $IN_ARG does not exist
        exit 1
    fi
    echo $OUTPUT_D
}

if [ -z $REF_ARG ]; then
    >&2 echo ERROR: -R REF_ARG not passed
    exit 1
fi
REFD_DEFAULT="$OUTD/reference"
REFD=$(extract_tarball $REF_ARG $REFD_DEFAULT)  

if [ -z $MAP_ARG ]; then
    >&2 echo ERROR: -M MAP_ARG not passed
    exit 1
fi
MAPD_DEFAULT="$OUTD/mappability"
MAPD=$(extract_tarball $MAP_ARG $MAPD_DEFAULT)

# Output:
# NORM_PDF - per sample
#   #NORM_PDF="$OUTD/%s.GC.pdf"
# OUTPARS - not generally used
# NORM_OUT - per chrom
# NORM_CONFIG="$OUTD/${SAMPLE_NAME}.norm-config.txt"

# Assumed per-chrom FASTA installed in same directory as $REF
FA_CHR="${REFD}/%s.fa"

MAP_CHR="$MAPD/$MER/${MER}.%s.txt"

OUTPARS="$RESULTSD/${SAMPLE_NAME}.out.txt"
PDF="$RESULTSD/${SAMPLE_NAME}.GC.pdf"
# following created if not passed:
#  NORM_CONFIG="$RESULTSD/${SAMPLE_NAME}.norm-config.txt"
# Also, following per-chrom file created:
#  binFile="$RESULTSD/${SAMPLE_NAME}.${CHR}.norm.bin" 

function write_norm_config {
    NORM_CONFIG="$RESULTSD/${SAMPLE_NAME}.norm-config.txt"

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


    # Build up CHRLIST_NORMALIZED for use in excess zero checks
    CHRLIST_NORMALIZED=""
#https://stackoverflow.com/questions/17403498/iterate-over-two-arrays-simultaneously-in-bash
    for i in "${!SEQLIST[@]}"; do
        SEQ="${SEQLIST[i]}"

        if [ ! -z $CHRLIST ]; then
            CHR="${CHRLIST[i]}"
        else
            CHR=$(echo $(basename $SEQ) | sed 's/\(.*\)\.unique.seq/\1/' )
        fi
        CHRLIST_NORMALIZED="$CHRLIST_NORMALIZED $CHR"
        faFile=$(printf $FA_CHR $CHR)
        confirm $faFile   
        MapFile=$(printf $MAP_CHR $CHR)
        confirm $MapFile
        readPosFile="$SEQ"
        confirm $readPosFile   
        binFile="$RESULTSD/${SAMPLE_NAME}.${CHR}.norm.bin" 
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

# This is where the real processing happens
CMD="$PERL $BICSEQ_NORM $XARGS --tmp=$TMPD -l $READ_LENGTH -s $FRAG_SIZE -b $BIN_SIZE --fig $PDF $NORM_CONFIG $OUTPARS"
if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
fi
test_exit_status

# Now test for "excess zeros" in the results
if [ $X0_POLICY != "ignore" ]; then
    ARGS="-o $RESULTSD/excess_zeros"
    if [ $X0_POLICY = "ERROR" ]; then
        ARGS="$ARGS -e"
    fi

    for i in $CHRLIST_NORMALIZED; do
        binFile="$RESULTSD/${SAMPLE_NAME}.${i}.norm.bin" 
        CMD="bash $TEST_X0 $ARGS $binFile"
        if [ $DRYRUN ]; then
            >&2 echo Dry run: $CMD
        else
            >&2 echo Running: $CMD
            eval $CMD
        fi
        test_exit_status
    done

# Now test if *any* chr had excess zeros, and create file excess_zeros_observed.dat 
# This allows for testing of a single flag
    if compgen -G "$RESULTSD/excess_zeros/*.excess_zeros_observed.dat" > /dev/null; then
        OUT_FLAG_FILE="$RESULTSD/excess_zeros/excess_zeros_observed.dat"
        echo "Excess zeros observed" > $OUT_FLAG_FILE
        test_exit_status
    fi
fi

# Remove $OUTD/mappability and $OUTD/reference if they exist
if [ $FINALIZE ]; then
    >&2 echo Removing temporary directories 
    if [ -d $MAPD_DEFAULT ]; then
        CMD="rm -r $MAPD_DEFAULT"
        run_cmd "$CMD" $DRYRUN
    fi
    if [ -d $REFD_DEFAULT ]; then
        CMD="rm -r $REFD_DEFAULT"
        run_cmd "$CMD" $DRYRUN
    fi
fi

>&2 echo SUCCESS
