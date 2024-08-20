Testing initial run of DLBCL data, case-only mode
Details similar to those described here
    /home/m.wyczalkowski/Projects/CromwellRunner/SomaticSV/26.DLBCL_TumorOnly20/README.project.md

# Error
First run ends in an error in annotation step.  See,
/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/execution/stderr

UniqueReads OK
Segmentation OK

[ Thu Aug 1 01:10:08 UTC 2024 ] Running: sed '1d' /cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/2077039735/case.cnv | cut -f1,2,3,7 | /usr/bin/bedtools intersect -loj -a /cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/-1087228521/gencode.v29.annotation.hg38.p12.bed -b - | /usr/bin/python -S /BICSEQ2/src/gene_segment_overlap.py > ./annotation/case.gene_level.log2.seg
Traceback (most recent call last):
  File "/BICSEQ2/src/gene_segment_overlap.py", line 23, in <module>
    gene_dict[gene][3] += int(line[6])-int(line[5])
TypeError: cannot concatenate 'str' and 'int' objects
[ Thu Aug 1 01:10:08 UTC 2024 ] run_annotation.sh Fatal ERROR. Exiting.

Path to code:
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticCNV/16.DLBCL_tumorOnly-20/Workflow/BICSEQ2.CWL/src/gene_segment_overlap.py

path to case.cnv:
/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/2077039735/case.cnv

     1	chrom	chr1
     2	start	876453
     3	end	940278
     4	binNum	537
     5	observed	55716
     6	expected	55875.2
     7	log2.copyRatio	-0.00514777331425179

## What was this file like before?  
Looking at typical case/control version of this file, based on information here,
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticCNV/15.HCMI_2/dat/analysis_summary.stored.dat
Typical example from tumor / normal is,
    /storage1/fs1/dinglab/Active/Projects/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/d61fdc90-0de9-4cf2-ab2a-11365d0cc948/call-segmentation/execution/glob-6325c75b329988a6d0f698dd56fdc192/case.cnv
     1	chrom	chr1
     2	start	143241934
     3	end	143409871
     4	binNum	49
     5	tumor	2435
     6	tumor_expect	1974.828
     7	normal	658
     8	normal_expect	948.239
     9	log2.copyRatio	0.831412799232362
    10	log2.TumorExpectRatio	0.341594667089708


# Use the Case-only flag
Annotation step has the following arguments
```
bash run_annotation.sh [options] CNV
 -C: process data for case-only segmentation mode.  Default is case-control.
```
and this is turned with case_only argument for annoation CWL tool

But this is already called, and that step is run with the following arguments, (from execution/script)

bash /BICSEQ2/src/run_annotation.sh -G <BED> -C <case.cnv>'

-> the -C flag is called

The command that was run, from stderr,

[ Thu Aug 1 01:10:08 UTC 2024 ] Running: sed '1d' /cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/2077039735/case.cnv | cut -f1,2,3,7 | /usr/bin/bedtools intersect -loj -a /cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/-1087228521/gencode.v29.annotation.hg38.p12.bed -b - | /usr/bin/python -S /BICSEQ2/src/gene_segment_overlap.py > ./annotation/case.gene_level.log2.seg

with the `cut -f1,2,3,7` being consistent with the -C flag called.

BED="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation/gencode.v29.annotation.hg38.p12.bed"
chr1    65418   71585   OR4F5
chr1    450702  451697  OR4F29
chr1    685678  686673  OR4F16
chr1    923927  944581  SAMD11
chr1    944203  959309  NOC2L


Run on the case-only samples, output of the bedtools intersect is,
chr1	65418	71585	OR4F5	.	-1	-1	.
chr1	450702	451697	OR4F29	.	-1	-1	.
chr1	685678	686673	OR4F16	.	-1	-1	.
chr1	923927	944581	SAMD11	chr1	940279	940378	4.92855015601956
chr1	923927	944581	SAMD11	chr1	940379	967295	-0.0412047419001536
chr1	923927	944581	SAMD11	chr1	876453	940278	-0.00514777331425179
chr1	944203	959309	NOC2L	chr1	940379	967295	-0.0412047419001536
chr1	960586	965715	KLHL17	chr1	940379	967295	-0.0412047419001536
chr1	966496	975865	PLEKHN1	chr1	967296	967395	1.70923387372529

