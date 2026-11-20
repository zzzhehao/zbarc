# Read All ABGD Partition Results in a Directory

Loads all initial and recursive ABGD partition files in `output_folder`
along with metadata such as partition type, index, and group count.

## Usage

``` r
abgd_read_result_all(output_folder)
```

## Arguments

- output_folder:

  Character. Path to the ABGD output directory.

## Value

A list of lists containing `path`, `partition_type`, `index`,
`group_count`, and `result` for each partition file.

## See also

[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md),
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md)

Other abgd:
[`abgd_delim()`](https://zzzhehao.github.io/zbarc/reference/abgd_delim.md),
[`abgd_disthist()`](https://zzzhehao.github.io/zbarc/reference/abgd_disthist.md),
[`abgd_execute()`](https://zzzhehao.github.io/zbarc/reference/abgd_execute.md),
[`abgd_read_result()`](https://zzzhehao.github.io/zbarc/reference/abgd_read_result.md),
[`abgd_summary()`](https://zzzhehao.github.io/zbarc/reference/abgd_summary.md)
