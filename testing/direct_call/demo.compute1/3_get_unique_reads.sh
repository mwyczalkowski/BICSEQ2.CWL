# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

NORMAL="/data/HCC1954.NORMAL.30x.compare.COST16011_region.bam"
TUMOR="/data/G15512.HCC1954.1.COST16011_region.bam"

NORMAL_OUT="/results/unique_reads/unique-normal.seq"
TUMOR_OUT="/results/unique_reads/unique-tumor.seq"

mkdir -p /results/unique_reads

# Do all chrom at once
NORMAL_OUT="/results/unique_reads/unique-normal.seq"
TUMOR_OUT="/results/unique_reads/unique-tumor.seq"
bash /BICSEQ2/src/get_unique.sh $@ -o $NORMAL_OUT $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ -o $TUMOR_OUT $NORMAL

# Do chrom 8, 11 individually
CHR=8
NORMAL_OUT="/results/unique_reads/unique-normal.${CHR}.seq"
TUMOR_OUT="/results/unique_reads/unique-tumor.${CHR}.seq"
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $NORMAL_OUT $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $TUMOR_OUT $NORMAL

CHR=11
NORMAL_OUT="/results/unique_reads/unique-normal.${CHR}.seq"
TUMOR_OUT="/results/unique_reads/unique-tumor.${CHR}.seq"
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $NORMAL_OUT $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ -c $CHR -o $TUMOR_OUT $NORMAL

