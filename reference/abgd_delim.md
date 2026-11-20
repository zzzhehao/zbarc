# Extract Species Delimitation Table from ABGD Recursive Partitions

Extract Species Delimitation Table from ABGD Recursive Partitions

## Usage

``` r
abgd_delim(output_folder, indices, label = NULL)
```

## Arguments

- output_folder:

  Character. Path to the ABGD output folder.

- indices:

  Numeric or integer vector. Partition indices to extract from recursive
  partitions.

- label:

  Character vector or `NULL`. Suffix(es) appended to `"abgd_"` to name
  output columns; must match `length(indices)` when
  `length(indices) > 1`. If `NULL` and `length(indices) == 1`, the
  column is named `"abgd"`.

## Value

A `data.frame` (tibble) with column `taxa` and one delimitation column
per selected partition.

## See also

[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)

Other abgd:
[`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md),
[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
