class: Workflow
cwlVersion: v1.0
id: bicseq2_cwl_case_control
label: BICseq2.cwl-case_control
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: REF
    type: File
    'sbg:x': 0
    'sbg:y': 121
  - id: MAP
    type: File
    'sbg:x': 300.875
    'sbg:y': 342
  - id: GENE_BED
    type: File
    'sbg:x': 0
    'sbg:y': 335
  - id: chr_list
    type: 'string[]'
    'sbg:x': 149.015625
    'sbg:y': 281.5
  - id: MER
    type: string?
    'sbg:x': 300.875
    'sbg:y': 235
  - id: normal_BAM
    type: File
    secondaryFiles:
      - .bai
    'sbg:x': 0
    'sbg:y': 228
  - id: tumor_BAM
    type: File
    secondaryFiles:
      - .bai
    'sbg:x': 0
    'sbg:y': 14
outputs:
  - id: annotated_cnv
    outputSource:
      annotation/annotated_cnv
    type: File
    'sbg:x': 1181.726806640625
    'sbg:y': 174.5
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
    'sbg:x': 300.875
    'sbg:y': 121
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
    out:
      - id: normbin
    run: ../tools/normalize.cwl
    label: normalize_normal
    'sbg:x': 496.9639892578125
    'sbg:y': 228
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
    'sbg:x': 754.7880249023438
    'sbg:y': 167.5
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
    'sbg:x': 936.8566284179688
    'sbg:y': 167.5
  - id: stage_bam_normal
    in:
      - id: BAM
        source: normal_BAM
    out:
      - id: output
    run: ../tools/stage_bam.cwl
    label: stage_bam_normal
    'sbg:x': 149.015625
    'sbg:y': 174.5
  - id: stage_bam_tumor
    in:
      - id: BAM
        source: tumor_BAM
    out:
      - id: output
    run: ../tools/stage_bam.cwl
    label: stage_bam_tumor
    'sbg:x': 149.015625
    'sbg:y': 67.5
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
    'sbg:x': 300.875
    'sbg:y': 0
  - id: normalize_tumor
    in:
      - id: REF
        source: REF
      - id: MAP
        source: MAP
      - id: finalize
        default: true
      - id: MER
        source: MER
      - id: SEQ
        source:
          - uniquereads_tumor/seq
    out:
      - id: normbin
    run: ../tools/normalize.cwl
    label: normalize_tumor
    'sbg:x': 496.9639892578125
    'sbg:y': 79
requirements:
  - class: ScatterFeatureRequirement
