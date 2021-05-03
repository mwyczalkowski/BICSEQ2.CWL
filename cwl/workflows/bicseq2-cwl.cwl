class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl
label: BICseq2.cwl
inputs:
  - id: BAM
    type: File
  - id: REF
    type: File
  - id: MAP
    type: File
  - id: GENE_BED
    type: File
  - id: chr_list
    type: 'string[]'
  - id: MER
    type: string?
outputs:
  - id: annotated_cnv
    outputSource:
      annotation/annotated_cnv
    type: File
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
requirements:
  - class: ScatterFeatureRequirement
