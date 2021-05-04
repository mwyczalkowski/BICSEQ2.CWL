CWL="BICSEQ2.CWL/cwl/tools/normalize.cwl"

YAML="yaml/normalize/normalize.tumor.yaml"
bash run_cromwell_compute1.sh $CWL $YAML
