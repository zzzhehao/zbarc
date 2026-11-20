# Split a Concatenated Alignment Back into Single-Locus FASTA Files

Slices a concatenated `DNAbin` alignment matrix by locus lengths, drops
taxa that are completely missing/ambiguous in a given locus, and writes
`reextracted_<locus>.fasta` files.

## Usage

``` r
split_concat_alignment(alignment, loci_name, loci_length, output_folder)
```

## Arguments

- alignment:

  A `DNAbin` alignment matrix.

- loci_name:

  Character vector. Names of each locus.

- loci_length:

  Numeric or integer vector. Column length of each locus in `alignment`.

- output_folder:

  Character. Directory where re-extracted FASTA files are written.

## Value

Character vector of output FASTA file paths.

## See also

[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md)

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
