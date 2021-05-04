Testing and development of BICseq2.CWL.

Here, focusing on testing of workflow for a few real chromosomes for CPTAC3 data.

Installation:

git clone --recurse-submodules https://github.com/mwyczalkowski/BICSEQ2.CWL.git 
-> not quite right

BAM: C3L-00004
C3L-00004.WGS.N.hg38 :
    /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data/22a34772-76b0-4cab-af6f-43472bb74199/1561b97d-8c8f-4fe6-a244-06452760074d_gdc_realn.bam
C3L-00004.WGS.T.hg38 :
    /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data/d3c54309-50b1-4257-8e90-4536dd45efe1/82ccdf4e-4527-47ca-8151-7e1248f1da09_gdc_realn.bam

docker mounting:
/data:/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data


# Existing datasets

Example directory for run:
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/scripts/BICSEQ2/testing/docker_call/run_cases.UCEC.rerun.compute1

Chromosome reference and mappability:
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/
    These were copied from katmai:
        /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/hg38 .
        /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer .
    Complete reference on storage1:
        /storage1/fs1/m.wyczalkowski/Active/Primary/Resources/References/GRCh38.d1.vd1/GRCh38.d1.vd1.fa

Gene annotation (gencode 29):
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation/gencode.v29.annotation.hg38.p12.bed
    Copied from 
        MGI:/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/cached.annotation/gencode.v29.annotation.hg38.p12.bed
    This was created with 
        MGI:/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/a_prep_gene_annotation.sh



# This has the per-chromosome reference
REFD=/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/hg38/
MAPD=/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs
MER=GRCh38.d1.vd1.fa.150mer

Compressed references:
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/hg38/GRCh38.d1.vd1-per_chrom_fa.tar.gz
and GRCh38.d1.vd1.fa.150mer.tar.gz is in .. directory

Question: is GRCh38.d1.vd1.fa.150mer.bedGraph required?  It is very large, maybe avoid it in tarball if not necessary
=> runA is WITH bedgraph
=> runB is without
==> there are differences, but they appear to be numerical in nature.  No error conditions, all completed runs.
    Conclusion: it is OK to use the smaller without-bedGraph file GRCh38.d1.vd1.fa.150mer-noBedGraph.tar.gz

With and without bedGraph:
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/GRCh38.d1.vd1.fa.150mer.tar.gz
/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/GRCh38.d1.vd1.fa.150mer-noBedGraph.tar.gz

BSD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/CPTAC3.compute1/BICSEQ2.CWL"
CHRLIST="$BSD/testing/test_data/chromosomes.18-20.dat"

# maps to /results
OUTD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/CPTAC3.compute1/results-tmp"

