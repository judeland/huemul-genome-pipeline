# Huemul mitochondrial genome workflow

This directory contains the scripts and parameter documentation used to
assemble, normalize, and annotate the mitochondrial genome of *Hippocamelus
bisulcus* associated with NCBI BioProject PRJNA1509444.

The mitochondrial workflow uses the Oxford Nanopore reads from Shehuen.

## Directory structure

```text
03_Mitochondrial_genome/
├── README.md
├── 01_read_enrichment/
│   └── enrich_mitochondrial_reads.sh
├── 02_assembly/
│   └── run_pmat.sh
├── 03_normalization/
│   └── normalize_mitogenome.sh
└── 04_annotation/
    └── MITOS2_Galaxy_parameters.md
```

## 1. Mitochondrial read enrichment

### `01_read_enrichment/enrich_mitochondrial_reads.sh`

Selects Shehuen reads within the mitochondrial-length range and aligns them
against the *Hippocamelus antisensis* mitochondrial genome NC_020711.1.

Mapped reads are extracted to generate the mitochondrial-enriched FASTQ used
for de novo assembly.

Principal inputs:

```text
reads/Shehuen.fastq.gz
references/mitochondrial/individual/Hippocamelus_antisensis_NC_020711.1.fasta
```

Principal output:

```text
mitochondrial_assembly/input_reads/mitochondrial_enriched_reads.fastq.gz
```

## 2. De novo mitochondrial assembly

### `02_assembly/run_pmat.sh`

Assembles the mitochondrial-enriched Oxford Nanopore reads using PMAT2 in
autoMito mode with Canu read correction.

Principal input:

```text
mitochondrial_enriched_reads.fastq.gz
```

Principal output:

```text
PMAT_mt.fa
```

## 3. Circular-genome normalization

### `03_normalization/normalize_mitogenome.sh`

Rotates the circular PMAT2 mitochondrial sequence so that its first position
corresponds to the conventional mitochondrial coordinate origin used for
annotation and comparison.

The huemul sequence retains its original strand orientation. No bases are
added, removed, or reverse-complemented.

The script also verifies that the PMAT2 and normalized sequences represent the
same circular molecule.

Principal output:

```text
Hbis_complete_mitochondrial_genome.fasta
```

## 4. Mitochondrial annotation

Mitochondrial structural annotation was performed with MITOS2 on the Galaxy
platform.

The input, genetic code, and other analysis settings are documented in:

```text
04_annotation/MITOS2_Galaxy_parameters.md
```

The retained annotation outputs include:

- mitochondrial GFF annotation;
- NCBI feature table;
- tabular annotation summary;
- nucleotide gene sequences;
- protein sequences;
- gene-order output.

## Workflow relationships

```text
Shehuen ONT reads
└── mitochondrial read enrichment
    └── PMAT2 de novo assembly
        └── circular-genome normalization
            └── MITOS2 annotation on Galaxy
                ├── final mitochondrial genome
                └── mitochondrial annotation files
```

## Downstream use

The normalized mitochondrial genome is subsequently used for:

- screening the nuclear assembly for mitochondrial homology;
- mitochondrial comparative analysis;
- mitochondrial phylogenetic inference.

The phylogenetic-analysis scripts are maintained separately in
`05_Phylogenetic_analyses`.

## External resources

The read-enrichment stage uses the *H. antisensis* mitochondrial genome
NC_020711.1 prepared through `00_References`.

Software versions used in the huemul analysis are documented in the
repository-level `SOFTWARE.md`.
