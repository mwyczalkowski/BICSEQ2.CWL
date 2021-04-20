Branch cwl is a development branch for packaging bicseq2 project into CWL wrapper.
Consider this v2.5 of the pipeline

* Removing code associated with managing multiple case and tracking runs
* Dockerfile builds on prior latest version, mwyczalkowski/bicseq2:201901
  Image tagged 201901 is no longer able to be rebuilt because server to get
  code is down, but we wish to retain underlying software versions

