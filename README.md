# xMAGIC

xMAGIC is a scalable method designed to integrate a large number of multi-omic xQTL datasets across diverse biological contexts with genome-wide association studies (GWAS) summary statistics. By linking epigenetic marks to target genes using multiple complementary approaches (e.g., chromatin interaction maps, pleiotropy association analysis) and combining association signals from expression and epigenetic phenotypes into a unified gene-trait association test, xMAGIC facilitates the identification of putative effector genes for 75.4% of GWAS loci, as demonstrated in an analysis of 45 human complex traits and 428 xQTL datasets, providing mechanistic insights into genetic associations.

![MAGIC_figure](figure/MAGIC.png)

## Installation
Install from source:
```
git clone https://github.com/yanglab-westlake/xMAGIC  # Assumed repository
cd xMAGIC
```

Verify the installation by running the following command:
```
xmagic --help
```

## Tutorial

xMAGIC integrates GWAS and xQTL summary statistics in a single-step analysis.

We have curated and prepared a variety of publicly available molecular QTL data (downloadable from the yanglab website) and functional element-to-gene maps (downloadable from the yanglab website), which users can use to perform the xMAGIC analysis with their specific complex trait of interest. For illustration purposes, we provide demonstration data that can be used to run xMAGIC analysis with the command line below.

### Running xMAGIC

The basic command to run xMAGIC is:

```
xmagic --besd-flist /data/myxqtl.list --gwas-summary /data/mygwas.ma --bfile /data/myldref --e2g-flist /data/mye2g.list --out /data/myxmagic
```

`--besd-flist`: A file listing paths to multiple xQTL BESD files (format similar to SMR: https://yanglab.westlake.edu.cn/software/smr/#DataManagement). These can include eQTLs, sQTLs, pQTLs, mQTLs, haQTLs, etc.

`--gwas-summary`: GWAS summary statistics file (format similar to GCTA-COJO: https://yanglab.westlake.edu.cn/software/gcta/#COJO).

`--bfile`: PLINK binary files (.bed, .bim, .fam) for LD reference.

`--out`: Prefix for output files, including gene-trait association p-values (.genes.ppa).

`--e2g-flist`: A text file listing paths to multiple functional element-to-gene mapping files. Each mapping file should be tab-delimited with at least four columns: the first three for the element coordinates (chromosome, start position, end position) and the fourth for the gene name. An optional fifth column can specify association strength, and an optional sixth column can specify context. Example file list (mye2g.list):

```
/path/ABC/ABC0.015_ProteinCoding_GRCh38_CHRALL.bed
/path/RoadmapLinks/Roadmap_links_ProteinCoding_GRCh38.bed
/path/EpiMapLinks/EpiMap_links_by_group.CHRALL_GRCh38.bed
/path/PCHi-C/PCHiC_Combined_ProteinCoding_GRCh38.bed
/path/Promoter/gencode.v40.TSS1kb.GRCh38.bed
/path/TSS/gencode.v40.closestTSS.GRCh38.bed
```

Example mapping file (ABC0.015_ProteinCoding_GRCh38_CHRALL.bed):
```
chr10 100009140   100009540   CHUK    0.0201393053305024  A Cardiomyocyte
chr10 100009140   100009540   COX15   0.017169317485787   A Cardiomyocyte
chr10 100009140   100009540   CUTC    0.017169317485787   A Cardiomyocyte
chr10 100009140   100009540   DNMBP   0.0255084527477278  A Cardiomyocyte
chr10 100009140   100009540   DNMBP   0.0414193988769557  A Cardiomyocyte
```

Example Output (.xmagic):

```
chr start   end strand  gene_id gene_name   p_xMAGIC_gene   p_xMAGIC_eQTL   p_xMAGIC_sQTL   p_xMAGIC_pQTL   p_xMAGIC_edQTL  p_xMAGIC_caQTL  p_xMAGIC_mQTL   p_xMAGIC_hQTL
chr11   61799627    61829318    -   ENSG00000149485 FADS1   8.049783e-12    6.383782e-12    3.348550e-10    2.102855e-06    NA  5.038419e-08    2.442678e-05    1.379328e-06
chr2    96122818    96138502    -   ENSG00000188886 ASTL    5.761937e-09    3.366470e-02    NA  NA  NA  2.319283e-05    1.920732e-09    2.819224e-04
chr7    1815793 2233243 -   ENSG00000002822 MAD1L1  3.203962e-08    8.191451e-05    2.832860e-06    NA  NA  7.537022e-05    1.240033e-09    3.533437e-02
chr1    1785285 1891117 -   ENSG00000078369 GNB1    0.0020844378    0.001483188 NA  NA  NA  0.0165264900    2.323335e-03    0.0036771070
```

Columns include chromosome, start/end positions, strand, gene ID, gene symbol, overall xMAGIC p-value, and layer-specific p-values (eQTL, sQTL, pQTL, edQTL, caQTL, mQTL, hQTL), with NA indicating unavailable data.

### Additional Parameters

```
xmagic --besd-flist myxqtl.list --gwas-summary mygwas.ma --bfile myldref --e2g-flist mye2g.list --thresh-smr 0.05 --thresh-heidi 0.01 --thread-num 4 --out myxmagic
```

`--thresh-smr`: SMR significance threshold (default: 0.05).

`--thresh-heidi`: HEIDI heterogeneity test threshold (default: 0.01).

`--thread-num`: Number of threads for parallel computing.

## Data Management

xMAGIC shares data formats with SMR. For full options, see [SMR documentation](https://yanglab.westlake.edu.cn/software/smr/). Curated xQTL datasets (428 total) can be downloaded from the yanglab website. Functional element-to-gene maps can be downloaded from the yanglab website.

## Online analysis
An online platform for xMAGIC is available at http://yanglab.westlake.edu.cn/xmagic, which requires only the upload of GWAS summary statistics.

## Citation
Qi T, Guo Y, Chen C, Xu T, Luo J, Jiang Z, Chen H, Guo M, Wang K, Hou J, Yang J. (2025). Integrative analysis of hundreds of multi-omic and cross-context xQTL datasets links over three-quarters of GWAS loci to putative effector genes. Under Review.


## Contact
Ting Qi (ting.qi@sinh.ac.cn) or Jian Yang (jian.yang@westlake.edu.cn).

