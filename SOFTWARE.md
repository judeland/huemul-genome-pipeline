# Software provenance

The following versions were used in the reported *Hippocamelus bisulcus*
analysis. Version numbers describe the historical analysis and are not imposed
as installation requirements for users of the repository.

| Analysis component | Software or resource | Version or release |
|---|---|---|
| Basecalling workflow | EPI2ME Labs wf-basecalling | 1.5.9 |
| Basecaller | Dorado model | `dna_r10.4.1_e8.2_400bps_sup@v5.2.0` |
| Combined-read quality assessment | NanoPlot | 1.47.1 |
| Per-sample read statistics | NanoStat | 1.6.0 |
| Assembly summary statistics | assembly-stats | 1.0.1 |
| Read filtering and mitochondrial enrichment | Filtlong | 0.3.1 |
| Read and assembly alignment | minimap2 | 2.31 |
| Alignment processing | SAMtools | 1.23.1 |
| Mitochondrial assembly | PMAT2 | 2.1.5 |
| PMAT2 read correction | Canu | 2.2 |
| Mitochondrial annotation | MITOS2 | 2.1.0 |
| Nuclear assembly | Flye | 2.9.6 |
| Haplotypic-duplication removal | purge_dups | 1.2.5 |
| Consensus polishing | Medaka | 2.2.2 |
| K-mer database | Meryl | 1.4.1 |
| K-mer assembly assessment | Merqury | 1.3 |
| FASTA/FASTQ processing | SeqKit | 2.13.0 |
| Mitochondrial-homology screening | BLAST+ | 2.17.0 |
| Biological-contamination screening | NCBI FCS-GX Galaxy wrapper | 0.5.5+galaxy2 |
| FCS-GX database | NCBI FCS-GX database | fcs-2023-01-24 |
| Residual-adaptor screening | NCBI FCS-adaptor Galaxy wrapper | 0.5.0+galaxy0 |
| Reference-guided scaffolding | RagTag | 2.1.0 |
| Assembly assessment | QUAST | 5.3.0 |
| Gene-space completeness | BUSCO | 6.1.0 |
| BUSCO lineage | cetartiodactyla_odb10 | 2024-01-08; n = 13,335 |
| Repeat-family discovery | RepeatModeler Galaxy wrapper | 2.0.5+galaxy0 |
| Repeat masking | RepeatMasker Galaxy wrapper | 4.1.5+galaxy0 |
| Annotation transfer | LiftOn | 1.0.9 |
| Annotation-method comparison | BRAKER3 | 3.0.8 |
| Annotation processing | AGAT | 1.7.0 |
| Comparative genomics | OrthoFinder | 3.1.5.post1.dev1 |
| OrthoFinder sequence search | bundled DIAMOND | 2.0.13 |
| OrthoFinder multiple-sequence alignment | bundled FAMSA | 2.2.3-1669fc1 (2024-09-17) |
| OrthoFinder species-tree inference | FastTree | 2.2.0, double precision |
| Nuclear and mitochondrial phylogeny | IQ-TREE | 3.1.2 |
| Mitochondrial alignment | MAFFT online server | v7 |
| Tree-label processing | Biopython | 1.84 |

## Notes

The DIAMOND version reported above (2.0.13) is the executable bundled with and
used internally by OrthoFinder, not a separately installed DIAMOND.
