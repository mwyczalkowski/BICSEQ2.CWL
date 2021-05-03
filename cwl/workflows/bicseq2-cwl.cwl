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
    'sbg:x': -525.6011352539062
    'sbg:y': 177
  - id: MAP
    type: File
    'sbg:x': -397.60113525390625
    'sbg:y': 258
  - id: GENE_BED
    type: File
    'sbg:x': 139.39886474609375
    'sbg:y': -224
outputs:
  - id: PDF
    outputSource:
      - normalize/PDF
    type: File?
    'sbg:x': -120.60113525390625
    'sbg:y': -224
  - id: parameter_estimate
    outputSource:
      - normalize/parameter_estimate
    type: File?
    'sbg:x': 33.39886474609375
    'sbg:y': -226
  - id: PNG
    outputSource:
      - segmentation/PNG
    type: File?
    'sbg:x': 172.39886474609375
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
      - id: SEQ
        source:
          - uniquereads/seq
    out:
      - id: PDF
      - id: parameter_estimate
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
