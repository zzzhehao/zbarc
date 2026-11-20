# Run Automatic Barcoding Gap Discovery (ABGD)

Run Automatic Barcoding Gap Discovery (ABGD)

## Usage

``` r
abgd_execute(
  alignment,
  exe,
  output_folder = NULL,
  a = T,
  p = 0.001,
  P = 0.1,
  n = 20,
  d = 3,
  X = 1.5,
  args = NULL,
  overwrite = F
)
```

## Arguments

- alignment:

  Character. Path to the input FASTA alignment file.

- exe:

  Character. Path to the ABGD executable.

- output_folder:

  Character or `NULL`. Output directory path. Defaults to
  `file.path(dirname(alignment), "ABGD")`.

- a:

  Logical. Whether to pass `-a` to ABGD. Default is `TRUE`.

- p:

  Numeric. Minimum a priori intraspecific divergence (`Pmin`). Default
  is `0.001`.

- P:

  Numeric. Maximum a priori intraspecific divergence (`Pmax`). Default
  is `0.1`.

- n:

  Integer. Number of steps in `[Pmin, Pmax]`. Default is `20`.

- d:

  Integer. Genetic distance option: `0` = Kimura-2P, `1` = Jukes-Cantor,
  `2` = Tamura-Nei, `3` = simple p-distance. Default is `3`.

- X:

  Numeric. Minimum relative gap width / slope increase (`X`). Default is
  `1.5`.

- args:

  Character or `NULL`. Additional CLI arguments passed to ABGD. Default
  is `NULL`.

- overwrite:

  Logical. Whether to overwrite `output_folder` if it already contains
  files. Default is `FALSE`.

## Value

Character path to `output_folder`.

## See also

[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md),
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)

Other abgd:
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md),
[`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
