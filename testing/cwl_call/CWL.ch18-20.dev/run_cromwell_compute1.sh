# Be sure this is running within cromwell-compatible docker 

# Usage: run_cromwell_compute1.sh $CWL $YAML

CWL=$1
YAML=$2

if [ ! -e $CWL ]; then
    >&2 echo ERROR: CWL $CWL not found
    exit 1
fi
if [ ! -e $YAML ]; then
    >&2 echo ERROR: YAML $YAML not found
    exit 1
fi

>&2 echo Starting cromwell
>&2 echo CWL = $CWL
>&2 echo YAML = $YAML

source /opt/ibm/lsfsuite/lsf/conf/lsf.conf
CONFIG="cromwell-config-db.compute1.dat"
CROMWELL="/usr/local/cromwell/cromwell-47.jar"
ARGS="-Xmx10g"
DB_ARGS="-Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/m.wyczalkowski/lib/cromwell-jar/cromwell.truststore"

# from https://confluence.ris.wustl.edu/pages/viewpage.action?spaceKey=CI&title=Cromwell#Cromwell-ConnectingtotheDatabase
# Connecting to the database section
# Note also database section in config fil
CMD="/usr/bin/java $ARGS -Dconfig.file=$CONFIG $DB_ARGS -jar $CROMWELL run -t cwl -i $YAML $CWL"

echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


