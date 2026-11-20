# Create a Wide Sequence Map Linking Sequences to Specimens Across Genes

Reshapes sequence metadata into a wide table linking sequences from the
same vouchered specimen across loci, which can be used as `sequence.map`
in
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md).

## Usage

``` r
generate_sequence_map(
  metadata.sequence,
  col_gene,
  col_id_specimen,
  col_id_sequence
)
```

## Arguments

- metadata.sequence:

  A `data.frame` containing sequence-level metadata.

- col_gene:

  Unquoted column name in `metadata.sequence` identifying the
  gene/locus.

- col_id_specimen:

  Unquoted column name in `metadata.sequence` identifying the specimen.

- col_id_sequence:

  Unquoted column name in `metadata.sequence` identifying the sequence
  or accession ID.

## Value

A wide `data.frame` with a `specimen` column (from `col_id_specimen`)
and one column per locus (`gene_<col_gene>`) populated with values from
`col_id_sequence`.

## See also

Other management:
[`clean_label()`](https://zzzhehao.github.io/zbarc/reference/clean_label.md),
[`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md)
