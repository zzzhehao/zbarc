# Concatenate Multiple Single-Locus Alignments into a Multi-Locus Alignment

Reads single-locus FASTA alignments, optionally applies metadata
filtering via
[`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md),
maps accession/sequence identifiers to organism labels using
`sequence.map`, filters taxa by locus availability, writes the
concatenated alignment and per-locus subsets, and returns summary
metadata.

## Usage

``` r
concatenate_alignment(
  fasta_path,
  names.alignments,
  sequence.map,
  identifier,
  accs_col,
  include_strategy = "all",
  include_strategy_loci,
  include_by,
  output_folder,
  run_name = NULL,
  exclude_options = NULL
)
```

## Arguments

- fasta_path:

  Character vector. Paths to single-locus FASTA alignment files in
  concatenation order.

- names.alignments:

  Character vector. Locus names matching `fasta_path` in length and
  order.

- sequence.map:

  A `data.frame` mapping sequence/accession IDs to organism identifiers.

- identifier:

  Character. Column name in `sequence.map` providing the organism/taxon
  label.

- accs_col:

  Character vector. Column names in `sequence.map` (one per locus)
  holding accession numbers or sequence names to match against FASTA
  headers.

- include_strategy:

  Character. Taxon inclusion rule across `include_strategy_loci`:
  `"all"` (default) or `"any"`.

- include_strategy_loci:

  Character vector. Locus names checked under `include_strategy`.

- include_by:

  Argument accepted in signature (currently unused in function body).

- output_folder:

  Character. Directory for output alignment files.

- run_name:

  Character or `NULL`. Optional suffix used in output filename
  (`concat_<run_name>.nexus`).

- exclude_options:

  List or `NULL`. Argument list (excluding `aln`) passed to
  [`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md),
  or a list of argument lists for sequential filtering steps. Default is
  `NULL`.

## Value

A named list containing:

- `alignment`:

  The concatenated `DNAbin` alignment matrix.

- `concat_fasta_path`:

  Path to the written concatenated alignment file.

- `loci_fasta_path`:

  Character vector of paths to per-locus re-extracted FASTA files.

- `taxa`:

  Character vector of included taxon labels.

- `loci_parition`:

  A `data.frame` of locus `name` and `length`.

- `sequence_composition`:

  A `data.frame` indicating per-locus sequence presence for included
  taxa.

## See also

[`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md)

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
