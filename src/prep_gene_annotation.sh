#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Download annotation GFF file and process it to obtain gene annotation BED file
# Usage:
#   bash prep_gene_annotation.sh [options] GFF_URL BED_OUT

# Input: 
#   URL of gff
#   path and filename of output.  May be relative.  Directory will be created.  All output will go to this directory
# Output:
#   Writes to output file
#   Temp directory in output file path, or specified independently
#
# Options:
# -d: dry run
# -n: do not delete temporary downloaded GFF file
# 
# TODO:
# Checks to see if output file exists before overwriting
#   Option to force overwrite even if output exists

source /BICSEQ2/src/utils.sh

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dn" opt; do
  case $opt in
    d)  
      DRYRUN=1
      ;;
    n)  
      NORMGZ=1
      ;;
#    l)   # example
#      READ_LENGTH=$OPTARG  
#      ;;
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


if [ "$#" -ne 2 ]; then 
    >&2 echo ERROR: Wrong number of arguments
    exit 1
fi

GFF_URL=$1
BED_OUT=$2

# Note that BED_OUT may be relative path (../foo/blah.bed)
# destination directory DESTD is absolute
# Need to create directory of $BED_OUT before running `readlink -f`
# 	(because readlink will fail if the directory does not exist)
BED_OUT_DIR=$(dirname $BED_OUT)	# possibly relative path to BED_OUT
>&2 echo Making directory $BED_OUT_DIR
mkdir -p $BED_OUT_DIR
test_exit_status

# expand out the path of $BED_OUT and save to DESTD
DESTD=$(dirname $(readlink -f $BED_OUT) )

>&2 echo Output absolute path $DESTD

GFF=$DESTD/$(basename $GFF_URL)
if [ -e $GFF ]; then
    >&2 echo Note: Target exists: $GFF
    >&2 echo Skipping download...
else
    >&2 echo Getting $GFF_URL writing to $GFF
    wget -O $GFF $GFF_URL
    test_exit_status
fi

>&2 echo Processing $GFF

# this needs to be in path so sort-bed found
BEDOPSD="/bedops/bin"
PATH="$PATH:$BEDOPSD"

# Yige update 1/5/19
# cat ${inputDir}${geneAnnoGFF3File} | awk '$3=="gene"' | grep protein_coding | convert2bed -i gff - | cut -f 1,2,3,10 | awk -F ';|\\t' '{print $1,$2,$3,$7}' | awk -F ' |\\=' '{print $1,$2,$3,$5}' OFS='\t' > ${inputDir}${geneAnnoBedFile}
CMD="zcat $GFF | awk '\$3==\"gene\"' | grep protein_coding | $BEDOPSD/convert2bed -i gff - | cut -f 1,2,3,10 | awk -F ';|\\t' '{print \$1,\$2,\$3,\$7}' | awk -F ' |\\=' '{print \$1,\$2,\$3,\$5}' OFS='\t' > $BED_OUT"
if [ $DRYRUN ]; then
    >&2 echo Dryrun: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    >&2 echo Successfully written to $BED_OUT
fi

if [ ! $NORMGZ ]; then
# "No rm gz" is not set
    >&2 echo Deleting temporary file $GFF
    rm -f $GFF
    test_exit_status
fi

>&2 echo SUCCESS 
