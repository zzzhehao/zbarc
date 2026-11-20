# Calculate Dynamic Layout Offsets for Tree + Heatmap

Computes the maximum tree width and determines the horizontal push
(`nudge_x`) needed to place tip labels outside a heatmap layer.

## Usage

``` r
.tree_calc_offsets(tree, offset = 0.01, width = 0.1, label_margin = 0.02)
```

## Arguments

- tree:

  A `tidytree` `treedata` object.

- offset:

  Numeric. Gap between tree tips and the heatmap. Default is `0.01`.

- width:

  Numeric. Heatmap width as a proportion of `tree_width`. Default is
  `0.1`.

- label_margin:

  Numeric. Space between the heatmap and tip labels. Default is `0.02`.

## Value

A named list with elements `tree_width` and `label_push`.

## See also

Other tree:
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
