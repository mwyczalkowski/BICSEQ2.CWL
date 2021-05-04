
DATAD="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data"
OUTD="/storage1/fs1/m.wyczalkowski/Active/Analysis.dev/BICseq2.cwl/results-tmp"

#REFD="/storage1/fs1/m.wyczalkowski/Active/Primary/Resources/References/GRCh38.d1.vd1/"  # location of original GRCh38.d1.vd1

#INPUTD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs"  # this has both per-chrom reference and mapping
INPUTD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets"

# BICseq2.CWL installation directory
BSD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/CPTAC3.chr18-20.compute1/BICSEQ2.CWL"

SYSTEM="compute1"
mkdir -p $OUTD

source $BSD/docker/docker_image.sh
bash $BSD/src/WUDocker/start_docker.sh $@ -M $SYSTEM -I $IMAGE $DATAD:/data $OUTD:/results $BSD:/BICSEQ2 $INPUTD:/reference 
