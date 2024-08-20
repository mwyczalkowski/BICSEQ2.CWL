# Running demo with bsub submission rather than an interactive terminal
### Cromwell

source /opt/ibm/lsfsuite/lsf/conf/lsf.conf

CWL="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticCNV/16.DLBCL_tumorOnly-20/Workflow/BICSEQ2.CWL/cwl/workflows/bicseq2-cwl.case-only.cwl"

CONFIG="dat/cromwell-config-db.dat"
YAML="dat/DLBCL20-test.yaml"

JAVA="/opt/java/openjdk/bin/java"
CROMWELL="/app/cromwell-78-38cd360.jar"

if [ ! -e $CONFIG ]; then
	>&2 echo ERROR: configuration file $CONFIG does not exist
	>&2 echo Please create it from template
	exit 1
fi

CMD="$JAVA -Dconfig.file=$CONFIG -jar $CROMWELL run -t cwl -i $YAML $CWL"

### Docker
IMAGE="mwyczalkowski/cromwell-runner:v78"

PWD=$(pwd)
CWL_ROOT_H=$PWD/../../..

VOLUME_MAPPING=" \
/storage1/fs1/m.wyczalkowski/Active \
/storage1/fs1/dinglab/Active \
/scratch1/fs1/dinglab
"

START_DOCKER="/home/m.wyczalkowski/bin/WUDocker/start_docker.sh"

# Based on /home/m.wyczalkowski/Projects/GDAN/import/24.ALCHEMIST_1205/50_make_BamMap-wide.sh
#ARGS="-l"
# -l - send output to stdout
# -r - remap paths
ARGS="-q dinglab -A"
DOCKER_CMD="bash $START_DOCKER -M compute1 -I $IMAGE $ARGS -c \"$CMD\" $VOLUME_MAPPING"
# DOCKER_CMD="bash ../../../docker/WUDocker/start_docker.sh $ARG -A -r -I $IMAGE -M compute1 $VOLUME_MAPPING"

>&2 echo Running: $DOCKER_CMD
eval $DOCKER_CMD


rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

