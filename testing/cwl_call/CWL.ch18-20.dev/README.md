Testing CWL tools and workflows on chrom 18-20
Testing based on that developed in ../demo_data.compute1/CWL.demo_data.dev/
  and also direct runs in ../CPTAC3.chr18-20.compute1.direct

Output of past unique_reads for tumor:
/storage1/fs1/m.wyczalkowski/Active/Analysis.dev/BICseq2.cwl/results-tmp/unique_reads/tumor/chr18.unique.seq
/storage1/fs1/m.wyczalkowski/Active/Analysis.dev/BICseq2.cwl/results-tmp/unique_reads/tumor/chr19.unique.seq
/storage1/fs1/m.wyczalkowski/Active/Analysis.dev/BICseq2.cwl/results-tmp/unique_reads/tumor/chr20.unique.seq

# Normalize step

Does not return anything:

[2021-05-03 04:32:27,78] [info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.
{
  "outputs": {
    "normalize.cwl.parameter_estimate": [],
    "normalize.cwl.PDF": [],
    "normalize.cwl.normbin": []
  },
  "id": "78665938-cb98-40df-9535-03d75361135c"
}

/storage1/fs1/m.wyczalkowski/Active/cromwell-data/cromwell-workdir/cromwell-executions/normalize.cwl/78665938-cb98-40df-9535-03d75361135c/call-normalize.cwl/executio
