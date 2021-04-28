# Execute normalization step on tumor and normal samples.  Process per-chrom only

# Tip: to debug norm-config file before processing, run with flags -dw,
# check / edit config file as necessary, and run with -C config.txt flag to pass config explicitly

UQD="/results/unique_reads"
NORMD="/results/norm"

# Will test both passing directories and uncompressing tarball
REF_GZ="/data/Homo_sapiens_assembly19.COST16011_region/Homo_sapiens_assembly19.COST16011_region.per_chrom.tar.gz"
MAP_GZ="/results/mappability/Homo_sapiens_assembly19.COST16011_region.150mer.tar.gz"

REFD="/data/Homo_sapiens_assembly19.COST16011_region"
MAPD="/results/mappability"

NORM_PER_CHR="$UQD/8.unique-normal.seq $UQD/11.unique-normal.seq"
TUM_PER_CHR="$UQD/8.unique.seq $UQD/11.unique.seq"

CHRLIST="8 11"
MER="Homo_sapiens_assembly19.COST16011_region.150mer"

CMD="bash /BICSEQ2/src/run_norm.sh $@ -o $NORMD -R $REF_GZ -F -M $MAP_GZ -s chr_tumor -m $MER $TUM_PER_CHR"
echo >&2 Running: $CMD
eval $CMD

# Find that this gives an error having to do with numerical problems, possibly in mgcv-package
# Most likely, this is associated with the test data.  Motivates moving to real data for testing.

CMD="bash /BICSEQ2/src/run_norm.sh $@ -o $NORMD -R $REFD -M $MAPD -s chr_normal -m $MER -c \"$CHRLIST\" $NORM_PER_CHR"
echo >&2 Running: $CMD
eval $CMD

