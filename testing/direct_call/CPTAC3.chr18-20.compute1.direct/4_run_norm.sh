# Execute normalization step on tumor and normal samples.  Process per-chrom only
# Use both staged and non-staged (.tar.gz) mapping and reference files

# Tip: to debug norm-config file before processing, run with flags -dw,

UQD="/results/unique_reads"
NORMD="/results/norm"

# Will test both passing directories and uncompressing tarball
REF_GZ="/reference/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz"
MAP_GZ="/reference/inputs/GRCh38.d1.vd1.fa.150mer.tar.gz"  # Don't use this
# Version of mappability below does not contain the .bedGraph file, which is very large.  Can it be used?
# Conclusion - yes, the noBedGraph version is OK to use
MAP_GZ_B="/reference/inputs/GRCh38.d1.vd1.fa.150mer-noBedGraph.tar.gz" # Use this

# Use these below for testing of runs without staging tarballs
REFD="/reference/inputs/hg38"
MAPD="/reference/inputs"
MER="GRCh38.d1.vd1.fa.150mer"

UQT="$UQD/tumor"
TUM_RES="$UQT/chr18.unique.seq $UQT/chr19.unique.seq $UQT/chr20.unique.seq"

UQN="$UQD/normal"
NORM_RES="$UQN/chr18.unique.seq $UQN/chr19.unique.seq $UQN/chr20.unique.seq"

CHRLIST=$(cat /BICSEQ2/testing/test_data/chromosomes.18-20.dat)
MER="GRCh38.d1.vd1.fa.150mer"

# for normal, do not stage .gz files
CMD="bash /BICSEQ2/src/run_norm.sh $@ -o $NORMD -R $REFD -M $MAPD -s normal -m $MER -c \"$CHRLIST\" $NORM_RES"
echo >&2 Running: $CMD
eval $CMD


# for tumor, stage reference and mapping files, and clean up after
# -noBedGraph mapping files were tested and are consistent with the
#   with-bedGraph results
# runA - MAP_GZ
# runB - MAP_GZ_B
CMD="bash /BICSEQ2/src/run_norm.sh $@ -o $NORMD -R $REF_GZ -F -M $MAP_GZ_B -s tumor -m $MER $TUM_RES"
echo >&2 Running: $CMD
eval $CMD



