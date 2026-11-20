# Summarize ABGD Partitions and Plot Group Counts

Summarize ABGD Partitions and Plot Group Counts

## Usage

``` r
abgd_summary(output_folder, silent = F, text.partition.size = 3.4)
```

## Arguments

- output_folder:

  Character. Path to the ABGD output folder.

- silent:

  Logical. If `FALSE`, prints the summary plot. Default is `FALSE`.

- text.partition.size:

  Numeric. Text size for prior divergence labels above points. Default
  is `3.4`.

## Value

A named list of length 2:

- `plot`:

  A `ggplot` object showing initial and recursive group counts across
  partitions.

- `summary`:

  A `data.frame` summarizing `index`, `initial`, `recursive`,
  `fine_group`, `fine_group_prop`, and `prior` intraspecific divergence.

## See also

[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)

Other abgd:
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md),
[`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md),
[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md)
