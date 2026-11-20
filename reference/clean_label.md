# Clean Sequence Labels in a FASTA Alignment

Formats sequence labels in a FASTA file by appending the detected gene
name (`COI`, `18S`, `28S`, or `16S`) from `basename(fasta_path)` to
voucher IDs matching `^VPS[0-9]{3}` or `^ZHH[0-9]{3}`, and strips
trailing `.1` or `.1_(reversed)` suffixes from sequence names.

## Usage

``` r
clean_label(fasta_path, noprefix = F)
```

## Arguments

- fasta_path:

  Character. Path to the input FASTA file.

- noprefix:

  Logical. If `TRUE`, strips leading `ZHH` or `VPS` prefixes from
  sequence labels. Default is `FALSE`.

## Value

Character path to the newly written `*_cleaned.fasta` file in the same
directory.

## See also

Other management:
[`exclude_by_meta()`](https://zzzhehao.github.io/zbarc/reference/exclude_by_meta.md),
[`generate_sequence_map()`](https://zzzhehao.github.io/zbarc/reference/generate_sequence_map.md)
