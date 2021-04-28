# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

NORMAL="/data/HCC1954.NORMAL.30x.compare.COST16011_region.bam"
TUMOR="/data/G15512.HCC1954.1.COST16011_region.bam"

OUTD="/results/unique_reads"
mkdir -p $OUTD

# Do all chrom at once.  Defaault output: 
# unique.seq if CHR is not specified, CHR.unique.seq if it is
# For normal, pass  name

NORMAL_OUT="/results/unique_reads/unique-normal.seq"
CMD="bash /BICSEQ2/src/get_unique.sh -O $OUTD $@ $TUMOR"
echo $CMD
eval $CMD
bash /BICSEQ2/src/get_unique.sh -o $NORMAL_OUT $@ $NORMAL

# Do chrom 8, 11 individually
CHR=8
NORMAL_OUT="/results/unique_reads/${CHR}.unique-normal.seq"
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -O $OUTD  $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $NORMAL_OUT $NORMAL

CHR=11
NORMAL_OUT="/results/unique_reads/${CHR}.unique-normal.seq"
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -O $OUTD  $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $NORMAL_OUT $NORMAL

