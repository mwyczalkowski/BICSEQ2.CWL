#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Copy or make a link to a file, for use as a null CWL step

Usage:
  stage_file.sh [options] FILE

FILE is an existing file to which we will make a link to

Options:
-h: Print this help message
-d: dry run
-o OUTFN: result filename is as given.  Default is same filename as input in current directory
-p [ hard | soft | copy ]: type of staging to do, using `ln -h`, `ln -s`, or `cp`, resp.
-s EXT: also stage secondary file which has given extension 

Additional processing details and background
EOF

#source /BICSEQ2/src/utils.sh
source utils.sh
PROCESS="hard"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdo:p:s:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  # example of binary argument
      DRYRUN=1
      ;;
    o) 
      OUTFN=$OPTARG
      ;;
    p) 
      PROCESS=$OPTARG
      ;;
    s) 
      EXT=$OPTARG
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

INFN=$1
if [ -z $INFN ]; then
    >&2 echo ERROR: input file must be specified
    echo "$USAGE"
    exit 1
fi
if [ ! -e $INFN ]; then
    >&2 echo ERROR: $INFN does not exist
    exit 1
fi

function stage_file {
    FILE_IN=$1
    FILE_OUT=$2 # this may be blank
    
    if [ ! $FILE_OUT ]; then
        FILE_OUT=$(basename $FILE_IN)
    else
        FILE_OUT=$FILE_OUT
        DIRNAME=$(dirname $FILE_OUT)
        CMD="mkdir -p $DIRNAME"
        run_cmd "$CMD" $DRYRUN
    fi

    if [ $PROCESS == "hard" ]; then
        CMD="ln -h $FILE_IN $FILE_OUT"
    elif [ $PROCESS == "soft" ]; then
        CMD="ln -s $FILE_IN $FILE_OUT"
    elif [ $PROCESS == "copy" ]; then
        CMD="cp $FILE_IN $FILE_OUT"
    else
        >&2 echo ERROR: unrecognized staging process: $PROCESS
        exit 1
    fi
    >&2 echo Staging \(via ${PROCESS}\) $FILE_IN to $FILE_OUT 
    run_cmd "$CMD" $DRYRUN
}

stage_file $INFN $OUTFN
if [ ! -z "$EXT" ]; then
    INFN2="${INFN}${EXT}"
    if [ ! -z "$OUTFN" ]; then
        OUTFN2=${OUTFN}${EXT}
        >&2 echo Staging secondary file $INFN2 to $OUTFN2 
    else
        >&2 echo Staging secondary file $INFN2 to default
        OUTFN2=""
    fi

    stage_file $INFN2 $OUTFN2
fi



