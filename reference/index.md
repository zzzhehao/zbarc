# Package index

## Data Retrieval (BOLD & GenBank)

Query, download, and parse records from BOLD and INSD XML files.

- [`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md)
  : Construct and Validate a BOLD API Query

- [`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md)
  : Validate Query Triplets via BOLD Preprocessor

- [`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md)
  : Get Query Token from BOLD API

- [`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md)
  : Download Records from BOLD API

- [`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md)
  : Read Downloaded BOLD Text into R

- [`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
  :

  Write BOLD Data to Disk Using `zhutilsr`

- [`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md)
  : Retrieve Data from the BOLD API

- [`load_insd()`](https://zzzhehao.github.io/zbarc/reference/load_insd.md)
  : Load Sequences from NCBI GenBank with Metadata from INSD XML Files

## Local BLAST

Build local nucleotide databases from BOLD data and run BLAST searches.

- [`bcdm2blastdb()`](https://zzzhehao.github.io/zbarc/reference/bcdm2blastdb.md)
  : Build a local BLAST reference database from a BOLD BCDM TSV
- [`blast()`](https://zzzhehao.github.io/zbarc/reference/blast.md) : Run
  a local BLAST search against a custom database

## Sequence Assembly, Alignment & Trimming

Wrappers and utilities for Sanger reads, MAFFT, Gblocks, and alignment
editing.

- [`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md) :
  Align Sequences Using MAFFT
- [`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md) :
  Trim Conserved Alignment Blocks with Gblocks
- [`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md)
  **\[deprecated\]** : Polish Sequence Alignment
- [`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md)
  : Visually Compare Original and Polished Alignments with MAFFT
- [`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md)
  : Check Stop Codons and Reading Frames in a Protein-Coding Alignment
- [`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
  : Remove Empty Columns from an Alignment
- [`clean_label()`](https://zzzhehao.github.io/zbarc/reference/clean_label.md)
  : Clean Sequence Labels in a FASTA Alignment
- [`convert_nexus2fasta()`](https://zzzhehao.github.io/zbarc/reference/convert_nexus2fasta.md)
  : Convert a NEXUS Alignment to FASTA Format
- [`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md)
  : Summarize Alignment Dimensions and Taxa from a FASTA or NEXUS File
- [`merge_fasta()`](https://zzzhehao.github.io/zbarc/reference/merge_fasta.md)
  : Merge Multiple FASTA Files and Deduplicate Sequence Names

## Species Delimitation (ABGD, ASAP, GMYC)

Run and parse delimitation analyses across multiple methods.

- [`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md)
  : Run Automatic Barcoding Gap Discovery (ABGD)
- [`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md)
  : Plot Distance Histogram from an ABGD Distance Matrix File
- [`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md)
  : Read a Single ABGD Partition Result File
- [`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md)
  : Read All ABGD Partition Results in a Directory
- [`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
  : Summarize ABGD Partitions and Plot Group Counts
- [`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)
  : Extract Species Delimitation Table from ABGD Recursive Partitions
- [`asap_execute()`](https://zzzhehao.github.io/zbarc/reference/asap_execute.md)
  : Run ASAP Species Delimitation
- [`asap()`](https://zzzhehao.github.io/zbarc/reference/asap.md) : ASAP
  Result S7 Class
- [`asap_evaluate()`](https://zzzhehao.github.io/zbarc/reference/asap_evaluate.md)
  : Evaluate ASAP Output
- [`gmyc_eval()`](https://zzzhehao.github.io/zbarc/reference/gmyc_eval.md)
  : Perform GMYC Species Delimitation on a BEAST2 Tree

## Phylogenetics (MrBayes, BEAST2, IQ-TREE)

Prepare NEXUS/MRCA inputs and run model selection or tree workflows.

- [`mrbayes_mcmc_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  [`mrbayes_partition_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  [`mrbayes_lset_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  [`mrbayes_prset_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  [`mrbayes_sum_cmd()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  [`mrbayes_block()`](https://zzzhehao.github.io/zbarc/reference/mrbayes.md)
  : Helper Functions to Generate MrBayes Blocks in NEXUS Files
- [`prepare_mrbayes_nexus()`](https://zzzhehao.github.io/zbarc/reference/prepare_mrbayes_nexus.md)
  : Generate a NEXUS File with an Embedded MrBayes Block
- [`beast2_write_mrca()`](https://zzzhehao.github.io/zbarc/reference/beast2_write_mrca.md)
  : Write MRCA Priors into a NEXUS Alignment File for BEAST2
- [`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md)
  : Run Substitution Model Selection (ModelFinder) in IQ-TREE
- [`midwayTreeViz()`](https://zzzhehao.github.io/zbarc/reference/midwayTreeViz.md)
  : Snapshot MrBayes Consensus Tree During an Active Analysis
- [`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md)
  : Read MrBayes Output Consensus Tree
- [`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md)
  : Reroot Consensus Tree Produced by MrBayes

## Tree & Heatmap Visualization

Relabel tips and render phylogenetic trees with annotation heatmaps.

- [`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md)
  : Relabel Tree Tip Labels Using a Lookup Mapper
- [`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
  : Visualize a Phylogenetic Tree with Optional Heatmap Annotation
- [`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md)
  : Add Heatmap Annotation to a Phylogenetic Tree
- [`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md)
  : Calculate Dynamic Layout Offsets for Tree + Heatmap
- [`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md)
  : Prepare and Format Tree for Plotting
- [`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md)
  : Visualize Base Phylogenetic Tree

## Metadata Mapping & Filtering

Link sequences to specimens and filter alignments by metadata.

- [`generate_sequence_map()`](https://zzzhehao.github.io/zbarc/reference/generate_sequence_map.md)
  : Create a Wide Sequence Map Linking Sequences to Specimens Across
  Genes
- [`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md)
  : Concatenate Multiple Single-Locus Alignments into a Multi-Locus
  Alignment
- [`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md)
  : Split a Concatenated Alignment Back into Single-Locus FASTA Files
- [`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md)
  : Exclude Sequences from an Alignment by Filtering Metadata

## Quarto Reports

Render HTML reports for BLAST, BOLD, distance, and barcoding workflows.

- [`render_report()`](https://zzzhehao.github.io/zbarc/reference/render_report.md)
  : Generate an Interactive HTML Report Using Quarto
- [`render_report_barcode()`](https://zzzhehao.github.io/zbarc/reference/render_report_barcode.md)
  : Generate a Combined Barcoding HTML Report
