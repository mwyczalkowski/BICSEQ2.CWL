class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl
label: BICseq2.cwl
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: BAM
    type: File
    'sbg:x': 0
    'sbg:y': 321
  - id: REF
    type: File
    'sbg:x': 0
    'sbg:y': 0
  - id: MAP
    type: File
    'sbg:x': 147.71875
    'sbg:y': 267.5
  - id: GENE_BED
    type: File
    'sbg:x': 0
    'sbg:y': 107
  - id: chr_list
    type: 'string[]'
    'sbg:x': 0
    'sbg:y': 214
  - id: MER
    type: string?
    'sbg:x': 147.71875
    'sbg:y': 160.5
outputs:
  - id: annotated_cnv
    outputSource:
      - annotation/annotated_cnv
    type: File
    'sbg:x': 1021.7628784179688
    'sbg:y': 160.5
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
    'sbg:x': 147.71875
    'sbg:y': 46.5
  - id: normalize
    in:
      - id: REF
        source: REF
      - id: MAP
        source: MAP
      - id: finalize
        default: true
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
    'sbg:x': 343.8077392578125
    'sbg:y': 139.5
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
    'sbg:x': 601.6317749023438
    'sbg:y': 153.5
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
    'sbg:x': 776.8926391601562
    'sbg:y': 153.5
requirements:
  - class: ScatterFeatureRequirement
