# zbarc

`zbarc` is an R package for DNA barcoding, sequence alignment, species
delimitation, phylogenetics, tree/heatmap visualization, metadata
mapping, and Quarto report generation.

## Getting Started

The function is currently only available on GitHub.

``` r

devtools::install_github("git@github.com:zzzhehao/zbarc.git")
```

## Overview of Capabilities

### BOLD & GenBank (INSD) Retrieval

- [`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md)
  — Construct and validate BOLD API query strings across taxonomic, BIN,
  geographic, institution, recordset, and ID criteria.
- [`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md)
  — Validate query triplets against the BOLD query preprocessor.
- [`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md)
  — Request a query token from the BOLD API.
- [`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md)
  — Download BOLD records in `tsv`, `dwc`, or `json` format.
- [`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md)
  — Parse downloaded BOLD text into an R `data.frame`.
- [`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
  — Write BOLD data objects to disk.
- [`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md)
  — End-to-end wrapper to chunk, validate, download, parse, and
  optionally save BOLD records.
- [`load_insd()`](https://zzzhehao.github.io/zbarc/reference/load_insd.md)
  — Load sequences and metadata from NCBI GenBank INSD XML files.

### Local BLAST

- [`bcdm2blastdb()`](https://zzzhehao.github.io/zbarc/reference/bcdm2blastdb.md)
  — Build a local nucleotide BLAST database from a BOLD BCDM TSV file.
- [`blast()`](https://zzzhehao.github.io/zbarc/reference/blast.md) — Run
  a local `blastn` search against a BLAST database using a FASTA file or
  raw sequence.

### Sequence Assembly, Alignment & Editing

- `assemble_map_reference()` — *(Deprecated)* Assemble Sanger `.ab1`
  reads by mapping to a reference sequence.
- [`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md) — Run
  MAFFT multiple sequence alignment and optionally view results in a
  browser.
- [`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md)
  — *(Deprecated)* Clean frame-shifting indels in a `DNAbin` alignment.
- [`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md)
  — Compare original and polished `DNAbin` alignments via MAFFT.
- [`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md)
  — Check reading frames and stop codons in protein-coding `DNAbin`
  alignments.
- [`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
  — Remove columns containing only specified empty/gap/ambiguous
  characters from a `DNAbin` object.
- [`clean_label()`](https://zzzhehao.github.io/zbarc/reference/clean_label.md)
  — Format voucher and accession labels in FASTA alignments.
- [`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md) —
  Trim conserved alignment blocks using Gblocks.
- [`convert_nexus2fasta()`](https://zzzhehao.github.io/zbarc/reference/convert_nexus2fasta.md)
  — Convert NEXUS alignments to FASTA format, with optional outgroup
  removal and label cleaning.

### Species Delimitation (ABGD, ASAP, GMYC)

- [`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md)
  — Run Automatic Barcoding Gap Discovery (ABGD) on a FASTA alignment.
- [`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md)
  — Plot a distance histogram from an ABGD distance matrix file.
- [`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md)
  — Read a single ABGD partition result file into a `data.frame`.
- [`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md)
  — Read all initial and recursive ABGD partition results from an output
  folder.
- [`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
  — Summarize ABGD partition group counts and prior divergence with a
  plot and table.
- [`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)
  — Build a delimitation table from selected ABGD recursive partitions.
- [`asap_execute()`](https://zzzhehao.github.io/zbarc/reference/asap_execute.md)
  — Run ASAP species delimitation on an aligned FASTA file.
- `asap` — S7 class storing parsed ASAP partition statistics,
  specimen-to-OTU assignments, and distance matrices.
- [`asap_evaluate()`](https://zzzhehao.github.io/zbarc/reference/asap_evaluate.md)
  — Evaluate top ASAP partitions from an output directory and return
  `asap` S7 objects.
- [`gmyc_eval()`](https://zzzhehao.github.io/zbarc/reference/gmyc_eval.md)
  — Run single- and/or multiple-threshold GMYC delimitation on a binary,
  ultrametric NEXUS tree.

### Phylogenetics (MrBayes, BEAST2, IQ-TREE)

- `mrbayes`
  ([`mrbayes_mcmc_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md),
  [`mrbayes_partition_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md),
  [`mrbayes_lset_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md),
  [`mrbayes_prset_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md),
  [`mrbayes_sum_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md),
  [`mrbayes_block()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md))
  — Generate MrBayes commands and NEXUS blocks.
- [`prepare_mrbayes_nexus()`](https://zzzhehao.github.io/zbarc/reference/prepare_mrbayes_nexus.md)
  — Write a `DNAbin` alignment to a NEXUS file with an embedded MrBayes
  block.
- [`beast2_write_mrca()`](https://zzzhehao.github.io/zbarc/reference/beast2_write_mrca.md)
  — Append MRCA monophyly `taxset` priors to a NEXUS file for BEAST2 /
  BEAUti.
- [`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md)
  — Run IQ-TREE ModelFinder (`-m MF`) on a FASTA alignment.
- [`midwayTreeViz()`](https://zzzhehao.github.io/zbarc/reference/midwayTreeViz.md)
  — Snapshot and visualize an ongoing MrBayes consensus tree during an
  active run.
- [`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md)
  — Read a MrBayes `.con.tre` consensus tree into a `tidytree`
  `treedata` object.
- [`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md)
  — Reroot a MrBayes consensus tree.

### Tree & Heatmap Visualization

- [`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md)
  — Relabel tree tip labels using a lookup mapper.
- [`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md)
  — Add heatmap annotation layers and mapped color palettes to a
  `ggtree` plot.
- [`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
  — Visualize a phylogenetic tree with optional heatmap annotation.

### Metadata Mapping & Alignment Concatenation

- [`generate_sequence_map()`](https://zzzhehao.github.io/zbarc/reference/generate_sequence_map.md)
  — Reshape sequence metadata into a wide specimen-by-gene table.
- `generate_sequence_LUT()` — Build a sequence-to-organism lookup table
  from specimen, station, and sequence map tables.
- [`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md)
  — Filter sequences from a `DNAbin` alignment based on metadata
  criteria.
- [`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md)
  — Split a concatenated alignment back into single-locus FASTA files.
- [`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md)
  — Concatenate multi-locus FASTA alignments based on a specimen
  sequence map.

### Quarto Reports

- [`render_report()`](https://zzzhehao.github.io/zbarc/reference/render_report.md)
  — Render HTML reports for `"ncbi"`, `"bold"`, or `"distance"` inputs
  using Quarto templates.
- [`render_report_barcode()`](https://zzzhehao.github.io/zbarc/reference/render_report_barcode.md)
  — Render a combined barcoding HTML report from BOLD, BLAST, FASTA, and
  optional metadata inputs.
