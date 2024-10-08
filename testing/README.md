# BICSEQ2 testing

Prior work: mutect-tool https://github.com/mwyczalkowski/mutect-tool/tree/master/testing

Testing takes place at 3 levels:
* `direct_call`
  * executes individual steps and entire workflow
  * is run from within docker container, e.g., `start_docker.sh bash` must be called first
* `docker_call`
  * executes individual steps and/or entire workflow
  * Started with something like `start_docker.sh workflow_step.sh ARGS`
* `cwl_call`
  * executes individual tools or entire workflow
  * May consist of calls to a monolithic CWL step or modular CWL steps
  * Modern (circa 2024) testing of CWL on compute1 using cromwell here:
        testing/cwl_call/DLBCL20-test
    * Others are old workflows for cromwell, rabix, and cwltool

Current testing takes place on three systems: shiso (macbook pro), katmai (ubuntu linux server),
and MGI (McDonnell Genome Institute cluster).  

Datasets we use currently:
* Demo dataset - small tumor / normal BAM file pair and reference, from distribution of Manta
  * https://github.com/ding-lab/SomaticSV/tree/master/testing/demo_data
  * storage1:/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/BICseq2/demo_data
  * tumor (G15512.HCC1954.1.COST16011_region.bam) and normal (HCC1954.NORMAL.30x.compare.COST16011_region.bam)
    have thousands and hundreds of reads, respectively, on chromosomes 8 and 11

* C3L-00008 chr18-20 - several chromosomes of specific dataset.  Hosted on katmai and MGI. hg38
* C3L-00008 - complete dataset from CPTAC3 project. hg38
  
We provide examples of code ("test projects") to execute particular aspects of BICSEQ2 workflow.
Currently not testing for "correctness" of results in automated fashion, but rather making sure 
it runs and eyeballing results. Projects also serve as examples of working workflows for future
development.

Project consists of one project config file and one or more scripts
* each script executes single step of workflow
* project config file common to all scripts in project
* Scripts will typically pass project config filename and additional arguments to executables in /src 
  directory
    * Arguments are generally things that may be iterated over; typically, per-sample details like sample name and BAM file
* Project names are of format STEP.DATASET.SYSTEM

