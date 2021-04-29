# Execute segmentation step 
#   1. for case only
#   2. using tumor/normal as case/control

CASE_LIST=" \
/results/norm/results/tumor.chr18.norm.bin \
/results/norm/results/tumor.chr19.norm.bin \
/results/norm/results/tumor.chr20.norm.bin"

CONTROL_LIST=" \
/results/norm/results/normal.chr18.norm.bin \
/results/norm/results/normal.chr19.norm.bin \
/results/norm/results/normal.chr20.norm.bin"

LAMBDA=3

OUTD="/results/segmentation-case"
CMD="bash /BICSEQ2/src/run_segmentation.sh $@ -l $LAMBDA -S \"$CASE_LIST\" -o $OUTD"
echo Running $CMD
eval $CMD

OUTD="/results/segmentation-case-control"
CMD="bash /BICSEQ2/src/run_segmentation.sh $@ -s case_name -l $LAMBDA -S \"$CASE_LIST\" -T \"$CONTROL_LIST\" -o $OUTD"

echo Running $CMD
eval $CMD
