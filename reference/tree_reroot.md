# Reroot Consensus Tree Produced by MrBayes

Reroot Consensus Tree Produced by MrBayes

## Usage

``` r
tree_reroot(tree, outgroup, outgroups = NULL, match.method = NULL)
```

## Arguments

- tree:

  A `tidytree` `treedata` object.

- outgroup:

  Character. Outgroup query string matched against tip labels when
  `outgroups` is `NULL`.

- outgroups:

  Character vector or `NULL`. Explicit vector of tip labels defining the
  outgroup.

- match.method:

  Character or `NULL`. Matching strategy when `outgroups` is `NULL`:
  `"best"` uses
  [`zhutilsr::find_best_match()`](https://zzzhehao.github.io/zhutilsr/reference/find_best_match.html),
  while `"include"` matches substrings via regex.

## Value

A rerooted `tidytree` `treedata` object.

## Details

Proper rerooting is currently only guaranteed for consensus trees
produced by MrBayes due to inconsistent conventions for branch support
values across phylogenetic tools (see Czech et al., 2017).

## References

Czech, L., Huerta-Cepas, J. and Stamatakis, A. (2017) “A Critical Review
on the Use of Support Values in Tree Viewers and Bioinformatics
Toolkits,” Molecular Biology and Evolution, 34(6), pp. 1535–1542.
Available at: https://doi.org/10.1093/molbev/msx055.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
