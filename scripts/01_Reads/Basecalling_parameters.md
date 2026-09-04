# Basecalling parameters

Provenance of the quality-filtered Oxford Nanopore FASTQ files deposited in the
NCBI Sequence Read Archive (SRR40078882, Shehuen; SRR40078881, Coirón) under
BioProject PRJNA1509444. These steps were run before the analyses in this
repository and are recorded here for provenance.

| Item | Value |
|---|---|
| Sequencing platform | Oxford Nanopore MinION Mk1B |
| Flow cells | 8 × R10.4.1 |
| Library kit | ONT Ligation Sequencing Kit V14 (SQK-LSK114) |
| Libraries | 5 total (4 from Shehuen, 1 from Coirón) |
| Data acquisition | MinKNOW |
| Basecalling workflow | EPI2ME Labs `wf-basecalling` v1.5.9 |
| Basecaller / model | Dorado, super-accuracy, `dna_r10.4.1_e8.2_400bps_sup@v5.2.0` |
| Adapter trimming | Dorado built-in trimming |
| Quality filter | minimum read quality Q ≥ 10 |

The basecalled, adapter-trimmed and quality-filtered reads were deposited in the
SRA and are re-downloaded by `download_sra_reads.sh`. Software versions are
listed in the repository-level `SOFTWARE.md`.
