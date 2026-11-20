# Visually Compare Original and Polished Alignments with MAFFT

Visually Compare Original and Polished Alignments with MAFFT

## Usage

``` r
check_polish(aln.old, aln.clean)
```

## Arguments

- aln.old:

  A `DNAbin` alignment object before polishing.

- aln.clean:

  A `DNAbin` alignment object after polishing.

## Value

Invisibly returns the combined re-aligned sequences as a `DNAbin`
object.

## See also

Other alignment:
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
