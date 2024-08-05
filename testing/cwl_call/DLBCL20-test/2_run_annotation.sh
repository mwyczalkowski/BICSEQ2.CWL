# Be sure this is running within cromwell-compatible docker on compute1 with,
# 0_start_docker-compute1_cromwell.sh

source /opt/ibm/lsfsuite/lsf/conf/lsf.conf

CWL="../../../cwl/tools/annotation.cwl"

CONFIG="dat/cromwell-config-db.dat"
YAML="dat/annotation.yaml"

JAVA="/opt/java/openjdk/bin/java"
CROMWELL="/app/cromwell-78-38cd360.jar"

if [ ! -e $CONFIG ]; then
	>&2 echo ERROR: configuration file $CONFIG does not exist
	>&2 echo Please create it from template
	exit 1
fi

CMD="$JAVA -Dconfig.file=$CONFIG -jar $CROMWELL run -t cwl -i $YAML $CWL"

echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

