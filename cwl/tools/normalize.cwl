class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: normalize
baseCommand:
  - bash
  - /BICSEQ2/src/run_norm.sh
inputs:
  - id: chrlist
    type: 'string[]?'
    inputBinding:
      position: 0
      prefix: '-c'
      itemSeparator: ' '
  - id: REF
    type: File
    inputBinding:
      position: 0
      prefix: '-R'
    label: reference.tar.gz
    doc: compressed TAR with per-chromosome reference files named CHR.fa
  - id: MAP
    type: File
    inputBinding:
      position: 0
      prefix: '-M'
    label: mappability.tar.gz
    doc: compressed file containing mappability files named MER.CHR.txt
  - id: finalize
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-F'
    doc: >-
      Remove mappability and reference directories.  Recommended for production
      pipelines
  - 'sbg:toolDefaultValue': '150'
    id: READ_LENGTH
    type: int?
    inputBinding:
      position: 0
      prefix: '-r'
    label: READ_LENGTH
  - 'sbg:toolDefaultValue': '350'
    id: FRAG_SIZE
    type: int?
    inputBinding:
      position: 0
      prefix: '-f'
  - 'sbg:toolDefaultValue': '100'
    id: BIN_SIZE
    type: int?
    inputBinding:
      position: 0
      prefix: '-b'
  - 'sbg:toolDefaultValue': GRCh38.d1.vd1.150mer
    id: MER
    type: string?
    inputBinding:
      position: 0
      prefix: '-m'
  - id: SEQ
    type: 'File[]'
    inputBinding:
      position: 99
    doc: List of results of get_unique.sh output
  - id: XARGS
    type: string?
    inputBinding:
      position: 0
      prefix: '-X'
  - id: X0_POLICY
    type: string?
    inputBinding:
      position: 0
      prefix: '-x'
    label: excess zero policy
    doc: >-
      how to test for "excess zeros" error condition: allowed values = ignore,
      warning (default), error
outputs:
  - id: normbin
    doc: 'Normalized data, per chrom'
    type: 'File[]'
    outputBinding:
      glob: norm/results/*.norm.bin
  - id: excess_zero_flags
    doc: >-
      Flag indicating whether excess zero error condition was observed for any
      chromosome
    type: 'File[]?'
    outputBinding:
      glob: norm/results/excess_zeros/*.excess_zeros_observed.dat
label: normalize
requirements:
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'mwyczalkowski/bicseq2:20210527'
