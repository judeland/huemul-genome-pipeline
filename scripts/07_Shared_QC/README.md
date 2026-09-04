# Shared quality-control scripts

This directory contains reusable quality-control scripts for read, assembly,
and proteome assessment. Each script can be executed independently when its
required input variables are supplied.

## Directory structure

```text
07_Shared_QC/
├── README.md
├── assembly_stats.sh
├── merqury.sh
├── nanoplot.sh
├── nanostat.sh
├── quast.sh
└── busco/
    ├── download_lineage.sh
    ├── busco_genome.sh
    └── busco_proteome.sh
```

## Read quality

- `nanostat.sh` generates tabular statistics for an Oxford Nanopore FASTQ file.
- `nanoplot.sh` generates a graphical NanoPlot report for an Oxford Nanopore
  FASTQ file.

## Assembly quality

- `assembly_stats.sh` calculates basic assembly size and contiguity statistics.
- `merqury.sh` estimates k-mer completeness and consensus QV using a Meryl
  database generated from the sequencing reads.
- `quast.sh` runs reference-based assembly assessment against the nuclear-only
  *Odocoileus virginianus* reference.

The final QUAST results reported for this project correspond to the
NCBI-oriented huemul assembly.

## BUSCO

- `busco/download_lineage.sh` downloads the `cetartiodactyla_odb10` lineage.
- `busco/busco_genome.sh` evaluates nuclear assemblies in genome mode.
- `busco/busco_proteome.sh` evaluates representative proteomes in protein mode.

The BUSCO scripts use a shared lineage-download directory so that the same
dataset can be reused in offline analyses.

Software versions used in the huemul analysis are documented in the
repository-level `SOFTWARE.md`.
