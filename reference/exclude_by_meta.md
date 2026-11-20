# Exclude Sequences from an Alignment by Filtering Metadata

Filters sequences in a `DNAbin` object whose `INSDSeq_primary-accession`
matches metadata rows matching `pattern` in `field`, optionally
retaining a random subset of matched sequences.

## Usage

``` r
exclude_by_meta(aln, field, pattern, retain = 0, seed = NULL, metadata)
```

## Arguments

- aln:

  A named `DNAbin` alignment object.

- field:

  Character. Column name in `metadata` to match against `pattern`.

- pattern:

  Character. Regular expression pattern; matching records are selected
  for exclusion.

- retain:

  Numeric or integer. Number of matching sequences to randomly retain
  rather than exclude. Default is `0`.

- seed:

  Integer or `NULL`. Optional random seed passed to
  [`set.seed()`](https://rdrr.io/r/base/Random.html) when `retain != 0`.

- metadata:

  A `data.frame` containing `INSDSeq_primary-accession` and `field`.

## Value

A filtered `DNAbin` alignment object.

## See also

Other management:
[`clean_label()`](https://zzzhehao.github.io/zbarc/reference/clean_label.md),
[`generate_sequence_map()`](https://zzzhehao.github.io/zbarc/reference/generate_sequence_map.md)
