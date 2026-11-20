# Merge Multiple FASTA Files and Deduplicate Sequence Names

Merge Multiple FASTA Files and Deduplicate Sequence Names

## Usage

``` r
merge_fasta(..., output_file, overwrite = FALSE)
```

## Arguments

- ...:

  Character paths to input FASTA files.

- output_file:

  Character. Path to the merged output FASTA file.

- overwrite:

  Logical. Whether to overwrite `output_file` if it already exists.
  Default is `FALSE`.

## Value

Invisibly returns the result of
[`ape::write.FASTA()`](https://rdrr.io/pkg/ape/man/write.dna.html).

## See also

Other i/o:
[`convert_nexus2fasta()`](https://zzzhehao.github.io/zbarc/reference/convert_nexus2fasta.md)
