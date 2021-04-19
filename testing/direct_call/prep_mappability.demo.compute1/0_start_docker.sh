
DATAD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/demo_data"
SYSTEM="compute1"

# changing directories so entire project directory is mapped by default
cd ../../..

source docker/docker_image.sh

bash src/WUDocker/start_docker.sh $@ -M $SYSTEM -I $IMAGE $DATAD:/data 


