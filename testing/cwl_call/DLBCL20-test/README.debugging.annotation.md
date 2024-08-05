Error running 6_run_gene_anotation.sh on case-only:
```
$ sed '1d' /results/segmentation-case/case.cnv | grep chr18 | cut -f1,2,3,9 | /usr/bin/bedtools intersect -loj -a /reference/cached.annotation/gencode.v29.annotation.hg38.p12.bed -b - | /usr/bin/python -S /BICSEQ2/src/gene_segment_overlap.py
line: ['chr18', '47389', '49557', 'TUBB8P12', 'chr18', '10495', '106605']
Traceback (most recent call last):
  File "/BICSEQ2/src/gene_segment_overlap.py", line 32, in <module>
    gene_dict[gene] = [line[0], line[1], line[2], int(line[6])-int(line[5]), (int(line[6])-int(line[5]))*math.pow(2,float(line[7]))]
IndexError: list index out of range
```

The problem seems to be that `gene_segment_overlap.py` is specific to CASE/CONTROL.  Here is what the differences look like:
## CASE_CONTROL

$ cat results-tmp/segmentation-case-control/case_name.cnv
chrom   start   end binNum  tumor   tumor_expect    normal  normal_expect   log2.copyRatio  log2.TumorExpectRatio
chr18   10495   80262667    717916  22398014    22526963.7986   21881156    21952962.8665   -0.00429041018015012    -0.00467335649289974
chr19   108056  58607112    526089  16907845    17120557.2722   16229467    16320959.5181   -0.0106616675510236 -0.014428163796242
chr20   67260   64334068    582736  18703462    18507084.0237   17845759    17851190.6068   0.0149317188319233  0.0188364411768835

     1  chrom   chr18
     2  start   10495
     3  end 80262667
     4  binNum  717916
     5  tumor   22398014
     6  tumor_expect    22526963.7986
     7  normal  21881156
     8  normal_expect   21952962.8665
     9  log2.copyRatio  -0.00429041018015012
    10  log2.TumorExpectRatio   -0.00467335649289974


## CASE-ONLY:
chrom	start	end	binNum	observed	expected	log2.copyRatio
chr18	10011	10494	3	715	94.1998	2.92397075726465
chr18	10495	106605	206	6877	6611.51	0.0566229571053229
chr18	106606	111189	10	4572	317.734	3.84675743784487

$ examine_row results-tmp/segmentation-case/case.cnv 2
     1	chrom	chr18
     2	start	10011
     3	end	10494
     4	binNum	3
     5	observed	715
     6	expected	94.1998
     7	log2.copyRatio	2.92397075726465

Expect that processing case-only will require changing the cut columns to,
  cut -f1,2,3,7

-> yes, this works.  Give run_annotation.sh a flag whether this is case-only or case-control data

