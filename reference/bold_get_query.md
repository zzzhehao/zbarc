# Construct and Validate a BOLD API Query

Takes vector or list inputs for available BOLD API scopes, formats them,
and validates them against the BOLD API preprocessor to return a formal
query string of triplets.

## Usage

``` r
bold_get_query(
  tax = NULL,
  bin = NULL,
  geo = NULL,
  inst = NULL,
  recordsetcode = NULL,
  ids = NULL,
  max_chars = 240
)
```

## Arguments

- tax:

  Taxonomic ranks (e.g., kingdom, phylum, class, order, family,
  subfamily, tribe, genus, species, subspecies). Accepts a character
  vector or list.

- bin:

  Barcode Index Number (BIN) URIs. Accepts a character vector or list.

- geo:

  Geopolitical divisions (e.g., country/ocean, province/state, region).
  Accepts a character vector or list.

- inst:

  Institution names or sequence sites. Accepts a character vector or
  list.

- recordsetcode:

  Dataset codes. Accepts a character vector or list.

- ids:

  Specimen or sequence IDs (`processid`, `sampleid`, `insdcacs`).
  Accepts a character vector or list.

- max_chars:

  Integer. Maximum character length per preprocessor request chunk.
  Default is `240`.

## Value

Invisibly returns a character string of semicolon-separated validated
query triplets.

## Details

The function accepts multiple search criteria to dictate the aggregate
data and barcodes returned. Criteria can be combined to allow for
different results:

- **Same Scope:** Criteria sharing the same scope combine results into a
  single result (implicit logical OR).

- **Different Scopes:** Criteria of different scopes apply an overlap
  constraint (implicit logical AND).

For example, searching for `tax` "Aves" and `geo` "Argentina" returns
barcodes that overlap on both the taxonomic and geographic criteria.

## See also

Other bold:
[`.chunk_query_terms()`](https://zzzhehao.github.io/zbarc/reference/dot-chunk_query_terms.md),
[`bold_download()`](https://zzzhehao.github.io/zbarc/reference/bold_download.md),
[`bold_get_token()`](https://zzzhehao.github.io/zbarc/reference/bold_get_token.md),
[`bold_read_data()`](https://zzzhehao.github.io/zbarc/reference/bold_read_data.md),
[`bold_retrieve()`](https://zzzhehao.github.io/zbarc/reference/bold_retrieve.md),
[`bold_validate_query()`](https://zzzhehao.github.io/zbarc/reference/bold_validate_query.md),
[`bold_write_data()`](https://zzzhehao.github.io/zbarc/reference/bold_write_data.md)
