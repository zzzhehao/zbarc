# Read Downloaded BOLD Text into R

Read Downloaded BOLD Text into R

## Usage

``` r
bold_read_data(raw_text, format)
```

## Arguments

- raw_text:

  Character. Raw text returned by
  [`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md).

- format:

  Character. Format of `raw_text`: `"tsv"`, `"dwc"`, or `"json"`
  (NDJSON).

## Value

A `data.frame` of parsed BOLD records.

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
[`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md),
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
[`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
