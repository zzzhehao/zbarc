# Align Sequences Using MAFFT

Align Sequences Using MAFFT

## Usage

``` r
mafft(input, output, browse = TRUE, args = NULL)
```

## Arguments

- input:

  Character. Path to input FASTA file.

- output:

  Character. Path to output aligned FASTA file.

- browse:

  Logical. If `TRUE`, opens the resulting alignment in a browser via
  [`DECIPHER::BrowseSeqs()`](https://rdrr.io/pkg/DECIPHER/man/BrowseSeqs.html).
  Default is `TRUE`.

- args:

  Character vector or `NULL`. Additional CLI arguments passed to
  `mafft`. Default is `NULL`.

## Value

Invisibly returns the integer exit status code from
`system2("mafft", ...)`.

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
