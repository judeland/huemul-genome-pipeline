# Huemul comparative genomics

This directory contains the OrthoFinder workflow used to compare the
representative *Hippocamelus bisulcus* proteome with annotated reference
proteomes from Cervidae and *Bos taurus*.

## Directory structure

```text
04_Comparative_genomics/
├── README.md
└── run_orthofinder.sh
```

## Input proteomes

The analysis uses one representative protein sequence per gene.

The *H. bisulcus* representative proteome is generated from the final LiftOn
annotation using AGAT.

The reference proteomes are downloaded and standardized using:

```text
00_References/proteomes/download_and_deduplicate_reference_proteomes.py
```

The dataset used in the reported analysis includes:

| Taxon | Assembly accession |
|---|---|
| *Cervus canadensis* | GCF_019320065.1 |
| *Cervus elaphus* | GCF_910594005.1 |
| *Cervus hanglu yarkandensis* | GCA_010411085.1 |
| *Dama dama* | GCF_033118175.1 |
| *Muntiacus muntjak* | GCA_008782695.1 |
| *Muntiacus reevesi* | GCF_963930625.1 |
| *Odocoileus virginianus* | GCF_023699985.2 |
| *Rangifer tarandus platyrhynchus* | GCA_949782905.1 |
| *Bos taurus* | GCF_002263795.3 |

## OrthoFinder analysis

### `run_orthofinder.sh`

Runs OrthoFinder in multiple-sequence-alignment mode using:

- DIAMOND for protein similarity searches;
- FAMSA for multiple-sequence alignments;
- FastTree for gene-tree inference.

The script identifies orthogroups and single-copy orthologues and generates
the concatenated species-tree alignment.

Principal outputs include:

```text
Orthogroups/Orthogroups.tsv
Orthogroups/Orthogroups.GeneCount.tsv
Orthogroups/Orthogroups_SingleCopyOrthologues.txt
Comparative_Genomics_Statistics/Statistics_Overall.tsv
Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv
Species_Tree/SpeciesTree_rooted.txt
WorkingDirectory/Alignments_ids/SpeciesTreeAlignment.fa
WorkingDirectory/SpeciesIDs.txt
```

## Downstream relationship

```text
Representative H. bisulcus proteome
+ standardized reference proteomes
└── OrthoFinder
    ├── orthogroup assignments
    ├── comparative-genomics statistics
    ├── single-copy orthologues
    └── concatenated nuclear alignment
        └── nuclear phylogenetic analysis
```

The nuclear phylogenetic scripts are maintained separately in:

```text
05_Phylogenetic_analyses/nuclear
```

Software versions used in the huemul analysis are documented in the
repository-level `SOFTWARE.md`.
