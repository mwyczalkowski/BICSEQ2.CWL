class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: uniquereads
baseCommand:
  - bash
  - /BICSEQ2/src/get_unique.sh
inputs:
  - id: chr
    type: string
    inputBinding:
      position: 0
      prefix: '-c'
    doc: >-
      Genomic region, e.g., "chr1".  Default is to process all chromosomes at
      once.
  - id: BAM
    type: File
    inputBinding:
      position: 99
    label: Input BAM file
    secondaryFiles:
      - .bai
outputs:
  - id: seq
    type: File
    outputBinding:
      glob: '*unique.seq'
label: UniqueReads
requirements:
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'mwyczalkowski/bicseq2:202408'
