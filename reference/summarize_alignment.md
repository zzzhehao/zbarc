# Summarize Alignment Dimensions and Taxa from a FASTA or NEXUS File

Summarize Alignment Dimensions and Taxa from a FASTA or NEXUS File

## Usage

``` r
summarize_alignment(path)
```

## Arguments

- path:

  Character. Path to a `.fasta` or `.nexus` alignment file.

## Value

A named list with elements `ntaxa` (integer), `width` (integer), and
`taxa` (character vector).

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
