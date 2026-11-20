# Prepare and Format Tree for Plotting

Rescales tree branch lengths to `"length_mean"` and optionally formats
tip labels using
[`zhutilsr::format_organism_name()`](https://zzzhehao.github.io/zhutilsr/reference/format_organism_name.html)
with spaces converted to tildes (`~`) for plotmath.

## Usage

``` r
.tree_prep_labels(tree, format.taxa = TRUE)
```

## Arguments

- tree:

  A `tidytree` `treedata` object.

- format.taxa:

  Logical. Whether to format taxa names for plotmath. Default is `TRUE`.

## Value

A rescaled (and optionally formatted) `treedata` object.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
