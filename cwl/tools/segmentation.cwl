class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: segmentation
baseCommand:
  - bash
  - /BICSEQ2/src/run_segmentation.sh
inputs:
  - id: case_list
    type: 'File[]'
    inputBinding:
      position: 0
      prefix: '-S'
      itemSeparator: ' '
    doc: normalized bin file of the case genome as obtained from BICseq2-norm
  - id: control_list
    type: 'File[]?'
    inputBinding:
      position: 0
      prefix: '-T'
      itemSeparator: ' '
  - id: CHR_LIST
    type: 'string[]?'
    inputBinding:
      position: 0
      prefix: '-c'
    doc: >-
      define chrom list, which will define CHR for each result.  List must be
      same length as CASE_LIST and CONTROL_LIST
  - 'sbg:toolDefaultValue': '3'
    id: lambda
    type: float
    inputBinding:
      position: 0
      prefix: '-l'
    doc: lambda arameter for NBICseq-norm.pl
  - id: XARGS
    type: string?
    inputBinding:
      position: 0
      prefix: '-X'
    doc: arguments to be passed directly to NBICseq-norm.pl
outputs:
  - id: PNG
    type: File?
    outputBinding:
      glob: segmentation/*.png
  - id: CNV
    type: File
    outputBinding:
      glob: segmentation/*.cnv
label: segmentation
requirements:
  - class: DockerRequirement
    dockerPull: 'mwyczalkowski/bicseq2:20210416'
  - class: ResourceRequirement
    ramMin: 8000
