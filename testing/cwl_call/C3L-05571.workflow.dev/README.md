Testing complete workflow of BICseq2.cwl with case/control for UCEC case C3L-05571
(picked this one because it was processed relatively recently, see 
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/scripts/BICSEQ2/testing/docker_call/run_cases.UCEC.rerun.compute1/dat/UCEC_3.analysis_description.dat
)

Testing based closely on work here: /home/m.wyczalkowski/Projects/BICseq2/CWL.ch18-20.dev

     1  # Case_Name C3L-05571
     2  Disease UCEC
     3  Output_Path /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/outputs/run_cases.UCEC.rerun/C3L-05571/annotation/C3L-05571.gene_level.log2.seg
     4  File_Format TSV
     5  Tumor_Sample_Name   C3L-05571.WGS.T.hg38
     6  Tumor_BAM_UUID  0a1d1971-388c-472e-a6ac-c3608817ee7d
     7  Normal_Sample_Name  C3L-05571.WGS.N.hg38
     8  Normal_BAM_UUID 04fe5225-2758-4691-b709-934aa7656050
     9  Result_Type SEG

From the above,
tumor BAM =  /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data/0a1d1971-388c-472e-a6ac-c3608817ee7d/63c942b4-6dcf-4ed7-8c57-d9216fb8ac87_wgs_gdc_realn.bam
normal BAM = /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data/04fe5225-2758-4691-b709-934aa7656050/2154e8df-970e-44cf-a0d9-ee0a6cc3a8f6_wgs_gdc_realn.bam

also, here's the CNV result:
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/outputs/run_cases.UCEC.rerun/C3L-05571/segmentation/C3L-05571.cnv

--
run 1:
This run succeeded:

[2021-05-04 08:44:57,22] [info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.
{
  "outputs": {
    "bicseq2-cwl.case-control.cwl.CNV": {
      "format": null,
      "location": "/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/9f211b4f-87b9-4fab-a782-7186c07391d6/call-segmentation/execution/glob-6325c75b329988a6d0f698dd56fdc192/case.cnv",
      "size": 40202,
      "secondaryFiles": [],
      "contents": null,
      "checksum": null,
      "class": "File"
    },
    "bicseq2-cwl.case-control.cwl.annotated_cnv": {
      "format": null,
      "location": "/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/bicseq2-cwl.case-control.cwl/9f211b4f-87b9-4fab-a782-7186c07391d6/call-annotation/execution/glob-8d2a4c6350ac0f3eef6344d845feb79b/case.gene_level.log2.seg",
      "size": 1012872,
      "secondaryFiles": [],
      "contents": null,
      "checksum": null,
      "class": "File"
    }
  },
  "id": "9f211b4f-87b9-4fab-a782-7186c07391d6"
}

--

Doing another run exactly like the one above.  How much natural variability is there in these runs?

