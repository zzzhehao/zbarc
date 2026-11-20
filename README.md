# zseq

`zseq` is an R package for DNA barcoding, sequence alignment, species delimitation, phylogenetics, tree/heatmap visualization, metadata mapping, and Quarto report generation.

## Getting Started

The function is currently only available on GitHub. 

```r
devtools::install_github("git@github.com:zzzhehao/zseq.git")
```

## Overview of Capabilities

### BOLD & GenBank (INSD) Retrieval
* `bold_get_query()` — Construct and validate BOLD API query strings across taxonomic, BIN, geographic, institution, recordset, and ID criteria.
* `bold_validate_query()` — Validate query triplets against the BOLD query preprocessor.
* `bold_get_token()` — Request a query token from the BOLD API.
* `bold_download()` — Download BOLD records in `tsv`, `dwc`, or `json` format.
* `bold_read_data()` — Parse downloaded BOLD text into an R `data.frame`.
* `bold_write_data()` — Write BOLD data objects to disk.
* `bold_retrieve()` — End-to-end wrapper to chunk, validate, download, parse, and optionally save BOLD records.
* `load_insd()` — Load sequences and metadata from NCBI GenBank INSD XML files.

### Local BLAST
* `bcdm2blastdb()` — Build a local nucleotide BLAST database from a BOLD BCDM TSV file.
* `blast()` — Run a local `blastn` search against a BLAST database using a FASTA file or raw sequence.

### Sequence Assembly, Alignment & Editing
* `assemble_map_reference()` — *(Deprecated)* Assemble Sanger `.ab1` reads by mapping to a reference sequence.
* `mafft()` — Run MAFFT multiple sequence alignment and optionally view results in a browser.
* `polish_alignment()` — *(Deprecated)* Clean frame-shifting indels in a `DNAbin` alignment.
* `check_polish()` — Compare original and polished `DNAbin` alignments via MAFFT.
* `codon_summary()` — Check reading frames and stop codons in protein-coding `DNAbin` alignments.
* `trim_empty_columns()` — Remove columns containing only specified empty/gap/ambiguous characters from a `DNAbin` object.
* `clean_label()` — Format voucher and accession labels in FASTA alignments.
* `gblocks()` — Trim conserved alignment blocks using Gblocks.
* `convert_nexus2fasta()` — Convert NEXUS alignments to FASTA format, with optional outgroup removal and label cleaning.

### Species Delimitation (ABGD, ASAP, GMYC)
* `abgd_execute()` — Run Automatic Barcoding Gap Discovery (ABGD) on a FASTA alignment.
* `abgd_disthist()` — Plot a distance histogram from an ABGD distance matrix file.
* `abgd_read_result()` — Read a single ABGD partition result file into a `data.frame`.
* `abgd_read_result_all()` — Read all initial and recursive ABGD partition results from an output folder.
* `abgd_summary()` — Summarize ABGD partition group counts and prior divergence with a plot and table.
* `abgd_delim()` — Build a delimitation table from selected ABGD recursive partitions.
* `asap_execute()` — Run ASAP species delimitation on an aligned FASTA file.
* `asap` — S7 class storing parsed ASAP partition statistics, specimen-to-OTU assignments, and distance matrices.
* `asap_evaluate()` — Evaluate top ASAP partitions from an output directory and return `asap` S7 objects.
* `gmyc_eval()` — Run single- and/or multiple-threshold GMYC delimitation on a binary, ultrametric NEXUS tree.

### Phylogenetics (MrBayes, BEAST2, IQ-TREE)
* `mrbayes` (`mrbayes_mcmc_cmd()`, `mrbayes_partition_cmd()`, `mrbayes_lset_cmd()`, `mrbayes_prset_cmd()`, `mrbayes_sum_cmd()`, `mrbayes_block()`) — Generate MrBayes commands and NEXUS blocks.
* `prepare_mrbayes_nexus()` — Write a `DNAbin` alignment to a NEXUS file with an embedded MrBayes block.
* `beast2_write_mrca()` — Append MRCA monophyly `taxset` priors to a NEXUS file for BEAST2 / BEAUti.
* `test_sub_model()` — Run IQ-TREE ModelFinder (`-m MF`) on a FASTA alignment.
* `midwayTreeViz()` — Snapshot and visualize an ongoing MrBayes consensus tree during an active run.
* `read_contree_mrbayes()` — Read a MrBayes `.con.tre` consensus tree into a `tidytree` `treedata` object.
* `tree_reroot()` — Reroot a MrBayes consensus tree.

### Tree & Heatmap Visualization
* `tree_relabel()` — Relabel tree tip labels using a lookup mapper.
* `tree_annotate()` — Add heatmap annotation layers and mapped color palettes to a `ggtree` plot.
* `tree_visualize()` — Visualize a phylogenetic tree with optional heatmap annotation.

### Metadata Mapping & Alignment Concatenation
* `generate_sequence_map()` — Reshape sequence metadata into a wide specimen-by-gene table.
* `generate_sequence_LUT()` — Build a sequence-to-organism lookup table from specimen, station, and sequence map tables.
* `exclude_by_meta()` — Filter sequences from a `DNAbin` alignment based on metadata criteria.
* `split_concat_alignment()` — Split a concatenated alignment back into single-locus FASTA files.
* `concatenate_alignment()` — Concatenate multi-locus FASTA alignments based on a specimen sequence map.

### Quarto Reports
* `render_report()` — Render HTML reports for `"ncbi"`, `"bold"`, or `"distance"` inputs using Quarto templates.
* `render_report_barcode()` — Render a combined barcoding HTML report from BOLD, BLAST, FASTA, and optional metadata inputs.