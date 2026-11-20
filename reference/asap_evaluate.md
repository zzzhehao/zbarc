# Evaluate ASAP Output

Evaluate ASAP Output

## Usage

``` r
asap_evaluate(dir, part = 3, smart_filter = TRUE)
```

## Arguments

- dir:

  Character. Path to an ASAP result directory.

- part:

  Integer. Number of top partitions to evaluate. Default is `3`.

- smart_filter:

  Logical. If `TRUE`, filters partitions by group count (`NbSubset`)
  keeping the lowest `p.val` per group size before ranking by
  `Asap.score`. If `FALSE`, takes the top distinct `Asap.score` values
  directly. Default is `TRUE`.

## Value

A list of [asap](https://zzzhehao.github.io/zbarc/reference/asap.md) S7
objects of length `part`.

## See also

Other asap:
[`asap()`](https://zzzhehao.github.io/zbarc/reference/asap.md),
[`asap_execute()`](https://zzzhehao.github.io/zbarc/reference/asap_execute.md)
