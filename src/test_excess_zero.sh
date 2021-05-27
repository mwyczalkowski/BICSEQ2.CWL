#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Evaluate results of normalization step to find "anomalous" results where most frequently observed value
# of column 3 is 0.
#
# Usage:
#   bash test_excess_zero.sh [options] NORM_BIN

#   NORM_BIN is normalized bin file as generated by BICseq2-norm.  
#   Output consists of one data file and an optional flag file in OUTD directory
#     NORM_BIN.dist.dat - rank sorted list of column 3 values by frequency
#     NORM_BIN.excess_zero.dat - a file which is created if the most frequently observed value of column 3 is 0
#   Note that the suffixes above are just appended to NORM_BIN filename
#
# Options:
#   -v: verbose
#   -e: issue error instead of warning errors if excess_zero condition encountered
#   -o OUTD: set output directory.  Defalt is ./norm/results

SCRIPT=$(basename $0)

OUTD="./norm/results"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":veo:" opt; do
  case $opt in
    v)  
      VERBOSE=1
      ;;
    e)  
      DO_ERR=1
      ;;
    o) 
      OUTD=$OPTARG
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

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi

NORM_BIN_PATH=$1
if [ ! -e $NORM_BIN_PATH ]; then    
    >&2 echo ERROR: $NORM_BIN_PATH not found
    exit 1
fi

NORM_BIN_BASE=$(basename $NORM_BIN_PATH)
mkdir -p $OUTD

DIST_OUT="$OUTD/${NORM_BIN_BASE}.dist.dat"
X0_FLAG_OUT="$OUTD/${NORM_BIN_BASE}.excess_zeros_observed.dat"

CMD="cut -f 3 $NORM_BIN_PATH | sort | uniq -c | sort -nr > $DIST_OUT"
>&2 echo Testing for excess zeros.  
>&2 echo Running: $CMD
eval $CMD
test_exit_status

TOP_N=$(head -1 $DIST_OUT | awk -F ' ' '{print $2}') 
if [[ "$TOP_N" = 0 ]]; then
    MSG1="excess zero condition observed in $NORM_BIN_PATH"
    MSG2="See $DIST_OUT for distribution"
    MSG3="Flag file $X0_FLAG_OUT written"
    echo $MSG1 > $X0_FLAG_OUT
    echo $MSG2 >> $X0_FLAG_OUT
    echo $MSG3 >> $X0_FLAG_OUT
    if [ $DO_ERR ]; then
        >&2 echo ERROR: $MSG1
        >&2 echo $MSG2
        >&2 echo $MSG3
        exit 1
    else
        >&2 echo WARNING: $MSG1
        >&2 echo $MSG2
        >&2 echo $MSG3
    fi
fi

