# Check Stop Codons and Reading Frames in a Protein-Coding Alignment

Check Stop Codons and Reading Frames in a Protein-Coding Alignment

## Usage

``` r
codon_summary(aln, code, verbose = T)
```

## Arguments

- aln:

  A named `DNAbin` alignment object.

- code:

  Integer or character. Genetic code passed to `code` in
  [`ape::trans()`](https://rdrr.io/pkg/ape/man/trans.html).

- verbose:

  Logical. Whether to print status messages via `cli`. Default is
  `TRUE`.

## Value

Invisibly returns a named list with elements `raw`, `tbl`, and `result`.

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
