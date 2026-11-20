# Write BOLD Data to Disk Using `zhutilsr`

Write BOLD Data to Disk Using `zhutilsr`

## Usage

``` r
bold_write_data(obj, dir = NULL, file = NULL, format = "tsv")
```

## Arguments

- obj:

  Object (typically a `data.frame`) to write to disk.

- dir:

  Character or `NULL`. Target directory path.

- file:

  Character or `NULL`. Target file name or file path.

- format:

  Character. Output format (`"tsv"`, `"dwc"`, or `"json"`). Default is
  `"tsv"`.

## Value

Result of
[`zhutilsr::safe_write()`](https://zzzhehao.github.io/zhutilsr/reference/safe_write.html).

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
[`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md),
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
[`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md)
