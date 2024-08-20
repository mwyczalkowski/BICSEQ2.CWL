class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl_case
label: BICseq2.cwl-case
inputs:
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
  - id: BAM
    type: File
    secondaryFiles:
      - .bai
  - id: X0_POLICY
    type: string?
    doc: >-
      Defines whether workflow error results because of excess zero error during
      normalization.  Allowed values: none, warning (default), error
outputs:
  - id: annotated_cnv
    outputSource:
      annotation/annotated_cnv
    type: File
  - id: excess_zero_flag
    outputSource:
      normalize/excess_zero_flag
    type: 'File[]?'
  - id: CNV
    outputSource:
      segmentation/CNV
    type: File
steps:
  - id: uniquereads
    in:
      - id: chr
        source: chr_list
      - id: BAM
        source: stage_bam/output
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
      - id: X0_POLICY
        default: warning
        source: X0_POLICY
      - id: x0_exclude
        default:
          - chrY
    out:
      - id: normbin
      - id: excess_zero_flag
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
      - id: case_only
        default: true
      - id: CNV
        source: segmentation/CNV
    out:
      - id: annotated_cnv
    run: ../tools/annotation.cwl
    label: annotation
  - id: stage_bam
    in:
      - id: BAM
        source: BAM
    out:
      - id: output
    run: ../tools/stage_bam.cwl
    label: stage_bam
requirements:
  - class: ScatterFeatureRequirement
