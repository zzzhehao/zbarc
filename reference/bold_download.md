# Download Records from BOLD API

Download Records from BOLD API

## Usage

``` r
bold_download(query_id, format = "tsv")
```

## Arguments

- query_id:

  Character. Query token returned by
  [`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md).

- format:

  Character. Data format (`"tsv"`, `"dwc"`, or `"json"`). Default is
  `"tsv"`.

## Value

A UTF-8 character string containing the raw downloaded records.

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md),
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
[`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
