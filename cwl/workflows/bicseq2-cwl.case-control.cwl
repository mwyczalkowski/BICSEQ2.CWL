class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl_case_control
label: BICseq2.cwl-case_control
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
  - id: normal_BAM
    type: File
    secondaryFiles:
      - .bai
  - id: tumor_BAM
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
  - id: CNV
    outputSource:
      segmentation/CNV
    type: File
  - id: excess_zero_flag_tumor 
    outputSource:
      normalize_tumor/excess_zero_flag
    type: File?
  - id: excess_zero_flag_normal
    outputSource:
      normalize_normal/excess_zero_flag
    type: File?
steps:
  - id: uniquereads_normal
    in:
      - id: chr
        source: chr_list
      - id: BAM
        source: stage_bam_normal/output
    out:
      - id: seq
    run: ../tools/uniquereads.cwl
    label: UniqueReads_normal
    scatter:
      - chr
    scatterMethod: dotproduct
  - id: normalize_normal
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
          - uniquereads_normal/seq
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
    label: normalize_normal
  - id: segmentation
    in:
      - id: case_list
        source:
          - normalize_tumor/normbin
      - id: control_list
        source:
          - normalize_normal/normbin
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
        default: false
      - id: CNV
        source: segmentation/CNV
    out:
      - id: annotated_cnv
    run: ../tools/annotation.cwl
    label: annotation
  - id: stage_bam_normal
    in:
      - id: BAM
        source: normal_BAM
    out:
      - id: output
    run: ../tools/stage_bam.cwl
    label: stage_bam_normal
  - id: stage_bam_tumor
    in:
      - id: BAM
        source: tumor_BAM
    out:
      - id: output
    run: ../tools/stage_bam.cwl
    label: stage_bam_tumor
  - id: uniquereads_tumor
    in:
      - id: chr
        source: chr_list
      - id: BAM
        source: stage_bam_tumor/output
    out:
      - id: seq
    run: ../tools/uniquereads.cwl
    label: UniqueReads_tumor
    scatter:
      - chr
    scatterMethod: dotproduct
  - id: normalize_tumor
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
          - uniquereads_normal/seq
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
    label: normalize_tumor
requirements:
  - class: ScatterFeatureRequirement
