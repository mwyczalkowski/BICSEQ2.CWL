# execute run_annotation step on katmai
GENE_BED="/reference/cached.annotation/gencode.v29.annotation.hg38.p12.bed"
OUTD="/results/annotation"

# Case-control
CNV="/results/segmentation-case-control/case_name.cnv"
CMD="bash /BICSEQ2/src/run_annotation.sh $@ -s case-control -G $GENE_BED -o $OUTD $CNV "
>&2 echo running $CMD
eval $CMD

# Case-only
CASE_ONLY_ARG="-C"  # this is important
CNV="/results/segmentation-case/case.cnv"
CMD="bash /BICSEQ2/src/run_annotation.sh $@ $CASE_ONLY_ARG -s case-only -G $GENE_BED -o $OUTD $CNV "
>&2 echo running $CMD
eval $CMD


