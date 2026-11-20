# Perform GMYC Species Delimitation on a BEAST2 Tree

Perform GMYC Species Delimitation on a BEAST2 Tree

## Usage

``` r
gmyc_eval(contree, prefix = NULL, method = "both")
```

## Arguments

- contree:

  Character. File path to a binary, ultrametric NEXUS tree (e.g.,
  maximum clade credibility tree from BEAST2).

- prefix:

  Character or `NULL`. Optional prefix prepended to output column names.

- method:

  Character. GMYC threshold method: `"single"`, `"multiple"`, or
  `"both"`. Default is `"both"`.

## Value

A `data.frame` containing `identifier` and delimited species columns for
the requested method(s).

## See also

[`beast2_write_mrca()`](https://zzzhehao.github.io/zbarc/reference/beast2_write_mrca.md)
