# Run ASAP Species Delimitation

Run ASAP Species Delimitation

## Usage

``` r
asap_execute(input, output_dir, exe, dist = 3, overwrite = FALSE, ...)
```

## Arguments

- input:

  Character. Path to an aligned FASTA file used as input.

- output_dir:

  Character. Path to the output directory.

- exe:

  Character. Path to the ASAP executable file.

- dist:

  Numeric or integer. Method for calculating genetic distance: `0` =
  Kimura-2P, `1` = Jukes-Cantor, `2` = Tamura-Nei, `3` = simple
  p-distance. Default is `3`.

- overwrite:

  Logical. Whether to overwrite existing files in `output_dir`. Default
  is `FALSE`.

- ...:

  Additional arguments passed to the ASAP CLI executable.

## Value

Character path to `output_dir`.

## See also

Other asap:
[`asap()`](https://zzzhehao.github.io/zbarc/reference/asap.md),
[`asap_evaluate()`](https://zzzhehao.github.io/zbarc/reference/asap_evaluate.md)
