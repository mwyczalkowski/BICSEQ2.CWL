class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl
label: BICseq2.cwl
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: BAM
    type: File
    'sbg:x': -677.6011352539062
    'sbg:y': -125
  - id: REF
    type: File
    'sbg:x': -657
    'sbg:y': 78
  - id: MAP
    type: File
    'sbg:x': -397.60113525390625
    'sbg:y': 258
  - id: GENE_BED
    type: File
    'sbg:x': 139.39886474609375
    'sbg:y': -224
  - id: chr_list
    type: 'string[]'
    'sbg:x': -799.078125
    'sbg:y': -323.5
  - id: MER
    type: string?
    'sbg:x': -623
    'sbg:y': 236
outputs:
  - id: PNG
    outputSource:
      - segmentation/PNG
    type: File?
    'sbg:x': 189
    'sbg:y': -382
  - id: annotated_cnv
    outputSource:
      - annotation/annotated_cnv
    type: File
    'sbg:x': 356.39886474609375
    'sbg:y': -72
steps:
  - id: uniquereads
    in:
      - id: chr
        source: chr_list
      - id: BAM
        source: BAM
    out:
      - id: seq
    run: ../tools/uniquereads.cwl
    label: UniqueReads
    scatter:
      - chr
    scatterMethod: dotproduct
    'sbg:x': -444
    'sbg:y': -184
  - id: normalize
    in:
      - id: REF
        source: REF
      - id: MAP
        source: MAP
      - id: READ_LENGTH
        default: 150
      - id: FRAG_SIZE
        default: 350
      - id: BIN_SIZE
        default: 100
      - id: MER
        source: MER
      - id: SEQ
        source:
          - uniquereads/seq
    out:
      - id: normbin
    run: ../tools/normalize.cwl
    label: normalize
    'sbg:x': -235.60113525390625
    'sbg:y': -74
  - id: segmentation
    in:
      - id: case_list
        source:
          - normalize/normbin
      - id: lambda
        default: 3
    out:
      - id: PNG
      - id: CNV
    run: ../tools/segmentation.cwl
    label: segmentation
    'sbg:x': -33.60113525390625
    'sbg:y': -66
  - id: annotation
    in:
      - id: GENE_BED
        source: GENE_BED
      - id: CNV
        source: segmentation/CNV
    out:
      - id: annotated_cnv
    run: ../tools/annotation.cwl
    label: annotation
    'sbg:x': 175.39886474609375
    'sbg:y': -63
requirements:
  - class: ScatterFeatureRequirement
