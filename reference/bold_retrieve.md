# Retrieve Data from the BOLD API

High-level wrapper that chunks long query strings, validates terms via
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
requests a token via
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
downloads records via
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
parses them via
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
and optionally writes them to disk via
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md).

## Usage

``` r
bold_retrieve(
  query,
  format = "tsv",
  extent = "full",
  output_dir = NULL,
  output_file = NULL,
  max_chars = 240
)
```

## Arguments

- query:

  Character. Search terms in `scope:term` format (e.g.,
  `"tax:Aves;geo:Argentina"`).

- format:

  Character. Desired data format (`"tsv"`, `"dwc"`, or `"json"`).
  Default is `"tsv"`.

- extent:

  Character. Extent parameter passed to
  [`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md).
  Default is `"full"`.

- output_dir:

  Character or `NULL`. Target directory to write files. If `NULL`, data
  is only returned to the R environment.

- output_file:

  Character or `NULL`. Target file name or path when saving to disk.

- max_chars:

  Integer. Maximum character length per query chunk. Default is `240`.

## Value

A combined `data.frame` of retrieved BOLD records, or `NULL` if no
records were retrieved.

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
[`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md),
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
