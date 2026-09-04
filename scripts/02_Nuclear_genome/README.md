# Huemul nuclear genome workflow

This directory contains the scripts and parameter documentation used to
generate, curate, scaffold, and annotate the nuclear genome assembly of
*Hippocamelus bisulcus* associated with NCBI BioProject PRJNA1509444.

The workflow is modular. Each script can be executed independently when its
required input files are available.

## Directory structure

```text
02_Nuclear_genome/
├── README.md
├── 01_assembly/
│   └── run_flye.sh
├── 02_post_assembly_curation/
│   ├── 01_run_purge_dups.sh
│   ├── 02_run_medaka.sh
│   ├── 03_run_merqury.sh
│   ├── 04_apply_fcs_gx_report.sh
│   ├── 05_screen_mitochondrial_hits.sh
│   ├── 06_apply_mitochondrial_screen.sh
│   ├── 07_filter_contig_length.sh
│   └── 08_apply_fcs_adaptor_report.sh
├── 03_scaffolding/
│   ├── 09_run_ragtag.sh
│   ├── 10_build_ncbi_submission.sh
│   └── build_ncbi_submission.py
└── 05_annotation/
    ├── repeat_annotation/
    │   ├── repeatmodeler.sh
    │   └── repeatmasker.sh
    └── gene_annotation/
        ├── lifton.sh
        └── agat.sh
```

## 1. De novo assembly

### `01_assembly/run_flye.sh`

Assembles the combined Shehuen and Coirón Oxford Nanopore reads using Flye in
high-quality Nanopore mode.

The script also invokes the shared assembly-statistics and genome-mode BUSCO
scripts.

Principal input:

```text
QC_reads/shehuen_coiron_reads.fastq.gz
```

Principal output: Flye draft nuclear assembly.

## 2. Post-assembly curation

The numbered scripts document the order used for assembly curation.

### Haplotypic duplicate removal

`01_run_purge_dups.sh` maps the combined reads to the Flye assembly, calculates
coverage cutoffs, identifies assembly self-overlaps, and generates the purged
primary assembly.

### Consensus polishing

`02_run_medaka.sh` performs one round of Medaka polishing using the combined
Oxford Nanopore reads.

### K-mer assessment

`03_run_merqury.sh` compares the Flye and Medaka assemblies using a Meryl
database generated from the combined reads.

### Taxonomic contamination

The Medaka-polished assembly was screened using NCBI FCS-GX on the Galaxy
platform.

`04_apply_fcs_gx_report.sh` applies the resulting action report to the
assembly.

### Mitochondrial-homology screening

`05_screen_mitochondrial_hits.sh` screens the nuclear assembly for regions
with homology to the assembled huemul mitochondrial genome.

`06_apply_mitochondrial_screen.sh` optionally removes sequences selected after
manual review by supplying an explicit list of sequence identifiers. This
removal step was not used for the huemul assembly because the detected
mitochondrial homologies represented embedded NUMTs rather than standalone
mitochondrial contigs.

### Contig-length filtering

`07_filter_contig_length.sh` retains contigs of at least 20,000 bp.

### Residual adapter screening

The length-filtered assembly was screened using NCBI FCS-adaptor on the Galaxy
platform.

`08_apply_fcs_adaptor_report.sh` applies the resulting report using the NCBI
FCS-GX clean-genome procedure.

## 3. Reference-guided scaffolding

### `03_scaffolding/09_run_ragtag.sh`

Scaffolds the final cleaned assembly against the *Odocoileus virginianus*
Ovbor_1.2 reference (GCF_023699985.2).

Assembly QC (assembly-statistics, BUSCO, and reference-based QUAST) is
performed on the final NCBI-oriented assembly in the following step.

### NCBI-oriented assembly preparation

`10_build_ncbi_submission.sh` calls `build_ncbi_submission.py` to:

- assign informative huemul sequence identifiers;
- retain the 36 chromosome-associated pseudomolecules;
- separate the composite RagTag Chr0 into individual unplaced scaffolds;
- preserve AGP component orientation;
- generate sequence-identifier mapping files;
- produce the final NCBI-oriented assembly;
- perform the final assembly-statistics, BUSCO, and reference-based QUAST
  assessments.

Principal outputs:

```text
Hbis_scaffolds_NCBI.fasta
Hbis_assembly.agp
object_name_map.tsv
chr0_split_map.tsv
```

`Hbis_scaffolds_NCBI.fasta` is the final nuclear assembly used for NCBI
submission, repeat annotation, gene annotation, and the final assembly QC.

## 4. Annotation

### Repeat annotation

`repeatmodeler.sh` documents the de novo repeat-library analysis performed
with RepeatModeler on Galaxy.

`repeatmasker.sh` documents the RepeatMasker analysis performed on Galaxy
using the custom RepeatModeler library and soft masking.

### Gene annotation

`lifton.sh` transfers gene models from the nuclear-only *O. virginianus*
reference annotation to the unmasked final huemul assembly.

`agat.sh` calculates annotation statistics, retains the longest transcript
isoform per gene, extracts complete and representative proteomes, and invokes
protein-mode BUSCO for the representative proteome.

## Main workflow relationships

```text
Combined ONT reads
└── Flye assembly
    └── purge_dups
        └── Medaka
            └── FCS-GX curation
                └── mitochondrial-homology assessment
                    └── ≥20-kb filtering
                        └── FCS-adaptor curation
                            └── RagTag scaffolding
                                └── NCBI-oriented final assembly
                                    ├── repeat annotation
                                    └── gene annotation
```

## External resources

The workflow uses:

- the Ovbor_1.2 reference (`GCF_023699985.2`) for RagTag scaffolding;
- the Ovbor_1.2 nuclear FASTA prepared in `00_References/nuclear` for the
  reference-based QUAST assessment;
- the matching Ovbor_1.2 nuclear FASTA and GFF3 annotation for LiftOn;
- the `cetartiodactyla_odb10` dataset managed by the shared BUSCO scripts;
- the huemul mitochondrial genome produced by `03_Mitochondrial_genome` for
  mitochondrial-homology screening.

Software versions used in the huemul analysis are documented in the
repository-level `SOFTWARE.md`.
