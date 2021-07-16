12345

[BICseq2 CWL pipeline](https://github.com/mwyczalkowski/BICSEQ2.git), version 2.5

# Background

The BICSEQ2.CWL project is a workflow implementation of the [BIC-Seq2 software](http://compbio.med.harvard.edu/BIC-seq/)
This includes a docker image containing the software and a CWL workflow implementation.

The following versions of BICSeq tools are used:
  * NBICseq-norm_v0.2.4
  * NBICseq-seg_v0.7.2
  * samtools-0.1.7a_getUnique-0.1.3
  * GEM-binaries-Linux-x86_64-core_i3-20130406-045632

Additional details about processing and interpretation can be found in the [README.processing_description.md](README.processing_description.md) file

# Versions

Prior versions through v2.1 : https://github.com/ding-lab/BICSEQ2

v2.5 retains the same tool and database versions as previous versions, but
implements a new [CWL](https://www.commonwl.org/user_guide/index.html) workflow
to improve reliability and allow large scale deployments.

Current docker image: `mwyczalkowski/bicseq2:20210625`
Note that the dockerfile builds on top of image tagged: mwyczalkowski/bicseq2:201901

# Workflow overview


## Workflow options

* case-only vs. case-control
* Excess zeros
* 



