# Huemul genome resources

This repository documents the principal analyses used to generate and assess
the nuclear genome assembly and complete mitochondrial genome of
*Hippocamelus bisulcus* associated with NCBI BioProject PRJNA1509444.

The scripts are organized as independent, reusable stages. They document the
analysis order and file relationships but do not enforce a single software
environment or mandatory master workflow.

## Repository structure

```text
scripts/
├── 00_References/
├── 01_Reads/
├── 02_Nuclear_genome/
├── 03_Mitochondrial_genome/
├── 04_Comparative_genomics/
├── 05_Phylogenetic_analyses/
└── 07_Shared_QC/
```

## Analysis overview

```text
Deposited quality-filtered ONT reads
├── nuclear genome
│   ├── Flye assembly
│   ├── purge_dups and Medaka
│   ├── contamination, mitochondrial-homology, length, and adaptor screening
│   ├── RagTag reference-guided scaffolding
│   ├── NCBI-oriented sequence preparation
│   ├── repeat annotation
│   └── LiftOn annotation and AGAT representative proteome
└── mitochondrial genome
    ├── mitochondrial-read enrichment
    ├── PMAT2 assembly
    ├── circular-genome normalization
    └── MITOS2 annotation on Galaxy

Representative proteomes
└── OrthoFinder comparative genomics
    └── nuclear IQ-TREE analysis

Complete mitochondrial genomes
└── MAFFT online alignment
    └── mitochondrial IQ-TREE analysis
```

Each main directory contains a README describing its inputs, outputs, and
relationship to the other stages. Software versions used in the reported
analysis are listed in [SOFTWARE.md](SOFTWARE.md).

## Create a working directory

`initialize_project_directory.sh` creates a self-contained working directory
at a user-selected location. It copies the repository scripts and creates the
input and output directories expected by the documented stages, but does not
install software or run any analysis.

```bash
bash initialize_project_directory.sh /path/to/huemul_genome_analysis
```

## Associated resources

- NCBI BioProject: PRJNA1509444
- Nuclear WGS accession: JCCBWI000000000
- Assembly version described in the manuscript: JCCBWI010000000
- Quality-filtered ONT reads: SRR40078882 (Shehuen) and SRR40078881 (Coirón)
- Associated analysis files: [Zenodo record 10.5281/zenodo.22063022](https://doi.org/10.5281/zenodo.22063022)
- Associated preprint: [Ousset et al. (2026), bioRxiv](https://doi.org/10.64898/2026.09.04.747633); the manuscript is currently under peer review.

## Reproducibility notes

- Run scripts from the repository root unless a script states otherwise.
- The fixed analytical parameters document the reported workflow and are
  intended to reproduce it. Some tools are stochastic or sensitive to software
  versions, thread counts, and reference/database releases, so minor variations
  between runs and environments are expected, although no substantial
  differences are anticipated; the deposited assemblies, annotations, and
  analysis files (NCBI, Zenodo) are the definitive results.
  `THREADS=16` can be adjusted to the available computing resources.
- Scripts can be tested and run progressively; a complete end-to-end rerun is
  not required before using individual stages.
- Several scripts overwrite outputs with the same names. Change output paths
  before rerunning when earlier results must be preserved.
- Galaxy and online-server analyses are documented through parameter files and
  local command-line equivalents where appropriate.

## Citation

If you use these scripts, please cite the associated publication and this
repository (see [CITATION.cff](CITATION.cff)). The associated data are archived
on Zenodo: https://doi.org/10.5281/zenodo.22063022

## License

Released under the MIT License (see [LICENSE](LICENSE)).
