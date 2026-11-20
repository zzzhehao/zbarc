# Relabel Tree Tip Labels Using a Lookup Mapper

Relabel Tree Tip Labels Using a Lookup Mapper

## Usage

``` r
tree_relabel(tree, identifier = "sequence", mapper)
```

## Arguments

- tree:

  A `tidytree` `treedata` object.

- identifier:

  Character. Mode for matching tip labels: `"sequence"` (default) maps
  tip labels directly via `identifier` to `c_organism_label`;
  `"organism"` matches voucher prefixes (`^ZHH|^VPS`) via
  `c_organism_id` to `c_organism_label`.

- mapper:

  A `data.frame` lookup table containing mapping columns (`identifier`,
  `c_organism_id`, and `c_organism_label`).

## Value

A `tidytree` `treedata` object with updated `@phylo$tip.label`.

## Details

Duplicate labels in the resulting tip labels can cause C++-level errors
when passed to
[`ggtree::ggtree()`](https://rdrr.io/pkg/ggtree/man/ggtree.html).
Deduplicate `mapper` (e.g., with
[`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html))
beforehand if needed.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
