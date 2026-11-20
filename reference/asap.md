# ASAP Result S7 Class

An S7 class storing parsed ASAP partition statistics, specimen-to-OTU
assignments, and pairwise genetic distance matrices.

## Usage

``` r
asap(
  partitions = (function (.data = list(), row.names = NULL) 
 {
     if
    (is.null(row.names)) {
         list2DF(.data)
     }
     else {
         out <-
    list2DF(.data, length(row.names))
attr(out, "row.names") <- row.names
      
      out
     }
 })(),
  best_rank = integer(0),
  best_score = integer(0),
  best_p = integer(0),
  notu = integer(0),
  otu = (function (.data = list(), row.names = NULL) 
 {
     if (is.null(row.names)) {
 
           list2DF(.data)
     }
     else {
         out <- list2DF(.data,
    length(row.names))
attr(out, "row.names") <- row.names
         out
     }

    })(),
  dist.mat = NULL
)
```

## Arguments

- partitions:

  A `data.frame` of all evaluated ASAP partitions.

- best_rank:

  An `integer` partition rank.

- best_score:

  A `numeric` ASAP score for the partition.

- best_p:

  A `numeric` p-value (`Proba`) for the partition.

- notu:

  An `integer` number of delimited subsets/OTUs.

- otu:

  A `data.frame` mapping specimen `identifier` to `otu`.

- dist.mat:

  A pairwise distance matrix object.

## See also

Other asap:
[`asap_evaluate()`](https://zzzhehao.github.io/zbarc/reference/asap_evaluate.md),
[`asap_execute()`](https://zzzhehao.github.io/zbarc/reference/asap_execute.md)
