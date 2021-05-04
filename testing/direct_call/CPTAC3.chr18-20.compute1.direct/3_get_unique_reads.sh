# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

#C3L-00004.WGS.N.hg38 :
NORMAL="/data/22a34772-76b0-4cab-af6f-43472bb74199/1561b97d-8c8f-4fe6-a244-06452760074d_gdc_realn.bam"
#C3L-00004.WGS.T.hg38 :
TUMOR="/data/d3c54309-50b1-4257-8e90-4536dd45efe1/82ccdf4e-4527-47ca-8151-7e1248f1da09_gdc_realn.bam"

OUTD_N="/results/unique_reads/normal"
OUTD_T="/results/unique_reads/tumor"
mkdir -p $OUTD_N
mkdir -p $OUTD_T

CMD="bash /BICSEQ2/src/get_unique.sh -c chr18 -O $OUTD_T $@ $TUMOR"
echo $CMD 
eval $CMD

CMD="bash /BICSEQ2/src/get_unique.sh -c chr19 -O $OUTD_T $@ $TUMOR"
echo $CMD 
eval $CMD

CMD="bash /BICSEQ2/src/get_unique.sh -c chr20 -O $OUTD_T $@ $TUMOR"
echo $CMD 
eval $CMD

# Normals
CMD="bash /BICSEQ2/src/get_unique.sh -c chr18 -O $OUTD_N $@ $NORMAL"
echo $CMD 
eval $CMD

CMD="bash /BICSEQ2/src/get_unique.sh -c chr19 -O $OUTD_N $@ $NORMAL"
echo $CMD 
eval $CMD

CMD="bash /BICSEQ2/src/get_unique.sh -c chr20 -O $OUTD_N $@ $NORMAL"
echo $CMD 
eval $CMD

