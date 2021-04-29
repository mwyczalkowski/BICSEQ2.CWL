# Run make_mappability.sh from within docker.  Typically, start docker first with 0_start_docker.sh

#Before running Demo data, be sure to uncompress reference:
#```
#cd demo_data
#tar -xvjf Homo_sapiens_assembly19.COST16011_region.fa.tar.bz2
#```

REF="/reference2/GRCh38.d1.vd1.fa"
OUTD="/results/mappability"

# Reference base name
CHRLIST="/BICSEQ2/testing/test_data/chromosomes.dat"

# process test data
bash /BICSEQ2/src/prep_mappability.sh $REF $OUTD $CHRLIST

# bash make_mappability.sh /data/Reference/GRCh38.d1.vd1.fa /Reference/GRCh38.d1.vd1.fa/mappability
