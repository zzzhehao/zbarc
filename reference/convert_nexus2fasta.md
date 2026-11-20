# Convert a NEXUS Alignment to FASTA Format

Convert a NEXUS Alignment to FASTA Format

## Usage

``` r
convert_nexus2fasta(
  nexus_path,
  fasta_path = NULL,
  safe_name = F,
  remove_outgroup = NULL
)
```

## Arguments

- nexus_path:

  Character. Path to the input NEXUS alignment file.

- fasta_path:

  Character or `NULL`. Path for the output FASTA file. If `NULL`,
  replaces `\\.nexus$` in `nexus_path` with `.fasta`.

- safe_name:

  Logical. Whether to remove underscores (`_`) from sequence labels.
  Default is `FALSE`.

- remove_outgroup:

  Character vector or `NULL`. Sequence labels to drop before renaming.
  Default is `NULL`.

## Value

Character path to the written FASTA file.

## See also

Other i/o:
[`merge_fasta()`](https://zzzhehao.github.io/zbarc/reference/merge_fasta.md)
