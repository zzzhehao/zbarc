# Get Query Token from BOLD API

Get Query Token from BOLD API

## Usage

``` r
bold_get_token(validated_query, extent = "full")
```

## Arguments

- validated_query:

  Character. Validated query string from Step 1.

- extent:

  Character. Extent of documents to retrieve. Default is `"full"`.

## Value

A character string giving the BOLD `query_id` token.

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
[`bold_get_query()`](https://zzzhehao.github.io/zbarc/reference/bold_get_query.md),
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
[`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
