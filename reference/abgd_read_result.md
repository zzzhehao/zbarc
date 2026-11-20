# Read a Single ABGD Partition Result File

Parses an ABGD partition output file (`part*.txt`) into a long-format
`data.frame` of `taxa` and `group` assignments.

## Usage

``` r
abgd_read_result(path)
```

## Arguments

- path:

  Character. Path to an ABGD partition text file.

## Value

A `data.frame` (tibble) with columns `taxa` (character) and `group`
(factor).

## See also

[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md),
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)

Other abgd:
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md),
[`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md),
[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result_all()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result_all.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
