
DATAD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/demo_data.compute1/demo_data/"
OUTD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/demo_data.compute1/tmp-results/"

# BICseq2.CWL installation directory
BSD="/home/m.wyczalkowski/Projects/BICseq2/demo_data.compute1/BICSeq2.dev.demo_data"
SYSTEM="compute1"
mkdir -p $OUTD

# changing directories so entire project directory is mapped by default
cd ../../..

source docker/docker_image.sh
bash src/WUDocker/start_docker.sh $@ -M $SYSTEM -I $IMAGE $DATAD:/data $OUTD:/results $BSD:/BICSEQ2
