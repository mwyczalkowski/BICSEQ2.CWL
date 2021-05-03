class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: annotation
baseCommand:
  - bash
  - /BICSEQ2/src/run_annotation.sh
inputs:
  - id: GENE_BED
    type: File
    inputBinding:
      position: 0
      prefix: '-G'
    doc: >-
      gene annotation bed file, created by prep_gene_annotation step (specific
      to ensembl build)
  - id: case_only
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-C'
    doc: Data is in case-only format
  - id: CNV
    type: File
    inputBinding:
      position: 99
    doc: file output by run_segmentation step
outputs:
  - id: annotated_cnv
    doc: Gene level CNV file
    type: File
    outputBinding:
      glob: annotation/*.gene_level.log2.seg
label: annotation
requirements:
  - class: DockerRequirement
    dockerPull: 'mwyczalkowski/bicseq2:20210416'
