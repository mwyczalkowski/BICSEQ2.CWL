# CPTAC3 Somatic CNV v2.5 processing description

The CPTAC3 Somatic CNV v2.5 data release is based on the 
[BICseq2 CWL v2.5 pipeline](https://github.com/mwyczalkowski/BICSEQ2.git).
This workflow includes the following tools:
  * NBICseq-norm_v0.2.4
  * NBICseq-seg_v0.7.2
  * samtools-0.1.7a_getUnique-0.1.3
  * GEM-binaries-Linux-x86_64-core_i3-20130406-045632

For CPTAC3, the following additional reference and database details apply:
* Gene annotation based on GENCODE release 29
* Read length assumed 150

## Versions

v2.5 - CWL implementation to improve reliability and performance. The underlying libraries and software versions are unchanged from v2.1
    and should be directly comparable
v2.1 - TODO 

# Processing description
We used [BIC-Seq2](http://compbio.med.harvard.edu/BIC-seq/) (Xi et al., 2016),
a read-depth-based CNV calling algorithm to detect somatic copy number
variation (CNVs) from the WGS data of a tumor with a normal as control.
Briefly, BIC-seq2 divides genomic regions into disjoint bins and counts
uniquely aligned reads in each bin. Then, it combines neighboring bins into
genomic segments with similar copy numbers iteratively based on Bayesian
Information Criteria (BIC), a statistical criterion measuring both the fitness
and complexity of a statistical model. 

We used paired-sample CNV calling that takes a pair of tumor and normal samples
as input and detects genomic regions with different copy numbers between the
two samples. We used a bin size of ∼100 bp and a lambda of 3 (a smoothing
parameter for CNV segmentation). We recommend to call segments as copy gain or
loss when their log2 copy ratios were larger than 0.2 or smaller than −0.2,
respectively (according to the BIC-seq publication).

## Input data

WGS tumor and normal 

## Output

* CNV file.  Output of Segmentation step.  Per-segment log2(copy ratio)
* SEG file.  Per-gene log2(copy ratio)

# Contact: 

* Yige Wu <yigewu@wustl.edu>
* Matt Wyczalkowski <m.wyczalkowski@wustl.edu>

