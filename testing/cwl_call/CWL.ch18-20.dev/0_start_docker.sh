IMAGE="mwyczalkowski/cromwell-runner"

# mapping from standard SomaticSV startup:/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticSV/09.LUAD_GBM_Confirmatory/00_start_docker.sh
HOME_MAP="/storage1/fs1/home1/Active/home/m.wyczalkowski:/home/m.wyczalkowski"
VOLUME_MAPPING=" \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
$HOME_MAP \
/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data"


bash BICSEQ2.CWL/src/WUDocker/start_docker.sh -I $IMAGE -M compute1 $VOLUME_MAPPING