Whereas run on case/control samples (with cut -f 1,2,3,9) it is,
chr1	65418	71585	OR4F5	chr1	10345	10694266	-0.0405308654817349
chr1	450702	451697	OR4F29	chr1	10345	10694266	-0.0405308654817349
chr1	685678	686673	OR4F16	chr1	10345	10694266	-0.0405308654817349
chr1	923927	944581	SAMD11	chr1	10345	10694266	-0.0405308654817349
chr1	944203	959309	NOC2L	chr1	10345	10694266	-0.0405308654817349

Recall, for gene_segment_overlap.py, documentation is,
'''dictionary to store for each gene, (0) chromosome, (1) gene start, (2) gene end, (3) bps of CNV segments overlapping this gene, (4) the sum of (length of CNV segment)\*(log2(copy ratio)) of all the CNV segments overlapping this gene (usually just 1) '''
'''for each line of the input, the columns represent (0) chromosome, (1) gene start, (2) gene end, (3) gene symbol, (4) chromosome, (5) CNV start, (6) CNV end, (7) CNV log2(copy ratio).'''

The issue may be associated with the fact that line 1 has '.' as chromosome, which makes this happen,
          gene_dict[gene] = [line[0], line[1], line[2], "NA", "NA"]
but then later
          gene_dict[gene][3] += int(line[6])-int(line[5])

## Understanding bedtools intersect

https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html

-loj: Perform a “left outer join”. That is, for each feature in A report each overlap with B. If no overlaps are found, report a NULL feature for B.

# Solution

Speculate that issue is caused by this line being run
    gene_dict[gene] = [line[0], line[1], line[2], "NA", "NA"]
and then this
    gene_dict[gene][3] += int(line[6])-int(line[5]) 

The solution in this case would seem to be run 
    gene_dict[gene][3] = int(line[6])-int(line[5]) 
and we wrap the += call in a try and to the = call if it fails.

For testing, we restart with the output of the above run, 
CNV=/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-only.cwl/ea188589-ee4e-4bdf-bef2-c26961a830d6/call-annotation/inputs/2077039735/case.cnv
BED=/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation/gencode.v29.annotation.hg38.p12.bed

Success!
[2024-08-03 00:54:01,69] [info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.
{
  "outputs": {
    "bicseq2-cwl.case-only.cwl.excess_zero_flag": null,
    "bicseq2-cwl.case-only.cwl.annotated_cnv": {
      "format": null,
      "location": "/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-only.cwl/d7c33970-3273-4864-b47c-6986bf88aebd/call-annotation/execution/glob-8d2a4c6350ac0f3eef6344d845feb79b/case.gene_level.log2.seg",
      "size": 1010356,
      "secondaryFiles": [],
      "contents": null,
      "checksum": null,
      "class": "File"
    }
  },
  "id": "d7c33970-3273-4864-b47c-6986bf88aebd"
}

## Confirming
Running 1_run_cromwell-tumor_only_workflow.sh,
```
Start:
[2024-08-05 17:34:56,67] [warn] DispatchedConfigAsyncJobExecutionActor [e5202230stage_bam:NA:1]: Unrecognized runtime attribute keys: memoryMax, memoryMin
...
[2024-08-05 19:35:13,42] [info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.
{
  "outputs": {
    "bicseq2-cwl.case-only.cwl.annotated_cnv": {
      "format": null,
      "location": "/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-only.cwl/e5202230-9691-4d8c-8038-c72a2fec5c61/call-annotation/execution/glob-8d2a4c6350ac0f3eef6344d845feb79b/case.gene_level.log2.seg",
      "size": 1010223,
      "secondaryFiles": [],
      "contents": null,
      "checksum": null,
      "class": "File"
    },
    "bicseq2-cwl.case-only.cwl.excess_zero_flag": null
  },
  "id": "e5202230-9691-4d8c-8038-c72a2fec5c61"
}
```

Note, only the .seg file is output.  Should also have CNV file output like tumor/normal.  

-> Somatic CNV takes about 2 hours to run

And rerunning,

3_launch_workflow.sh

-> has this succeeded?  seems like it has not.
