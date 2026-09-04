# Huemul genome pipeline: sequencing reads

This directory contains scripts for downloading and assessing the Oxford
Nanopore reads used to generate the nuclear genome assembly and mitochondrial
genome of *Hippocamelus bisulcus* associated with NCBI BioProject
PRJNA1509444.

## Samples and accessions

| Individual | SRA accession | BioSample |
|---|---|---|
| Shehuen | SRR40078882 | SAMN62264853 |
| Coirón | SRR40078881 | SAMN62264854 |

Both accessions are associated with BioProject PRJNA1509444.

## Directory contents

```text
01_Reads/
├── README.md
├── Basecalling_parameters.md
├── download_sra_reads.sh
└── run_read_qc.sh
```

## Basecalling provenance

`Basecalling_parameters.md` records the sequencing platform, EPI2ME Labs
workflow, Dorado model, trimming, and minimum read-quality settings used to
produce the FASTQ files deposited in SRA.

## Read download

`download_sra_reads.sh` downloads:

```text
reads/Shehuen.fastq.gz
reads/Coiron.fastq.gz
```

## Read quality assessment

`run_read_qc.sh` generates:

- a NanoStat summary for each individual;
- a combined FASTQ containing both read sets;
- a NanoPlot report for the combined reads.

## Downstream use

```text
Shehuen reads ─────┬──► Nuclear genome assembly
                   └──► Mitochondrial read enrichment

Coirón reads ──────────► Nuclear genome assembly
```

Software versions are documented in the repository-level `SOFTWARE.md`.
