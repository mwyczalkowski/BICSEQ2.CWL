IMAGE="mwyczalkowski/cromwell-runner:v78"

PWD=$(pwd)
CWL_ROOT_H=$PWD/../../..

VOLUME_MAPPING=" \
$CWL_ROOT_H \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
/scratch1/fs1/dinglab
"

ARG="-q dinglab-interactive"

WUDOCKER="/home/m.wyczalkowski/bin/WUDocker/start_docker.sh"

CMD="bash $WUDOCKER $ARG -A -r -I $IMAGE -M compute1 $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD
