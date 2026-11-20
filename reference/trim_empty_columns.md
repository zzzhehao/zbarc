# Remove Empty Columns from an Alignment

Scans a `DNAbin` alignment and removes any columns (positions) where all
sequences consist entirely of specified target characters, such as gaps
(`-`), ambiguous bases (`N`), or missing data (`?`).

## Usage

``` r
trim_empty_columns(x, chars = c("-", "n", "?"))
```

## Arguments

- x:

  A `DNAbin` object (matrix, list, or vector). If provided as a list,
  all sequences must have the same length.

- chars:

  Character vector specifying which bases should be treated as "empty".
  Defaults to `c("-", "n", "?")` (case-insensitive).

## Value

A `DNAbin` object of the same structure as `x` with empty columns
removed.

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md)
