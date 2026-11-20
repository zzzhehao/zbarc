# Run a local BLAST search against a custom database

Run a local BLAST search against a custom database

## Usage

``` r
blast(query, db_path, evalue = 1e-05, max_target_seqs = 10)
```

## Arguments

- query:

  Character. Path to a query FASTA file, or a raw DNA sequence string.

- db_path:

  Character. Path to the BLAST database (the base name returned by
  [`bcdm2blastdb()`](https://zzzhehao.github.io/zbarc/reference/bcdm2blastdb.md)).

- evalue:

  Numeric. Expectation value (`E`) threshold for saving hits. Default is
  `1e-5`.

- max_target_seqs:

  Integer. Maximum number of aligned sequences to keep per query.
  Default is `10`.

## Value

A `data.frame` of BLAST tabular hits (format 6), or `NULL` if no hits
are found.

## See also

Other blast:
[`bcdm2blastdb()`](https://zzzhehao.github.io/zbarc/reference/bcdm2blastdb.md)
